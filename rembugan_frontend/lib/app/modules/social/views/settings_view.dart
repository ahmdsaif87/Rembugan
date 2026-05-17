import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import 'social_components.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SocialScaffold(
      title: 'Pengaturan',
      subtitle: 'Akun, privasi, dan preferensi',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SettingTile(
            icon: FluentIcons.person_24_regular,
            title: 'Akun',
            subtitle: 'Email, NIM, dan keamanan login',
          ),
          _SettingTile(
            icon: FluentIcons.alert_24_regular,
            title: 'Notifikasi',
            subtitle: 'Atur aktivitas yang ingin diberi tahu',
          ),
          _SettingTile(
            icon: FluentIcons.lock_closed_24_regular,
            title: 'Privasi',
            subtitle: 'Kontrol profil dan visibilitas postingan',
          ),
          _SettingTile(
            icon: FluentIcons.color_24_regular,
            title: 'Tampilan',
            subtitle: 'Tema, ukuran teks, dan preferensi visual',
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        minVerticalPadding: 14,
        leading: Icon(icon, color: AppColors.textPrimary),
        title: Text(
          title,
          style: AppFonts.generalSansStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppFonts.generalSansStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}
