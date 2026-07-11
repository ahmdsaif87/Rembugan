import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_toast.dart';
import 'social_components.dart';

class CreatePostView extends StatefulWidget {
  const CreatePostView({super.key});

  @override
  State<CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  bool _isOffer = false;
  bool _isLoading = false;
  String _uploadProgress = '';
  String? _selectedCategory;
  final _skills = <String>[];
  final _tags = <String>[];
  final _images = <XFile>[];
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _skillTextController = TextEditingController();
  final _contentController = TextEditingController();
  final _projectNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _slotsController = TextEditingController();
  final _tagTextController = TextEditingController();

  List<String> _skillOptions = [];
  List<String> _categories = [];
  List<String> _tagOptions = [];

  @override
  void initState() {
    super.initState();
    _fetchSuggestions();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _projectNameController.dispose();
    _descriptionController.dispose();
    _slotsController.dispose();
    _tagTextController.dispose();
    _skillTextController.dispose();
    super.dispose();
  }

  Future<void> _fetchSuggestions() async {
    try {
      final api = Get.find<ApiClient>();
      final res = await api.get('/projects/suggestions');
      final data = (res.data as Map<String, dynamic>?)?['data'] as Map<String, dynamic>?;
      if (data != null) {
        setState(() {
          _categories = (data['categories'] as List<dynamic>?)?.cast<String>() ?? [];
          _skillOptions = (data['skills'] as List<dynamic>?)?.cast<String>() ?? [];
          _tagOptions = (data['tags'] as List<dynamic>?)?.cast<String>() ?? [];
        });
      }
    } catch (e) {
      debugPrint('Failed to fetch suggestions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final user = Get.find<AuthService>().currentUser.value;
    final userName = user?.fullName ?? 'Pengguna';
    final photoUrl = Get.find<ProfileService>().profile.value.photoUrl;
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
                AppAvatar(
                  photoUrl: photoUrl,
                  radius: 18,
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
                        _OfferInfoBanner(),
                        const SizedBox(height: AppSpacing.md),
                        _OfferFormContent(
                          selectedCategory: _selectedCategory,
                          skills: _skills,
                          onCategoryTap: _showCategoryPicker,
                          onSkillAdd: _showSkillPicker,
                          onSkillRemove: (s) => setState(() => _skills.remove(s)),
                          projectNameController: _projectNameController,
                          descriptionController: _descriptionController,
                          slotsController: _slotsController,
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
                          controller: _contentController,
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
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              borderSide: const BorderSide(color: AppColors.error500, width: 1.2),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              borderSide: const BorderSide(color: AppColors.error500, width: 1.2),
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
                        const SizedBox(height: AppSpacing.lg),
                        const _FieldLabel('Tag'),
                        const SizedBox(height: AppSpacing.xs),
                        _SkillInput(
                          skills: _tags,
                          onAdd: _showTagPicker,
                          onRemove: (t) => setState(() => _tags.remove(t)),
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
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: SizedBox(
                          height: 36,
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
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _images.removeAt(i)),
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: const BoxDecoration(
                                        color: AppColors.error500,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        FluentIcons.dismiss_24_filled,
                                        size: 9,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
                const Spacer(),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handlePost,
                  child: _isLoading
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            ),
                            if (_uploadProgress.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text(
                                _uploadProgress,
                                style: AppFonts.satoshiStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ],
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

  void _showCategoryPicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => _SearchablePickerSheet(
        title: 'Pilih kategori',
        searchHint: 'Cari kategori',
        options: _categories,
        selectedOptions: _selectedCategory != null ? [_selectedCategory!] : [],
        skillTextController: _skillTextController,
        singleSelect: true,
        customInputHint: 'Tambah kategori custom',
        onSelected: (category) {
          if (_selectedCategory == category) {
            setState(() => _selectedCategory = null);
          } else {
            setState(() => _selectedCategory = category);
          }
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
        customInputHint: 'Tambah skill custom',
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

  void _showTagPicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => _SearchablePickerSheet(
        title: 'Tambah tag',
        searchHint: 'Cari tag',
        options: _tagOptions,
        selectedOptions: _tags,
        skillTextController: _tagTextController,
        customInputHint: 'Tambah tag custom',
        onSelected: (tag) {
          setState(() {
            if (_tags.contains(tag)) {
              _tags.remove(tag);
            } else {
              _tags.add(tag);
            }
          });
        },
      ),
    );
  }

  Future<void> _handlePost() async {
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
    if (_isOffer) {
      final confirmed = await _confirmOfferPost();
      if (confirmed != true) return;
    }
    setState(() {
      _isLoading = true;
      _uploadProgress = '';
    });
    try {
      final api = Get.find<ApiClient>();
      if (_isOffer) {
        await api.post('/posts/create', data: {
          'type': 'offer',
          'title': _projectNameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'required_skills': _skills,
          'category': _selectedCategory,
          'total_slots': int.tryParse(_slotsController.text.trim()),
        });
        AppToast.success('Tawaran berhasil dikirim');
      } else {
        List<String> mediaUrls = [];
        if (_images.isNotEmpty) {
          for (var i = 0; i < _images.length; i++) {
            if (!mounted) return;
            setState(() => _uploadProgress = 'Mengupload ${i + 1}/${_images.length} gambar...');
            final bytes = await File(_images[i].path).readAsBytes();
            final result = await api.uploadImageBytes(
              '/upload/image',
              bytes,
              filename: _images[i].name,
            );
            final url = (result is Map<String, dynamic> ? result['url'] : null) as String?;
            if (url != null) mediaUrls.add(url);
          }
        }
        await api.post('/posts/create', data: {
          'type': 'post',
          'content': _contentController.text.trim(),
          'tags': _tags,
          'media_urls': mediaUrls,
        });
        AppToast.success('Postingan berhasil diunggah');
      }
    } catch (e) {
      AppToast.error('Gagal mengirim. Coba lagi.');
      return;
    } finally {
      if (mounted) setState(() { _isLoading = false; _uploadProgress = ''; });
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<bool?> _confirmOfferPost() {
    final c = AppC.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        title: Text(
          'Terbitkan tawaran proyek?',
          style: AppFonts.satoshiStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _projectNameController.text.trim(),
              style: AppFonts.satoshiStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_skills.length} skill dibutuhkan • ${_slotsController.text.trim()} anggota',
              style: AppFonts.satoshiStyle(
                fontSize: 12.5,
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Workspace akan dibuat otomatis setelah tawaran diterbitkan.',
              style: AppFonts.satoshiStyle(
                fontSize: 13,
                height: 1.45,
                color: c.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Terbitkan'),
          ),
        ],
      ),
    );
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
    if (source == ImageSource.camera) {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) setState(() => _images.add(picked));
    } else {
      final picked = await _picker.pickMultiImage(imageQuality: 85);
      setState(() => _images.addAll(picked));
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

class _AppInput extends StatelessWidget {
  const _AppInput({
    this.controller,
    required this.hintText,
    required this.icon,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController? controller;
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
      controller: controller,
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
    this.singleSelect = false,
    this.customInputHint = 'Tambah custom',
  });

  final String title;
  final String searchHint;
  final List<String> options;
  final List<String> selectedOptions;
  final ValueChanged<String> onSelected;
  final TextEditingController? skillTextController;
  final bool singleSelect;
  final String customInputHint;

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
                        hintText: widget.customInputHint,
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

class _OfferInfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: c.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            FluentIcons.info_24_regular,
            size: 20,
            color: AppColors.primary500,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tawaran akan tampil di Jelajah dan membuat workspace otomatis untuk tim kamu.',
              style: AppFonts.satoshiStyle(
                fontSize: 12.5,
                height: 1.4,
                color: c.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferFormContent extends StatelessWidget {
  const _OfferFormContent({
    required this.selectedCategory,
    required this.skills,
    required this.onCategoryTap,
    required this.onSkillAdd,
    required this.onSkillRemove,
    required this.projectNameController,
    required this.descriptionController,
    required this.slotsController,
  });

  final String? selectedCategory;
  final List<String> skills;
  final VoidCallback onCategoryTap;
  final VoidCallback onSkillAdd;
  final ValueChanged<String> onSkillRemove;
  final TextEditingController projectNameController;
  final TextEditingController descriptionController;
  final TextEditingController slotsController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Nama proyek'),
        const SizedBox(height: AppSpacing.xs),
        _AppInput(
          controller: projectNameController,
          hintText: 'Contoh: Mentoring Kampus App',
          icon: FluentIcons.briefcase_24_regular,
          validator: (v) => v?.trim().isEmpty == true ? 'Nama proyek wajib diisi' : null,
        ),
        const SizedBox(height: AppSpacing.md),
        _LabeledPicker(
          label: 'Kategori',
          value: selectedCategory,
          hintText: 'Pilih kategori',
          icon: FluentIcons.tag_24_regular,
          onTap: onCategoryTap,
        ),
        const SizedBox(height: AppSpacing.lg),
        const _FieldLabel('Deskripsi proyek'),
        const SizedBox(height: AppSpacing.xs),
        _AppInput(
          controller: descriptionController,
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
        const _FieldLabel('Total anggota tim'),
        const SizedBox(height: AppSpacing.xs),
        _AppInput(
          controller: slotsController,
          hintText: 'Contoh: 4',
          icon: FluentIcons.people_24_regular,
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v?.trim().isEmpty == true) return 'Jumlah anggota wajib diisi';
            final n = int.tryParse(v!.trim());
            if (n == null || n < 1) return 'Minimal 1 anggota';
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
