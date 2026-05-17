import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_chrome.dart';
import 'social_components.dart';

class OtherProfileView extends StatelessWidget {
  const OtherProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return SocialScaffold(
      title: 'Profil',
      actions: const [
        AppIconButton(icon: FluentIcons.more_horizontal_24_regular),
      ],
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
                      backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/150?img=47',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Raka Pratama',
                            style: AppFonts.headingStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '@raka.design',
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
                  'UI/UX Designer dan product thinker. Mendesain produk kolaborasi kampus dengan fokus pada clarity, flow, dan UX research.',
                  style: AppFonts.generalSansStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    _ProfileMetric(value: '1.2K', label: 'Pengikut'),
                    SizedBox(width: 22),
                    _ProfileMetric(value: '48', label: 'Posting'),
                    SizedBox(width: 22),
                    _ProfileMetric(value: '9', label: 'Kolaborasi'),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Diikuti juga oleh Dede dan 6 koneksi lain',
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
                    AppTextPill(label: 'Figma', active: true),
                    AppTextPill(label: 'Research'),
                    AppTextPill(label: 'Design System'),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (GuestGuard.blockIfGuest('mengikuti profil')) {
                            return;
                          }
                        },
                        child: const Text('Ikuti'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    AppIconButton(
                      icon: FluentIcons.chat_24_regular,
                      onTap: () {
                        if (GuestGuard.blockIfGuest('membuka chat')) return;
                      },
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
              children: [
                _ProfileTab(label: 'Posting', active: true),
                const SizedBox(width: 18),
                _ProfileTab(label: 'Proyek', active: false),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.border),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: SocialPostCard(
              name: 'Raka Pratama',
              handle: '@raka - 1h',
              avatarUrl: 'https://i.pravatar.cc/100?img=47',
              body:
                  'Sedang eksplorasi pattern untuk onboarding komunitas kampus. Yang paling penting: user cepat paham value tanpa kebanyakan teks.',
            ),
          ),
        ],
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
