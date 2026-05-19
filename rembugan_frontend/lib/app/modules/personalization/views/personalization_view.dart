import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
          'Pilih cara paling nyaman. Kamu bisa scan resume, isi sendiri, atau lanjut dulu dan rapikan nanti.',
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
          title: 'Scan resume',
          description:
              'AI bantu membaca resume dan membuat draft bio, skill, dan experience.',
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
          description: 'Mulai dari resume, atau tulis profil secara manual.',
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
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
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
                  borderRadius: BorderRadius.circular(15),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(34),
                boxShadow: AppShadows.brand,
              ),
              child: const Icon(
                FluentIcons.document_24_regular,
                color: Colors.white,
                size: 42,
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                          TextFormField(
                            initialValue: profile.name,
                            onChanged: controller.updateName,
                            decoration: const InputDecoration(
                              labelText: 'Nama',
                            ),
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
                TextFormField(
                  initialValue: profile.bio,
                  onChanged: controller.updateBio,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    hintText:
                        'Ceritakan tentang dirimu, minat, dan hal yang sedang kamu fokuskan.',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _ExtractionCard(
            title: 'Skill',
            action: SizedBox(
              width: 128,
              child: TextField(
                controller: skillInput,
                onSubmitted: (value) {
                  controller.addSkill(value);
                  skillInput.clear();
                },
                decoration: const InputDecoration(
                  hintText: 'Cari atau tambah',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            child: Wrap(
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
          ),
          const SizedBox(height: 14),
          _ExtractionCard(
            title: 'Experience',
            action: TextButton.icon(
              onPressed: controller.addExperience,
              icon: const Icon(FluentIcons.add_24_regular, size: 16),
              label: const Text('Tambah'),
            ),
            child: Column(
              children: profile.experiences
                  .map(
                    (experience) => _ExperiencePreview(
                      experience: experience,
                      onDelete: () => controller.removeExperience(experience),
                    ),
                  )
                  .toList(),
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
                icon: const Icon(FluentIcons.arrow_left_24_regular),
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
                TextFormField(
                  initialValue: profile.name,
                  onChanged: controller.updateName,
                  decoration: const InputDecoration(labelText: 'Nama'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: profile.bio,
                  onChanged: controller.updateBio,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    hintText:
                        'Ceritakan tentang dirimu, minat, dan hal yang sedang kamu fokuskan.',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: profile.location,
                  onChanged: controller.updateLocation,
                  decoration: const InputDecoration(labelText: 'Lokasi'),
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
                    borderRadius: BorderRadius.circular(14),
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
                  child: TextFormField(
                    initialValue: profile.socialLink,
                    onChanged: controller.updateSocialLink,
                    decoration: const InputDecoration(
                      hintText:
                          'GitHub, portfolio, LinkedIn, atau website pribadi',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _ExtractionCard(
            title: 'Skill',
            action: SizedBox(
              width: 150,
              child: TextField(
                controller: skillInput,
                onSubmitted: (value) {
                  controller.addSkill(value);
                  skillInput.clear();
                },
                decoration: const InputDecoration(
                  hintText: 'Cari atau tambah',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            child: profile.skills.isEmpty
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
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 14),
          _ExtractionCard(
            title: 'Experience',
            action: TextButton.icon(
              onPressed: controller.addExperience,
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
                    children: profile.experiences
                        .map(
                          (experience) => _ExperiencePreview(
                            experience: experience,
                            onDelete: () =>
                                controller.removeExperience(experience),
                          ),
                        )
                        .toList(),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
  const _ExperiencePreview({required this.experience, required this.onDelete});

  final ProfileExperience experience;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
            margin: const EdgeInsets.only(top: 6),
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
          IconButton(
            onPressed: onDelete,
            icon: const Icon(FluentIcons.delete_24_regular, size: 18),
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
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppFonts.satoshiStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
        color: Colors.white,
        size: 22,
      ),
    );
  }
}
