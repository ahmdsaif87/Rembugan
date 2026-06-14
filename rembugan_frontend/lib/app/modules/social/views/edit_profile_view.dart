import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/profile_service.dart';
import '../../../core/theme/theme.dart';
import '../../../routes/app_pages.dart';
import 'social_components.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final ProfileService profileService = Get.find<ProfileService>();
  late ProfileData draft;

  @override
  void initState() {
    super.initState();
    draft = profileService.profile.value;
  }

  void persist(ProfileData value) {
    setState(() => draft = value);
    profileService.updateProfile(value);
  }

  void showProfileSheet() {
    final nameController = TextEditingController(text: draft.name);
    final bioController = TextEditingController(text: draft.bio);
    final majorController = TextEditingController(text: draft.major);

    _showEditSheet(
      title: 'Edit profil',
      helper: 'Bio dibuat dari resume dan masih bisa kamu edit.',
      child: Column(
        children: [
          _SheetField(label: 'Nama', controller: nameController),
          _SheetField(
            label: 'Bio',
            helper:
                'Ceritakan tentang dirimu, minat, dan hal yang sedang kamu fokuskan.',
            controller: bioController,
            maxLines: 5,
          ),
          _SheetField(label: 'Jurusan', controller: majorController),
        ],
      ),
      onSave: () {
        persist(
          draft.copyWith(
            name: nameController.text.trim(),
            bio: bioController.text.trim(),
            major: majorController.text.trim(),
          ),
        );
      },
    );
  }

  void showSocialSheet() {
    final linkController = TextEditingController(text: draft.socialLink);

    _showEditSheet(
      title: 'Edit social link',
      helper: 'Tambahkan link yang ingin kamu tampilkan.',
      child: Row(
        children: [
          const _LinkIcon(),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: linkController,
              decoration: const InputDecoration(
                hintText: 'GitHub, portfolio, LinkedIn, atau website pribadi',
              ),
            ),
          ),
        ],
      ),
      onSave: () {
        persist(draft.copyWith(socialLink: linkController.text.trim()));
      },
    );
  }

  void showSkillSheet() {
    final skillController = TextEditingController();
    var skills = [...draft.skills];

    _showEditSheet(
      title: 'Perbarui skill',
      helper: 'Skill membantu sistem merekomendasikan proyek yang relevan.',
      child: StatefulBuilder(
        builder: (context, setSheetState) {
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
                    backgroundColor: AppColors.primarySoft,
                    side: BorderSide(color: AppColors.border),
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
      onSave: () => persist(draft.copyWith(skills: skills)),
    );
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
        persist(draft.copyWith(experiences: experiences));
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
          persist(
            draft.copyWith(
              experiences: draft.experiences
                  .where((item) => item != experience)
                  .toList(),
            ),
          );
          Get.back();
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
  }) {
    Get.bottomSheet(
      _EditBottomSheet(
        title: title,
        helper: helper,
        onSave: () {
          onSave();
          Get.back();
        },
        child: child,
      ),
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SocialScaffold(
      title: 'Edit Profil',
      subtitle: 'Ubah bagian yang kamu perlukan',
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text(
            'Selesai',
            style: AppFonts.satoshiStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _AiPersonalizeCard(onTap: () => Get.toNamed(Routes.PERSONALIZATION)),
          const SizedBox(height: 14),
          _EditPreviewSection(
            title: 'Profil',
            subtitle: 'Nama, bio, dan lokasi.',
            icon: FluentIcons.person_24_regular,
            onEdit: showProfileSheet,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundImage: AssetImage(draft.avatarAsset),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: _MiniEditButton(onTap: showProfileSheet),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        draft.name,
                        style: AppFonts.satoshiStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        draft.bio,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.satoshiStyle(
                          fontSize: 12.5,
                          height: 1.45,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _EditPreviewSection(
            title: 'Social Links',
            subtitle: 'Link yang tampil di profilmu.',
            icon: FluentIcons.link_24_regular,
            onEdit: showSocialSheet,
            child: Row(
              children: [
                const _LinkIcon(),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    draft.socialLink.isEmpty
                        ? 'Tambahkan link yang ingin kamu tampilkan.'
                        : draft.socialLink,
                    style: AppFonts.satoshiStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: draft.socialLink.isEmpty
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _EditPreviewSection(
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
          const SizedBox(height: 14),
          _EditPreviewSection(
            title: 'Experience',
            subtitle: 'Pengalaman yang membentuk perjalanan dan skill kamu.',
            icon: FluentIcons.briefcase_24_regular,
            onEdit: () => showExperienceSheet(),
            actionLabel: 'Tambah',
            child: draft.experiences.isEmpty
                ? Text(
                    'Tambahkan pengalaman agar profile lebih meyakinkan.',
                    style: AppFonts.satoshiStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
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
          const SizedBox(height: 14),
          _EditPreviewSection(
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
                    persist(
                      draft.copyWith(collaborationHistory: collaborations),
                    );
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _AiPersonalizeCard extends StatelessWidget {
  const _AiPersonalizeCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.grey900,
      borderRadius: BorderRadius.circular(AppRadius.lg),
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
                  color: AppColors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  FluentIcons.sparkle_24_filled,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personalize with AI',
                      style: AppFonts.satoshiStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Scan ulang resume untuk merapikan bio, skill, dan experience.',
                      style: AppFonts.satoshiStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: AppColors.white.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                FluentIcons.chevron_right_24_regular,
                color: AppColors.white,
                size: 20,
              ),
            ],
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
                      style: AppFonts.satoshiStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: AppFonts.satoshiStyle(
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
          const SizedBox(height: 14),
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
                  style: AppFonts.satoshiStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${experience.organization} - ${experience.duration}',
                  style: AppFonts.satoshiStyle(
                    fontSize: 12,
                    color: c.textSecondary,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  experience.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.satoshiStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: c.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(FluentIcons.edit_24_regular, size: 18),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(FluentIcons.delete_24_regular, size: 18),
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
                  style: AppFonts.satoshiStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.role} - ${item.members} anggota - ${item.status}',
                  style: AppFonts.satoshiStyle(
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

class _EditBottomSheet extends StatelessWidget {
  const _EditBottomSheet({
    required this.title,
    required this.helper,
    required this.child,
    required this.onSave,
  });

  final String title;
  final String helper;
  final Widget child;
  final VoidCallback onSave;

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
                title,
                style: AppFonts.headingStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                helper,
                style: AppFonts.satoshiStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: c.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              child,
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
                      onPressed: onSave,
                      child: const Text('Simpan'),
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
              style: AppFonts.satoshiStyle(
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
  });

  final String label;
  final TextEditingController controller;
  final String? helper;
  final int maxLines;

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
            style: AppFonts.satoshiStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: c.textSecondary,
            ),
          ),
          if (helper != null) ...[
            const SizedBox(height: 4),
            Text(
              helper!,
              style: AppFonts.satoshiStyle(
                fontSize: 12,
                height: 1.35,
                color: c.textTertiary,
              ),
            ),
          ],
          const SizedBox(height: 8),
          TextFormField(controller: controller, maxLines: maxLines),
        ],
      ),
    );
  }
}

class _LinkIcon extends StatelessWidget {
  const _LinkIcon();

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: c.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.border),
      ),
      child: Icon(
        FluentIcons.code_24_regular,
        color: c.textPrimary,
        size: 19,
      ),
    );
  }
}

class _MiniEditButton extends StatelessWidget {
  const _MiniEditButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.grey900,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 28,
          height: 28,
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
