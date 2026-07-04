import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_toast.dart';
import 'image_viewer.dart';

class PostCardWidget extends StatefulWidget {
  const PostCardWidget({
    required this.showcaseId,
    required this.authorId,
    required this.avatarUrl,
    required this.name,
    required this.subtitle,
    required this.content,
    this.mediaUrls,
    this.initialLikes = 0,
    this.initialComments = 0,
    this.isLiked = false,
    this.connectionStatus,
    this.showFollowButton = true,
    required this.onShowComments,
    required this.onShowShare,
    this.onToggleLike,
    this.onTapProfile,
    super.key,
  });

  final String showcaseId;
  final String authorId;
  final String avatarUrl;
  final String name;
  final String subtitle;
  final String content;
  final List<String>? mediaUrls;
  final int initialLikes;
  final int initialComments;
  final bool isLiked;
  final String? connectionStatus;
  final bool showFollowButton;
  final VoidCallback onShowComments;
  final VoidCallback onShowShare;
  final VoidCallback? onToggleLike;
  final VoidCallback? onTapProfile;

  @override
  State<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<PostCardWidget> {
  late bool _isLiked;
  bool _isBookmarked = false;
  late String? _connectionStatus;
  bool _followingLoading = false;
  late int _likeCount;
  late int _commentCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _likeCount = widget.initialLikes;
    _commentCount = widget.initialComments;
    _connectionStatus = widget.connectionStatus;
  }

  @override
  void didUpdateWidget(PostCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLiked != widget.isLiked) {
      _isLiked = widget.isLiked;
    }
    if (oldWidget.initialLikes != widget.initialLikes) {
      _likeCount = widget.initialLikes;
    }
    if (oldWidget.initialComments != widget.initialComments) {
      _commentCount = widget.initialComments;
    }
    if (oldWidget.connectionStatus != widget.connectionStatus) {
      _connectionStatus = widget.connectionStatus;
    }
  }

  bool get _isConnected => _connectionStatus == 'accepted';
  bool get _isPending => _connectionStatus == 'pending';

  Future<void> _toggleFollow() async {
    if (_followingLoading) return;
    setState(() => _followingLoading = true);
    try {
      final api = Get.find<ApiClient>();
      if (_isConnected) {
        // Unfollow — delete connection (not implemented yet, just toast)
        AppToast.info('Koneksi dengan ${widget.name} telah dihapus.',
            title: 'Koneksi Dihapus');
        setState(() => _connectionStatus = null);
      } else if (_isPending) {
        AppToast.info('Permintaan pertemanan sudah dikirim ke ${widget.name}.',
            title: 'Tertunda');
      } else {
        await api.post('/connections/send/${widget.authorId}');
        setState(() => _connectionStatus = 'pending');
        AppToast.info('Permintaan pertemanan terkirim ke ${widget.name}.',
            title: 'Permintaan Terkirim');
      }
    } catch (e) {
      AppToast.error('Gagal mengirim permintaan. Coba lagi.');
    } finally {
      setState(() => _followingLoading = false);
    }
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likeCount++;
      } else {
        _likeCount--;
      }
    });
    widget.onToggleLike?.call();
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    AppToast.info(
      _isBookmarked
          ? 'Postingan berhasil disimpan ke penanda kamu.'
          : 'Postingan dihapus dari penanda kamu.',
      title: _isBookmarked ? 'Postingan disimpan' : 'Postingan dihapus',
    );
  }

  String get _followLabel {
    if (_followingLoading) return '...';
    if (_isConnected) return 'Teman';
    if (_isPending) return 'Tertunda';
    return 'Ikuti';
  }

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: widget.onShowComments,
        child: Container(
          color: c.surface,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Material(
                    color: AppColors.transparent,
                    child: InkWell(
                      onTap: widget.onTapProfile,
                      borderRadius: BorderRadius.circular(20),
                      child: AppAvatar(
                        photoUrl: widget.avatarUrl.startsWith('http') ? widget.avatarUrl : null,
                        radius: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Material(
                      color: AppColors.transparent,
                      child: InkWell(
                        onTap: widget.onTapProfile,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.satoshiStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: c.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              widget.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.satoshiStyle(
                                fontSize: 12,
                                color: c.grey500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (widget.showFollowButton)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      height: 28,
                      child: TextButton(
                        onPressed: _toggleFollow,
                        style: TextButton.styleFrom(
                          backgroundColor: _isConnected
                              ? c.grey100
                              : _isPending
                                  ? AppColors.warning50
                                  : AppColors.primary,
                          foregroundColor: _isConnected
                              ? c.textSecondary
                              : _isPending
                                  ? AppColors.warning700
                                  : AppColors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                        ),
                        child: _followingLoading
                            ? SizedBox(
                                width: 14, height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _isConnected ? c.textSecondary : AppColors.white,
                                ),
                              )
                            : Text(
                                _followLabel,
                                style: AppFonts.satoshiStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _isConnected
                                      ? c.textSecondary
                                      : _isPending
                                          ? AppColors.warning700
                                          : AppColors.white,
                                ),
                              ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.content,
                maxLines: 8,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.satoshiStyle(
                  fontSize: 14,
                  color: c.textPrimary,
                  height: 1.38,
                ),
              ),
              if (widget.mediaUrls != null && widget.mediaUrls!.isNotEmpty) ...[
                const SizedBox(height: 12),
                if (widget.mediaUrls!.length == 1)
                  GestureDetector(
                    onTap: () => showImageViewer(context, imageUrl: widget.mediaUrls!.first),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: SizedBox(
                        width: double.infinity,
                        height: 373,
                        child: Image.network(
                          widget.mediaUrls!.first,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) =>
                              progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  )
                else if (widget.mediaUrls!.length == 2)
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => showImageViewer(context, imageUrl: widget.mediaUrls![0]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            child: SizedBox(
                              height: 236,
                              child: Image.network(
                                widget.mediaUrls![0],
                                fit: BoxFit.cover,
                                loadingBuilder: (_, child, progress) =>
                                    progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => showImageViewer(context, imageUrl: widget.mediaUrls![1]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            child: SizedBox(
                              height: 236,
                              child: Image.network(
                                widget.mediaUrls![1],
                                fit: BoxFit.cover,
                                loadingBuilder: (_, child, progress) =>
                                    progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInteractionItem(
                    _isLiked
                        ? FluentIcons.heart_24_filled
                        : FluentIcons.heart_24_regular,
                    '$_likeCount',
                    'menyukai postingan',
                    _isLiked ? AppColors.error500 : c.grey500,
                    onTap: _toggleLike,
                  ),
                  const SizedBox(width: 16),
                  _buildInteractionItem(
                    FluentIcons.chat_24_regular,
                    '$_commentCount',
                    'berkomentar',
                    c.grey500,
                    onTap: widget.onShowComments,
                  ),
                  const Spacer(),
                  _buildInteractionItem(
                    FluentIcons.send_24_regular,
                    '',
                    'membagikan postingan',
                    c.grey500,
                    onTap: widget.onShowShare,
                  ),
                  const SizedBox(width: 16),
                  _buildInteractionItem(
                    _isBookmarked
                        ? FluentIcons.bookmark_24_filled
                        : FluentIcons.bookmark_24_regular,
                    '',
                    'menyimpan postingan',
                    _isBookmarked ? AppColors.warning500 : c.grey500,
                    onTap: _toggleBookmark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractionItem(
    IconData icon,
    String count,
    String feature,
    Color activeColor, {
    required VoidCallback onTap,
  }) {
    final c = AppC.of(context);
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 2,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Icon(icon, color: activeColor, size: 22),
              if (count.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  count,
                  style: AppFonts.satoshiStyle(
                    fontSize: 12,
                    color: c.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
