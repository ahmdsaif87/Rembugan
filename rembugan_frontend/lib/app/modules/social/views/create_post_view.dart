import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/theme/theme.dart';
import 'social_components.dart';

class CreatePostView extends StatefulWidget {
  const CreatePostView({super.key});

  @override
  State<CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  bool _isOffer = false;
  bool _isLoading = false;
  String? _selectedMajor;
  String? _selectedCategory;
  final _skills = <String>[];
  final _images = <XFile>[];
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _skillTextController = TextEditingController();
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
  static const _categories = [
    'Mobile App',
    'Web App',
    'AI / ML',
    'UI / UX Design',
    'Backend API',
    'Data Science',
    'IoT / Hardware',
    'Game Development',
    'DevOps',
    'Research',
    'Content Creation',
    'Lainnya',
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final user = Get.find<AuthService>().currentUser.value;
    final userName = user?.fullName ?? 'Pengguna';
    return SocialScaffold(
      title: _isOffer ? 'Buat Tawaran' : 'Buat Postingan',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: c.grey200,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: AppFonts.satoshiStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: AppFonts.satoshiStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                        ),
                      ),
                      const SizedBox.shrink(),
                    ],
                  ),
                ),
                _TypeChip(
                  icon: FluentIcons.compose_24_regular,
                  label: 'Postingan',
                  active: !_isOffer,
                  onTap: () => setState(() => _isOffer = false),
                ),
                const SizedBox(width: 6),
                _TypeChip(
                  icon: FluentIcons.briefcase_24_regular,
                  label: 'Tawaran',
                  active: _isOffer,
                  onTap: () => setState(() => _isOffer = true),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: c.border.withValues(alpha: 0.4)),
          Expanded(
            child: Form(
              key: _formKey,
              child: _isOffer
                  ? ListView(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      children: [
                        _OfferFormContent(
                          selectedMajor: _selectedMajor,
                          selectedCategory: _selectedCategory,
                          skills: _skills,
                          onMajorTap: _showMajorPicker,
                          onCategoryTap: _showCategoryPicker,
                          onSkillAdd: _showSkillPicker,
                          onSkillRemove: (s) => setState(() => _skills.remove(s)),
                        ),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.md,
                      ),
                      children: [
                        TextFormField(
                          autofocus: true,
                          minLines: 6,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: 'Apa yang ingin kamu bagikan?',
                            hintStyle: AppFonts.satoshiStyle(
                              fontSize: 16,
                              color: c.textTertiary,
                              height: 1.5,
                            ),
                            filled: true,
                            fillColor: c.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(AppSpacing.md),
                          ),
                          style: AppFonts.satoshiStyle(
                            fontSize: 16,
                            color: c.textPrimary,
                            height: 1.5,
                          ),
                          validator: (v) =>
                              v?.trim().isEmpty == true ? 'Postingan tidak boleh kosong' : null,
                        ),
                      ],
                    ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              MediaQuery.of(context).padding.bottom + AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: c.surface,
              border: Border(
                top: BorderSide(color: c.border.withValues(alpha: 0.3)),
              ),
            ),
            child: Row(
              children: [
                if (!_isOffer) ...[
                  Material(
                    color: AppColors.transparent,
                    child: InkWell(
                      onTap: _showImagePicker,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: c.grey100,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Icon(
                          FluentIcons.image_24_regular,
                          size: 20,
                          color: AppColors.primary500,
                        ),
                      ),
                    ),
                  ),
                  if (_images.isNotEmpty) ...[
                    const SizedBox(width: AppSpacing.sm),
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: _images.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 6),
                        itemBuilder: (_, i) => Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              child: Image.file(
                                File(_images[i].path),
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => setState(() => _images.removeAt(i)),
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                    color: AppColors.error500,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    FluentIcons.dismiss_24_filled,
                                    size: 10,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
                const Spacer(),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handlePost,
                  child: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(
                          _isOffer ? 'Kirim Tawaran' : 'Posting',
                          style: AppFonts.satoshiStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    foregroundColor: AppColors.white,
                    disabledBackgroundColor: c.grey300,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ),
              ],
            ),
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

  void _showCategoryPicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => _MajorPickerSheet(
        title: 'Pilih kategori',
        majors: _categories,
        selectedMajor: _selectedCategory,
        onSelected: (category) {
          setState(() => _selectedCategory = category);
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
        skillTextController: _skillTextController,
        onSelected: (skill) {
          setState(() {
            if (_skills.contains(skill)) {
              _skills.remove(skill);
            } else {
              _skills.add(skill);
            }
          });
        },
      ),
    );
  }

  void _handlePost() {
    if (!_formKey.currentState!.validate()) return;
    if (_isOffer && _skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tambahkan minimal 1 skill yang dibutuhkan'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isOffer ? 'Tawaran berhasil dikirim' : 'Postingan berhasil diunggah'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        ),
      );
      Get.back();
    });
  }

  Future<void> _showImagePicker() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: AppC.of(context).surfaceElevated,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 42, height: 4,
                decoration: BoxDecoration(
                  color: AppC.of(context).borderStrong,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(FluentIcons.camera_24_regular),
              title: const Text('Ambil foto'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(FluentIcons.image_24_regular),
              title: const Text('Pilih dari galeri'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      setState(() => _images.add(picked));
    }
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Text(
      label,
      style: AppFonts.satoshiStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: c.textPrimary,
      ),
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
    final c = AppC.of(context);
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
              color: c.background,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: c.border),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: c.textTertiary),
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
                          ? c.textTertiary
                          : c.textPrimary,
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
      ],
    );
  }
}

class _MajorPickerSheet extends StatefulWidget {
  const _MajorPickerSheet({
    this.title = 'Pilih jurusan',
    required this.majors,
    required this.selectedMajor,
    required this.onSelected,
  });

  final String title;
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
    final c = AppC.of(context);
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
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
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
                hintText: 'Cari jurusan',
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
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: c.border.withValues(alpha: 0.4)),
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

class _AppInput extends StatelessWidget {
  const _AppInput({
    required this.hintText,
    required this.icon,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  final String hintText;
  final IconData icon;
  final int minLines;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return TextFormField(
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: AppFonts.satoshiStyle(fontSize: 13, color: c.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppFonts.satoshiStyle(
          fontSize: 13,
          color: c.textTertiary,
        ),
        filled: true,
        fillColor: c.background,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: maxLines > 1 ? 14 : 0,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.sm,
            top: maxLines > 1 ? 14 : 0,
          ),
          child: Icon(icon, size: 18, color: c.textTertiary),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(
            color: AppColors.primary500,
            width: 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.error500, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.error500, width: 1.2),
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
    final c = AppC.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.border),
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
                color: c.grey100,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: c.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FluentIcons.add_24_regular,
                    size: 13,
                    color: c.textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Tambah skill',
                    style: AppFonts.satoshiStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: c.textSecondary,
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
    final c = AppC.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: c.borderStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppFonts.satoshiStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(width: 6),
          Material(
            color: AppColors.transparent,
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  FluentIcons.dismiss_24_regular,
                  size: 12,
                  color: c.textTertiary,
                ),
              ),
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
    this.skillTextController,
  });

  final String title;
  final String searchHint;
  final List<String> options;
  final List<String> selectedOptions;
  final ValueChanged<String> onSelected;
  final TextEditingController? skillTextController;

  @override
  State<_SearchablePickerSheet> createState() => _SearchablePickerSheetState();
}

class _SearchablePickerSheetState extends State<_SearchablePickerSheet> {
  String _query = '';
  final _customSkillController = TextEditingController();

  @override
  void dispose() {
    _customSkillController.dispose();
    super.dispose();
  }

  void _addCustomSkill() {
    final text = _customSkillController.text.trim();
    if (text.isEmpty) return;
    widget.onSelected(text);
    _customSkillController.clear();
    setState(() => _query = '');
  }

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
          color: c.surfaceElevated,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: AppFonts.satoshiStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Selesai',
                    style: AppFonts.satoshiStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: TextField(
                      controller: _customSkillController,
                      decoration: InputDecoration(
                        hintText: 'Tambah skill custom',
                        hintStyle: AppFonts.satoshiStyle(
                          fontSize: 13,
                          color: c.textTertiary,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: c.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          borderSide: BorderSide(color: c.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          borderSide: BorderSide(color: c.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          borderSide: const BorderSide(
                            color: AppColors.primary500,
                            width: 1.2,
                          ),
                        ),
                      ),
                      style: AppFonts.satoshiStyle(
                        fontSize: 13,
                        color: c.textPrimary,
                      ),
                      onSubmitted: (_) => _addCustomSkill(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: AppColors.transparent,
                  child: InkWell(
                    onTap: _addCustomSkill,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary500,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(
                        FluentIcons.add_24_filled,
                        size: 18,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              autofocus: true,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: widget.searchHint,
                hintStyle: AppFonts.satoshiStyle(
                  fontSize: 13,
                  color: c.textTertiary,
                ),
                filled: true,
                fillColor: c.background,
                prefixIcon: Icon(
                  FluentIcons.search_24_regular,
                  size: 18,
                  color: c.textTertiary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: BorderSide(color: c.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: BorderSide(color: c.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: const BorderSide(
                    color: AppColors.primary500,
                    width: 1.2,
                  ),
                ),
              ),
              style: AppFonts.satoshiStyle(
                fontSize: 13,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: c.border.withValues(alpha: 0.4)),
                itemBuilder: (context, index) {
                  final option = filtered[index];
                  final selected = widget.selectedOptions.contains(option);

                  return InkWell(
                    onTap: () {
                      widget.onSelected(option);
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.primary500 : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppRadius.xxs),
                              border: Border.all(
                                color: selected ? AppColors.primary500 : c.borderStrong,
                                width: selected ? 0 : 1.5,
                              ),
                            ),
                            child: selected
                                ? const Icon(
                                    FluentIcons.checkmark_24_filled,
                                    size: 14,
                                    color: AppColors.white,
                                  )
                                : null,
                          ),
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

class _OfferFormContent extends StatelessWidget {
  const _OfferFormContent({
    required this.selectedMajor,
    required this.selectedCategory,
    required this.skills,
    required this.onMajorTap,
    required this.onCategoryTap,
    required this.onSkillAdd,
    required this.onSkillRemove,
  });

  final String? selectedMajor;
  final String? selectedCategory;
  final List<String> skills;
  final VoidCallback onMajorTap;
  final VoidCallback onCategoryTap;
  final VoidCallback onSkillAdd;
  final ValueChanged<String> onSkillRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Nama proyek'),
        const SizedBox(height: AppSpacing.xs),
        _AppInput(
          hintText: 'Contoh: Mentoring Kampus App',
          icon: FluentIcons.briefcase_24_regular,
          validator: (v) => v?.trim().isEmpty == true ? 'Nama proyek wajib diisi' : null,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _LabeledPicker(
                label: 'Jurusan',
                value: selectedMajor,
                hintText: 'Pilih jurusan',
                icon: FluentIcons.hat_graduation_24_regular,
                onTap: onMajorTap,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _LabeledPicker(
                label: 'Kategori',
                value: selectedCategory,
                hintText: 'Pilih kategori',
                icon: FluentIcons.tag_24_regular,
                onTap: onCategoryTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const _FieldLabel('Deskripsi proyek'),
        const SizedBox(height: AppSpacing.xs),
        _AppInput(
          hintText:
              'Ceritakan tujuan proyek, progress saat ini, dan tipe kolaborator yang kamu cari.',
          icon: FluentIcons.text_description_24_regular,
          minLines: 5,
          maxLines: 8,
          validator: (v) => v?.trim().isEmpty == true ? 'Deskripsi wajib diisi' : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        const _FieldLabel('Skill yang dibutuhkan'),
        const SizedBox(height: AppSpacing.xs),
        _SkillInput(
          skills: skills,
          onAdd: onSkillAdd,
          onRemove: onSkillRemove,
        ),
        const SizedBox(height: AppSpacing.lg),
        const _FieldLabel('Slot tersisa'),
        const SizedBox(height: AppSpacing.xs),
        _AppInput(
          hintText: 'Contoh: 2',
          icon: FluentIcons.people_24_regular,
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v?.trim().isEmpty == true) return 'Slot wajib diisi';
            final n = int.tryParse(v!.trim());
            if (n == null || n < 1) return 'Minimal 1 slot';
            return null;
          },
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
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
    final c = AppC.of(context);
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: active ? AppColors.primary500 : c.grey100,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: active ? AppColors.white : c.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: AppFonts.satoshiStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? AppColors.white : c.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
