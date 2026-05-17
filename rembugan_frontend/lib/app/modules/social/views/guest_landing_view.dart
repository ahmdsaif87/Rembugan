import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../../../routes/app_pages.dart';
import 'social_components.dart';

class GuestLandingView extends StatelessWidget {
  const GuestLandingView({super.key});

  @override
  Widget build(BuildContext context) {
    return SocialScaffold(
      title: 'Mode Tamu',
      subtitle: 'Jelajahi konten publik tanpa akun',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  FluentIcons.eye_24_regular,
                  size: 28,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Anda sedang membaca sebagai guest',
                  style: AppFonts.headingStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Guest bisa melihat feed, proyek publik, profil, dan komentar. Untuk berinteraksi, masuk dengan akun Rembugan.',
                  style: AppFonts.interStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    AppTextPill(label: 'Baca feed', active: true),
                    AppTextPill(label: 'Lihat proyek', active: true),
                    AppTextPill(label: 'Buka profil publik', active: true),
                    AppTextPill(label: 'Chat terkunci'),
                    AppTextPill(label: 'Komentar terkunci'),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.offAllNamed(Routes.HOME),
                        child: const Text('Lanjut Jelajah'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.offAllNamed(Routes.LOGIN),
                        child: const Text('Masuk'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
