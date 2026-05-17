import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_chrome.dart';
import 'social_components.dart';

class CreatePostView extends StatefulWidget {
  const CreatePostView({super.key});

  @override
  State<CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  bool _isOffer = false;

  @override
  void initState() {
    super.initState();
    if (GuestGuard.isGuest) {
      Future.microtask(
        () => GuestGuard.showLoginPrompt(feature: 'membuat postingan'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SocialScaffold(
      title: _isOffer ? 'Buat Tawaran' : 'Buat Postingan',
      subtitle: _isOffer
          ? 'Buka peluang kolaborasi dengan konteks yang jelas'
          : 'Bagikan ide kolaborasi dengan jelas',
      actions: [
        TextButton(
          onPressed: Get.back,
          style: TextButton.styleFrom(
            backgroundColor: AppColors.textPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          child: Text(
            'Post',
            style: AppFonts.generalSansStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppSurface(
            shadow: const [],
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundImage: AssetImage(
                        'lib/assets/img/avatar.png',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dede Fernanda',
                          style: AppFonts.generalSansStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Publik',
                          style: AppFonts.generalSansStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _CreateTypeOption(
                        icon: FluentIcons.compose_24_regular,
                        title: 'Postingan',
                        subtitle: 'Update, cerita, diskusi',
                        active: !_isOffer,
                        onTap: () => setState(() => _isOffer = false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _CreateTypeOption(
                        icon: FluentIcons.briefcase_24_regular,
                        title: 'Tawaran',
                        subtitle: 'Cari anggota/proyek',
                        active: _isOffer,
                        onTap: () => setState(() => _isOffer = true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_isOffer) ...[
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Judul tawaran, mis. UI Designer untuk MVP',
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                TextField(
                  minLines: _isOffer ? 6 : 8,
                  maxLines: 12,
                  decoration: InputDecoration(
                    hintText: _isOffer
                        ? 'Jelaskan kebutuhan, skill yang dicari, timeline, dan benefit kolaborasi...'
                        : 'Tulis update, cari anggota tim, atau bagikan progres...',
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppTextPill(
                label: 'Tambah gambar',
                icon: FluentIcons.image_24_regular,
              ),
              if (_isOffer)
                const AppTextPill(
                  label: 'Skill dibutuhkan',
                  icon: FluentIcons.people_24_regular,
                )
              else
                const AppTextPill(
                  label: 'Cari anggota',
                  icon: FluentIcons.people_24_regular,
                ),
              const AppTextPill(
                label: 'Tandai proyek',
                icon: FluentIcons.briefcase_24_regular,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreateTypeOption extends StatelessWidget {
  const _CreateTypeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFF4F5F7) : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: active ? AppColors.textPrimary : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20,
              color: active ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppFonts.interStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.interStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
