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
    this.tags,
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
  final List<String>? tags;
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
    if (oldWidget.isLiked != widget.isLiked) _isLiked = widget.isLiked;
    if (oldWidget.initialLikes != widget.initialLikes) _likeCount = widget.initialLikes;
    if (oldWidget.initialComments != widget.initialComments) _commentCount = widget.initialComments;
    if (oldWidget.connectionStatus != widget.connectionStatus) _connectionStatus = widget.connectionStatus;
  }

  bool get _isConnected => _connectionStatus == 'accepted';
  bool get _isPending => _connectionStatus == 'pending';

  Future<void> _toggleFollow() async {
    if (_followingLoading) return;
    setState(() => _followingLoading = true);
    try {
      final api = Get.find<ApiClient>();
      if (_isConnected) {
        await api.put('/connections/remove/${widget.authorId}');
        setState(() => _connectionStatus = null);
        AppToast.info('Koneksi dengan ${widget.name} telah dihapus.', title: 'Koneksi Dihapus');
      } else if (_isPending) {
        await api.put('/connections/cancel/${widget.authorId}');
        setState(() => _connectionStatus = null);
        AppToast.info('Permintaan ke ${widget.name} dibatalkan.', title: 'Permintaan Dibatalkan');
      } else {
        await api.post('/connections/send/${widget.authorId}');
        setState(() => _connectionStatus = 'pending');
        AppToast.info('Permintaan koneksi terkirim ke ${widget.name}.', title: 'Permintaan Terkirim');
      }
    } catch (e) {
      AppToast.error('Gagal memproses. Coba lagi.');
    } finally {
      setState(() => _followingLoading = false);
    }
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
    widget.onToggleLike?.call();
  }

  String get _followLabel {
    if (_followingLoading) return '...';
    if (_isConnected) return 'Terhubung';
    if (_isPending) return 'Tertunda';
    return 'Hubungkan';
  }

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(
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
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: c.textPrimary,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                widget.subtitle,
                                style: AppFonts.satoshiStyle(
                                  fontSize: 11,
                                  color: c.textTertiary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                FluentIcons.globe_24_regular,
                                size: 11,
                                color: c.textTertiary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (widget.showFollowButton)
                  SizedBox(
                    height: 24,
                    child: OutlinedButton(
                      onPressed: _toggleFollow,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: c.surface,
                        foregroundColor: _isConnected || _isPending
                            ? c.textSecondary
                            : AppColors.primary,
                        side: BorderSide(
                          color: _isConnected || _isPending
                              ? c.grey300
                              : AppColors.primary,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _followingLoading
                          ? SizedBox(
                              width: 14, height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: c.textSecondary,
                              ),
                            )
                          : Text(
                              _followLabel,
                              style: AppFonts.satoshiStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _isConnected || _isPending
                                    ? c.textSecondary
                                    : AppColors.primary,
                              ),
                            ),
                    ),
                  ),
              ],
            ),

            // ── Content ──
            if (widget.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  widget.content,
                  style: AppFonts.satoshiStyle(
                    fontSize: 14,
                    color: c.textPrimary,
                    height: 1.45,
                  ),
                ),
              ),

            // ── Tags ──
            if (widget.tags != null && widget.tags!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: widget.tags!.map((t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: c.primarySoft,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      '#$t',
                      style: AppFonts.satoshiStyle(
                        fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary500,
                      ),
                    ),
                  )).toList(),
                ),
              ),

            // ── Media ──
            if (widget.mediaUrls != null && widget.mediaUrls!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  height: widget.mediaUrls!.length == 1 ? 373 : 236,
                  child: widget.mediaUrls!.length == 1
                      ? GestureDetector(
                          onTap: () => showMediaViewer(context, widget.mediaUrls!, initialPage: 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              widget.mediaUrls!.first,
                              width: double.infinity,
                              height: 373,
                              fit: BoxFit.cover,
                              loadingBuilder: (_, child, progress) =>
                                  progress == null ? child : Container(color: c.surfaceSecondary),
                              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => showMediaViewer(context, widget.mediaUrls!, initialPage: 0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    widget.mediaUrls![0],
                                    height: 236,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (_, child, progress) =>
                                        progress == null ? child : Container(color: c.surfaceSecondary),
                                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => showMediaViewer(context, widget.mediaUrls!, initialPage: 1),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    widget.mediaUrls![1],
                                    height: 236,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (_, child, progress) =>
                                        progress == null ? child : Container(color: c.surfaceSecondary),
                                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),

            // ── Action Buttons ──
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _ActionButton(
                        icon: FluentIcons.heart_24_regular,
                        activeIcon: FluentIcons.heart_24_filled,
                        count: '$_likeCount',
                        isActive: _isLiked,
                        activeColor: AppColors.error500,
                        onTap: _toggleLike,
                      ),
                      const SizedBox(width: 16),
                      _ActionButton(
                        icon: FluentIcons.chat_24_regular,
                        activeIcon: FluentIcons.chat_24_regular,
                        count: '$_commentCount',
                        isActive: false,
                        activeColor: c.textSecondary,
                        onTap: widget.onShowComments,
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: widget.onShowShare,
                    child: Icon(
                      FluentIcons.share_24_regular,
                      size: 24,
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.activeIcon,
    required this.count,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String count;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            isActive ? activeIcon : icon,
            size: 24,
            color: isActive ? activeColor : c.textSecondary,
          ),
          if (count.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              count,
              style: AppFonts.satoshiStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isActive ? activeColor : c.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
