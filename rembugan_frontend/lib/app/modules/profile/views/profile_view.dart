import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/profile_service.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_avatar.dart';
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
        final svc = controller.profileService;
        if (svc.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (svc.errorMessage.value != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(FluentIcons.error_circle_24_regular, size: 48, color: c.textTertiary),
                  const SizedBox(height: 16),
                  Text(
                    svc.errorMessage.value!,
                    textAlign: TextAlign.center,
                    style: AppFonts.satoshiStyle(fontSize: 14, color: c.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: svc.fetchProfile,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }
        final profile = svc.profile.value;

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            _ProfileCover(
              photoUrl: profile.photoUrl,
              coverUrl: profile.coverUrl,
              onSettings: () => Get.toNamed(Routes.SETTINGS),
              onEditCover: () => Get.toNamed(Routes.EDIT_PROFILE),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 56, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileIdentity(profile: profile),
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
    required this.photoUrl,
    this.coverUrl = '',
    required this.onSettings,
    required this.onEditCover,
  });

  final String photoUrl;
  final String coverUrl;
  final VoidCallback onSettings;
  final VoidCallback onEditCover;

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
            child: coverUrl.isNotEmpty
                ? Image.network(coverUrl, fit: BoxFit.cover)
                : const AppCoverPlaceholder(),
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
            top: topPadding + 64,
            right: 16,
            child: _ProfileCircleButton(
              icon: FluentIcons.image_edit_24_regular,
              onTap: onEditCover,
            ),
          ),
          Positioned(
            left: 16,
            bottom: -46,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 3),
              ),
              child: AppAvatar(photoUrl: photoUrl, radius: 47),
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
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: c.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: 23, color: c.grey900),
        ),
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
          profile.interest,
          style: AppFonts.satoshiStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: c.grey500,
          ),
        ),
        const SizedBox(height: 6),
        Row(
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
            const SizedBox(width: 16),
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
        if (profile.bio.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            profile.bio,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.satoshiStyle(
              fontSize: 13,
              height: 1.32,
              color: c.grey900,
            ),
          ),
        ],
        if (profile.socialLink.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            profile.socialLink,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.satoshiStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.info500,
            ),
          ),
        ],
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
          child: Material(
            color: AppColors.transparent,
            child: InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(AppRadius.sm),
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
                      'Edit profil',
                      style: AppFonts.satoshiStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Material(
          color: AppColors.transparent,
          child: InkWell(
            onTap: onSaved,
            borderRadius: BorderRadius.circular(AppRadius.sm),
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
      if (profile.experiences.isEmpty) {
        return _EmptyTabState(
          icon: FluentIcons.document_24_regular,
          title: 'Belum ada pengalaman',
          message:
              'Tambahkan pengalaman pertamamu agar profil terlihat lebih profesional dan menarik perhatian kolaborator.',
          actionLabel: 'Edit Profil',
          onAction: () => Get.toNamed(Routes.EDIT_PROFILE),
        );
      }
      return Column(
        children: profile.experiences
            .map((experience) => _ExperienceCard(item: experience))
            .toList(),
      );
    }

    if (activeIndex == 2) {
      if (profile.skills.isEmpty) {
        return _EmptyTabState(
          icon: FluentIcons.hat_graduation_24_regular,
          title: 'Belum ada keahlian',
          message:
              'Tambahkan keahlianmu agar lebih mudah ditemukan dalam pencarian proyek dan kolaborasi.',
          actionLabel: 'Edit Profil',
          onAction: () => Get.toNamed(Routes.EDIT_PROFILE),
        );
      }
      return _SkillWrap(skills: profile.skills);
    }

    if (activeIndex == 3) {
      final collaborations = profile.collaborationHistory
          .where((item) => item.visible)
          .toList();

      if (collaborations.isEmpty) {
        return _EmptyTabState(
          icon: FluentIcons.people_team_24_regular,
          title: 'Belum ada kolaborasi',
          message:
              'Mulai berkolaborasi dengan teman atau ikut kompetisi untuk membangun portofoliomu.',
          actionLabel: 'Jelajahi',
          onAction: () => Get.toNamed(Routes.EXPLORE),
        );
      }
      return Column(
        children: collaborations
            .map((collaboration) => _CollaborationCard(item: collaboration))
            .toList(),
      );
    }

      return _EmptyTabState(
        icon: FluentIcons.document_24_regular,
        title: 'Belum ada postingan',
        message:
            'Bagikan aktivitas atau proyekmu agar terlihat oleh orang lain dan membangun portofolio yang menarik.',
        actionLabel: 'Buat Postingan',
        onAction: () => Get.toNamed(Routes.CREATE_POST),
    );
  }
}

class _EmptyTabState extends StatelessWidget {
  const _EmptyTabState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: 60,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: c.primarySoft,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(icon, size: 32, color: AppColors.primary500),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppFonts.satoshiStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppFonts.satoshiStyle(
                fontSize: 14,
                color: c.textSecondary,
                height: 1.45,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 28),
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(FluentIcons.edit_24_regular, size: 16),
                  label: Text(actionLabel!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
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
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
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
    return Material(
      color: AppColors.transparent,
      child: InkWell(
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
                  color: active ? AppColors.primary500 : c.textSecondary,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 2.0,
              width: 48,
              decoration: BoxDecoration(
                color: active ? AppColors.primary500 : AppColors.transparent,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
