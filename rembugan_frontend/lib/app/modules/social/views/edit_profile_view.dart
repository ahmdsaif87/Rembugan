import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import 'social_components.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return SocialScaffold(
      title: 'Edit Profil',
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text(
            'Simpan',
            style: AppFonts.generalSansStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(
              children: [
                const CircleAvatar(
                  radius: 44,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=60',
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _Field(label: 'Nama', value: 'Dede Fernanda'),
          const _Field(
            label: 'Headline',
            value: 'Fullstack Developer | Flutter & Node.js Enthusiast',
          ),
          const _Field(
            label: 'Bio',
            value:
                'Software engineer yang fokus pada mobile app, kolaborasi, dan produk berdampak.',
            maxLines: 4,
          ),
          const _Field(label: 'Lokasi', value: 'Malang, Indonesia'),
          const _Field(label: 'Website', value: 'github.com/dedef'),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value, this.maxLines = 1});

  final String label;
  final String value;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppFonts.generalSansStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(initialValue: value, maxLines: maxLines),
        ],
      ),
    );
  }
}
