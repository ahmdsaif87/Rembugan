import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../routes/app_pages.dart';
import '../controllers/explore_controller.dart';
import '../domain/entities/competition.dart';
import '../domain/entities/explore_tab.dart';
import '../domain/entities/project.dart';

class ExploreView extends GetView<ExploreController> {
  const ExploreView({super.key});

  static const _brand = AppColors.primary500;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Scaffold(
      backgroundColor: c.grey50,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: c.surface,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  _SearchBar(
                    hint: 'Cari proyek, lomba, atau orang',
                    onFilter: () =>
                        _showFilterSheet(context, controller.activeTab.value),
                    onChanged: controller.search,
                    controller: controller.searchTextController,
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => Row(
                      children: [
                        _SegmentButton(
                          label: 'Proyek',
                          active: controller.activeTab.value.isProject,
                          onTap: () => controller.changeTab(ExploreTab.project),
                        ),
                        _SegmentButton(
                          label: 'Lomba',
                          active: controller.activeTab.value.isCompetition,
                          onTap: () =>
                              controller.changeTab(ExploreTab.competition),
                        ),
                        _SegmentButton(
                          label: 'Orang',
                          active: controller.activeTab.value.isPeople,
                          onTap: () => controller.changeTab(ExploreTab.people),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const _ExploreSkeleton();
                }
                if (controller.hasError.value) {
                  return _buildErrorState(context);
                }
                switch (controller.activeTab.value) {
                  case ExploreTab.competition:
                    return _buildLombaTab(context);
                  case ExploreTab.people:
                    return _buildOrangTab(context);
                  case ExploreTab.project:
                    return _buildProyekTab(context);
                }
              }),
            ),
          ],
        ),
      ),

    );
  }

  Widget _buildErrorState(BuildContext context) {
    final c = AppC.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 80),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.danger50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                FluentIcons.wifi_off_24_regular,
                size: 28,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Gagal memuat',
              style: AppFonts.satoshiStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value.isNotEmpty
                  ? controller.errorMessage.value
                  : 'Terjadi kesalahan. Coba lagi.',
              textAlign: TextAlign.center,
              style: AppFonts.satoshiStyle(
                fontSize: 14,
                color: c.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: () => controller.retry(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: c.border),
                  foregroundColor: c.textPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                child: Text(
                  'Coba Lagi',
                  style: AppFonts.satoshiStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProyekTab(BuildContext context) {
    return Obx(
      () {
        if (!controller.isLoading.value &&
            !controller.isRefreshing.value &&
            controller.filteredProjects.isEmpty &&
            !controller.isLoadingMore.value) {
          final isOnboarded = Get.find<AuthService>()
              .currentUser
              .value
              ?.isOnboarded;
          return _buildEmptyState(
            context,
            icon: FluentIcons.search_24_regular,
            title: 'Proyek tidak ditemukan',
            message: isOnboarded == false
                ? 'Lengkapi profil untuk mendapatkan rekomendasi proyek yang sesuai dengan minatmu.'
                : 'Coba ubah kata kunci atau filter pencarian kamu.',
            actionLabel: isOnboarded == false ? 'Lengkapi Profil' : 'Reset Filter',
            onAction: isOnboarded == false
                ? () => Get.toNamed(Routes.PERSONALIZATION)
                : controller.clearAllFilters,
          );
        }
        final showBanner = Get.find<AuthService>()
                .currentUser
                .value
                ?.isOnboarded ==
            false;
        final listCount =
            controller.filteredProjects.length + (showBanner ? 1 : 0);
        final hasMore = controller.hasMoreProjects;
        final itemCount = listCount + (hasMore ? 1 : 0);
        return RefreshIndicator(
          onRefresh: controller.refreshProjects,
          displacement: 50,
          edgeOffset: 20,
          child: ListView.separated(
            controller: controller.projectScrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            itemCount: itemCount,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              if (showBanner && index == 0) {
                return _CompleteProfileBanner(
                  onTap: () => Get.toNamed(Routes.PERSONALIZATION),
                );
              }

              final dataIndex = index - (showBanner ? 1 : 0);
              if (dataIndex >= controller.filteredProjects.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Skeleton(width: 24, height: 24),
                  ),
                );
              }

              final project = controller.filteredProjects[dataIndex];
              return _ProjectCard(
                project: project,
                matchLabel: dataIndex == 0
                    ? 'Paling cocok untuk kamu'
                    : 'Skill yang sama',
                onDetail: () => ExploreView.showProjectSheet(
                  context,
                  project,
                  onApply: controller.applyToProject,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLombaTab(BuildContext context) {
    return Obx(
      () {
        if (controller.filteredCompetitions.isEmpty) {
          return _buildEmptyState(
            context,
            icon: FluentIcons.search_24_regular,
            title: 'Lomba tidak ditemukan',
            message: 'Belum ada lomba yang cocok dengan filter saat ini. Coba ubah kategori atau atur ulang filter.',
            actionLabel: 'Reset Filter',
            onAction: controller.clearAllFilters,
          );
        }
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 28),
              sliver: SliverGrid.builder(
                itemCount: controller.filteredCompetitions.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.57,
                ),
                itemBuilder: (context, index) {
                  final competition = controller.filteredCompetitions[index];
                  return _CompetitionCard(
                    competition: competition,
                    index: index,
                    onTap: () => ExploreView.showCompetitionSheet(
                      context,
                      competition,
                      index,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrangTab(BuildContext context) {
    return Obx(
      () {
        if (controller.filteredPeople.isEmpty) {
          final emptyMsg = controller.hasActiveOffering
              ? 'Belum ada pengguna dengan skill yang cocok untuk "${controller.activeOfferingTitle.value}".'
              : 'Coba ubah kata kunci atau filter untuk menemukan pengguna lain.';
          return _buildEmptyState(
            context,
            icon: FluentIcons.person_search_24_regular,
            title: 'Orang tidak ditemukan',
            message: emptyMsg,
            actionLabel: controller.hasActiveOffering
                ? 'Kembali ke rekomendasi umum'
                : 'Reset Filter',
            onAction: controller.hasActiveOffering
                ? controller.clearActiveOffering
                : controller.clearAllFilters,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
          itemCount: controller.filteredPeople.length + 1,
          separatorBuilder: (_, index) => SizedBox(height: index == 0 ? 12 : 16),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (controller.hasActiveOffering)
                    _OfferingContextHeader(
                      projectTitle: controller.activeOfferingTitle.value!,
                      onBackToGeneral: controller.clearActiveOffering,
                    ),
                  const SizedBox(height: 8),
                  _SectionHeader(
                    title: controller.hasActiveOffering
                        ? 'Rekomendasi untuk "${controller.activeOfferingTitle.value}"'
                        : 'Rekomendasi',
                    trailing: '${controller.filteredPeople.length} hasil',
                  ),
                ],
              );
            }

            final person = controller.filteredPeople[index - 1];
            return _PersonCard(
              id: person.id,
              name: person.name,
              role: person.role,
              avatarUrl: person.avatarUrl,
              tags: person.tags,
              matchLabel: person.matchLabel,
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final c = AppC.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: c.primarySoft,
                shape: BoxShape.circle,
                border: Border.all(color: c.border, width: 1),
              ),
              child: Icon(icon, size: 28, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
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
                height: 1.4,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: onAction,
                  icon: Icon(FluentIcons.edit_24_regular, size: 16, color: c.textPrimary),
                  label: Text(actionLabel),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: c.border),
                    foregroundColor: c.textPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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

  void _showFilterSheet(BuildContext context, ExploreTab tab) {
    final c = AppC.of(context);
    final title = tab.isCompetition
        ? 'Filter lomba'
        : tab.isPeople
        ? 'Filter orang'
        : 'Filter proyek';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.48,
        minChildSize: 0.38,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: c.background,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
              border: Border(top: BorderSide(color: c.border)),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: c.borderStrong,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: AppFonts.headingStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Persempit hasil dengan opsi yang paling relevan.',
                  style: AppFonts.interStyle(
                    fontSize: 13,
                    color: c.textSecondary,
                  ),
                ),
                if (tab.isPeople) ...[
                  const SizedBox(height: 8),
                  const _ProfileFilterPreview(),
                ],
                const SizedBox(height: 12),
                _FilterSheetContent(tab: tab),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          controller.clearAllFilters();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          controller.applyFilters();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Terapkan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static void showProjectSheet(
    BuildContext context,
    Project project, {
    Future<String?> Function(int projectId)? onApply,
  }) {
    final c = AppC.of(context);
    var applying = false;

    final ctrl = Get.find<ExploreController>();
    if (project.isOwner) {
      ctrl.setActiveOffering(project.projectId, project.title);
    } else if (ctrl.hasActiveOffering) {
      ctrl.clearActiveOffering();
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return _DetailSheetFrame(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    project.title,
                    style: AppFonts.satoshiStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    project.description.isNotEmpty
                        ? project.description
                        : 'Belum ada deskripsi proyek.',
                    style: AppFonts.satoshiStyle(
                      fontSize: 13,
                      height: 1.55,
                      color: c.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Skill Dibutuhkan',
                    style: AppFonts.satoshiStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: project.skills
                        .map((skill) => _Pill(skill, c.grey50, c.textSecondary))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Anggota Tim',
                    style: AppFonts.satoshiStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      for (var i = 0; i < project.memberNames.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.md),
                          child: _TeamMember(
                            name: project.memberNames[i],
                            avatarUrl: i < project.memberAvatars.length
                                ? project.memberAvatars[i]
                                : null,
                          ),
                        ),
                      for (var i = 0; i < project.openSlots; i++)
                        const Padding(
                          padding: EdgeInsets.only(right: AppSpacing.md),
                          child: _EmptyMember(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _OwnerTile(project: project),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _OutlineAction(
                          label: 'Tutup',
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _PrimaryAction(
                          label: project.isOwner
                              ? 'Punya Saya'
                              : (project.isMember
                                  ? 'Bergabung'
                                  : (project.hasApplied
                                      ? 'Menunggu'
                                      : (applying ? 'Mengirim...' : 'Minta Bergabung'))),
                          onTap: project.isOwner || project.isMember || project.hasApplied || applying
                              ? null
                              : () async {
                                  if (onApply == null) return;
                                  final confirmed = await _confirmProjectApplication(context, project);
                                  if (confirmed != true || !context.mounted) return;
                                  setSheetState(() => applying = true);
                                  final err = await onApply(project.projectId);
                                  if (!context.mounted) return;
                                  if (err == null) {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Lamaran berhasil dikirim!'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  } else {
                                    setSheetState(() => applying = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(err),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Future<bool?> _confirmProjectApplication(
    BuildContext context,
    Project project,
  ) {
    final c = AppC.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        title: Text(
          'Kirim permintaan bergabung?',
          style: AppFonts.satoshiStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
          ),
        ),
        content: Text(
          'Owner proyek "${project.title}" akan melihat profil dan skill kamu sebelum menerima permintaan.',
          style: AppFonts.satoshiStyle(
            fontSize: 13,
            height: 1.45,
            color: c.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Kirim Permintaan'),
          ),
        ],
      ),
    );
  }

  static void showCompetitionSheet(
    BuildContext context,
    Competition competition,
    int index,
  ) {
    final c = AppC.of(context);
    final posterUrl = competition.posterUrl;

    final String richCaption = competition.caption.isNotEmpty
        ? competition.caption
        : '''
🚨 OPEN REGISTRATION! 🚨
🎉 ${competition.title.toUpperCase()}
📝 ${competition.category} Competition

📅 Deadline: ${competition.deadline}

📲 Daftar sekarang di link ini!
${competition.registrationLink}

#rembugan #competition2026 #lombanasional #${competition.category.toLowerCase()} #eventmahasiswa''';

    bool isExpanded = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            final bool showSeeMore = richCaption.length > 150;
            final String displayedCaption = (showSeeMore && !isExpanded)
                ? '${richCaption.substring(0, 140)}...'
                : richCaption;

            return _DetailSheetFrame(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. poster image (perfect scale preservation, never cut off!)
                  GestureDetector(
                    onTap: () => posterUrl.isNotEmpty
                        ? _showImageViewer(context, imageUrl: posterUrl)
                        : _showImageViewer(context, assetPath: 'lib/assets/img/contoh poster1.jpeg'),
                    child: Container(
                      height: 320,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: c.grey100,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: c.border, width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: posterUrl.isNotEmpty
                            ? Image.network(
                                posterUrl,
                                fit: BoxFit.contain,
                                
                                errorBuilder: (_, __, ___) => Image.asset(
                                  'lib/assets/img/contoh poster1.jpeg',
                                  fit: BoxFit.contain,
                                ),
                              )
                            : Image.asset('lib/assets/img/contoh poster1.jpeg', fit: BoxFit.contain),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. badge & organizer tag
                  _Pill(
                    competition.category,
                    AppColors.info50,
                    AppColors.info600,
                  ),
                  const SizedBox(height: 12),

                  // 3. title
                  Text(
                    competition.title,
                    style: AppFonts.satoshiStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.18,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Diselenggarakan oleh: ${competition.organizer}',
                    style: AppFonts.satoshiStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: c.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (competition.daysLeft != null) ...[
                    _CompetitionTimelineBox(
                      daysLeft: competition.daysLeft!,
                      deadline: competition.deadline,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Divider
                  Divider(color: c.border, height: 1),
                  const SizedBox(height: 16),

                  // 4. caption
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayedCaption,
                        style: AppFonts.satoshiStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: c.grey700,
                        ),
                      ),
                      if (showSeeMore) ...[
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                          child: Text(
                            isExpanded
                                ? 'Lihat lebih sedikit'
                                : 'Lihat selengkapnya',
                            style: AppFonts.satoshiStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 5. actions
                  Row(
                    children: [
                      Expanded(
                        child: _OutlineAction(
                          label: 'Tutup',
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _PrimaryAction(
                      label: 'Buka Link',
                          onTap: () => openRegistrationLink(competition),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Future<void> openRegistrationLink(Competition competition) async {
    final rawLink = competition.registrationLink.trim();
    if (rawLink.isEmpty) {
      AppToast.error('Link pendaftaran belum tersedia.');
      return;
    }

    final normalizedLink = rawLink.startsWith('http') ? rawLink : 'https://$rawLink';
    final uri = Uri.tryParse(normalizedLink);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    await Clipboard.setData(ClipboardData(text: rawLink));
    AppToast.success(rawLink, title: 'Link disalin');
  }
}

class _ExploreSkeleton extends StatelessWidget {
  const _ExploreSkeleton();

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        children: [
          _skeletonBlock(c: c, height: 32),
          const SizedBox(height: 16),
          _skeletonBlock(c: c, height: 120),
          const SizedBox(height: 12),
          _skeletonBlock(c: c, height: 60),
          const SizedBox(height: 12),
          _skeletonBlock(c: c, height: 120),
        ],
      ),
    );
  }

  Widget _skeletonBlock({required AppC c, required double height}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: c.grey100,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.hint,
    required this.onFilter,
    required this.onChanged,
    required this.controller,
  });

  final String hint;
  final VoidCallback onFilter;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: c.grey100,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppFonts.satoshiStyle(
                fontSize: 13.5,
                color: c.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppFonts.satoshiStyle(
                  fontSize: 13.5,
                  color: c.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                filled: true,
                fillColor: c.grey100,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: Icon(FluentIcons.search_24_regular, color: c.grey900, size: 19),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 39,
                  minHeight: 0,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: const BorderSide(
                    color: AppColors.primary200,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: onFilter,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: c.border, width: 1.0),
            ),
            child: Icon(
              FluentIcons.filter_24_regular,
              size: 20,
              color: c.grey900,
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterSheetContent extends StatelessWidget {
  const _FilterSheetContent({required this.tab});

  final ExploreTab tab;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExploreController>();
    final isLomba = tab.isCompetition;
    final isPeople = tab.isPeople;

    return Obx(() {
      return Column(
        children: [
          _SortSelector(
            isPeople: isPeople,
            option2: !isPeople ? 'Semua' : null,
            selectedSort: controller.selectedSort.value,
            onSortChanged: (sort) => controller.selectedSort.value = sort,
          ),
          if (isPeople) ...[
            const SizedBox(height: 8),
            _FilterSelectField(
              label: 'Jurusan',
              value: controller.selectedFaculty.value,
              icon: FluentIcons.hat_graduation_24_regular,
              options: const [
                'Semua jurusan',
                'Teknik Informatika',
                'Sistem Informasi',
                'DKV',
                'Manajemen',
              ],
              onChanged: (val) => controller.selectedFaculty.value = val,
            ),
            const SizedBox(height: 8),
            _FilterSelectField(
              label: 'Skill',
              value: controller.selectedSkill.value,
              icon: FluentIcons.code_24_regular,
              options: const ['Semua skill', 'Flutter', 'UI/UX', 'Firebase', 'React'],
              onChanged: (val) => controller.selectedSkill.value = val,
            ),
            const SizedBox(height: 8),
            _FilterSelectField(
              label: 'Ketersediaan',
              value: controller.selectedAvailability.value,
              icon: FluentIcons.people_24_regular,
              options: const [
                'Terbuka kolaborasi',
                'Aktif minggu ini',
                'Ada portfolio',
              ],
              onChanged: (val) => controller.selectedAvailability.value = val,
            ),
          ],
          if (isLomba) ...[
            const SizedBox(height: 8),
            _FilterSelectField(
              label: 'Deadline pendaftaran',
              value: controller.selectedDeadline.value,
              icon: FluentIcons.calendar_24_regular,
              options: const [
                'Semua deadline',
                '< 1 minggu',
                '1 minggu',
                '2 minggu',
                'Bulan ini',
              ],
              onChanged: (val) => controller.selectedDeadline.value = val,
            ),
          ],
        ],
      );
    });
  }
}

class _SortSelector extends StatelessWidget {
  const _SortSelector({
    required this.isPeople,
    required this.selectedSort,
    required this.onSortChanged,
    this.option2,
  });

  final bool isPeople;
  final String? option2;
  final String selectedSort;
  final ValueChanged<String> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final option2Label = option2 ?? (isPeople ? 'Terpopuler' : 'Terbaru');
    return _FilterPanel(
      label: 'Urutan',
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onSortChanged('Paling relevan'),
              child: _SortOption(
                label: 'Paling relevan',
                icon: FluentIcons.sparkle_24_filled,
                selected:
                    selectedSort == 'Paling relevan' || selectedSort.isEmpty,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => onSortChanged(option2Label),
              child: _SortOption(
                label: option2Label,
                icon: isPeople
                    ? FluentIcons.arrow_trending_24_regular
                    : FluentIcons.clock_24_regular,
                selected: selectedSort == option2Label,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.label,
    required this.icon,
    required this.selected,
  });

  final String label;
  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary500 : c.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: selected ? AppColors.primary500 : c.border,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 15,
            color: selected ? AppColors.white : c.textSecondary,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.satoshiStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.white : c.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSelectField extends StatelessWidget {
  const _FilterSelectField({
    required this.label,
    required this.value,
    required this.icon,
    required this.options,
    this.onChanged,
  });

  final String label;
  final String value;
  final IconData icon;
  final List<String> options;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return _FilterPanel(
      label: label,
      child: InkWell(
        onTap: () => _showOptions(context),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: c.border),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: c.textTertiary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.satoshiStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
              ),
              Icon(
                FluentIcons.chevron_down_24_regular,
                size: 16,
                color: c.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => _SearchableFilterSheet(
        title: label,
        value: value,
        options: options,
        onChanged: onChanged,
      ),
    );
  }
}

class _SearchableFilterSheet extends StatefulWidget {
  const _SearchableFilterSheet({
    required this.title,
    required this.value,
    required this.options,
    this.onChanged,
  });

  final String title;
  final String value;
  final List<String> options;
  final ValueChanged<String>? onChanged;

  @override
  State<_SearchableFilterSheet> createState() => _SearchableFilterSheetState();
}

class _SearchableFilterSheetState extends State<_SearchableFilterSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final filtered = widget.options
        .where((option) => option.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.78,
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).padding.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: c.borderStrong,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.title,
              style: AppFonts.satoshiStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              autofocus: true,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Cari ${widget.title.toLowerCase()}',
                prefixIcon: Icon(
                  FluentIcons.search_24_regular,
                  size: 18,
                  color: c.textTertiary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: filtered.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: c.border.withValues(alpha: 0.4),
                ),
                itemBuilder: (context, index) {
                  final option = filtered[index];
                  final selected = option == widget.value;
                  return InkWell(
                    onTap: () {
                      if (widget.onChanged != null) {
                        widget.onChanged!(option);
                      }
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option,
                              style: AppFonts.satoshiStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: c.textPrimary,
                              ),
                            ),
                          ),
                          if (selected)
                            const Icon(
                              FluentIcons.checkmark_24_filled,
                              size: 18,
                              color: AppColors.primary500,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: c.grey50,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppFonts.satoshiStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _ProfileFilterPreview extends StatelessWidget {
  const _ProfileFilterPreview();

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          const AppAvatar(radius: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preview hasil orang',
                  style: AppFonts.satoshiStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Filter membantu menemukan calon kolaborator yang relevan.',
                  style: AppFonts.satoshiStyle(
                    fontSize: 11,
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
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
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? AppColors.primary500 : AppColors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: AppFonts.satoshiStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: active ? c.textPrimary : c.grey500,
            ),
          ),
        ),
      ),
    );
  }
}

class _CompleteProfileBanner extends StatelessWidget {
  const _CompleteProfileBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: AppColors.primary500,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(
                  FluentIcons.people_edit_24_regular,
                  color: AppColors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lengkapi profilmu',
                      style: AppFonts.satoshiStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tambahkan skill dan minatmu untuk mendapatkan rekomendasi yang lebih relevan.',
                      style: AppFonts.satoshiStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.white.withValues(alpha: 0.84),
                        height: 1.28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lengkapi sekarang',
                          style: AppFonts.satoshiStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          FluentIcons.arrow_right_24_regular,
                          color: AppColors.white,
                          size: 19,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfferingContextHeader extends StatelessWidget {
  const _OfferingContextHeader({
    required this.projectTitle,
    required this.onBackToGeneral,
  });

  final String projectTitle;
  final VoidCallback onBackToGeneral;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.primary200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mencari anggota untuk proyekmu',
                  style: AppFonts.satoshiStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  projectTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.satoshiStyle(
                    fontSize: 11,
                    color: AppColors.primary600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onBackToGeneral,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.xs),
                border: Border.all(color: AppColors.primary200),
              ),
              child: Text(
                'Ganti',
                style: AppFonts.satoshiStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.trailing});

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.headingStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
                height: 1.1,
              ),
            ),
          ),
          Text(
            trailing,
            style: AppFonts.satoshiStyle(
              fontSize: 11,
              color: c.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.project,
    required this.matchLabel,
    required this.onDetail,
  });

  final Project project;
  final String matchLabel;
  final VoidCallback onDetail;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final visibleSkills = project.skills.take(2).toList();

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onDetail,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: c.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (project.isOwner)
                _MatchBadge(label: 'Punya Saya')
              else if (project.isMember)
                _MatchBadge(label: 'Anggota')
              else if (project.hasApplied)
                _MatchBadge(label: 'Menunggu')
              else if (project.matchScore > 0)
                _MatchBadge(label: 'Sesuai skill'),
              const SizedBox(height: AppSpacing.sm),
              Text(
                project.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.satoshiStyle(
                  fontSize: 17,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                project.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.satoshiStyle(
                  fontSize: 13,
                  height: 1.24,
                  fontWeight: FontWeight.w400,
                  color: c.grey600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: visibleSkills
                    .map(
                      (skill) =>
                          _MiniChip(label: skill, color: c.grey100),
                    )
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                _ProjectAvatarStack(count: project.memberAvatars.length),
                const SizedBox(width: 12),
                Text(
                  project.postedAgo,
                  style: AppFonts.satoshiStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: c.textSecondary,
                  ),
                ),
                const Spacer(),
                Icon(
                  FluentIcons.people_team_24_filled,
                  size: 23,
                  color: c.grey700,
                ),
                const SizedBox(width: 8),
                Text(
                  '${project.filledSlots}/${project.totalSlots}',
                  style: AppFonts.satoshiStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _ProjectAvatarStack extends StatelessWidget {
  const _ProjectAvatarStack({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final visibleCount = count.clamp(1, 2);

    return SizedBox(
      width: 57,
      height: 22,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < visibleCount; i++)
            Positioned(
              left: i * 15,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: c.surface, width: 1.4),
                ),
                child: const AppAvatar(radius: 10),
              ),
            ),
          Positioned(
            left: visibleCount * 15,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: c.grey100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                FluentIcons.add_16_filled,
                size: 15,
                color: c.grey500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompetitionCard extends StatelessWidget {
  const _CompetitionCard({
    required this.competition,
    required this.index,
    required this.onTap,
  });

  final Competition competition;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final posterUrl = competition.posterUrl;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Ink(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: c.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Expanded(
              flex: 5,
              child: SizedBox(
                width: double.infinity,
                child: posterUrl.isNotEmpty
                    ? Image.network(
                        posterUrl,
                        fit: BoxFit.cover,
                        
                        errorBuilder: (_, __, ___) => Image.asset(
                          'lib/assets/img/contoh poster1.jpeg',
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset('lib/assets/img/contoh poster1.jpeg', fit: BoxFit.cover),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TinyTag(label: competition.category),
                    const SizedBox(height: 8),
                    Text(
                      competition.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.satoshiStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      competition.organizer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.satoshiStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: c.grey500,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          FluentIcons.calendar_ltr_16_regular,
                          size: 12,
                          color: AppColors.error500,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            competition.deadline,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.satoshiStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.error500,
                            ),
                          ),
                        ),
                        if (competition.matchScore > 0) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            FluentIcons.circle_12_filled,
                            size: 7,
                            color: AppColors.warning500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Paling Sesuai',
                            style: AppFonts.satoshiStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.warning600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _MatchBadge extends StatelessWidget {
  const _MatchBadge({required this.label});

  final String label;

  _StatusTone get tone {
    final value = label.toLowerCase();
    if (value.contains('cocok')) {
      return const _StatusTone(
        background: AppColors.info50,
        border: AppColors.info50,
        foreground: AppColors.info700,
      );
    }
    if (value.contains('ditutup') || value.contains('deadline')) {
      return const _StatusTone(
        background: AppColors.warning50,
        border: AppColors.warning100,
        foreground: AppColors.warning700,
      );
    }
    if (value.contains('penuh')) {
      return const _StatusTone(
        background: AppColors.danger50,
        border: AppColors.danger100,
        foreground: AppColors.danger600,
      );
    }
    if (value.contains('trending')) {
      return const _StatusTone(
        background: AppColors.info50,
        border: AppColors.info100,
        foreground: AppColors.info600,
      );
    }
    if (value.contains('baru')) {
      return const _StatusTone(
        background: AppColors.primary50,
        border: AppColors.primary50,
        foreground: AppColors.primary400,
      );
    }
    if (value.contains('menunggu')) {
      return const _StatusTone(
        background: AppColors.warning50,
        border: AppColors.warning100,
        foreground: AppColors.warning700,
      );
    }
    return const _StatusTone(
      background: AppColors.info50,
      border: AppColors.info50,
      foreground: AppColors.info700,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = tone;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: style.background),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppFonts.satoshiStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: style.foreground,
        ),
      ),
    );
  }
}

class _StatusTone {
  const _StatusTone({
    required this.background,
    required this.border,
    required this.foreground,
  });

  final Color background;
  final Color border;
  final Color foreground;
}

class _TinyTag extends StatelessWidget {
  const _TinyTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: c.grey100,
        borderRadius: BorderRadius.circular(AppRadius.xxs),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppFonts.satoshiStyle(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: c.textTertiary,
        ),
      ),
    );
  }
}

class _DetailSheetFrame extends StatelessWidget {
  const _DetailSheetFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 40),
      padding: EdgeInsets.fromLTRB(
        28,
        10,
        28,
        MediaQuery.of(context).padding.bottom + 22,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: c.borderStrong,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            const SizedBox(height: 28),
            child,
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label, this.background, this.foreground);

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppFonts.satoshiStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppFonts.satoshiStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: c.grey700,
        ),
      ),
    );
  }
}

class _TeamMember extends StatelessWidget {
  const _TeamMember({required this.name, this.avatarUrl});

  final String name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppAvatar(photoUrl: avatarUrl, radius: 18),
        const SizedBox(height: 4),
        SizedBox(
          width: 48,
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppFonts.satoshiStyle(fontSize: 9, color: c.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _EmptyMember extends StatelessWidget {
  const _EmptyMember();

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: c.borderStrong,
              style: BorderStyle.solid,
            ),
          ),
          child: Icon(FluentIcons.add_24_regular, size: 18, color: c.borderStrong),
        ),
        const SizedBox(height: 6),
        Text(
          'Terbuka',
          style: AppFonts.satoshiStyle(
            fontSize: 10,
            color: c.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _OwnerTile extends StatelessWidget {
  const _OwnerTile({required this.project});

  final Project project;

  void _goToProfile(BuildContext context) {
    if (project.posterId.isEmpty) return;
    Get.toNamed(
      Routes.otherProfileRoute(project.posterId),
      arguments: {
        'name': project.postedBy,
        'role': '',
        'avatarUrl': project.avatarUrl,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: () => _goToProfile(context),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: c.border),
          ),
          child: Row(
            children: [
              AppAvatar(photoUrl: project.avatarUrl, radius: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diposting oleh',
                      style: AppFonts.satoshiStyle(
                        fontSize: 10,
                        color: c.textSecondary,
                      ),
                    ),
                    Text(
                      project.postedBy,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.satoshiStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: c.background,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: c.border),
                ),
                child: Text(
                  'Profil',
                  style: AppFonts.satoshiStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ExploreView._brand,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled ? AppColors.primary500 : AppColors.grey300,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(
            label,
            style: AppFonts.satoshiStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlineAction extends StatelessWidget {
  const _OutlineAction({required this.label, required this.onTap});

  final String label;
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
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: c.border),
          ),
          child: Text(
            label,
            style: AppFonts.satoshiStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: c.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.tags,
    required this.matchLabel,
  });

  final String id;
  final String name;
  final String role;
  final String avatarUrl;
  final List<String> tags;
  final String matchLabel;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: () => Get.toNamed(
          Routes.otherProfileRoute(id),
          arguments: {
            'name': name,
            'role': role,
            'avatarUrl': avatarUrl,
            'tags': tags,
          },
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: c.border, width: 1),
          ),
          child: Row(
            children: [
              AppAvatar(photoUrl: avatarUrl, radius: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (matchLabel.isNotEmpty) ...[
                      _MatchBadge(label: matchLabel),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.satoshiStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                    ),
                    Text(
                      role,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.satoshiStyle(
                        fontSize: 11,
                        color: c.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ...tags.take(1).map(
                              (tag) =>
                                  _MiniChip(label: tag, color: c.grey50),
                            ),
                        if (tags.length > 3)
                          _MiniChip(
                            label: '+${tags.length - 3}',
                            color: c.grey50,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.CHAT, arguments: {'name': name});
                },
                child: Icon(
                  FluentIcons.send_24_regular,
                  size: 20,
                  color: c.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showImageViewer(
  BuildContext context, {
  String? assetPath,
  String? imageUrl,
}) {
  showDialog<void>(
    context: context,
    barrierColor: AppColors.black.withValues(alpha: 0.5),
    builder: (context) => GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(color: AppColors.black.withValues(alpha: 0.4)),
            ),
          ),
          Positioned(
            top: 40,
            right: AppSpacing.lg,
            child: Material(
              color: AppColors.white.withValues(alpha: 0.15),
              shape: const CircleBorder(),
              child: IconButton(
                icon: Icon(FluentIcons.dismiss_24_regular, color: AppColors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Center(
            child: InteractiveViewer(
              clipBehavior: Clip.none,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.95,
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  child: assetPath != null
                      ? Image.asset(assetPath, fit: BoxFit.contain)
                      : Image.network(
                          imageUrl!,
                          fit: BoxFit.contain,
                          
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _CompetitionTimelineBox extends StatelessWidget {
  const _CompetitionTimelineBox({
    required this.daysLeft,
    required this.deadline,
  });

  final int daysLeft;
  final String deadline;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final isUrgent = daysLeft <= 5;
    final isWarning = daysLeft <= 10;

    final Color primaryColor = isUrgent
        ? AppColors.error500
        : isWarning
        ? AppColors.warning500
        : AppColors.primary;

    final Color bgColor = isUrgent
        ? AppColors.danger50
        : isWarning
        ? AppColors.warning50
        : AppColors.info50;

    final Color borderColor = isUrgent
        ? AppColors.danger100
        : isWarning
        ? AppColors.warning100
        : AppColors.info100;

    final double progress = daysLeft <= 0
        ? 1.0
        : (30 - daysLeft).clamp(0, 30) / 30.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isUrgent ? FluentIcons.alert_24_regular : FluentIcons.clock_alarm_24_regular,
                  color: primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUrgent
                          ? 'Tenggat Waktu Sangat Dekat!'
                          : 'Sisa Waktu Pendaftaran',
                      style: AppFonts.satoshiStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isUrgent
                            ? AppColors.danger800
                            : AppColors.info700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Batas akhir: $deadline',
                      style: AppFonts.satoshiStyle(
                        fontSize: 10.5,
                        color: isUrgent
                            ? AppColors.danger700
                            : AppColors.info600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Text(
                  daysLeft <= 0 ? 'Ditutup' : '$daysLeft Hari Lagi',
                  style: AppFonts.satoshiStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: primaryColor.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pendaftaran Dibuka',
                style: AppFonts.satoshiStyle(
                  fontSize: 9.5,
                  color: c.textTertiary,
                ),
              ),
              Text(
                daysLeft <= 0
                    ? 'Sudah Ditutup'
                    : isUrgent
                    ? 'Segera ditutup!'
                    : 'Sisa $daysLeft hari',
                style: AppFonts.satoshiStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: isUrgent ? AppColors.error500 : c.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
