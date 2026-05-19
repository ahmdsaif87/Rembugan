import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_chrome.dart';
import '../../../routes/app_pages.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool isDark = false;
  String googleEmail = 'nanda.saif87@gmail.com';

  @override
  Widget build(BuildContext context) {
    // Premium theme-aware local styling for instant visual feedback
    final backgroundColor = isDark ? const Color(0xFF0F0F0F) : AppColors.background;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtitleColor = isDark ? Colors.white60 : AppColors.textSecondary;
    final borderColor = isDark ? const Color(0xFF2E2E2E) : AppColors.border;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: AppLayeredBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Custom Clean Header
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: Get.back,
                      icon: Icon(
                        FluentIcons.arrow_left_24_regular,
                        color: textColor,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pengaturan',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.headingStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          Text(
                            'Akun, privasi, dan preferensi',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.satoshiStyle(
                              fontSize: 12,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 0.5,
                color: borderColor,
              ),
              
              // Settings Body List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // --- SECTION 1: AKUN & KEAMANAN ---
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'AKUN & KEAMANAN',
                        style: AppFonts.satoshiStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white38 : AppColors.textTertiary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    // Google Account Tile
                    _buildSettingsTile(
                      icon: FluentIcons.person_accounts_24_regular,
                      title: 'Akun Google',
                      subtitle: googleEmail == 'Belum ditautkan'
                          ? 'Hubungkan ke akun Google'
                          : 'Tersambung: $googleEmail',
                      cardColor: cardColor,
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                      borderColor: borderColor,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: googleEmail == 'Belum ditautkan'
                              ? AppColors.danger50
                              : AppColors.success50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          googleEmail == 'Belum ditautkan' ? 'Belum Taut' : 'Aktif',
                          style: AppFonts.satoshiStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: googleEmail == 'Belum ditautkan'
                                ? AppColors.danger700
                                : AppColors.success700,
                          ),
                        ),
                      ),
                      onTap: () => _showGoogleAccountSheet(context, isDark),
                    ),

                    // Change Password Tile
                    _buildSettingsTile(
                      icon: FluentIcons.key_24_regular,
                      title: 'Ganti Password',
                      subtitle: 'Perbarui kata sandi akun Anda',
                      cardColor: cardColor,
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                      borderColor: borderColor,
                      onTap: () => _showChangePasswordSheet(context, isDark),
                    ),

                    const SizedBox(height: 18),

                    // --- SECTION 2: PREFERENSI ---
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'PREFERENSI',
                        style: AppFonts.satoshiStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white38 : AppColors.textTertiary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    // Theme selector (Inside a satisfying custom widget tile)
                    Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isDark ? FluentIcons.weather_moon_24_regular : FluentIcons.weather_sunny_24_regular,
                                color: textColor,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tema Tampilan',
                                      style: AppFonts.satoshiStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      ),
                                    ),
                                    Text(
                                      'Sesuaikan kenyamanan visual Anda',
                                      style: AppFonts.satoshiStyle(
                                        fontSize: 11.5,
                                        color: subtitleColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // Custom Premium Segmented Toggle
                          Container(
                            height: 38,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF262626) : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isDark = false;
                                      });
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: !isDark ? (isDark ? const Color(0xFF1E1E1E) : Colors.white) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: !isDark
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.04),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 1.5),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            FluentIcons.weather_sunny_24_regular,
                                            size: 15,
                                            color: !isDark ? AppColors.textPrimary : AppColors.textTertiary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Terang',
                                            style: AppFonts.satoshiStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: !isDark ? AppColors.textPrimary : AppColors.textTertiary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isDark = true;
                                      });
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isDark ? (isDark ? const Color(0xFF1E1E1E) : Colors.white) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: isDark
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.12),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 1.5),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            FluentIcons.weather_moon_24_regular,
                                            size: 15,
                                            color: isDark ? Colors.white : AppColors.textTertiary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Gelap',
                                            style: AppFonts.satoshiStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? Colors.white : AppColors.textTertiary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // --- SECTION 3: TENTANG ---
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'TENTANG',
                        style: AppFonts.satoshiStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white38 : AppColors.textTertiary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    
                    _buildSettingsTile(
                      icon: FluentIcons.info_24_regular,
                      title: 'Versi Aplikasi',
                      subtitle: '1.0.0 (Premium Startup UI)',
                      cardColor: cardColor,
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                      borderColor: borderColor,
                    ),

                    const SizedBox(height: 18),

                    // --- SECTION 4: KELUAR ---
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'SESI',
                        style: AppFonts.satoshiStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white38 : AppColors.textTertiary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    _buildSettingsTile(
                      icon: Icons.logout,
                      title: 'Keluar dari Akun',
                      subtitle: 'Selesaikan sesi Anda di perangkat ini',
                      cardColor: cardColor,
                      textColor: const Color(0xFFEF4444),
                      subtitleColor: subtitleColor,
                      borderColor: borderColor,
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFFEF4444),
                        size: 18,
                      ),
                      onTap: () => _showLogoutConfirmSheet(context, isDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color cardColor,
    required Color textColor,
    required Color subtitleColor,
    required Color borderColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minVerticalPadding: 14,
        leading: Icon(icon, color: textColor, size: 20),
        title: Text(
          title,
          style: AppFonts.satoshiStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppFonts.satoshiStyle(
            fontSize: 11.5,
            color: subtitleColor,
          ),
        ),
        trailing: trailing ?? Icon(
          Icons.chevron_right,
          color: isDark ? Colors.white38 : AppColors.textTertiary,
          size: 18,
        ),
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context, bool isDark) {
    final currentPw = TextEditingController();
    final newPw = TextEditingController();
    final confirmPw = TextEditingController();

    final textStyle = AppFonts.satoshiStyle(
      fontSize: 13.5,
      fontWeight: FontWeight.w600,
      color: isDark ? Colors.white : AppColors.textPrimary,
    );

    final inputDecoration = (String hint) => InputDecoration(
      filled: true,
      fillColor: isDark ? const Color(0xFF262626) : const Color(0xFFF9FAFB),
      hintText: hint,
      hintStyle: AppFonts.satoshiStyle(
        fontSize: 13,
        color: isDark ? Colors.white38 : AppColors.textTertiary.withValues(alpha: 0.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      isDense: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF2E2E2E) : AppColors.border.withValues(alpha: 0.8),
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDark ? Colors.white54 : AppColors.textPrimary.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF2E2E2E) : AppColors.border.withValues(alpha: 0.8),
          width: 1.0,
        ),
      ),
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF444444) : const Color(0xFFD4D9E2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Ganti Password',
                style: AppFonts.headingStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 18),
              
              Text(
                'PASSWORD SEKARANG',
                style: AppFonts.satoshiStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white38 : AppColors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: currentPw,
                obscureText: true,
                decoration: inputDecoration('Masukkan password saat ini'),
                style: textStyle,
              ),
              const SizedBox(height: 14),

              Text(
                'PASSWORD BARU',
                style: AppFonts.satoshiStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white38 : AppColors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: newPw,
                obscureText: true,
                decoration: inputDecoration('Masukkan password baru'),
                style: textStyle,
              ),
              const SizedBox(height: 14),

              Text(
                'KONFIRMASI PASSWORD BARU',
                style: AppFonts.satoshiStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white38 : AppColors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: confirmPw,
                obscureText: true,
                decoration: inputDecoration('Ulangi password baru'),
                style: textStyle,
              ),
              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 44,
                child: GestureDetector(
                  onTap: () {
                    if (newPw.text == confirmPw.text && newPw.text.isNotEmpty) {
                      Get.back();
                      Get.snackbar(
                        'Sukses',
                        'Password berhasil diperbarui!',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: isDark ? const Color(0xFF2E2E2E) : Colors.black,
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16),
                        borderRadius: 12,
                      );
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Perbarui Password',
                      style: AppFonts.satoshiStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGoogleAccountSheet(BuildContext context, bool isDark) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF444444) : const Color(0xFFD4D9E2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      FluentIcons.person_accounts_24_regular,
                      size: 20,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Akun Google Terhubung',
                          style: AppFonts.satoshiStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          googleEmail,
                          style: AppFonts.satoshiStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Tautan ini digunakan untuk mempermudah sinkronisasi data proyek, obrolan, dan keamanan akun Anda.',
                style: AppFonts.satoshiStyle(
                  fontSize: 12.5,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        Get.showOverlay(
                          asyncFunction: () async {
                            await Future<void>.delayed(const Duration(milliseconds: 600));
                            setState(() {
                              googleEmail = 'nanda.dev@gmail.com';
                            });
                            Get.snackbar(
                              'Sukses',
                              'Akun Google berhasil diubah ke nanda.dev@gmail.com',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: isDark ? const Color(0xFF2E2E2E) : Colors.black,
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(16),
                              borderRadius: 12,
                            );
                          },
                          loadingWidget: const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        );
                      },
                      child: Container(
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Ganti Akun',
                          style: AppFonts.satoshiStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        setState(() {
                          googleEmail = 'Belum ditautkan';
                        });
                        Get.snackbar(
                          'Sukses',
                          'Tautan Akun Google berhasil diputuskan.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: isDark ? const Color(0xFF2E2E2E) : Colors.black,
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                      },
                      child: Container(
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? const Color(0xFF3E3E3E) : AppColors.border,
                          ),
                        ),
                        child: Text(
                          'Putuskan',
                          style: AppFonts.satoshiStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmSheet(BuildContext context, bool isDark) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF444444) : const Color(0xFFD4D9E2),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.logout,
                    size: 20,
                    color: Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Keluar Akun?',
                        style: AppFonts.satoshiStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Selesaikan sesi aktif Anda',
                        style: AppFonts.satoshiStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Apakah Anda yakin ingin keluar dari Rembugan? Anda harus masuk kembali menggunakan email dan password untuk mengakses proyek dan obrolan Anda.',
              style: AppFonts.satoshiStyle(
                fontSize: 12.5,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                      Get.showOverlay(
                        asyncFunction: () async {
                          await Future<void>.delayed(const Duration(milliseconds: 600));
                          Get.offAllNamed(Routes.LOGIN);
                          Get.snackbar(
                            'Berhasil Keluar',
                            'Sampai jumpa kembali di Rembugan!',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.black,
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                          );
                        },
                        loadingWidget: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      );
                    },
                    child: Container(
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Ya, Keluar',
                        style: AppFonts.satoshiStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? const Color(0xFF3E3E3E) : AppColors.border,
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: AppFonts.satoshiStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
