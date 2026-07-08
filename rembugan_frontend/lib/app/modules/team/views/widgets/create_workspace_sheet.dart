import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../controllers/team_controller.dart';

class CreateWorkspaceSheet extends StatefulWidget {
  const CreateWorkspaceSheet({super.key});

  static void show() {
    Get.bottomSheet(
      const CreateWorkspaceSheet(),
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
    );
  }

  @override
  State<CreateWorkspaceSheet> createState() => _CreateWorkspaceSheetState();
}

class _CreateWorkspaceSheetState extends State<CreateWorkspaceSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _skillCtrl = TextEditingController();
  final _skills = <String>[];
  final _totalSlotsCtrl = TextEditingController();
  String? _selectedCategory;
  DateTime? _deadline;
  bool _isSubmitting = false;

  static const _categories = [
    'Tech',
    'Design',
    'Business',
    'Education',
    'Social',
    'Kesehatan',
    'Seni',
    'Lainnya',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _skillCtrl.dispose();
    _totalSlotsCtrl.dispose();
    super.dispose();
  }

  void _addSkill() {
    final text = _skillCtrl.text.trim();
    if (text.isNotEmpty && !_skills.contains(text)) {
      setState(() => _skills.add(text));
      _skillCtrl.clear();
    }
  }

  void _removeSkill(String skill) {
    setState(() => _skills.remove(skill));
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_skills.isEmpty) {
      AppToast.warning('Tambahkan minimal 1 skill yang dibutuhkan.');
      return;
    }

    setState(() => _isSubmitting = true);

    final ctrl = Get.find<TeamController>();
    final ok = await ctrl.createProject(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      requiredSkills: _skills,
      category: _selectedCategory,
      deadline: _deadline?.toIso8601String(),
      totalSlots: _totalSlotsCtrl.text.isNotEmpty
          ? int.tryParse(_totalSlotsCtrl.text)
          : null,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (ok) {
        Navigator.pop(context);
        AppToast.success('Workspace berhasil dibuat!');
      } else {
        AppToast.error('Gagal membuat workspace. Coba lagi.', title: 'Error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                Icon(
                  FluentIcons.briefcase_24_regular,
                  size: 40,
                  color: AppColors.primary500,
                ),
                const SizedBox(height: 12),
                Text(
                  'Buat Workspace Baru',
                  style: AppFonts.interStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Isi detail proyek untuk memulai kolaborasi.',
                  style: AppFonts.interStyle(
                    fontSize: 13,
                    color: c.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                _buildFieldLabel(c, 'Judul Proyek *'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleCtrl,
                  validator: (v) =>
                      (v == null || v.trim().length < 5) ? 'Minimal 5 karakter' : null,
                  decoration: _inputDecoration(c, 'contoh: Aplikasi E-Learning'),
                ),
                const SizedBox(height: 16),
                _buildFieldLabel(c, 'Deskripsi *'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  validator: (v) =>
                      (v == null || v.trim().length < 20) ? 'Minimal 20 karakter' : null,
                  decoration: _inputDecoration(c, 'Jelaskan tujuan dan kebutuhan proyek...'),
                ),
                const SizedBox(height: 16),
                _buildFieldLabel(c, 'Kategori'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  items: _categories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v),
                  decoration: _inputDecoration(c, 'Pilih kategori'),
                ),
                const SizedBox(height: 16),
                _buildFieldLabel(c, 'Skill yang Dibutuhkan *'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _skillCtrl,
                        decoration: _inputDecoration(c, 'contoh: Flutter'),
                        onSubmitted: (_) => _addSkill(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _addSkill,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        padding: const EdgeInsets.all(12),
                        backgroundColor: AppColors.primary500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                      child: const Icon(FluentIcons.add_24_regular, size: 20),
                    ),
                  ],
                ),
                if (_skills.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _skills.map((s) {
                      return Chip(
                        label: Text(s, style: const TextStyle(fontSize: 12)),
                        deleteIcon: const Icon(FluentIcons.dismiss_12_regular, size: 14),
                        onDeleted: () => _removeSkill(s),
                        backgroundColor: c.primarySoft,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        labelStyle: AppFonts.interStyle(
                          fontSize: 12,
                          color: AppColors.primary500,
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel(c, 'Deadline'),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _pickDeadline,
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                border: Border.all(color: c.border),
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    FluentIcons.calendar_24_regular,
                                    size: 18,
                                    color: c.textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _deadline != null
                                          ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                                          : 'Pilih tanggal',
                                      style: AppFonts.interStyle(
                                        fontSize: 14,
                                        color: _deadline != null
                                            ? c.textPrimary
                                            : c.textTertiary,
                                      ),
                                    ),
                                  ),
                                  if (_deadline != null)
                                    GestureDetector(
                                      onTap: () => setState(() => _deadline = null),
                                      child: const Icon(
                                        FluentIcons.dismiss_12_regular,
                                        size: 16,
                                        color: AppColors.danger500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel(c, 'Total Slot'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _totalSlotsCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: _inputDecoration(c, 'contoh: 5'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary500,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.white, strokeWidth: 2,
                            ),
                          )
                        : const Text('Buat Workspace'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(AppC c, String label) {
    return Text(
      label,
      style: AppFonts.interStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: c.textPrimary,
      ),
    );
  }

  InputDecoration _inputDecoration(AppC c, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppFonts.interStyle(
        fontSize: 14,
        color: c.textTertiary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
        borderSide: const BorderSide(color: AppColors.primary500, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.danger500),
      ),
    );
  }
}
