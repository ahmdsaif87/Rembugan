import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import 'social_components.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return SocialScaffold(
      title: 'Notifikasi',
      subtitle: 'Aktivitas terbaru',
      actions: [
        TextButton(
          onPressed: () {},
          child: Text(
            'Tandai dibaca',
            style: AppFonts.interStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: _NotificationCategory(label: 'Terbaru', count: '3 baru'),
          ),
          _NotificationTile(
            avatarUrl: 'https://i.pravatar.cc/100?img=47',
            title: 'Raka membalas komentar Anda',
            subtitle: 'Kalau butuh review UX, aku bisa bantu.',
            time: '8m',
            unread: true,
          ),
          Divider(height: 1, indent: 72, color: AppColors.border),
          _NotificationTile(
            avatarUrl: 'https://i.pravatar.cc/100?img=33',
            title: 'Cameron mengundang Anda ke proyek',
            subtitle: 'Rembugan Dev Team membutuhkan Flutter dev.',
            time: '1j',
            unread: true,
          ),
          Divider(height: 1, indent: 72, color: AppColors.border),
          _NotificationTile(
            avatarUrl: 'https://i.pravatar.cc/100?img=12',
            title: 'Marvin menyimpan postingan Anda',
            subtitle: 'Postingan tentang hackathon bulan depan.',
            time: '2j',
          ),
          Divider(height: 1, indent: 72, color: AppColors.border),
        ],
      ),
    );
  }
}

class _NotificationCategory extends StatelessWidget {
  const _NotificationCategory({required this.label, required this.count});

  final String label;
  final String count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppFonts.headingStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          count,
          style: AppFonts.interStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.avatarUrl,
    required this.title,
    required this.subtitle,
    required this.time,
    this.unread = false,
  });

  final String avatarUrl;
  final String title;
  final String subtitle;
  final String time;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(avatarUrl),
                ),
                if (unread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppFonts.generalSansStyle(
                            fontSize: 13,
                            fontWeight: unread
                                ? FontWeight.w800
                                : FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: AppFonts.generalSansStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppFonts.generalSansStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Tandai sudah dibaca',
              onPressed: () {},
              icon: const Icon(
                FluentIcons.checkmark_circle_24_regular,
                size: 18,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
