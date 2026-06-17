import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/api_client.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../routes/app_pages.dart';
import 'social_components.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final ProfileService profileService = Get.find<ProfileService>();
  final ApiClient api = Get.find<ApiClient>();
  final _picker = ImagePicker();

  late ProfileData draft;
  late TextEditingController nameController;
  late TextEditingController bioController;
  late TextEditingController majorController;
  late TextEditingController socialController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    draft = profileService.profile.value;
    nameController = TextEditingController(text: draft.name);
    bioController = TextEditingController(text: draft.bio);
    majorController = TextEditingController(text: draft.major);
    socialController = TextEditingController(text: draft.socialLink);
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    majorController.dispose();
    socialController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isCover) async {
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
    if (picked == null) return;

    AppToast.info('Mengupload gambar...');
    try {
      final bytes = await picked.readAsBytes();
      final url = await api.uploadImageBytes(
        '/upload/image',
        bytes,
        picked.name,
      );
      if (url != null && mounted) {
        setState(() {
          if (isCover) {
            draft = draft.copyWith(coverUrl: url);
          } else {
            draft = draft.copyWith(photoUrl: url);
          }
        });
        AppToast.success('Gambar berhasil diupload.');
      } else {
        AppToast.error('Gagal mengupload gambar.');
      }
    } catch (e) {
      AppToast.error('Gagal mengupload: $e');
    }
  }

  Future<void> _save() async {
    if (nameController.text.trim().isEmpty) {
      AppToast.error('Nama wajib diisi.');
      return;
    }

    setState(() => _isSaving = true);

    final old = profileService.profile.value;
    final newDraft = draft.copyWith(
      name: nameController.text.trim(),
      bio: bioController.text.trim(),
      major: majorController.text.trim(),
      socialLink: socialController.text.trim(),
    );

    profileService.updateProfile(newDraft);

    final settings = <String, dynamic>{};
    if (newDraft.name != old.name) settings['full_name'] = newDraft.name;
    if (newDraft.bio != old.bio) settings['bio'] = newDraft.bio;
    if (newDraft.major != old.major) settings['major'] = newDraft.major;
    if (newDraft.photoUrl != old.photoUrl) settings['photo_url'] = newDraft.photoUrl;
    if (newDraft.coverUrl != old.coverUrl) settings['cover_url'] = newDraft.coverUrl;
    if (newDraft.socialLink != old.socialLink) {
      settings['social_links'] = {'url': newDraft.socialLink};
    }

    if (settings.isNotEmpty) {
      final err = await profileService.updateSettings(settings);
      if (err != null) {
        AppToast.error(err, title: 'Error');
        setState(() => _isSaving = false);
        return;
      }
    }

    setState(() {
      draft = newDraft;
      _isSaving = false;
    });
    AppToast.success('Profil berhasil diperbarui.');
    Get.offNamed(Routes.PROFILE);
  }

  void showSkillSheet() {
    final skillController = TextEditingController();
    var skills = [...draft.skills];

    _showEditSheet(
      title: 'Perbarui skill',
      helper: 'Skill membantu sistem merekomendasikan proyek yang relevan.',
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          final c = AppC.of(context);
          void addSkill(String value) {
            final skill = value.trim();
            if (skill.isEmpty || skills.contains(skill)) return;
            setSheetState(() {
              skills = [...skills, skill];
              skillController.clear();
            });
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skills.map((skill) {
                  return InputChip(
                    label: Text(skill),
                    onDeleted: () {
                      setSheetState(() {
                        skills = skills.where((item) => item != skill).toList();
                      });
                    },
                    backgroundColor: c.primarySoft,
                    side: BorderSide(color: c.border),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: skillController,
                onSubmitted: addSkill,
                decoration: InputDecoration(
                  hintText: 'Cari atau tambah skill',
                  suffixIcon: IconButton(
                    onPressed: () => addSkill(skillController.text),
                    icon: const Icon(FluentIcons.add_24_regular),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      onSave: () {
        setState(() => draft = draft.copyWith(skills: skills));
        _saveSkills(skills);
      },
    );
  }

  Future<void> _saveSkills(List<String> skills) async {
    final err = await profileService.updateSettings({'skills': skills});
    if (err != null) {
      AppToast.error(err, title: 'Error');
    }
  }

  void showExperienceSheet({ProfileExperience? experience, int? index}) {
    final titleController = TextEditingController(
      text: experience?.title ?? '',
    );
    final orgController = TextEditingController(
      text: experience?.organization ?? '',
    );
    final durationController = TextEditingController(
      text: experience?.duration ?? '',
    );
    final descriptionController = TextEditingController(
      text: experience?.description ?? '',
    );

    _showEditSheet(
      title: experience == null ? 'Tambah pengalaman' : 'Edit pengalaman',
      helper: 'Pengalaman yang membentuk perjalanan dan skill kamu.',
      child: Column(
        children: [
          _SheetField(label: 'Peran atau posisi', controller: titleController),
          _SheetField(
            label: 'Nama organisasi atau proyek',
            controller: orgController,
          ),
          _SheetField(
            label: 'Waktu berlangsung',
            controller: durationController,
          ),
          _SheetField(
            label: 'Ceritakan kontribusi atau pengalamanmu',
            controller: descriptionController,
            maxLines: 4,
          ),
        ],
      ),
      onSave: () {
        final updated = ProfileExperience(
          title: titleController.text.trim(),
          organization: orgController.text.trim(),
          duration: durationController.text.trim(),
          description: descriptionController.text.trim(),
          techStack: experience?.techStack ?? const [],
        );
        final experiences = [...draft.experiences];
        if (index == null) {
          experiences.add(updated);
        } else {
          experiences[index] = updated;
        }
        setState(() => draft = draft.copyWith(experiences: experiences));
      },
    );
  }

  void deleteExperience(ProfileExperience experience) {
    Get.bottomSheet(
      _ConfirmSheet(
        title: 'Hapus pengalaman ini?',
        message:
            'Pengalaman ini akan hilang dari profilmu, tapi bisa kamu tambahkan lagi nanti.',
        onConfirm: () {
          setState(() {
            draft = draft.copyWith(
              experiences: draft.experiences
                  .where((item) => item != experience)
                  .toList(),
            );
          });
          Get.back();
          AppToast.success('Pengalaman dihapus.');
        },
      ),
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
    );
  }

  void _showEditSheet({
    required String title,
    required String helper,
    required Widget child,
    required VoidCallback onSave,
    GlobalKey<FormState>? formKey,
  }) {
    Get.bottomSheet(
      _EditBottomSheet(
        title: title,
        helper: helper,
        onSave: onSave,
        formKey: formKey,
        child: child,
      ),
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.surface,
        leading: IconButton(
          icon: const Icon(FluentIcons.dismiss_24_regular),
          onPressed: Get.back,
        ),
        title: Text(
          'Edit profil',
          style: AppFonts.interStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: c.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              height: 34,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Text(
                        'Simpan',
                        style: AppFonts.interStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Cover + Avatar header
          SizedBox(
            height: topPadding + 168,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Cover image
                GestureDetector(
                  onTap: () => _pickImage(true),
                  child: SizedBox(
                    height: 140,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        draft.coverUrl.isNotEmpty
                            ? Image.network(draft.coverUrl, fit: BoxFit.cover)
                            : Container(color: AppColors.grey200),
                        Container(
                          color: Colors.black26,
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  FluentIcons.camera_24_regular,
                                  color: AppColors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Edit cover',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Avatar
                Positioned(
                  left: 16,
                  bottom: -46,
                  child: GestureDetector(
                    onTap: () => _pickImage(false),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.white, width: 3),
                          ),
                          child: AppAvatar(
                            photoUrl: draft.photoUrl,
                            radius: 47,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.white, width: 2),
                            ),
                            child: const Icon(
                              FluentIcons.camera_24_regular,
                              size: 14,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Form fields
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 56, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _Field(
                  label: 'Nama',
                  controller: nameController,
                  hint: 'Nama lengkap',
                ),
                const SizedBox(height: 16),
                _Field(
                  label: 'Bio',
                  controller: bioController,
                  hint: 'Ceritakan tentang dirimu',
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                _Field(
                  label: 'Jurusan',
                  controller: majorController,
                  hint: 'Program studi atau jurusan',
                ),
                const SizedBox(height: 16),
                _Field(
                  label: 'Tautan',
                  controller: socialController,
                  hint: 'GitHub, portfolio, LinkedIn, atau website',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Sections
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _EditPreviewSection(
              title: 'Skill',
              subtitle: 'Skill membantu sistem merekomendasikan proyek.',
              icon: FluentIcons.sparkle_24_regular,
              onEdit: showSkillSheet,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: draft.skills
                    .map((skill) => AppTextPill(label: skill))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _EditPreviewSection(
              title: 'Experience',
              subtitle: 'Pengalaman yang membentuk perjalanan dan skill kamu.',
              icon: FluentIcons.briefcase_24_regular,
              onEdit: () => showExperienceSheet(),
              actionLabel: 'Tambah',
              child: draft.experiences.isEmpty
                  ? Text(
                      'Tambahkan pengalaman agar profil lebih meyakinkan.',
                      style: AppFonts.interStyle(
                        fontSize: 13,
                        color: c.textSecondary,
                      ),
                    )
                  : Column(
                      children: draft.experiences.asMap().entries.map((entry) {
                        return _ExperiencePreviewItem(
                          experience: entry.value,
                          onEdit: () => showExperienceSheet(
                            experience: entry.value,
                            index: entry.key,
                          ),
                          onDelete: () => deleteExperience(entry.value),
                        );
                      }).toList(),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _EditPreviewSection(
              title: 'Riwayat Kolaborasi',
              subtitle:
                  'Dibuat otomatis dari workspace yang selesai di REMBUGAN.',
              icon: FluentIcons.people_24_regular,
              onEdit: () {},
              hideAction: true,
              child: Column(
                children: draft.collaborationHistory.asMap().entries.map((entry) {
                  return _CollaborationVisibilityItem(
                    item: entry.value,
                    onToggle: () {
                      final collaborations = [...draft.collaborationHistory];
                      collaborations[entry.key] = entry.value.copyWith(
                        visible: !entry.value.visible,
                      );
                      setState(() {
                        draft = draft.copyWith(collaborationHistory: collaborations);
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _AiPersonalizeCard(
              onTap: () => Get.toNamed(Routes.PERSONALIZATION),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.interStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: c.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: AppFonts.interStyle(
            fontSize: 14,
            color: c.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppFonts.interStyle(
              fontSize: 14,
              color: c.textTertiary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: c.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: c.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _AiPersonalizeCard extends StatelessWidget {
  const _AiPersonalizeCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.border),
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: c.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: c.border),
                  ),
                  child: Icon(
                    FluentIcons.sparkle_24_filled,
                    color: AppColors.primary500,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personalisasi dengan AI',
                        style: AppFonts.interStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Scan ulang resume untuk merapikan bio, skill, dan pengalaman.',
                        style: AppFonts.interStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  FluentIcons.chevron_right_24_regular,
                  color: c.textTertiary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditPreviewSection extends StatelessWidget {
  const _EditPreviewSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onEdit,
    required this.child,
    this.actionLabel,
    this.hideAction = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onEdit;
  final Widget child;
  final String? actionLabel;
  final bool hideAction;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: c.textPrimary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppFonts.interStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: AppFonts.interStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!hideAction)
                actionLabel == null
                    ? _MiniEditButton(onTap: onEdit)
                    : TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(FluentIcons.add_24_regular, size: 16),
                        label: Text(actionLabel!),
                      ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _ExperiencePreviewItem extends StatelessWidget {
  const _ExperiencePreviewItem({
    required this.experience,
    required this.onEdit,
    required this.onDelete,
  });

  final ProfileExperience experience;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: c.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  experience.title,
                  style: AppFonts.interStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${experience.organization} - ${experience.duration}',
                  style: AppFonts.interStyle(
                    fontSize: 12,
                    color: c.textSecondary,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  experience.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.interStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: c.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 36,
            height: 36,
            child: IconButton(
              onPressed: onEdit,
              icon: const Icon(FluentIcons.edit_24_regular, size: 16),
              padding: EdgeInsets.zero,
            ),
          ),
          SizedBox(
            width: 36,
            height: 36,
            child: IconButton(
              onPressed: onDelete,
              icon: const Icon(FluentIcons.delete_24_regular, size: 16),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _CollaborationVisibilityItem extends StatelessWidget {
  const _CollaborationVisibilityItem({
    required this.item,
    required this.onToggle,
  });

  final PlatformCollaboration item;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: c.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Icon(
            item.visible
                ? FluentIcons.eye_24_regular
                : FluentIcons.eye_off_24_regular,
            size: 18,
            color: c.textPrimary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.workspace,
                  style: AppFonts.interStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.role} - ${item.members} anggota - ${item.status}',
                  style: AppFonts.interStyle(
                    fontSize: 12,
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onToggle,
            child: Text(item.visible ? 'Sembunyikan' : 'Tampilkan'),
          ),
        ],
      ),
    );
  }
}

class _EditBottomSheet extends StatefulWidget {
  const _EditBottomSheet({
    required this.title,
    required this.helper,
    required this.onSave,
    this.formKey,
    required this.child,
  });

  final String title;
  final String helper;
  final VoidCallback onSave;
  final GlobalKey<FormState>? formKey;
  final Widget child;

  @override
  State<_EditBottomSheet> createState() => _EditBottomSheetState();
}

class _EditBottomSheetState extends State<_EditBottomSheet> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: SafeArea(
        top: false,
          child: SingleChildScrollView(
            child: Form(
              key: widget.formKey,
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
                    style: AppFonts.headingStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.helper,
                    style: AppFonts.interStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: c.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  widget.child,
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSaving ? null : Get.back,
                          child: const Text('Batalkan'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSaving
                              ? null
                              : () {
                                  if (widget.formKey?.currentState?.validate() == false) return;
                                  setState(() => _isSaving = true);
                                  widget.onSave();
                                  Get.back();
                                },
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Simpan'),
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

class _ConfirmSheet extends StatelessWidget {
  const _ConfirmSheet({
    required this.title,
    required this.message,
    required this.onConfirm,
  });

  final String title;
  final String message;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppFonts.headingStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppFonts.interStyle(
                fontSize: 13,
                height: 1.45,
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: Get.back,
                    child: const Text('Batalkan'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    child: const Text('Hapus'),
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

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.label,
    required this.controller,
    this.helper,
    this.maxLines = 1,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String? helper;
  final int maxLines;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppFonts.interStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: c.textSecondary,
            ),
          ),
          if (helper != null) ...[
            const SizedBox(height: 4),
            Text(
              helper!,
              style: AppFonts.interStyle(
                fontSize: 12,
                height: 1.35,
                color: c.textTertiary,
              ),
            ),
          ],
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: validator,
          ),
        ],
      ),
    );
  }
}

class _MiniEditButton extends StatelessWidget {
  const _MiniEditButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.grey600;
    return Material(
      color: bg,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            FluentIcons.edit_24_regular,
            color: AppColors.white,
            size: 14,
          ),
        ),
      ),
    );
  }
}
