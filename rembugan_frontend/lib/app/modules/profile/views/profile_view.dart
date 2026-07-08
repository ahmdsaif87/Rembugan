import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/profile_service.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../routes/app_pages.dart';
import '../../home/views/widgets/post_card_widget.dart';
import '../../home/views/widgets/share_sheet.dart';
import '../../main_shell/controllers/main_shell_controller.dart';
import '../../social/views/comment_view.dart';
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
          return const SkeletonProfile();
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
                  OutlinedButton(
                    onPressed: svc.fetchProfile,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppC.of(context).border),
                      foregroundColor: AppC.of(context).textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    child: Text('Coba Lagi',
                      style: AppFonts.satoshiStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppC.of(context).textPrimary),
                    ),
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
              onQrTap: () => Get.toNamed(Routes.PROFILE_QR),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 56, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileIdentity(profile: profile),
                  const SizedBox(height: 14),
                  _ProfileActionButton(
                    icon: FluentIcons.edit_24_regular,
                    label: 'Edit Profil',
                    onTap: () => Get.toNamed(Routes.EDIT_PROFILE),
                    primary: true,
                  ),
                  _ProfileCompletionCard(profile: profile),
                  const SizedBox(height: 16),
                  _ProfileTabs(
                    activeIndex: controller.selectedTabIndex.value,
                    onChanged: controller.changeTab,
                  ),
                  const SizedBox(height: 14),
                  _ProfileTabContent(
                    activeIndex: controller.selectedTabIndex.value,
                    profile: profile,
                    showcases: controller.showcases,
                    isShowcasesLoading: controller.isShowcasesLoading.value,
                    avatarUrl: profile.photoUrl,
                    authorName: profile.name,
                    authorId: profile.id ?? '',
                  ),
                ],
              ),
            ),
          ],
        );
      }),

    );
  }
}

class _ProfileCover extends StatelessWidget {
  const _ProfileCover({
    required this.photoUrl,
    this.coverUrl = '',
    required this.onSettings,
    required this.onQrTap,
  });

  final String photoUrl;
  final String coverUrl;
  final VoidCallback onSettings;
  final VoidCallback onQrTap;

  @override
  Widget build(BuildContext context) {
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
              icon: FluentIcons.qr_code_24_regular,
              onTap: onQrTap,
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
          profile.major,
          style: AppFonts.satoshiStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: c.grey500,
          ),
        ),
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
        ),
        if (profile.interest.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            profile.interest,
            style: AppFonts.satoshiStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: c.textSecondary,
            ),
          ),
        ],
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
        if (profile.socialLinks.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (profile.socialLinks.containsKey('instagram'))
                _SocialLinkButton(
                  icon: FluentIcons.camera_24_regular,
                  label: 'Instagram',
                  url: 'https://instagram.com/${profile.socialLinks['instagram']}',
                ),
              if (profile.socialLinks.containsKey('linkedin'))
                _SocialLinkButton(
                  icon: FluentIcons.briefcase_24_regular,
                  label: 'LinkedIn',
                  url: 'https://linkedin.com/in/${profile.socialLinks['linkedin']}',
                ),
              if (profile.socialLinks.containsKey('website'))
                _SocialLinkButton(
                  icon: FluentIcons.globe_24_regular,
                  label: 'Website',
                  url: profile.socialLinks['website']!,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SocialLinkButton extends StatelessWidget {
  const _SocialLinkButton({
    required this.icon,
    required this.label,
    required this.url,
  });

  final IconData icon;
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Material(
      color: c.primarySoft,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: () async {
          try {
            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          } catch (_) {
            AppToast.error('Tidak bisa membuka tautan');
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: AppColors.primary500),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppFonts.satoshiStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary500,
                ),
              ),
            ],
          ),
        ),
      ),
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

class _ProfileActionButton extends StatelessWidget {
  const _ProfileActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.primary,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          width: double.infinity,
          height: 44,
          decoration: BoxDecoration(
            color: primary ? AppColors.primary500 : c.surface,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: primary ? null : Border.all(color: c.borderStrong),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: primary ? AppColors.white : c.textSecondary),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppFonts.satoshiStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: primary ? AppColors.white : c.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCompletionCard extends StatelessWidget {
  const _ProfileCompletionCard({required this.profile});

  final ProfileData profile;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final hasSocialLinks = profile.socialLinks.values.any((value) => value.trim().isNotEmpty);
    final hasExperience = profile.experiences.any(
      (experience) => experience.title.trim().isNotEmpty && experience.organization.trim().isNotEmpty,
    );
    final checks = <bool>[
      profile.photoUrl.trim().isNotEmpty,
      profile.bio.trim().isNotEmpty,
      profile.skills.any((skill) => skill.trim().isNotEmpty),
      hasExperience,
      hasSocialLinks,
    ];
    final completed = checks.where((done) => done).length;
    if (completed == checks.length) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$completed dari ${checks.length} bagian profil lengkap',
                  style: AppFonts.satoshiStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed(Routes.EDIT_PROFILE),
                child: const Text('Lengkapi'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: completed / checks.length,
              minHeight: 6,
              backgroundColor: c.surface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary500),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Profil lengkap bikin rekomendasi proyek dan kolaborator lebih akurat.',
            style: AppFonts.satoshiStyle(
              fontSize: 12,
              height: 1.35,
              color: c.textSecondary,
            ),
          ),
        ],
      ),
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

class _ProfileTabContent extends StatefulWidget {
  const _ProfileTabContent({
    required this.activeIndex,
    required this.profile,
    required this.showcases,
    required this.isShowcasesLoading,
    required this.avatarUrl,
    required this.authorName,
    required this.authorId,
  });

  final int activeIndex;
  final ProfileData profile;
  final List<Map<String, dynamic>> showcases;
  final bool isShowcasesLoading;
  final String avatarUrl;
  final String authorName;
  final String authorId;

  @override
  State<_ProfileTabContent> createState() => _ProfileTabContentState();
}

class _ProfileTabContentState extends State<_ProfileTabContent> {
  void _showShareSheet(BuildContext context, String showcaseId, String postType) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) => ShareSheet(postId: showcaseId, postType: postType),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pc = Get.find<ProfileController>();
    if (widget.activeIndex == 0) {
      if (widget.isShowcasesLoading) {
        return const SkeletonShowcaseList();
      }
      if (widget.showcases.isEmpty) {
        return _EmptyTabState(
          icon: FluentIcons.document_24_regular,
          title: 'Belum ada postingan',
          message:
              'Bagikan aktivitas atau proyekmu agar terlihat oleh orang lain dan membangun portofolio yang menarik.',
          actionLabel: 'Buat Postingan',
          onAction: () => Get.toNamed(Routes.CREATE_POST),
        );
      }
      return Column(
        children: widget.showcases.map((s) {
          final createdAt = s['created_at'] as String? ?? '';
          final showcaseId = s['id'] as String? ?? '';
          String timeAgo = '';
          try {
            final dt = DateTime.parse(createdAt).toLocal();
            final diff = DateTime.now().difference(dt);
            if (diff.inMinutes < 1) timeAgo = 'Baru saja';
            else if (diff.inMinutes < 60) timeAgo = '${diff.inMinutes}m lalu';
            else if (diff.inHours < 24) timeAgo = '${diff.inHours}j lalu';
            else if (diff.inDays < 7) timeAgo = '${diff.inDays}h lalu';
            else timeAgo = '${(diff.inDays / 7).floor()}mg lalu';
          } catch (_) {}

          return PostCardWidget(
            showcaseId: showcaseId,
            authorId: widget.authorId,
            avatarUrl: widget.avatarUrl,
            name: widget.authorName,
            subtitle: timeAgo,
            content: s['content'] as String? ?? '',
            mediaUrls: (s['media_urls'] as List<dynamic>?)?.cast<String>(),
            isLiked: pc.likedShowcaseIds.contains(showcaseId),
            initialLikes: s['likes_count'] as int? ?? 0,
            initialComments: s['comments_count'] as int? ?? 0,
            showFollowButton: false,
            onShowComments: () => showCommentsSheet(context, showcaseId),
            onShowShare: () => _showShareSheet(context, showcaseId, 'post'),
            onToggleLike: () => pc.toggleLike(showcaseId),
          );
        }).toList(),
      );
    }

    if (widget.activeIndex == 1) {
      if (widget.profile.experiences.isEmpty) {
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
        children: widget.profile.experiences
            .map((experience) => _ExperienceCard(item: experience))
            .toList(),
      );
    }

    if (widget.activeIndex == 2) {
      if (widget.profile.skills.isEmpty) {
        return _EmptyTabState(
          icon: FluentIcons.hat_graduation_24_regular,
          title: 'Belum ada keahlian',
          message:
              'Tambahkan keahlianmu agar lebih mudah ditemukan dalam pencarian proyek dan kolaborasi.',
          actionLabel: 'Edit Profil',
          onAction: () => Get.toNamed(Routes.EDIT_PROFILE),
        );
      }
      return _SkillWrap(skills: widget.profile.skills);
    }

    if (widget.activeIndex == 3) {
      final collaborations = widget.profile.collaborationHistory
          .where((item) => item.visible)
          .toList();

      if (collaborations.isEmpty) {
        return _EmptyTabState(
          icon: FluentIcons.people_team_24_regular,
          title: 'Belum ada kolaborasi',
          message:
              'Mulai berkolaborasi dengan teman atau ikut kompetisi untuk membangun portofoliomu.',
          actionLabel: 'Jelajahi',
          onAction: () => Get.find<MainShellController>().changeTab(1),
        );
      }
      return Column(
        children: collaborations
            .map((collaboration) => _CollaborationCard(item: collaboration))
            .toList(),
      );
    }

    return const SizedBox.shrink();
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
                child: OutlinedButton.icon(
                  onPressed: onAction,
                  icon: Icon(FluentIcons.edit_24_regular, size: 16, color: c.textPrimary),
                  label: Text(actionLabel!),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: c.border),
                    foregroundColor: c.textPrimary,
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
