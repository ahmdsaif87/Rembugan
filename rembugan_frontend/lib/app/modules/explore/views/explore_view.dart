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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
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
      ),
      bottomNavigationBar: const AppBottomNav(
        current: AppNavDestination.explore,
      ),
    );
  }

  Widget _buildProyekTab(BuildContext context) {
    return ListView.separated(
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
              trailing: '${controller.filteredProjects.length * 5} hasil',
            ),
          );
        }

        final project = controller.filteredProjects[index - 1];
        return _ProjectCard(
          project: project,
          matchLabel: index == 1
              ? 'Paling cocok untuk kamu'
              : 'Skill yang sama',
          onDetail: () => _showProjectSheet(context, project),
        );
      },
    );
  }

  Widget _buildLombaTab(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
          sliver: SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'Kompetisi aktif',
              trailing: '${controller.competitions.length * 4} hasil',
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
          sliver: SliverGrid.builder(
            itemCount: controller.competitions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 16,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final competition = controller.competitions[index];
              return _CompetitionCard(
                competition: competition,
                index: index,
                onTap: () => _showCompetitionSheet(context, competition),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrangTab() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      itemCount: 3,
      separatorBuilder: (_, index) => SizedBox(height: index == 0 ? 14 : 18),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const _SectionHeader(
            title: 'Orang Disekitar',
            trailing: '12 hasil',
          );
        }

        final people = [
          (
            'Dede Fernanda',
            'Flutter Developer',
            'https://i.pravatar.cc/100?img=60',
            ['Flutter', 'Figma'],
            'Skill yang sama',
          ),
          (
            'Raka Pratama',
            'UI/UX Designer',
            'https://i.pravatar.cc/100?img=47',
            ['Design', 'Research'],
            'Paling cocok untuk kamu',
          ),
        ];
        final person = people[index - 1];
        return _PersonCard(
          name: person.$1,
          role: person.$2,
          avatarUrl: person.$3,
          tags: person.$4,
          matchLabel: person.$5,
        );
      },
    );
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
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
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

  void _showProjectSheet(BuildContext context, Project project) {
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

  void _showCompetitionSheet(BuildContext context, Competition competition) {
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
              _Pill(
                competition.category,
                const Color(0xFFEAF2FF),
                AppColors.info600,
              ),
              const SizedBox(height: 18),
              Text(
                competition.title,
                style: AppFonts.satoshiStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.18,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                competition.caption,
                style: AppFonts.satoshiStyle(
                  fontSize: 13,
                  height: 1.55,
                  color: const Color(0xFF666D78),
                ),
              ),
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
                      label: 'Daftar Lomba',
                      onTap: () => _openRegistrationLink(competition),
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

  Future<void> _openRegistrationLink(Competition competition) async {
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
  const _SearchBar({required this.hint, required this.onFilter});

  final String hint;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: ExploreView._line),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const Icon(Icons.search, size: 18, color: ExploreView._muted),
                const SizedBox(width: 8),
                Text(
                  hint,
                  style: AppFonts.satoshiStyle(
                    fontSize: 13,
                    color: ExploreView._muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: onFilter,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: ExploreView._line),
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
    final isLomba = tab.isCompetition;
    final isPeople = tab.isPeople;

    return Column(
      children: [
        _SortSelector(isPeople: isPeople),
        const SizedBox(height: 12),
        _FilterSelectField(
          label: 'Jurusan',
          value: 'Semua jurusan',
          icon: Icons.school_outlined,
          options: const [
            'Semua jurusan',
            'Teknik Informatika',
            'Sistem Informasi',
            'DKV',
            'Manajemen',
          ],
        ),
        const SizedBox(height: 12),
        _FilterSelectField(
          label: isPeople ? 'Skill' : 'Kategori',
          value: isPeople
              ? 'Semua skill'
              : isLomba
              ? 'Semua kategori lomba'
              : 'Semua kategori proyek',
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
        ),
        const SizedBox(height: 12),
        _FilterSelectField(
          label: isPeople
              ? 'Ketersediaan'
              : isLomba
              ? 'Deadline pendaftaran'
              : 'Slot tersisa',
          value: isPeople
              ? 'Terbuka kolaborasi'
              : isLomba
              ? '1 minggu'
              : 'Semua slot',
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
              ? const ['< 1 minggu', '1 minggu', '2 minggu', 'Bulan ini']
              : const ['Semua slot', '1 slot', '2 slot', '3+ slot'],
        ),
      ],
    );
  }
}

class _SortSelector extends StatelessWidget {
  const _SortSelector({required this.isPeople});

  final bool isPeople;

  @override
  Widget build(BuildContext context) {
    return _FilterPanel(
      label: 'Urutan',
      child: Row(
        children: [
          const Expanded(
            child: _SortOption(
              label: 'Paling relevan',
              icon: FluentIcons.sparkle_24_filled,
              selected: true,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SortOption(
              label: isPeople ? 'Terpopuler' : 'Terbaru',
              icon: isPeople ? Icons.trending_up : FluentIcons.clock_24_regular,
              selected: false,
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
  });

  final String label;
  final String value;
  final IconData icon;
  final List<String> options;

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
      builder: (_) =>
          _SearchableFilterSheet(title: label, value: value, options: options),
    );
  }
}

class _SearchableFilterSheet extends StatefulWidget {
  const _SearchableFilterSheet({
    required this.title,
    required this.value,
    required this.options,
  });

  final String title;
  final String value;
  final List<String> options;

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
                    onTap: () => Navigator.of(context).pop(),
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

class _ProjectCard extends StatefulWidget {
  const _ProjectCard({
    required this.project,
    required this.matchLabel,
    required this.onDetail,
  });

  final Project project;
  final String matchLabel;
  final VoidCallback onDetail;

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _hasRequested = false;

  Color get _progressColor {
    if (widget.project.openSlots <= 1) return AppColors.warning;
    if (widget.project.filledSlots / widget.project.totalSlots >= 0.7) {
      return AppColors.success;
    }
    return const Color(0xFF4B5563);
  }

  void _confirmJoinRequest() {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.info50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.info100),
                ),
                child: const Icon(
                  FluentIcons.people_team_add_24_regular,
                  color: AppColors.info700,
                  size: 22,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Minta bergabung?',
                style: AppFonts.headingStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Permintaan kamu akan dikirim ke pemilik proyek "${widget.project.title}".',
                style: AppFonts.satoshiStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() => _hasRequested = true);
                        Get.snackbar(
                          'Permintaan terkirim',
                          'Kamu akan mendapat update saat diterima.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.success50,
                          colorText: AppColors.success800,
                          duration: const Duration(seconds: 3),
                        );
                      },
                      child: const Text('Kirim'),
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
          onTap: widget.onDetail,
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
                            label: widget.project.category,
                            background: const Color(0xFFFFF1E7),
                            foreground: const Color(0xFFFF6B2C),
                          ),
                          _ProjectTag(
                            label: widget.project.faculty.replaceAll(
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
                  widget.project.title,
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
                _MatchBadge(label: widget.matchLabel),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: widget.project.skills
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
                      '${widget.project.filledSlots} bergabung',
                      style: AppFonts.satoshiStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      '- ${widget.project.openSlots} slot terbuka',
                      style: AppFonts.satoshiStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ExploreView._brand,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        '${widget.project.filledSlots}/${widget.project.totalSlots} terisi',
                        style: AppFonts.satoshiStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: ExploreView._brand,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value:
                        widget.project.filledSlots / widget.project.totalSlots,
                    minHeight: 3,
                    color: _progressColor.withValues(alpha: 0.54),
                    backgroundColor: AppColors.surfaceSecondary,
                  ),
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
                            i < widget.project.memberAvatars.length;
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
                            left: widget.project.memberAvatars.length * 22,
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
                      widget.project.postedAgo,
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
                      widget.project.deadline,
                      style: AppFonts.satoshiStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _OutlineAction(
                        label: 'Lihat detail',
                        onTap: widget.onDetail,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _RequestJoinAction(
                        requested: _hasRequested,
                        onTap: _hasRequested ? null : _confirmJoinRequest,
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

class _RequestJoinAction extends StatelessWidget {
  const _RequestJoinAction({required this.requested, required this.onTap});

  final bool requested;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: requested ? AppColors.success50 : AppColors.primary,
          borderRadius: BorderRadius.circular(14),
          border: requested ? Border.all(color: AppColors.success100) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              requested
                  ? FluentIcons.checkmark_circle_24_filled
                  : FluentIcons.people_add_24_regular,
              size: 15,
              color: requested ? AppColors.success700 : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              requested ? 'Permintaan terkirim' : 'Minta Bergabung',
              style: AppFonts.satoshiStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: requested ? AppColors.success800 : Colors.white,
              ),
            ),
          ],
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
    final icon = switch (index % 5) {
      0 => Icons.verified_outlined,
      1 => Icons.card_giftcard,
      2 => Icons.desktop_windows_outlined,
      3 => Icons.image_outlined,
      _ => Icons.menu_book_outlined,
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
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(competition.color.start),
                      Color(competition.color.end),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _Badge(label: competition.badge),
                    ),
                    Center(child: Icon(icon, size: 34, color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 5,
              runSpacing: 4,
              children: [
                _TinyTag(label: index == 0 ? 'Paling cocok' : 'Sesuai jurusan'),
                Text(
                  competition.category,
                  style: AppFonts.satoshiStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                _TinyTag(label: competition.campusTag),
              ],
            ),
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
                  color: index == 3 ? AppColors.danger : ExploreView._muted,
                ),
                const SizedBox(width: 4),
                Text(
                  competition.deadline,
                  style: AppFonts.satoshiStyle(
                    fontSize: 9,
                    color: index == 3 ? AppColors.danger : ExploreView._muted,
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
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: AppFonts.satoshiStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
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
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ExploreView._line),
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
