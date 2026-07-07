import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/api_client.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_toast.dart';
import '../../home/views/widgets/share_sheet.dart';
import '../controllers/comment_controller.dart';
import 'comment_view.dart';

class PostDetailView extends StatefulWidget {
  const PostDetailView({required this.showcaseId, super.key});

  final String showcaseId;

  @override
  State<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
  final _api = Get.find<ApiClient>();
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  bool _isLiked = false;
  int _likesCount = 0;
  int _commentsCount = 0;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final res = await _api.get('/showcase/${widget.showcaseId}');
      final body = (res.data as Map<String, dynamic>? ?? {})['data'] as Map<String, dynamic>? ?? {};
      _data = body;
      _isLiked = body['liked_by_me'] as bool? ?? false;
      _likesCount = body['likes_count'] as int? ?? 0;
      final rawComments = body['comments'] as List<dynamic>? ?? [];
      int total = rawComments.length;
      for (final c in rawComments) {
        final replies = c['replies'] as List<dynamic>? ?? [];
        total += replies.length;
      }
      _commentsCount = total;
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _toggleLike() async {
    try {
      if (_isLiked) {
        await _api.delete('/showcase/${widget.showcaseId}/like');
      } else {
        await _api.post('/showcase/${widget.showcaseId}/like');
      }
      setState(() {
        _isLiked = !_isLiked;
        _likesCount += _isLiked ? 1 : -1;
      });
    } catch (_) {
      AppToast.error('Gagal menyukai postingan');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.surface.withValues(alpha: 0.96),
        elevation: 0,
        surfaceTintColor: AppColors.transparent,
        leading: IconButton(
          icon: Icon(FluentIcons.chevron_left_24_regular, color: c.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Postingan',
          style: AppFonts.satoshiStyle(
            fontSize: 16, fontWeight: FontWeight.w600, color: c.textPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? Center(child: Text('Postingan tidak ditemukan', style: AppFonts.satoshiStyle(fontSize: 14, color: c.textSecondary)))
              : SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  AppAvatar(
                                    photoUrl: _data!['author_photo'] as String?,
                                    radius: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _data!['author_name'] as String? ?? '',
                                      style: AppFonts.satoshiStyle(
                                        fontSize: 15, fontWeight: FontWeight.w700, color: c.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if ((_data!['content'] as String? ?? '').isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Text(
                                  _data!['content'] as String? ?? '',
                                  style: AppFonts.satoshiStyle(
                                    fontSize: 14, color: c.textPrimary, height: 1.5,
                                  ),
                                ),
                              ],
                              if ((_data!['tags'] as List?)?.isNotEmpty == true) ...[
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: (_data!['tags'] as List).map((t) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: c.primarySoft,
                                      borderRadius: BorderRadius.circular(AppRadius.pill),
                                    ),
                                    child: Text(
                                      '#$t',
                                      style: AppFonts.satoshiStyle(
                                        fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary500,
                                      ),
                                    ),
                                  )).toList(),
                                ),
                              ],
                              if ((_data!['media_urls'] as List?)?.isNotEmpty == true) ...[
                                const SizedBox(height: 14),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    (_data!['media_urls'] as List).first as String,
                                    width: double.infinity,
                                    height: 300,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (_, child, progress) =>
                                        progress == null ? child : Container(height: 300, color: c.surfaceSecondary),
                                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: _toggleLike,
                                    child: Row(
                                      children: [
                                        Icon(
                                          _isLiked ? FluentIcons.heart_24_filled : FluentIcons.heart_24_regular,
                                          size: 22,
                                          color: _isLiked ? AppColors.error500 : c.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$_likesCount',
                                          style: AppFonts.satoshiStyle(
                                            fontSize: 14, fontWeight: FontWeight.w500,
                                            color: _isLiked ? AppColors.error500 : c.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  GestureDetector(
                                    onTap: () async {
                                      await showCommentsSheet(context, widget.showcaseId);
                                      _fetch();
                                    },
                                    child: Row(
                                      children: [
                                        Icon(FluentIcons.chat_24_regular, size: 22, color: c.textSecondary),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$_commentsCount',
                                          style: AppFonts.satoshiStyle(
                                            fontSize: 14, fontWeight: FontWeight.w500, color: c.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet<void>(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: AppColors.transparent,
                                        builder: (_) => ShareSheet(postId: widget.showcaseId, postType: 'post'),
                                      );
                                    },
                                    child: Icon(FluentIcons.share_24_regular, size: 22, color: c.textSecondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
