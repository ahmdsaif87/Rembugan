import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_chrome.dart';
import 'social_components.dart';

class CreatePostView extends StatefulWidget {
  const CreatePostView({super.key});

  @override
  State<CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  bool _isOffer = false;
  String? _selectedMajor;
  final _skills = ['Flutter', 'UI/UX'];
  static const _majors = [
    'Teknik Informatika',
    'Sistem Informasi',
    'Teknik Komputer',
    'Teknik Elektro',
    'Teknik Industri',
    'Desain Komunikasi Visual',
    'Manajemen',
    'Akuntansi',
    'Ilmu Komunikasi',
    'Psikologi',
    'Pendidikan Bahasa Inggris',
    'Hukum',
  ];
  static const _skillOptions = [
    'Flutter',
    'Dart',
    'Firebase',
    'UI/UX',
    'Figma',
    'React',
    'Node.js',
    'Python',
    'Laravel',
    'REST API',
    'Copywriting',
    'Research',
  ];

  @override
  Widget build(BuildContext context) {
    return SocialScaffold(
      title: _isOffer ? 'Buat Tawaran' : 'Buat Postingan',
      // subtitle: _isOffer
      //     ? 'Buka peluang kolaborasi dengan konteks yang jelas'
      //     : 'Bagikan ide kolaborasi dengan jelas',
      actions: [
        TextButton(
          onPressed: Get.back,
          style: TextButton.styleFrom(
            backgroundColor: AppColors.primary500,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          child: Text(
            'Post',
            style: AppFonts.satoshiStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppSurface(
            shadow: const [],
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundImage: AssetImage('lib/assets/img/avatar.png'),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dede Fernanda',
                          style: AppFonts.satoshiStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Publik',
                          style: AppFonts.satoshiStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _CreateTypeOption(
                        icon: FluentIcons.compose_24_regular,
                        title: 'Postingan',
                        subtitle: 'Update, cerita, diskusi',
                        active: !_isOffer,
                        onTap: () => setState(() => _isOffer = false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _CreateTypeOption(
                        icon: FluentIcons.briefcase_24_regular,
                        title: 'Tawaran',
                        subtitle: 'Cari anggota/proyek',
                        active: _isOffer,
                        onTap: () => setState(() => _isOffer = true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_isOffer) ...[
                  const _FieldLabel('Nama proyek'),
                  const SizedBox(height: 8),
                  const _AppInput(
                    hintText: 'Contoh: Mentoring Kampus App',
                    icon: FluentIcons.briefcase_24_regular,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _LabeledPicker(
                          label: 'Jurusan',
                          value: _selectedMajor,
                          hintText: 'Pilih jurusan',
                          icon: FluentIcons.hat_graduation_24_regular,
                          onTap: _showMajorPicker,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: _LabeledInput(
                          label: 'Kategori',
                          hintText: 'Mobile App',
                          icon: FluentIcons.tag_24_regular,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const _FieldLabel('Deskripsi proyek'),
                  const SizedBox(height: 8),
                  const _AppInput(
                    hintText:
                        'Ceritakan tujuan proyek, progress saat ini, dan tipe kolaborator yang kamu cari.',
                    icon: FluentIcons.text_description_24_regular,
                    minLines: 5,
                    maxLines: 8,
                  ),
                  const SizedBox(height: 14),
                  const _FieldLabel('Skill yang dibutuhkan'),
                  const SizedBox(height: 8),
                  _SkillInput(
                    skills: _skills,
                    onAdd: _showSkillPicker,
                    onRemove: (skill) => setState(() => _skills.remove(skill)),
                  ),
                  const SizedBox(height: 14),
                  const _FieldLabel('Slot tersisa'),
                  const SizedBox(height: 8),
                  const _AppInput(
                    hintText: 'Contoh: 2',
                    icon: FluentIcons.people_24_regular,
                    keyboardType: TextInputType.number,
                  ),
                ] else ...[
                  TextField(
                    minLines: 8,
                    maxLines: 12,
                    decoration: InputDecoration(
                      hintText:
                          'Tulis update, cari anggota tim, atau bagikan progres...',
                      fillColor: AppColors.background,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppTextPill(
                label: 'Tambah gambar',
                icon: FluentIcons.image_24_regular,
              ),
              if (_isOffer)
                const AppTextPill(
                  label: 'Skill dibutuhkan',
                  icon: FluentIcons.people_24_regular,
                )
              else
                const AppTextPill(
                  label: 'Tandai proyek',
                  icon: FluentIcons.briefcase_24_regular,
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMajorPicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => _MajorPickerSheet(
        majors: _majors,
        selectedMajor: _selectedMajor,
        onSelected: (major) {
          setState(() => _selectedMajor = major);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showSkillPicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => _SearchablePickerSheet(
        title: 'Tambah skill',
        searchHint: 'Cari skill',
        options: _skillOptions,
        selectedOptions: _skills,
        onSelected: (skill) {
          if (!_skills.contains(skill)) {
            setState(() => _skills.add(skill));
          }
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppFonts.satoshiStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _LabeledInput extends StatelessWidget {
  const _LabeledInput({
    required this.label,
    required this.hintText,
    required this.icon,
  });

  final String label;
  final String hintText;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 8),
        _AppInput(hintText: hintText, icon: icon),
      ],
    );
  }
}

class _LabeledPicker extends StatelessWidget {
  const _LabeledPicker({
    required this.label,
    required this.hintText,
    required this.icon,
    required this.onTap,
    this.value,
  });

  final String label;
  final String hintText;
  final IconData icon;
  final VoidCallback onTap;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.textTertiary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value ?? hintText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.satoshiStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: value == null
                          ? AppColors.textTertiary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  FluentIcons.chevron_down_24_regular,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MajorPickerSheet extends StatefulWidget {
  const _MajorPickerSheet({
    required this.majors,
    required this.selectedMajor,
    required this.onSelected,
  });

  final List<String> majors;
  final String? selectedMajor;
  final ValueChanged<String> onSelected;

  @override
  State<_MajorPickerSheet> createState() => _MajorPickerSheetState();
}

class _MajorPickerSheetState extends State<_MajorPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.majors
        .where((major) => major.toLowerCase().contains(_query.toLowerCase()))
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
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
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
                  color: AppColors.borderStrong,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Pilih jurusan',
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
                hintText: 'Cari jurusan',
                prefixIcon: Icon(
                  FluentIcons.search_24_regular,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: AppColors.border.withValues(alpha: 0.4)),
                itemBuilder: (context, index) {
                  final major = filtered[index];
                  final selected = major == widget.selectedMajor;

                  return InkWell(
                    onTap: () => widget.onSelected(major),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              major,
                              style: AppFonts.satoshiStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
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

class _AppInput extends StatelessWidget {
  const _AppInput({
    required this.hintText,
    required this.icon,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
  });

  final String hintText;
  final IconData icon;
  final int minLines;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppFonts.satoshiStyle(fontSize: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        fillColor: AppColors.background,
        prefixIcon: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.sm,
            top: maxLines > 1 ? 14 : 0,
          ),
          child: Icon(icon, size: 18, color: AppColors.textTertiary),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
      ),
    );
  }
}

class _SkillInput extends StatelessWidget {
  const _SkillInput({
    required this.skills,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> skills;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        spacing: 7,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ...skills.map(
            (skill) =>
                _SkillDraftChip(label: skill, onRemove: () => onRemove(skill)),
          ),
          InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FluentIcons.add_24_regular,
                    size: 13,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Tambah skill',
                    style: AppFonts.satoshiStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillDraftChip extends StatelessWidget {
  const _SkillDraftChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppFonts.satoshiStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              FluentIcons.dismiss_24_regular,
              size: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchablePickerSheet extends StatefulWidget {
  const _SearchablePickerSheet({
    required this.title,
    required this.searchHint,
    required this.options,
    required this.selectedOptions,
    required this.onSelected,
  });

  final String title;
  final String searchHint;
  final List<String> options;
  final List<String> selectedOptions;
  final ValueChanged<String> onSelected;

  @override
  State<_SearchablePickerSheet> createState() => _SearchablePickerSheetState();
}

class _SearchablePickerSheetState extends State<_SearchablePickerSheet> {
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
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
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
                hintText: widget.searchHint,
                prefixIcon: Icon(
                  FluentIcons.search_24_regular,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: AppColors.border.withValues(alpha: 0.4)),
                itemBuilder: (context, index) {
                  final option = filtered[index];
                  final selected = widget.selectedOptions.contains(option);

                  return InkWell(
                    onTap: () => widget.onSelected(option),
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
                                color: AppColors.textPrimary,
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

class _CreateTypeOption extends StatelessWidget {
  const _CreateTypeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: active ? AppColors.grey100 : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: active ? AppColors.primary500 : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20,
              color: active ? AppColors.primary500 : AppColors.textSecondary,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppFonts.interStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.interStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
