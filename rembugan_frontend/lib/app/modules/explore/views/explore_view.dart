import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_chrome.dart';
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
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Column(
                children: [
                  Obx(
                    () => _SearchBar(
                      hint: 'Cari proyek, lomba, atau orang',
                      onFilter: () =>
                          _showFilterSheet(context, controller.activeTab.value),
                      onChanged: controller.search,
                      controller: controller.searchTextController,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                switch (controller.activeTab.value) {
                  case ExploreTab.competition:
                    return _buildLombaTab(context);
                  case ExploreTab.people:
                    return _buildOrangTab();
                  case ExploreTab.project:
                    return _buildProyekTab(context);
                }
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(
        current: AppNavDestination.explore,
      ),
    );
  }

  Widget _buildProyekTab(BuildContext context) {
    return Obx(
      () => ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        itemCount: controller.filteredProjects.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return const _CompleteProfileBanner();
          }

          final project = controller.filteredProjects[index - 1];
          return _ProjectCard(
            project: project,
            matchLabel: index == 1
                ? 'Paling cocok untuk kamu'
                : 'Skill yang sama',
            onDetail: () => ExploreView.showProjectSheet(context, project),
          );
        },
      ),
    );
  }

  Widget _buildLombaTab(BuildContext context) {
    return Obx(
      () => CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 28),
            sliver: SliverGrid.builder(
              itemCount: controller.filteredCompetitions.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 18,
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
      ),
    );
  }

  Widget _buildOrangTab() {
    return Obx(
      () => ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
        itemCount: controller.filteredPeople.length + 1,
        separatorBuilder: (_, index) => SizedBox(height: index == 0 ? 14 : 18),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _SectionHeader(
              title: 'Orang Disekitar',
              trailing: '${controller.filteredPeople.length} hasil',
            );
          }

          final person = controller.filteredPeople[index - 1];
          return _PersonCard(
            name: person.name,
            role: person.role,
            avatarUrl: person.avatarUrl,
            tags: person.tags,
            matchLabel: person.matchLabel,
          );
        },
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
        initialChildSize: 0.68,
        minChildSize: 0.42,
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
              padding: EdgeInsets.fromLTRB(
                20,
                10,
                20,
                MediaQuery.of(context).padding.bottom + 20,
              ),
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
                const SizedBox(height: 22),
                Text(
                  title,
                  style: AppFonts.headingStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Persempit hasil dengan opsi yang paling relevan.',
                  style: AppFonts.interStyle(
                    fontSize: 13,
                    color: c.textSecondary,
                  ),
                ),
                if (tab.isPeople) ...[
                  const SizedBox(height: 14),
                  const _ProfileFilterPreview(),
                ],
                const SizedBox(height: 22),
                _FilterSheetContent(tab: tab),
                const SizedBox(height: 24),
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

  static void showProjectSheet(BuildContext context, Project project) {
    final c = AppC.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) {
        return _DetailSheetFrame(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Pill(
                    project.category,
                    AppColors.warning50,
                    AppColors.warning500,
                  ),
                  _Pill(project.faculty, AppColors.info50, AppColors.info600),
                  _Pill('FTIK', c.grey100, c.textSecondary),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                project.title,
                style: AppFonts.satoshiStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: c.textSecondary),
                  const SizedBox(width: 5),
                  Text(
                    'Deadline ${project.deadline}',
                    style: AppFonts.satoshiStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Rembugan adalah platform kolaborasi berbasis mobile untuk ekosistem kampus. Kami butuh Flutter dev berpengalaman state management dan seorang UI/UX designer.',
                style: AppFonts.satoshiStyle(
                  fontSize: 13,
                  height: 1.55,
                  color: c.textSecondary,
                ),
              ),
              const SizedBox(height: 22),
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
              const SizedBox(height: 14),
              Row(
                children: [
                  for (var i = 0; i < project.memberAvatars.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.md),
                      child: _TeamMember(
                        name: project.memberNames[i],
                        avatarUrl: project.memberAvatars[i],
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
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: _PrimaryAction(
                      label: 'Minta Bergabung',
                      onTap: () {
                        Navigator.of(context).pop();
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
  }

  static void showCompetitionSheet(
    BuildContext context,
    Competition competition,
    int index,
  ) {
    final c = AppC.of(context);
    final posterAsset = switch (index % 4) {
      0 => 'lib/assets/img/contoh poster1.jpeg',
      1 => 'lib/assets/img/contoh poster2.jpeg',
      2 => 'lib/assets/img/contoh poster3.jpeg',
      _ => 'lib/assets/img/contoh poster4.jpeg',
    };

    final String richCaption =
        '''
🚨 OPEN REGISTRATION! 🚨
🎉 ${competition.title.toUpperCase()}
📝 ${competition.category} Competition

Saatnya generasi muda bersuara lewat karya!
Tunjukkan ide terbaikmu tentang:
✨ Peran generasi muda di era digital✨

📌 Kategori:
✍️ Essay / Ideation
🎨 Poster / Design Product

📌 Benefit Peserta:
🏆 Juara 1, 2, 3 (Uang Pembinaan + Trophy + Sertifikat)
🎖️ Harapan 1, 2, 3 (Uang Pembinaan + Trophy + Sertifikat)
📄 E-sertifikat untuk 10 Finalis Karya Terbaik
📜 E-sertifikat nasional untuk semua peserta aktif

⚠️ KUOTA TERBATAS!
Sistem pendaftaran akan ditutup seketika jika kuota terpenuhi.

📅 Deadline: ${competition.deadline}

🔥 Jangan tunggu “nanti”
Karena nanti = sudah ditutup

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
                    onTap: () =>
                        _showImageViewer(context, assetPath: posterAsset),
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
                        child: Image.asset(posterAsset, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

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
                  const SizedBox(height: 28),

                  // 5. actions
                  Row(
                    children: [
                      Expanded(
                        child: _OutlineAction(
                          label: 'Tutup',
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 2,
                        child: _PrimaryAction(
                          label: 'Daftar Lomba',
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
    await Clipboard.setData(ClipboardData(text: competition.registrationLink));
    Get.back<void>();
    Get.snackbar(
      'Link pendaftaran siap',
      competition.registrationLink,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
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
                  padding: const EdgeInsets.only(left: 11, right: 8),
                  child: Icon(Icons.search, color: c.grey900, size: 19),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 39,
                  minHeight: 0,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 9,
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
            selectedSort: controller.selectedSort.value,
            onSortChanged: (sort) => controller.selectedSort.value = sort,
          ),
          const SizedBox(height: 12),
          _FilterSelectField(
            label: 'Jurusan',
            value: controller.selectedFaculty.value,
            icon: Icons.school_outlined,
            options: const [
              'Semua jurusan',
              'Teknik Informatika',
              'Sistem Informasi',
              'DKV',
              'Manajemen',
            ],
            onChanged: (val) => controller.selectedFaculty.value = val,
          ),
          const SizedBox(height: 12),
          _FilterSelectField(
            label: isPeople ? 'Skill' : 'Kategori',
            value: isPeople
                ? controller.selectedSkill.value
                : controller.selectedCategory.value,
            icon: isPeople ? Icons.code : FluentIcons.tag_24_regular,
            options: isPeople
                ? const ['Semua skill', 'Flutter', 'UI/UX', 'Firebase', 'React']
                : isLomba
                ? const [
                    'Semua kategori',
                    'Hackathon',
                    'UI/UX',
                    'Bisnis',
                    'Data',
                  ]
                : const [
                    'Semua kategori',
                    'Mobile App',
                    'Web App',
                    'UI/UX',
                    'Riset',
                  ],
            onChanged: (val) {
              if (isPeople) {
                controller.selectedSkill.value = val;
              } else {
                controller.selectedCategory.value = val;
              }
            },
          ),
          const SizedBox(height: 12),
          _FilterSelectField(
            label: isPeople
                ? 'Ketersediaan'
                : isLomba
                ? 'Deadline pendaftaran'
                : 'Slot tersisa',
            value: isPeople
                ? controller.selectedAvailability.value
                : isLomba
                ? controller.selectedDeadline.value
                : controller.selectedSlot.value,
            icon: isPeople
                ? FluentIcons.people_24_regular
                : isLomba
                ? Icons.calendar_today_outlined
                : FluentIcons.people_24_regular,
            options: isPeople
                ? const [
                    'Terbuka kolaborasi',
                    'Aktif minggu ini',
                    'Ada portfolio',
                  ]
                : isLomba
                ? const [
                    'Semua deadline',
                    '< 1 minggu',
                    '1 minggu',
                    '2 minggu',
                    'Bulan ini',
                  ]
                : const ['Semua slot', '1 slot', '2 slot', '3+ slot'],
            onChanged: (val) {
              if (isPeople) {
                controller.selectedAvailability.value = val;
              } else if (isLomba) {
                controller.selectedDeadline.value = val;
              } else {
                controller.selectedSlot.value = val;
              }
            },
          ),
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
  });

  final bool isPeople;
  final String selectedSort;
  final ValueChanged<String> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final option2 = isPeople ? 'Terpopuler' : 'Terbaru';
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
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => onSortChanged(option2),
              child: _SortOption(
                label: option2,
                icon: isPeople
                    ? Icons.trending_up
                    : FluentIcons.clock_24_regular,
                selected: selectedSort == option2,
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
      height: 45,
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
          const SizedBox(width: 7),
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
              const SizedBox(width: 10),
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
            const SizedBox(height: 18),
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
            const SizedBox(height: 10),
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
          const SizedBox(height: 9),
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
          const CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage('lib/assets/img/avatar.png'),
          ),
          const SizedBox(width: 10),
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
                const SizedBox(height: 3),
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
              color: active ? c.textPrimary : c.grey400,
            ),
          ),
        ),
      ),
    );
  }
}

class _CompleteProfileBanner extends StatelessWidget {
  const _CompleteProfileBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 17),
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
                const SizedBox(height: 6),
                Text(
                  'Tambahkan skill dan minatmu untuk mendapatkan rekomendasi yang lebih relevan.',
                  style: AppFonts.satoshiStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.white.withValues(alpha: 0.84),
                    height: 1.28,
                  ),
                ),
                const SizedBox(height: 15),
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
                    const SizedBox(width: 7),
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

    return GestureDetector(
      onTap: onDetail,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: c.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    project.faculty.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.satoshiStyle(
                      fontSize: 12,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      color: AppColors.info700,
                    ),
                  ),
                ),
                const _MatchBadge(label: 'Sesuai skill'),
              ],
            ),
            const SizedBox(height: 15),
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
            const SizedBox(height: 10),
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
            const SizedBox(height: 16),
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
            const SizedBox(height: 18),
            Row(
              children: [
                _ProjectAvatarStack(count: project.memberAvatars.length),
                const SizedBox(width: 10),
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
                child: const CircleAvatar(
                  radius: 10,
                  backgroundImage: AssetImage('lib/assets/img/avatar.png'),
                ),
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
    // Select from our beautiful local competition posters
    final posterAsset = switch (index % 4) {
      0 => 'lib/assets/img/contoh poster1.jpeg',
      1 => 'lib/assets/img/contoh poster2.jpeg',
      2 => 'lib/assets/img/contoh poster3.jpeg',
      _ => 'lib/assets/img/contoh poster4.jpeg',
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: c.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: SizedBox(
                width: double.infinity,
                child: Image.asset(posterAsset, fit: BoxFit.cover),
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
                    const SizedBox(height: 5),
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
                        color: c.grey400,
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
                    ),
                  ],
                ),
              ),
            ),
          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: style.background),
      ),
      child: Text(
        label,
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
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
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
      margin: const EdgeInsets.only(top: 42),
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
              height: 5,
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
        vertical: 7,
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
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        label,
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
  const _TeamMember({required this.name, required this.avatarUrl});

  final String name;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: const AssetImage('lib/assets/img/avatar.png'),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: AppFonts.satoshiStyle(
            fontSize: 10,
            color: c.textSecondary,
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
          child: Icon(Icons.add, size: 18, color: c.borderStrong),
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

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: const AssetImage('lib/assets/img/avatar.png'),
          ),
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
                  style: AppFonts.satoshiStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
                Text(
                  '${project.posterRole} - FTIK',
                  style: AppFonts.satoshiStyle(
                    fontSize: 10,
                    color: c.textSecondary,
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
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary500,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
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
    );
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.tags,
    required this.matchLabel,
  });

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
        onTap: () => Get.toNamed(Routes.OTHER_PROFILE),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: c.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: const AssetImage('lib/assets/img/avatar.png'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MatchBadge(label: matchLabel),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      style: AppFonts.satoshiStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                    ),
                    Text(
                      role,
                      style: AppFonts.satoshiStyle(
                        fontSize: 11,
                        color: c.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: tags
                          .map(
                            (tag) =>
                                _MiniChip(label: tag, color: c.grey50),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.send_outlined,
                size: 20,
                color: c.textSecondary,
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
                icon: const Icon(Icons.close, color: AppColors.white),
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
                      : Image.network(imageUrl!, fit: BoxFit.contain),
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
                  isUrgent ? Icons.local_fire_department : Icons.alarm_outlined,
                  color: primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
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
                    const SizedBox(height: 2),
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
                  vertical: 5,
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
          const SizedBox(height: 6),
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
