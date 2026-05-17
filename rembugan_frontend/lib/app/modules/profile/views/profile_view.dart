import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_chrome.dart';
import '../../../routes/app_pages.dart';
import '../../social/views/social_components.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppLayeredBackground(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 38,
                          backgroundImage: AssetImage(
                            'lib/assets/img/avatar.png',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Dede Fernanda',
                                      style: AppFonts.headingStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                        height: 1.1,
                                      ),
                                    ),
                                  ),
                                  AppIconButton(
                                    icon: FluentIcons.settings_24_regular,
                                    onTap: () => Get.toNamed(Routes.SETTINGS),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '@dede.flutter',
                                style: AppFonts.interStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Fullstack developer yang fokus pada Flutter, produk kolaboratif, dan pengalaman mobile yang clean.',
                      style: AppFonts.generalSansStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: const [
                        _ProfileMetric(value: '842', label: 'Pengikut'),
                        SizedBox(width: 22),
                        _ProfileMetric(value: '32', label: 'Posting'),
                        SizedBox(width: 22),
                        _ProfileMetric(value: '7', label: 'Kolaborasi'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Malang, Indonesia - github.com/dedef',
                      style: AppFonts.interStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        AppTextPill(label: 'Flutter', active: true),
                        AppTextPill(label: 'Dart'),
                        AppTextPill(label: 'Node.js'),
                        AppTextPill(label: 'UI/UX'),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Get.toNamed(Routes.EDIT_PROFILE),
                            child: const Text('Edit Profil'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        AppIconButton(
                          icon: FluentIcons.bookmark_24_regular,
                          onTap: () => Get.toNamed(Routes.SAVED),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: const [
                    _ProfileTab(label: 'Posting', active: true),
                    SizedBox(width: 18),
                    _ProfileTab(label: 'Proyek', active: false),
                    SizedBox(width: 18),
                    _ProfileTab(label: 'Riwayat', active: false),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: SocialPostCard(
                  name: 'Dede Fernanda',
                  handle: '@dede - 2j',
                  avatarUrl: 'https://i.pravatar.cc/100?img=60',
                  body:
                      'Baru menyelesaikan polishing UI untuk chat dan explore. Small details matter: spacing, hierarchy, dan empty state.',
                ),
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, indent: 64, color: AppColors.border),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 24),
                child: SocialPostCard(
                  name: 'Dede Fernanda',
                  handle: '@dede - 1h',
                  avatarUrl: 'https://i.pravatar.cc/100?img=60',
                  body:
                      'Mencari tim hackathon bulan depan. Butuh UI/UX Designer dan Backend Dev yang nyaman kerja cepat.',
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(
        current: AppNavDestination.profile,
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppFonts.interStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppFonts.interStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label,
        style: AppFonts.interStyle(
          fontSize: 14,
          fontWeight: active ? FontWeight.w900 : FontWeight.w700,
          color: active ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
