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
        AppToast.info('Koneksi dengan ${widget.name} telah dihapus.', title: 'Koneksi Dihapus');
        setState(() => _connectionStatus = null);
      } else if (_isPending) {
        AppToast.info('Permintaan pertemanan sudah dikirim ke ${widget.name}.', title: 'Tertunda');
      } else {
        await api.post('/connections/send/${widget.authorId}');
        setState(() => _connectionStatus = 'pending');
        AppToast.info('Permintaan pertemanan terkirim ke ${widget.name}.', title: 'Permintaan Terkirim');
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
      _likeCount += _isLiked ? 1 : -1;
    });
    widget.onToggleLike?.call();
  }

  void _toggleBookmark() {
    setState(() => _isBookmarked = !_isBookmarked);
    AppToast.info(
      _isBookmarked ? 'Postingan berhasil disimpan ke penanda kamu.' : 'Postingan dihapus dari penanda kamu.',
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

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
            child: Row(
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
                const SizedBox(width: 10),
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
                          const SizedBox(height: 1),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
          ),

          // ── Content ──
          if (widget.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                widget.content,
                style: AppFonts.satoshiStyle(
                  fontSize: 14,
                  color: c.textPrimary,
                  height: 1.45,
                ),
              ),
            ),

          // ── Media ──
          if (widget.mediaUrls != null && widget.mediaUrls!.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: widget.mediaUrls!.length == 1 ? 373 : 236,
              child: widget.mediaUrls!.length == 1
                  ? GestureDetector(
                      onTap: () => showMediaViewer(context, widget.mediaUrls!, initialPage: 0),
                      child: Image.network(
                        widget.mediaUrls!.first,
                        width: double.infinity,
                        height: 373,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) =>
                            progress == null ? child : Container(color: c.surfaceSecondary),
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => showMediaViewer(context, widget.mediaUrls!, initialPage: 0),
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => showMediaViewer(context, widget.mediaUrls!, initialPage: 1),
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
                      ],
                    ),
            ),
          ],

          // ── Action Buttons ──
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE4E6EB))),
            ),
            child: Row(
              children: [
                _FeedActionButton(
                  icon: FluentIcons.heart_24_regular,
                  activeIcon: FluentIcons.heart_24_filled,
                  count: '$_likeCount',
                  isActive: _isLiked,
                  activeColor: AppColors.error500,
                  onTap: _toggleLike,
                ),
                _FeedActionButton(
                  icon: FluentIcons.chat_24_regular,
                  activeIcon: FluentIcons.chat_24_regular,
                  count: '$_commentCount',
                  isActive: false,
                  activeColor: c.textSecondary,
                  onTap: widget.onShowComments,
                ),
                _FeedActionButton(
                  icon: FluentIcons.share_24_regular,
                  activeIcon: FluentIcons.share_24_regular,
                  count: '',
                  isActive: false,
                  activeColor: c.textSecondary,
                  onTap: widget.onShowShare,
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _FeedActionButton extends StatelessWidget {
  const _FeedActionButton({
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
    return Expanded(
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.xs),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  size: 18,
                  color: isActive ? activeColor : c.textSecondary,
                ),
                if (count.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(
                    count,
                    style: AppFonts.satoshiStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive ? activeColor : c.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
