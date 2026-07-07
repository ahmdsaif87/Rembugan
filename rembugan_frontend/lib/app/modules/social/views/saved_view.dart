import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../../../routes/app_pages.dart';
import 'social_components.dart';

class SavedView extends StatefulWidget {
  const SavedView({super.key});

  @override
  State<SavedView> createState() => _SavedViewState();
}

class _SavedViewState extends State<SavedView> {
  bool _showDemo = false;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return SocialScaffold(
      title: 'Tersimpan',
      subtitle: 'Postingan dan proyek yang Anda tandai',
      child: _showDemo
          ? ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                SocialPostCard(
                  name: 'Cameron Williamson',
                  handle: '@cameron - proyek',
                  avatarUrl: 'https://i.pravatar.cc/100?img=33',
                  body:
                      'Mencari Flutter developer untuk memperhalus chat experience dan notification flow.',
                  onTap: () => Get.toNamed(Routes.COMMENTS),
                ),
                const SizedBox(height: 12),
                SocialPostCard(
                  name: 'Raka Pratama',
                  handle: '@raka - desain',
                  avatarUrl: 'https://i.pravatar.cc/100?img=47',
                  body:
                      'Checklist design review: hierarchy, tap target, empty state, loading state, dan copy yang jelas.',
                  onTap: () => Get.toNamed(Routes.COMMENTS),
                ),
              ],
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: 60,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: c.primarySoft,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: const Icon(
                        FluentIcons.bookmark_multiple_24_regular,
                        size: 32,
                        color: AppColors.primary500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Belum ada yang tersimpan',
                      style: AppFonts.satoshiStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kamu bisa menyimpan postingan, proyek, atau lomba yang menarik dengan menekan ikon simpan untuk akses cepat nanti.',
                      textAlign: TextAlign.center,
                      style: AppFonts.satoshiStyle(
                        fontSize: 14,
                        color: c.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () => Get.toNamed(Routes.EXPLORE),
                        icon: const Icon(FluentIcons.search_24_regular, size: 16),
                        label: const Text('Jelajahi Postingan'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppC.of(context).border),
                          foregroundColor: AppC.of(context).textPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => setState(() => _showDemo = true),
                      child: Text(
                        'Lihat contoh',
                        style: AppFonts.satoshiStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: c.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
