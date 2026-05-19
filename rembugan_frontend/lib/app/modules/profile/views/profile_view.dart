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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppLayeredBackground(
        child: SafeArea(
          child: Obx(() {
            final profile = controller.profileService.profile.value;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                _ProfileTopBar(onSettings: () => Get.toNamed(Routes.SETTINGS)),
                const SizedBox(height: 24),
                _ProfileStatsHeader(profile: profile),
                const SizedBox(height: 20),
                _ProfileIdentity(profile: profile),
                const SizedBox(height: 14),
                _SkillWrap(skills: profile.skills),
                const SizedBox(height: 22),
                _ProfileActions(
                  onEdit: () => Get.toNamed(Routes.EDIT_PROFILE),
                  onSaved: () => Get.toNamed(Routes.SAVED),
                ),
                const SizedBox(height: 26),
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
            );
          }),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(
        current: AppNavDestination.profile,
      ),
    );
  }
}

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Profile',
          style: AppFonts.headingStyle(
            fontSize: 27,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.05,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: onSettings,
          borderRadius: BorderRadius.circular(17),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: AppColors.borderStrong),
            ),
            child: const Center(
              child: Icon(
                FluentIcons.settings_24_regular,
                color: AppColors.textPrimary,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileStatsHeader extends StatelessWidget {
  const _ProfileStatsHeader({required this.profile});

  final ProfileData profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: AssetImage(profile.avatarAsset),
        ),
        const SizedBox(width: 24),
        const Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ProfileMetric(value: '32', label: 'Postingan'),
              _ProfileMetric(value: '842', label: 'Pengikut'),
              _ProfileMetric(value: '7', label: 'Kolaborasi'),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity({required this.profile});

  final ProfileData profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                profile.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.satoshiStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.15,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'D4 Teknik Informatika',
              style: AppFonts.satoshiStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          profile.socialLink,
          style: AppFonts.satoshiStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          profile.bio,
          style: AppFonts.satoshiStyle(
            fontSize: 13,
            height: 1.62,
            color: AppColors.textPrimary.withValues(alpha: 0.88),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        label,
        style: AppFonts.satoshiStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
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
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: onEdit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Edit Profile',
                    style: AppFonts.satoshiStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    FluentIcons.sparkle_24_filled,
                    size: 15,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 18),
        InkWell(
          onTap: onSaved,
          borderRadius: BorderRadius.circular(17),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: AppColors.borderStrong),
            ),
            child: const Icon(
              FluentIcons.bookmark_24_regular,
              color: AppColors.textPrimary,
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
    const tabs = ['Postingan', 'Pengalaman', 'Kolaborasi'];

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
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
              'Nyoba merapikan flow onboarding dan matching project supaya mahasiswa bisa lebih cepat menemukan tim yang cocok.',
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 7),
            decoration: const BoxDecoration(
              color: Colors.black,
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
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.organization} - ${item.duration}',
                  style: AppFonts.satoshiStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item.description,
                  style: AppFonts.satoshiStyle(
                    fontSize: 11.5,
                    height: 1.5,
                    color: AppColors.textSecondary,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.border),
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
                  color: const Color(0xFFF4F5F7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  FluentIcons.people_team_24_regular,
                  size: 17,
                  color: AppColors.textPrimary,
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
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.workspace,
                      style: AppFonts.satoshiStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
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
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.contribution,
            style: AppFonts.satoshiStyle(
              fontSize: 11.5,
              height: 1.5,
              color: AppColors.textSecondary,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppFonts.satoshiStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
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
                    backgroundColor: AppColors.primarySoft,
                    backgroundImage: AssetImage(avatarAsset),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppFonts.satoshiStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.satoshiStyle(
                            fontSize: 11.5,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    FluentIcons.more_vertical_24_regular,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                content,
                style: AppFonts.satoshiStyle(
                  fontSize: 13.5,
                  color: AppColors.textPrimary.withValues(alpha: 0.88),
                  height: 1.5,
                ),
              ),
              if (hasImage && imageUrl != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl!,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInteractionItem(
                    FluentIcons.heart_24_regular,
                    likeCount,
                    const Color(0xFFE5484D),
                  ),
                  const SizedBox(width: 22),
                  _buildInteractionItem(
                    FluentIcons.chat_24_regular,
                    commentCount,
                    AppColors.textSecondary,
                  ),
                  const Spacer(),
                  _buildInteractionItem(
                    FluentIcons.send_24_regular,
                    '',
                    AppColors.textSecondary,
                  ),
                  const SizedBox(width: 20),
                  _buildInteractionItem(
                    FluentIcons.bookmark_24_regular,
                    '',
                    const Color(0xFFD69E2E),
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
    Color activeColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: activeColor.withValues(alpha: 0.88), size: 20),
          if (count.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              count,
              style: AppFonts.satoshiStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniSkillChip extends StatelessWidget {
  const _MiniSkillChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Text(
        label,
        style: AppFonts.satoshiStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: AppFonts.satoshiStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: AppFonts.satoshiStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            child: Text(
              label,
              style: AppFonts.satoshiStyle(
                fontSize: 14,
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                color: active ? AppColors.textPrimary : AppColors.textTertiary,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 2.5,
            width: 48,
            decoration: BoxDecoration(
              color: active ? AppColors.textPrimary : Colors.transparent,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ],
      ),
    );
  }
}
