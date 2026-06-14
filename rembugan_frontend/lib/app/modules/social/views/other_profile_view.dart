import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';

class OtherProfileView extends StatefulWidget {
  const OtherProfileView({super.key});

  @override
  State<OtherProfileView> createState() => _OtherProfileViewState();
}

class _OtherProfileViewState extends State<OtherProfileView> {
  int selectedTabIndex = 0;
  bool isFollowing = false;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _ProfileCover(
            avatarAsset: 'lib/assets/img/avatar.png',
            onBack: () => Get.back(),
            onMore: () {},
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 56, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ProfileIdentity(),
                const SizedBox(height: 12),
                Text(
                  '1.2K pengikut  9 Kolaborasi',
                  style: AppFonts.satoshiStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: c.grey900,
                  ),
                ),
                const SizedBox(height: 14),
                _ProfileActions(
                  isFollowing: isFollowing,
                  onFollowToggle: () {
                    setState(() {
                      isFollowing = !isFollowing;
                    });
                  },
                  onChat: () {
                    Get.toNamed('/room-chat');
                  },
                ),
                const SizedBox(height: 16),
                _ProfileTabs(
                  activeIndex: selectedTabIndex,
                  onChanged: (index) {
                    setState(() {
                      selectedTabIndex = index;
                    });
                  },
                ),
                const SizedBox(height: 14),
                _ProfileTabContent(activeIndex: selectedTabIndex),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCover extends StatelessWidget {
  const _ProfileCover({
    required this.avatarAsset,
    required this.onBack,
    required this.onMore,
  });

  final String avatarAsset;
  final VoidCallback onBack;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: topPadding + 158,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/img/contoh poster4.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: c.surface.withValues(alpha: 0.18)),
          ),
          Positioned(
            top: topPadding + 16,
            left: 16,
            child: _ProfileCircleButton(
              icon: FluentIcons.chevron_left_24_regular,
              onTap: onBack,
            ),
          ),
          Positioned(
            top: topPadding + 16,
            right: 16,
            child: _ProfileCircleButton(
              icon: FluentIcons.more_horizontal_24_regular,
              onTap: onMore,
            ),
          ),
          Positioned(
            left: 16,
            bottom: -46,
            child: Container(
              width: 94,
              height: 94,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 3),
              ),
              child: CircleAvatar(
                backgroundImage: AssetImage(avatarAsset),
                backgroundColor: c.grey100,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCircleButton extends StatelessWidget {
  const _ProfileCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: c.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, size: 23, color: c.grey900),
      ),
    );
  }
}

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity();

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Raka Pratama',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppFonts.satoshiStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: c.grey900,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'D4 Teknik Informatika',
          style: AppFonts.satoshiStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: c.grey500,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'UI/UX Designer dan product thinker. Mendesain produk kolaborasi kampus dengan fokus pada clarity, flow, dan UX research.',
          style: AppFonts.satoshiStyle(
            fontSize: 13,
            height: 1.32,
            color: c.grey900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'github.com/raka-design',
          style: AppFonts.satoshiStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.info500,
          ),
        ),
      ],
    );
  }
}

class _SkillWrap extends StatelessWidget {
  const _SkillWrap();

  @override
  Widget build(BuildContext context) {
    final skills = ['Figma', 'Research', 'Design System'];
    return Wrap(
      spacing: 7,
      runSpacing: 8,
      children: skills.map((skill) => _SkillChip(label: skill)).toList(),
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: c.grey200),
      ),
      child: Text(
        label,
        style: AppFonts.satoshiStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: c.textPrimary,
        ),
      ),
    );
  }
}

class _ProfileActions extends StatelessWidget {
  const _ProfileActions({
    required this.isFollowing,
    required this.onFollowToggle,
    required this.onChat,
  });

  final bool isFollowing;
  final VoidCallback onFollowToggle;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onFollowToggle,
            child: Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isFollowing ? c.grey100 : AppColors.primary500,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: isFollowing
                    ? Border.all(color: c.border)
                    : null,
              ),
              child: Text(
                isFollowing ? 'Mengikuti' : 'Ikuti',
                style: AppFonts.satoshiStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isFollowing
                      ? c.textSecondary
                      : c.surface,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: onChat,
          child: Container(
            width: 42,
            height: 40,
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: c.borderStrong),
            ),
            child: Icon(
              FluentIcons.chat_24_regular,
              color: c.textPrimary,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileTabs extends StatelessWidget {
  const _ProfileTabs({required this.activeIndex, required this.onChanged});

  final int activeIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    const tabs = ['Postingan', 'Pengalaman', 'Keahlian', 'Kolaborasi'];

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          tabs.length,
          (index) => _ProfileTab(
            label: tabs[index],
            active: activeIndex == index,
            onTap: () => onChanged(index),
          ),
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxs,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              label,
              style: AppFonts.satoshiStyle(
                fontSize: 14,
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                color: active ? AppColors.primary500 : c.textTertiary,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 2.5,
            width: 48,
            decoration: BoxDecoration(
              color: active ? AppColors.primary500 : AppColors.transparent,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTabContent extends StatelessWidget {
  const _ProfileTabContent({required this.activeIndex});

  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    if (activeIndex == 1) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        alignment: Alignment.center,
        child: Text(
          'Belum ada riwayat pengalaman',
          style: AppFonts.satoshiStyle(
            fontSize: 13,
            color: c.textTertiary,
          ),
        ),
      );
    }

    if (activeIndex == 2) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: _SkillWrap(),
      );
    }

    if (activeIndex == 3) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        alignment: Alignment.center,
        child: Text(
          'Belum ada riwayat kolaborasi',
          style: AppFonts.satoshiStyle(
            fontSize: 13,
            color: c.textTertiary,
          ),
        ),
      );
    }

    return const Column(
      children: [
        _PostCard(
          avatarAsset: 'lib/assets/img/avatar.png',
          name: 'Raka Pratama',
          subtitle: 'D4 Teknik Informatika - 1 jam lalu',
          content:
              'Sedang eksplorasi pattern untuk onboarding komunitas kampus. Yang paling penting: user cepat paham value tanpa kebanyakan teks.',
          likeCount: '142',
          commentCount: '24',
        ),
      ],
    );
  }
}

class _PostCard extends StatefulWidget {
  const _PostCard({
    required this.avatarAsset,
    required this.name,
    required this.subtitle,
    required this.content,
    this.hasImage = false,
    this.imageUrl,
    required this.likeCount,
    required this.commentCount,
  });

  final String avatarAsset;
  final String name;
  final String subtitle;
  final String content;
  final bool hasImage;
  final String? imageUrl;
  final String likeCount;
  final String commentCount;

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _isLiked = false;
  bool _isBookmarked = false;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _likeCount = int.tryParse(widget.likeCount) ?? 0;
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
  }

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.soft,
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: c.primarySoft,
                    backgroundImage: AssetImage(widget.avatarAsset),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Text(
                            widget.name,
                            style: AppFonts.satoshiStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: c.grey900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.satoshiStyle(
                              fontSize: 11.5,
                              color: c.grey400,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    FluentIcons.more_vertical_24_regular,
                    color: c.grey400,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.content,
                style: AppFonts.satoshiStyle(
                  fontSize: 13.5,
                  color: c.grey900,
                  height: 1.45,
                ),
              ),
              if (widget.hasImage && widget.imageUrl != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: Image.network(
                    widget.imageUrl!,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
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
                    _isLiked ? AppColors.error500 : c.grey500,
                    onTap: _toggleLike,
                  ),
                  const SizedBox(width: 22),
                  _buildInteractionItem(
                    FluentIcons.chat_24_regular,
                    widget.commentCount,
                    c.grey500,
                    onTap: () {},
                  ),
                  const Spacer(),
                  _buildInteractionItem(
                    FluentIcons.send_24_regular,
                    '',
                    c.grey500,
                    onTap: () {},
                  ),
                  const SizedBox(width: 20),
                  _buildInteractionItem(
                    _isBookmarked
                        ? FluentIcons.bookmark_24_filled
                        : FluentIcons.bookmark_24_regular,
                    '',
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
    Color activeColor, {
    required VoidCallback onTap,
  }) {
    final c = AppC.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 2,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Icon(icon, color: activeColor, size: 20),
            if (count.isNotEmpty) ...[
              const SizedBox(width: 6),
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
    );
  }
}
