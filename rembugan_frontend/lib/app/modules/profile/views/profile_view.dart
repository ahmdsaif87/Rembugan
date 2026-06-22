import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/profile_service.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_chrome.dart';
import '../../../routes/app_pages.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: Obx(() {
        final profile = controller.profileService.profile.value;

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            _ProfileCover(
              avatarAsset: profile.avatarAsset,
              onBack: Get.back,
              onSettings: () => Get.toNamed(Routes.SETTINGS),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 56, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileIdentity(profile: profile),
                  const SizedBox(height: 12),
                  Text(
                    '842 koneksi  7 Kolaborasi',
                    style: AppFonts.satoshiStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: c.grey900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _ProfileActions(
                    onEdit: () => Get.toNamed(Routes.EDIT_PROFILE),
                    onSaved: () => Get.toNamed(Routes.SAVED),
                  ),
                  const SizedBox(height: 16),
                  _ProfileTabs(
                    activeIndex: controller.selectedTabIndex.value,
                    onChanged: controller.changeTab,
                  ),
                  const SizedBox(height: 14),
                  _ProfileTabContent(
                    activeIndex: controller.selectedTabIndex.value,
                    profile: profile,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: const AppBottomNav(
        current: AppNavDestination.profile,
      ),
    );
  }
}

class _ProfileCover extends StatelessWidget {
  const _ProfileCover({
    required this.avatarAsset,
    required this.onBack,
    required this.onSettings,
  });

  final String avatarAsset;
  final VoidCallback onBack;
  final VoidCallback onSettings;

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
              icon: FluentIcons.settings_24_regular,
              onTap: onSettings,
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
  const _ProfileIdentity({required this.profile});

  final ProfileData profile;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          profile.name,
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
          profile.major,
          style: AppFonts.satoshiStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: c.grey500,
          ),
        ),
<<<<<<< Updated upstream
        const SizedBox(height: 10),
        Text(
          profile.bio,
          style: AppFonts.satoshiStyle(
            fontSize: 13,
            height: 1.32,
            color: c.grey900,
          ),
=======
        if (profile.faculty != null || profile.major != null) ...[
          const SizedBox(height: 2),
          Text(
            [profile.faculty, profile.major].whereType<String>().join(' • '),
            style: AppFonts.satoshiStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: c.grey400,
            ),
          ),
        ],
        const SizedBox(height: 6),
        Row(
          children: [
            GestureDetector(
              onTap: () => Get.toNamed(Routes.CONNECTIONS_LIST, arguments: {
                'userId': profile.id,
                'userName': profile.name,
              }),
              child: Row(
                children: [
                  Icon(FluentIcons.people_24_regular, size: 14, color: c.grey500),
                  const SizedBox(width: 4),
                  Text(
                    '${profile.connectionCount} koneksi',
                    style: AppFonts.satoshiStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: c.grey500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => Get.toNamed(Routes.PROJECT_HISTORY, arguments: {
                'userName': profile.name,
                'projects': profile.projectHistory,
              }),
              child: Row(
                children: [
                  Icon(FluentIcons.briefcase_24_regular, size: 14, color: c.grey500),
                  const SizedBox(width: 4),
                  Text(
                    '${profile.projectCount} proyek',
                    style: AppFonts.satoshiStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: c.grey500,
                    ),
                  ),
                ],
              ),
            ),
          ],
>>>>>>> Stashed changes
        ),
        const SizedBox(height: 8),
        Text(
          profile.socialLink,
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
  const _SkillWrap({required this.skills});

  final List<String> skills;

  @override
  Widget build(BuildContext context) {
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
  const _ProfileActions({required this.onEdit, required this.onSaved});

  final VoidCallback onEdit;
  final VoidCallback onSaved;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onEdit,
            child: Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary500,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Edit profile',
                    style: AppFonts.satoshiStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: c.surface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: onSaved,
          child: Container(
            width: 42,
            height: 40,
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: c.borderStrong),
            ),
            child: Icon(
              FluentIcons.bookmark_24_regular,
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

class _ProfileTabContent extends StatelessWidget {
  const _ProfileTabContent({required this.activeIndex, required this.profile});

  final int activeIndex;
  final ProfileData profile;

  @override
  Widget build(BuildContext context) {
    if (activeIndex == 1) {
      return Column(
        children: profile.experiences
            .map((experience) => _ExperienceCard(item: experience))
            .toList(),
      );
    }

    if (activeIndex == 2) {
      return _SkillWrap(skills: profile.skills);
    }

    if (activeIndex == 3) {
      final collaborations = profile.collaborationHistory
          .where((item) => item.visible)
          .toList();

      return Column(
        children: collaborations
            .map((collaboration) => _CollaborationCard(item: collaboration))
            .toList(),
      );
    }

    return Column(
      children: [
        _PostCard(
          avatarAsset: profile.avatarAsset,
          name: profile.name,
          subtitle: 'D4 Teknik Informatika - 2 jam lalu',
          content:
              'Sharing sedikit tips buat temen-temen D4 Teknik Informatika yang lagi ngerjain project akhir: Coba biasain bikin design system di Figma dulu sebelum masuk ke codingan Flutter. Ini bener-bener ngehemat waktu integrasi UI nanti dan bikin komponen jadi reusable',
          hasImage: true,
          imageUrl: 'lib/assets/img/contoh poster2.jpeg',
          likeCount: '120',
          commentCount: '20',
        ),
        _PostCard(
          avatarAsset: profile.avatarAsset,
          name: profile.name,
          subtitle: 'D4 Teknik Informatika - Kemarin',
          content:
              'Selesai bikin prototype dashboard tim kecil. Fokusnya biar task, file, dan diskusi tetap gampang discan.',
          likeCount: '76',
          commentCount: '12',
        ),
      ],
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard({required this.item});

  final ProfileExperience item;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: c.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 7),
            decoration: const BoxDecoration(
              color: AppColors.primary500,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text(
                    item.title,
                    style: AppFonts.satoshiStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${item.organization} - ${item.duration}',
                    style: AppFonts.satoshiStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: c.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.description,
                    style: AppFonts.satoshiStyle(
                      fontSize: 11.5,
                      height: 1.5,
                      color: c.textSecondary,
                    ),
                  ),
                if (item.techStack.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: item.techStack
                        .map((skill) => _MiniSkillChip(label: skill))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CollaborationCard extends StatelessWidget {
  const _CollaborationCard({required this.item});

  final PlatformCollaboration item;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: c.grey100,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: c.border),
                ),
                child: Icon(
                  FluentIcons.people_team_24_regular,
                  size: 17,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(
                        item.role,
                        style: AppFonts.satoshiStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.workspace,
                        style: AppFonts.satoshiStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: c.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              _StatusPill(label: item.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${item.members} anggota - ${item.duration}',
            style: AppFonts.satoshiStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: c.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.contribution,
            style: AppFonts.satoshiStyle(
              fontSize: 11.5,
              height: 1.5,
              color: c.textSecondary,
            ),
          ),
          if (item.skills.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: item.skills
                  .map((skill) => _MiniSkillChip(label: skill))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: c.grey100,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppFonts.satoshiStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: c.textPrimary,
        ),
      ),
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
                  child: widget.imageUrl!.startsWith('lib/assets/')
                      ? Image.asset(
                          widget.imageUrl!,
                          width: double.infinity,
                          height: 236,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          widget.imageUrl!,
                          width: double.infinity,
                          height: 236,
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

class _MiniSkillChip extends StatelessWidget {
  const _MiniSkillChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: c.borderStrong),
      ),
      child: Text(
        label,
        style: AppFonts.satoshiStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: c.textPrimary,
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
