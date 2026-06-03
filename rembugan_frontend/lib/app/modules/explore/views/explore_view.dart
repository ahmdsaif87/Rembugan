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

  static const _ink = Color(0xFF111827);
  static const _muted = Color(0xFF8A9099);
  static const _chip = Color(0xFFF5F7FA);
  static const _line = Color(0xFFE7EAF0);
  static const _brand = Color(0xFF111111);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppLayeredBackground(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  children: [
                    Obx(
                      () => _SearchBar(
                        hint: controller.activeTab.value.isCompetition
                            ? 'Cari lomba'
                            : controller.activeTab.value.isPeople
                            ? 'Cari orang'
                            : 'Cari proyek',
                        onFilter: () => _showFilterSheet(
                          context,
                          controller.activeTab.value,
                        ),
                        onChanged: controller.search,
                        controller: controller.searchTextController,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Obx(
                      () => Row(
                        children: [
                          _SegmentButton(
                            icon: FluentIcons.briefcase_24_regular,
                            label: 'Proyek',
                            active: controller.activeTab.value.isProject,
                            onTap: () =>
                                controller.changeTab(ExploreTab.project),
                          ),
                          const SizedBox(width: 8),
                          _SegmentButton(
                            icon: FluentIcons.trophy_24_regular,
                            label: 'Lomba',
                            active: controller.activeTab.value.isCompetition,
                            onTap: () =>
                                controller.changeTab(ExploreTab.competition),
                          ),
                          const SizedBox(width: 8),
                          _SegmentButton(
                            icon: Icons.people_outline,
                            label: 'Orang',
                            active: controller.activeTab.value.isPeople,
                            onTap: () =>
                                controller.changeTab(ExploreTab.people),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: const Color(0xFFF6F8FA),
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
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(
        current: AppNavDestination.explore,
      ),
    );
  }

  Widget _buildProyekTab(BuildContext context) {
    return Obx(() => ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      itemCount: controller.filteredProjects.length + 1,
      separatorBuilder: (_, index) =>
          index == 0 ? const SizedBox(height: 14) : const SizedBox(height: 18),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: _SectionHeader(
              title: 'Proyek terbuka',
              trailing: '${controller.filteredProjects.length} hasil',
            ),
          );
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
    ));
  }

  Widget _buildLombaTab(BuildContext context) {
    return Obx(() => CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
          sliver: SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'Kompetisi aktif',
              trailing: '${controller.filteredCompetitions.length} hasil',
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
          sliver: SliverGrid.builder(
            itemCount: controller.filteredCompetitions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 16,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final competition = controller.filteredCompetitions[index];
              return _CompetitionCard(
                competition: competition,
                index: index,
                onTap: () => ExploreView.showCompetitionSheet(context, competition, index),
              );
            },
          ),
        ),
      ],
    ));
  }

  Widget _buildOrangTab() {
    return Obx(() => ListView.separated(
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
    ));
  }

  void _showFilterSheet(BuildContext context, ExploreTab tab) {
    final title = tab.isCompetition
        ? 'Filter lomba'
        : tab.isPeople
        ? 'Filter orang'
        : 'Filter proyek';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.68,
        minChildSize: 0.42,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(top: BorderSide(color: AppColors.border)),
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
                      color: AppColors.borderStrong,
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
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Persempit hasil dengan opsi yang paling relevan.',
                  style: AppFonts.interStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
                    const Color(0xFFFFF1E7),
                    const Color(0xFFFF6B2C),
                  ),
                  _Pill(
                    project.faculty,
                    const Color(0xFFEAF2FF),
                    AppColors.info600,
                  ),
                  _Pill('FTIK', const Color(0xFFF3F4F6), _muted),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                project.title,
                style: AppFonts.satoshiStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: _muted),
                  const SizedBox(width: 5),
                  Text(
                    'Deadline ${project.deadline}',
                    style: AppFonts.satoshiStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _muted,
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
                  color: const Color(0xFF666D78),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Skill Dibutuhkan',
                style: AppFonts.satoshiStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: project.skills
                    .map(
                      (skill) => _Pill(skill, _chip, const Color(0xFF64748B)),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              Text(
                'Anggota Tim',
                style: AppFonts.satoshiStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (var i = 0; i < project.memberAvatars.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _TeamMember(
                        name: project.memberNames[i],
                        avatarUrl: project.memberAvatars[i],
                      ),
                    ),
                  for (var i = 0; i < project.openSlots; i++)
                    const Padding(
                      padding: EdgeInsets.only(right: 16),
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

  static void showCompetitionSheet(BuildContext context, Competition competition, int index) {
    final posterAsset = switch (index % 4) {
      0 => 'lib/assets/img/contoh poster1.jpeg',
      1 => 'lib/assets/img/contoh poster2.jpeg',
      2 => 'lib/assets/img/contoh poster3.jpeg',
      _ => 'lib/assets/img/contoh poster4.jpeg',
    };

    final String richCaption = '''
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
      backgroundColor: Colors.transparent,
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
                    onTap: () => _showImageViewer(context, assetPath: posterAsset),
                    child: Container(
                      height: 320,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          posterAsset,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  
                  // 2. badge & organizer tag
                  _Pill(
                    competition.category,
                    const Color(0xFFEAF2FF),
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
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    'Diselenggarakan oleh: ${competition.organizer}',
                    style: AppFonts.satoshiStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
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
                  const Divider(color: AppColors.border, height: 1),
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
                          color: const Color(0xFF374151),
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
                            isExpanded ? 'Lihat lebih sedikit' : 'Lihat selengkapnya',
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
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppFonts.satoshiStyle(
                fontSize: 13.5,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppFonts.satoshiStyle(
                  fontSize: 13.5,
                  color: ExploreView._muted,
                  fontWeight: FontWeight.w500,
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Icon(
                    Icons.search,
                    color: ExploreView._muted,
                    size: 20,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 0,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: onFilter,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.tune, size: 19, color: ExploreView._muted),
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
                ? const ['Semua kategori', 'Hackathon', 'UI/UX', 'Bisnis', 'Data']
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
                ? const ['Semua deadline', '< 1 minggu', '1 minggu', '2 minggu', 'Bulan ini']
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
                selected: selectedSort == 'Paling relevan' || selectedSort.isEmpty,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => onSortChanged(option2),
              child: _SortOption(
                label: option2,
                icon: isPeople ? Icons.trending_up : FluentIcons.clock_24_regular,
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
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: selected ? AppColors.textPrimary : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? AppColors.textPrimary : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 15,
            color: selected ? Colors.white : AppColors.textSecondary,
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
                color: selected ? Colors.white : AppColors.textSecondary,
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
    return _FilterPanel(
      label: label,
      child: InkWell(
        onTap: () => _showOptions(context),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textTertiary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.satoshiStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                FluentIcons.chevron_down_24_regular,
                size: 16,
                color: AppColors.textTertiary,
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
      backgroundColor: Colors.transparent,
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: AppColors.borderStrong,
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
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              autofocus: true,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Cari ${widget.title.toLowerCase()}',
                prefixIcon: const Icon(
                  FluentIcons.search_24_regular,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.border),
                itemBuilder: (context, index) {
                  final option = filtered[index];
                  final selected = option == widget.value;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      option,
                      style: AppFonts.satoshiStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    trailing: selected
                        ? const Icon(
                            FluentIcons.checkmark_24_filled,
                            size: 18,
                            color: AppColors.textPrimary,
                          )
                        : null,
                    onTap: () {
                      if (widget.onChanged != null) {
                        widget.onChanged!(option);
                      }
                      Navigator.of(context).pop();
                    },
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppFonts.satoshiStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
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
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Filter membantu menemukan calon kolaborator yang relevan.',
                  style: AppFonts.satoshiStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
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
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 40,
          decoration: BoxDecoration(
            color: active ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? Colors.black : ExploreView._line,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: active ? Colors.white : ExploreView._muted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppFonts.satoshiStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
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
                color: ExploreView._ink,
                height: 1.1,
              ),
            ),
          ),
          Text(
            trailing,
            style: AppFonts.satoshiStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: const Color(0xFFDDE2EA), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onDetail,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _ProjectTag(
                            label: project.category,
                            background: const Color(0xFFFFF1E7),
                            foreground: const Color(0xFFFF6B2C),
                          ),
                          _ProjectTag(
                            label: project.faculty.replaceAll(
                              'Teknik Informatika',
                              'TI',
                            ),
                            background: const Color(0xFFEAF2FF),
                            foreground: AppColors.info600,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.bookmark_border,
                      size: 20,
                      color: Color(0xFFB8BFC9),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  project.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.satoshiStyle(
                    fontSize: 18,
                    height: 1.18,
                    fontWeight: FontWeight.w600,
                    color: ExploreView._ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Aplikasi mobile untuk mempertemukan mahasiswa yang ingin berkolaborasi dalam proyek teknologi, riset, maupun startup.',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.satoshiStyle(
                    fontSize: 12,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                _MatchBadge(label: matchLabel),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: project.skills
                      .map(
                        (skill) => _MiniChip(
                          label: skill,
                          color: AppColors.background,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.people,
                      size: 15,
                      color: Color(0xFF4B5563),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${project.filledSlots} bergabung',
                      style: AppFonts.satoshiStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${project.filledSlots}/${project.totalSlots} kuota)',
                      style: AppFonts.satoshiStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: project.openSlots <= 2
                            ? const Color(0xFFFEF2F2)
                            : const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: project.openSlots <= 2
                              ? const Color(0xFFFEE2E2)
                              : const Color(0xFFDCFCE7),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        '${project.openSlots} slot tersisa',
                        style: AppFonts.satoshiStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: project.openSlots <= 2
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 68,
                      height: 28,
                      child: Stack(
                        children: [
                          for (
                            var i = 0;
                            i < project.memberAvatars.length;
                            i++
                          )
                            Positioned(
                              left: i * 19,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 13,
                                  backgroundImage: const AssetImage(
                                    'lib/assets/img/avatar.png',
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            left: project.memberAvatars.length * 22,
                            child: const CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.surfaceSecondary,
                              child: Icon(
                                Icons.add,
                                size: 14,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      project.postedAgo,
                      style: AppFonts.satoshiStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.schedule,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      project.deadline,
                      style: AppFonts.satoshiStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectTag extends StatelessWidget {
  const _ProjectTag({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppFonts.satoshiStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: const Color(0xFFDDE2EA), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      posterAsset,
                      fit: BoxFit.cover,
                    ),
                    // Elegant dark overlay to guarantee badge readability
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.2),
                            Colors.black.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _Badge(label: index == 0 ? 'Paling cocok' : 'Sesuai jurusan'),
                    ),
                    if (competition.daysLeft != null)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: _DeadlineBadge(daysLeft: competition.daysLeft!),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            _TinyTag(label: competition.category),
            const SizedBox(height: 4),
            Text(
              competition.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.satoshiStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: ExploreView._ink,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              competition.organizer,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.satoshiStyle(
                fontSize: 9,
                color: ExploreView._muted,
              ),
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 11,
                  color: (competition.daysLeft != null && competition.daysLeft! <= 5) ? AppColors.danger : ExploreView._muted,
                ),
                const SizedBox(width: 4),
                Text(
                  competition.deadline,
                  style: AppFonts.satoshiStyle(
                    fontSize: 9,
                    color: (competition.daysLeft != null && competition.daysLeft! <= 5) ? AppColors.danger : ExploreView._muted,
                  ),
                ),
                if (competition.daysLeft != null && competition.daysLeft! > 0) ...[
                  const Spacer(),
                  Icon(
                    Icons.local_fire_department,
                    size: 11.5,
                    color: (competition.daysLeft! <= 5) ? const Color(0xFFEF4444) : (competition.daysLeft! <= 10 ? const Color(0xFFF59E0B) : const Color(0xFF10B981)),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${competition.daysLeft} hari lagi',
                    style: AppFonts.satoshiStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: (competition.daysLeft! <= 5) ? const Color(0xFFEF4444) : (competition.daysLeft! <= 10 ? const Color(0xFFF59E0B) : const Color(0xFF10B981)),
                    ),
                  ),
                ]
              ],
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
        background: AppColors.success50,
        border: AppColors.success100,
        foreground: AppColors.success700,
        icon: Icons.check_circle_outline,
      );
    }
    if (value.contains('ditutup') || value.contains('deadline')) {
      return const _StatusTone(
        background: AppColors.warning50,
        border: AppColors.warning100,
        foreground: AppColors.warning700,
        icon: Icons.schedule,
      );
    }
    if (value.contains('penuh')) {
      return const _StatusTone(
        background: AppColors.danger50,
        border: AppColors.danger100,
        foreground: AppColors.danger600,
        icon: Icons.block,
      );
    }
    if (value.contains('trending')) {
      return const _StatusTone(
        background: AppColors.info50,
        border: AppColors.info100,
        foreground: AppColors.info600,
        icon: Icons.trending_up,
      );
    }
    if (value.contains('baru')) {
      return const _StatusTone(
        background: Color(0xFFF5F3FF),
        border: Color(0xFFF5F3FF),
        foreground: Color(0xFF8B5CF6),
        icon: Icons.auto_awesome,
      );
    }
    return const _StatusTone(
      background: AppColors.background,
      border: AppColors.border,
      foreground: AppColors.textSecondary,
      icon: Icons.info_outline,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = tone;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: style.background),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 12, color: style.foreground),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppFonts.satoshiStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: style.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTone {
  const _StatusTone({
    required this.background,
    required this.border,
    required this.foreground,
    required this.icon,
  });

  final Color background;
  final Color border;
  final Color foreground;
  final IconData icon;
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 9, color: AppColors.warning),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppFonts.satoshiStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TinyTag extends StatelessWidget {
  const _TinyTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppFonts.satoshiStyle(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: AppColors.textTertiary,
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
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 42),
      padding: EdgeInsets.fromLTRB(
        28,
        10,
        28,
        MediaQuery.of(context).padding.bottom + 22,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(999),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppFonts.satoshiStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
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
            color: AppColors.textSecondary,
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
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.borderStrong,
              style: BorderStyle.solid,
            ),
          ),
          child: const Icon(Icons.add, size: 18, color: AppColors.borderStrong),
        ),
        const SizedBox(height: 6),
        Text(
          'Terbuka',
          style: AppFonts.satoshiStyle(
            fontSize: 10,
            color: AppColors.textTertiary,
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ExploreView._line),
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
                    color: ExploreView._muted,
                  ),
                ),
                Text(
                  project.postedBy,
                  style: AppFonts.satoshiStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ExploreView._ink,
                  ),
                ),
                Text(
                  '${project.posterRole} - FTIK',
                  style: AppFonts.satoshiStyle(
                    fontSize: 10,
                    color: ExploreView._muted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.border),
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
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: AppFonts.satoshiStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: Colors.white,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: AppFonts.satoshiStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.toNamed(Routes.OTHER_PROFILE),
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFDDE2EA), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
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
                        color: ExploreView._ink,
                      ),
                    ),
                    Text(
                      role,
                      style: AppFonts.satoshiStyle(
                        fontSize: 11,
                        color: ExploreView._muted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: tags
                          .map(
                            (tag) =>
                                _MiniChip(label: tag, color: ExploreView._chip),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.send_outlined,
                size: 20,
                color: ExploreView._muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showImageViewer(BuildContext context, {String? assetPath, String? imageUrl}) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (context) => GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                color: Colors.black.withValues(alpha: 0.4),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Material(
              color: Colors.white.withValues(alpha: 0.15),
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Center(
            child: InteractiveViewer(
              clipBehavior: Clip.none,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
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

class _DeadlineBadge extends StatelessWidget {
  const _DeadlineBadge({required this.daysLeft});

  final int daysLeft;

  @override
  Widget build(BuildContext context) {
    if (daysLeft < 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Ditutup',
          style: AppFonts.satoshiStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }
    
    final isUrgent = daysLeft <= 5;
    final isWarning = daysLeft <= 10;
    
    final Color bg = isUrgent
        ? const Color(0xFFEF4444)
        : isWarning
            ? const Color(0xFFF59E0B)
            : const Color(0xFF10B981);
            
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: bg.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUrgent ? Icons.local_fire_department : Icons.schedule,
            size: 9.5,
            color: Colors.white,
          ),
          const SizedBox(width: 2.5),
          Text(
            isUrgent ? '$daysLeft hari lagi!' : '$daysLeft hari lagi',
            style: AppFonts.satoshiStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompetitionTimelineBox extends StatelessWidget {
  const _CompetitionTimelineBox({required this.daysLeft, required this.deadline});

  final int daysLeft;
  final String deadline;

  @override
  Widget build(BuildContext context) {
    final isUrgent = daysLeft <= 5;
    final isWarning = daysLeft <= 10;
    
    final Color primaryColor = isUrgent
        ? const Color(0xFFEF4444)
        : isWarning
            ? const Color(0xFFF59E0B)
            : AppColors.primary;
            
    final Color bgColor = isUrgent
        ? const Color(0xFFFEF2F2)
        : isWarning
            ? const Color(0xFFFFFBEB)
            : const Color(0xFFF0F9FF);

    final Color borderColor = isUrgent
        ? const Color(0xFFFEE2E2)
        : isWarning
            ? const Color(0xFFFEF3C7)
            : const Color(0xFFE0F2FE);

    final double progress = daysLeft <= 0 ? 1.0 : (30 - daysLeft).clamp(0, 30) / 30.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
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
                        color: isUrgent ? const Color(0xFF991B1B) : const Color(0xFF0369A1),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Batas akhir: $deadline',
                      style: AppFonts.satoshiStyle(
                        fontSize: 10.5,
                        color: isUrgent ? const Color(0xFFB91C1C) : const Color(0xFF0284C7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  daysLeft <= 0 ? 'Ditutup' : '$daysLeft Hari Lagi',
                  style: AppFonts.satoshiStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
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
                  color: AppColors.textTertiary,
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
                  color: isUrgent ? const Color(0xFFEF4444) : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
