import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../routes/app_pages.dart';
import 'image_viewer.dart';

class PostCardWidget extends StatefulWidget {
  const PostCardWidget({
    required this.avatarUrl,
    required this.name,
    required this.subtitle,
    required this.content,
    required this.hasImage,
    this.imageAssets,
    this.showFollowButton = true,
    this.initialLikes = 120,
    required this.onShowComments,
    required this.onShowShare,
    super.key,
  });

  final String avatarUrl;
  final String name;
  final String subtitle;
  final String content;
  final bool hasImage;
  final List<String>? imageAssets;
  final bool showFollowButton;
  final int initialLikes;
  final VoidCallback onShowComments;
  final VoidCallback onShowShare;

  @override
  State<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<PostCardWidget> {
  bool _isLiked = false;
  bool _isBookmarked = false;
  bool _isFollowing = false;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.initialLikes;
  }

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
    });
    AppToast.info(
      _isFollowing
          ? 'Kamu sekarang mengikuti ${widget.name}.'
          : 'Kamu berhenti mengikuti ${widget.name}.',
      title: _isFollowing ? 'Mengikuti' : 'Batal Mengikuti',
    );
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
                      onTap: () => Get.toNamed(Routes.OTHER_PROFILE),
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
                        onTap: () => Get.toNamed(Routes.OTHER_PROFILE),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'Dede Fernanda',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppFonts.satoshiStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: c.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '• 5 Menit',
                                  style: AppFonts.satoshiStyle(
                                    fontSize: 11,
                                    color: c.grey500,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 1),
                            Text(
                              'Teknik Informatika',
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
                          backgroundColor: _isFollowing
                              ? c.grey100
                              : AppColors.primary,
                          foregroundColor: _isFollowing
                              ? c.textSecondary
                              : AppColors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                        ),
                        child: Text(
                          _isFollowing ? 'Mengikuti' : 'Ikuti',
                          style: AppFonts.satoshiStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _isFollowing
                                ? c.textSecondary
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
              if (widget.imageAssets != null &&
                  widget.imageAssets!.isNotEmpty) ...[
                const SizedBox(height: 12),
                if (widget.imageAssets!.length == 1)
                  GestureDetector(
                    onTap: () => showImageViewer(
                      context,
                      assetPath: widget.imageAssets!.first,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Image.asset(
                        widget.imageAssets!.first,
                        width: double.infinity,
                        height: 373,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else if (widget.imageAssets!.length == 2)
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => showImageViewer(
                            context,
                            assetPath: widget.imageAssets![0],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            child: Image.asset(
                              widget.imageAssets![0],
                              height: 236,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => showImageViewer(
                            context,
                            assetPath: widget.imageAssets![1],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            child: Image.asset(
                              widget.imageAssets![1],
                              height: 236,
                              fit: BoxFit.cover,
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
                  '20',
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
