import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../core/services/profile_service.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_chrome.dart';
import '../../../routes/app_pages.dart';
import '../controllers/personalization_controller.dart';

class PersonalizationView extends GetView<PersonalizationController> {
  const PersonalizationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppLayeredBackground(
        child: SafeArea(
          child: Obx(() {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: controller.isUploading.value
                  ? _ScanningState(controller: controller)
                  : controller.isScanned.value
                  ? _ExtractionResult(controller: controller)
                  : controller.isManualInput.value
                  ? _ManualInputState(controller: controller)
                  : _UploadState(controller: controller),
            );
          }),
        ),
      ),
    );
  }
}

class _UploadState extends StatelessWidget {
  const _UploadState({required this.controller});

  final PersonalizationController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('upload'),
      padding: const EdgeInsets.fromLTRB(24, 34, 24, 24),
      children: [
        _AiBadge(label: 'Personalisasi profil'),
        const SizedBox(height: 16),
        Text(
          'Buat profil kolaborasimu',
          style: AppFonts.headingStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Pilih cara paling nyaman. Kamu bisa scan CV, isi sendiri, atau lanjut dulu dan rapikan nanti.',
          style: AppFonts.satoshiStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 28),
        _ActionCard(
          onTap: controller.simulateUpload,
          icon: FluentIcons.document_pdf_24_regular,
          title: 'Scan CV',
          description:
              'AI bantu membaca dan membuat draft bio, skill, dan experience dari CV kamu.',
          badge: 'Paling cepat',
        ),
        const SizedBox(height: 12),
        _ActionCard(
          onTap: controller.startManualInput,
          icon: FluentIcons.edit_24_regular,
          title: 'Isi manual',
          description:
              'Tulis profilmu sendiri dengan form ringan yang bisa diedit kapan saja.',
        ),
        const SizedBox(height: 18),
        TextButton(
          onPressed: () => Get.offAllNamed(Routes.HOME),
          child: Text(
            'Lewati dulu',
            style: AppFonts.satoshiStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _FlowStep(
          icon: FluentIcons.arrow_upload_24_regular,
          title: 'Scan atau isi sendiri',
          description: 'Mulai dari CV, atau tulis profil secara manual.',
        ),
        _FlowStep(
          icon: FluentIcons.sparkle_24_regular,
          title: 'Rapikan hasilnya',
          description: 'Nama, bio, skill, dan pengalaman tetap bisa diedit.',
        ),
        _FlowStep(
          icon: FluentIcons.person_24_regular,
          title: 'Profil siap dipakai',
          description: 'Profil membantu rekomendasi proyek dan collaborator.',
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.onTap,
    required this.icon,
    required this.title,
    required this.description,
    this.badge,
  });

  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final String description;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(icon, color: AppColors.textPrimary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppFonts.satoshiStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (badge != null) _CapabilityChip(label: badge!),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: AppFonts.satoshiStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                FluentIcons.chevron_right_24_regular,
                color: AppColors.textTertiary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanningState extends StatelessWidget {
  const _ScanningState({required this.controller});

  final PersonalizationController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final progress =
          (controller.scanningStep.value + 1) /
          controller.extractionSteps.length;
      final step = controller.extractionSteps[controller.scanningStep.value];

      return Padding(
        key: const ValueKey('scanning'),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 260,
              height: 260,
              child: Lottie.asset(
                'lib/assets/animations/scan.json',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'AI sedang mengekstrak resume',
              textAlign: TextAlign.center,
              style: AppFonts.headingStyle(
                fontSize: 23,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              step,
              textAlign: TextAlign.center,
              style: AppFonts.satoshiStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.surfaceSecondary,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    FluentIcons.sparkle_24_filled,
                    color: AppColors.textPrimary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Menyusun profil awal',
                    style: AppFonts.satoshiStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ExtractionResult extends StatelessWidget {
  const _ExtractionResult({required this.controller});

  final PersonalizationController controller;

  @override
  Widget build(BuildContext context) {
    final skillInput = TextEditingController();

    return Obx(() {
      final profile = controller.extractedProfile.value;

      return ListView(
        key: const ValueKey('result'),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
        children: [
          Row(
            children: [
              const _SuccessMark(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Draft profil siap',
                      style: AppFonts.headingStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Cek sebentar. Kamu bebas hapus, tambah, atau ubah hasilnya.',
                      style: AppFonts.satoshiStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _ExtractionCard(
            title: 'Profil dari resume',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: AppColors.primarySoft,
                      backgroundImage: AssetImage(profile.avatarAsset),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTextField(
                            initialValue: profile.name,
                            onChanged: controller.updateName,
                            labelText: 'Nama',
                          ),
                          const SizedBox(height: 8),
                          _AiBadge(
                            label: profile.hasResumePhoto
                                ? 'Foto CV terdeteksi'
                                : 'Avatar default digunakan',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  initialValue: profile.bio,
                  onChanged: controller.updateBio,
                  maxLines: 5,
                  labelText: 'Bio',
                  hintText:
                      'Ceritakan tentang dirimu, minat, dan hal yang sedang kamu fokuskan.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const SizedBox(height: 14),
          _ExtractionCard(
            title: 'Skill',
            child: StatefulBuilder(
              builder: (context, setStateBuilder) {
                final query = skillInput.text.trim().toLowerCase();
                final List<String> suggestions = _popularSkills.where((s) {
                  final matchesQuery = s.toLowerCase().contains(query);
                  final alreadyAdded = profile.skills.contains(s);
                  return matchesQuery && !alreadyAdded;
                }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: skillInput,
                            hintText: 'Cari atau ketik skill baru...',
                            prefixIcon: const Icon(
                              FluentIcons.search_16_regular,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            onChanged: (_) => setStateBuilder(() {}),
                            onFieldSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                controller.addSkill(value);
                                skillInput.clear();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            if (skillInput.text.trim().isNotEmpty) {
                              controller.addSkill(skillInput.text);
                              skillInput.clear();
                            }
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.primary500,
                              borderRadius: BorderRadius.circular(AppRadius.xs),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              FluentIcons.add_16_regular,
                              color: AppColors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (skillInput.text.isNotEmpty &&
                        suggestions.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Rekomendasi skill:',
                        style: AppFonts.satoshiStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: suggestions.take(6).map((s) {
                          return GestureDetector(
                            onTap: () {
                              controller.addSkill(s);
                              skillInput.clear();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.grey100,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.xxs,
                                ),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                s,
                                style: AppFonts.satoshiStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: profile.skills.map((skill) {
                        return InputChip(
                          label: Text(skill),
                          onDeleted: () => controller.removeSkill(skill),
                          backgroundColor: AppColors.primarySoft,
                          side: const BorderSide(color: AppColors.border),
                          labelStyle: AppFonts.satoshiStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          _ExtractionCard(
            title: 'Experience',
            action: TextButton.icon(
              onPressed: () => _showExperienceDialog(context, controller),
              icon: const Icon(FluentIcons.add_24_regular, size: 16),
              label: const Text('Tambah'),
            ),
            child: Column(
              children: profile.experiences.asMap().entries.map((entry) {
                final index = entry.key;
                final experience = entry.value;
                return _ExperiencePreview(
                  experience: experience,
                  onDelete: () => controller.removeExperience(experience),
                  onEdit: () => _showExperienceDialog(
                    context,
                    controller,
                    index: index,
                    experience: experience,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.reset,
                  child: const Text('Scan ulang'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    controller.generateProfile();
                    Get.offAllNamed(Routes.HOME);
                  },
                  child: const Text('Simpan profil'),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}

class _ManualInputState extends StatelessWidget {
  const _ManualInputState({required this.controller});

  final PersonalizationController controller;

  @override
  Widget build(BuildContext context) {
    final skillInput = TextEditingController();

    return Obx(() {
      final profile = controller.extractedProfile.value;

      return ListView(
        key: const ValueKey('manual'),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
        children: [
          Row(
            children: [
              IconButton(
                onPressed: controller.reset,
                icon: const Icon(FluentIcons.chevron_left_24_regular),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Isi profil manual',
                      style: AppFonts.headingStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Cukup isi yang penting dulu. Nanti masih bisa diedit.',
                      style: AppFonts.satoshiStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ExtractionCard(
            title: 'Profil',
            child: Column(
              children: [
                AppTextField(
                  initialValue: profile.name,
                  onChanged: controller.updateName,
                  labelText: 'Nama',
                ),
                const SizedBox(height: 12),
                AppTextField(
                  initialValue: profile.bio,
                  onChanged: controller.updateBio,
                  maxLines: 5,
                  labelText: 'Bio',
                  hintText:
                      'Ceritakan tentang dirimu, minat, dan hal yang sedang kamu fokuskan.',
                ),
                const SizedBox(height: 12),
                AppTextField(
                  initialValue: profile.major,
                  onChanged: controller.updateMajor,
                  labelText: 'Jurusan',
                  hintText: 'Contoh: Teknik Informatika',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _ExtractionCard(
            title: 'Social link',
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    FluentIcons.code_24_regular,
                    color: AppColors.textPrimary,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppTextField(
                    initialValue: profile.socialLink,
                    onChanged: controller.updateSocialLink,
                    hintText:
                        'GitHub, portfolio, LinkedIn, atau website pribadi',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const SizedBox(height: 14),
          _ExtractionCard(
            title: 'Skill',
            child: StatefulBuilder(
              builder: (context, setStateBuilder) {
                final query = skillInput.text.trim().toLowerCase();
                final List<String> suggestions = _popularSkills.where((s) {
                  final matchesQuery = s.toLowerCase().contains(query);
                  final alreadyAdded = profile.skills.contains(s);
                  return matchesQuery && !alreadyAdded;
                }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: skillInput,
                            hintText: 'Cari atau ketik skill baru...',
                            prefixIcon: const Icon(
                              FluentIcons.search_16_regular,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            onChanged: (_) => setStateBuilder(() {}),
                            onFieldSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                controller.addSkill(value);
                                skillInput.clear();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            if (skillInput.text.trim().isNotEmpty) {
                              controller.addSkill(skillInput.text);
                              skillInput.clear();
                            }
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.primary500,
                              borderRadius: BorderRadius.circular(AppRadius.xs),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              FluentIcons.add_16_regular,
                              color: AppColors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (skillInput.text.isNotEmpty &&
                        suggestions.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Rekomendasi skill:',
                        style: AppFonts.satoshiStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: suggestions.take(6).map((s) {
                          return GestureDetector(
                            onTap: () {
                              controller.addSkill(s);
                              skillInput.clear();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.grey100,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.xxs,
                                ),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                s,
                                style: AppFonts.satoshiStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 14),
                    profile.skills.isEmpty
                        ? Text(
                            'Skill membantu sistem merekomendasikan proyek yang relevan.',
                            style: AppFonts.satoshiStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: profile.skills.map((skill) {
                              return InputChip(
                                label: Text(skill),
                                onDeleted: () => controller.removeSkill(skill),
                                backgroundColor: AppColors.primarySoft,
                                side: const BorderSide(color: AppColors.border),
                                labelStyle: AppFonts.satoshiStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              );
                            }).toList(),
                          ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          _ExtractionCard(
            title: 'Experience',
            action: TextButton.icon(
              onPressed: () => _showExperienceDialog(context, controller),
              icon: const Icon(FluentIcons.add_24_regular, size: 16),
              label: const Text('Tambah'),
            ),
            child: profile.experiences.isEmpty
                ? Text(
                    'Tambahkan pengalaman agar profile lebih meyakinkan.',
                    style: AppFonts.satoshiStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  )
                : Column(
                    children: profile.experiences.asMap().entries.map((entry) {
                      final index = entry.key;
                      final experience = entry.value;
                      return _ExperiencePreview(
                        experience: experience,
                        onDelete: () => controller.removeExperience(experience),
                        onEdit: () => _showExperienceDialog(
                          context,
                          controller,
                          index: index,
                          experience: experience,
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.offAllNamed(Routes.HOME),
                  child: const Text('Lewati dulu'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    controller.generateProfile();
                    Get.offAllNamed(Routes.HOME);
                  },
                  child: const Text('Simpan profil'),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}

class _ExtractionCard extends StatelessWidget {
  const _ExtractionCard({
    required this.title,
    required this.child,
    this.action,
  });

  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppFonts.satoshiStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ExperiencePreview extends StatelessWidget {
  const _ExperiencePreview({
    required this.experience,
    required this.onDelete,
    required this.onEdit,
  });

  final ProfileExperience experience;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 9,
            height: 9,
            margin: const EdgeInsets.only(top: AppSpacing.xxs),
            decoration: const BoxDecoration(
              color: AppColors.textPrimary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  experience.title,
                  style: AppFonts.satoshiStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${experience.organization} - ${experience.duration}',
                  style: AppFonts.satoshiStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  experience.description,
                  style: AppFonts.satoshiStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (experience.techStack.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: experience.techStack
                        .map((tech) => _CapabilityChip(label: tech))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(FluentIcons.edit_24_regular, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(FluentIcons.delete_24_regular, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlowStep extends StatelessWidget {
  const _FlowStep({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, size: 18, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.satoshiStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: AppFonts.satoshiStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.45,
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

class _CapabilityChip extends StatelessWidget {
  const _CapabilityChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xxs),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppFonts.satoshiStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _AiBadge extends StatelessWidget {
  const _AiBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            FluentIcons.sparkle_24_filled,
            color: AppColors.textPrimary,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppFonts.satoshiStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessMark extends StatelessWidget {
  const _SuccessMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        color: AppColors.success,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        FluentIcons.checkmark_24_filled,
        color: AppColors.white,
        size: 22,
      ),
    );
  }
}

// ── Unified Popular Skills List ──
const List<String> _popularSkills = [
  'Flutter',
  'Dart',
  'Figma',
  'UI/UX',
  'Python',
  'Firebase',
  'React',
  'Node.js',
  'PostgreSQL',
  'Golang',
  'CSS',
  'HTML',
  'REST API',
  'GetX',
  'Git',
  'DevOps',
];

// ── Experience Edit/Add Form Dialog ──
void _showExperienceDialog(
  BuildContext context,
  PersonalizationController controller, {
  int? index,
  ProfileExperience? experience,
}) {
  final titleController = TextEditingController(text: experience?.title ?? '');
  final orgController = TextEditingController(
    text: experience?.organization ?? '',
  );
  final durationController = TextEditingController(
    text: experience?.duration ?? '',
  );
  final descController = TextEditingController(
    text: experience?.description ?? '',
  );
  final techController = TextEditingController(
    text: experience?.techStack.join(', ') ?? '',
  );

  showDialog<void>(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        backgroundColor: AppColors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    experience == null
                        ? 'Tambah Pengalaman'
                        : 'Ubah Pengalaman',
                    style: AppFonts.headingStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      FluentIcons.dismiss_24_regular,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: titleController,
                labelText: 'Peran / Posisi',
                hintText: 'Contoh: Frontend Lead, UI/UX Designer',
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: orgController,
                labelText: 'Organisasi / Perusahaan',
                hintText: 'Contoh: Hackathon Team, PT Angin Ribut',
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: durationController,
                labelText: 'Durasi / Periode',
                hintText: 'Contoh: Feb 2025 - Jun 2025, Des 2025',
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: descController,
                maxLines: 3,
                labelText: 'Deskripsi',
                hintText:
                    'Ceritakan apa saja tanggung jawab atau pencapaianmu...',
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: techController,
                labelText: 'Teknologi / Tech Stack',
                hintText: 'Pisahkan dengan koma (Contoh: Flutter, Figma, Dart)',
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 8),
                  AppButton(
                    width: 110,
                    onTap: () {
                      final techStack = techController.text
                          .split(',')
                          .map((t) => t.trim())
                          .where((t) => t.isNotEmpty)
                          .toList();

                      final newExp = ProfileExperience(
                        title: titleController.text.trim().isEmpty
                            ? 'Role baru'
                            : titleController.text.trim(),
                        organization: orgController.text.trim().isEmpty
                            ? 'Organisasi / Proyek'
                            : orgController.text.trim(),
                        duration: durationController.text.trim().isEmpty
                            ? 'Periode'
                            : durationController.text.trim(),
                        description: descController.text.trim().isEmpty
                            ? 'Deskripsi singkat pengalaman.'
                            : descController.text.trim(),
                        techStack: techStack,
                      );

                      if (index != null) {
                        controller.updateExperience(index, newExp);
                      } else {
                        controller.addCustomExperience(newExp);
                      }
                      Navigator.pop(context);
                    },
                    label: 'Simpan',
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
