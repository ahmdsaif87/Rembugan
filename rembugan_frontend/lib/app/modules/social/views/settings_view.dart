import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/theme_service.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_chrome.dart';
import '../../../routes/app_pages.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  String? linkedEmail;

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppC.of(context);
    final cardColor = c.card;
    final textColor = c.textPrimary;
    final subtitleColor = c.textSecondary;
    final borderColor = c.border;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                        FluentIcons.chevron_left_24_regular,
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
              Container(height: 0.5, color: borderColor),

              // Settings Body List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    // --- SECTION 1: AKUN & KEAMANAN ---
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.xxs,
                        bottom: AppSpacing.xs,
                      ),
                      child: Text(
                        'AKUN & KEAMANAN',
                        style: AppFonts.satoshiStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: c.textTertiary.withValues(alpha: isDark ? 0.38 : 1.0),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    // Linked email tile
                    _buildSettingsTile(
                      icon: FluentIcons.mail_24_regular,
                      title: 'Email Tertaut',
                      subtitle: linkedEmail == null
                          ? 'Tautkan email untuk pemulihan akun'
                          : 'Terverifikasi: $linkedEmail',
                      cardColor: cardColor,
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                      borderColor: borderColor,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: linkedEmail == null
                              ? AppColors.danger50
                              : AppColors.success50,
                          borderRadius: BorderRadius.circular(AppRadius.xxs),
                        ),
                        child: Text(
                          linkedEmail == null ? 'Belum Taut' : 'Aktif',
                          style: AppFonts.satoshiStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: linkedEmail == null
                                ? AppColors.danger700
                                : AppColors.success700,
                          ),
                        ),
                      ),
                      onTap: () => _showLinkEmailSheet(context, isDark),
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
                      padding: const EdgeInsets.only(
                        left: AppSpacing.xxs,
                        bottom: AppSpacing.xs,
                      ),
                      child: Text(
                        'PREFERENSI',
                        style: AppFonts.satoshiStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: c.textTertiary.withValues(alpha: isDark ? 0.38 : 1.0),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    // Theme selector (Inside a satisfying custom widget tile)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isDark
                                    ? FluentIcons.weather_moon_24_regular
                                    : FluentIcons.weather_sunny_24_regular,
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
                              color: c.grey100,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      themeService.setDarkMode(false);
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: !isDark
                                            ? c.card
                                            : AppColors.transparent,
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.xs,
                                        ),
                                        boxShadow: !isDark
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.black
                                                      .withValues(alpha: 0.04),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 1.5),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            FluentIcons
                                                .weather_sunny_24_regular,
                                            size: 15,
                                            color: !isDark
                                                ? c.textPrimary
                                                : c.textTertiary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Terang',
                                            style: AppFonts.satoshiStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: !isDark
                                                  ? c.textPrimary
                                                  : c.textTertiary,
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
                                      themeService.setDarkMode(true);
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? c.card
                                            : AppColors.transparent,
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.xs,
                                        ),
                                        boxShadow: isDark
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.black
                                                      .withValues(alpha: 0.12),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 1.5),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            FluentIcons.weather_moon_24_regular,
                                            size: 15,
                                            color: isDark
                                                ? AppColors.white
                                                : c.textTertiary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Gelap',
                                            style: AppFonts.satoshiStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: isDark
                                                  ? AppColors.white
                                                  : c.textTertiary,
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
                      padding: const EdgeInsets.only(
                        left: AppSpacing.xxs,
                        bottom: AppSpacing.xs,
                      ),
                      child: Text(
                        'TENTANG',
                        style: AppFonts.satoshiStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: c.textTertiary.withValues(alpha: isDark ? 0.38 : 1.0),
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
                      padding: const EdgeInsets.only(
                        left: AppSpacing.xxs,
                        bottom: AppSpacing.xs,
                      ),
                      child: Text(
                        'SESI',
                        style: AppFonts.satoshiStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: c.textTertiary.withValues(alpha: isDark ? 0.38 : 1.0),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    _buildSettingsTile(
                      icon: Icons.logout,
                      title: 'Keluar dari Akun',
                      subtitle: 'Selesaikan sesi Anda di perangkat ini',
                      cardColor: cardColor,
                      textColor: AppColors.error500,
                      subtitleColor: subtitleColor,
                      borderColor: borderColor,
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppColors.error500,
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
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Icon(icon, color: textColor, size: 20),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppFonts.satoshiStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppFonts.satoshiStyle(
                          fontSize: 11.5,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                trailing ??
                    Icon(
                      FluentIcons.chevron_right_24_regular,
                      color: subtitleColor,
                      size: 18,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showChangePasswordSheet(
    BuildContext context,
    bool isDark,
  ) async {
    final c = AppC.of(context);
    final currentPw = TextEditingController();
    final newPw = TextEditingController();
    final confirmPw = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          decoration: BoxDecoration(
            color: c.surfaceElevated,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
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
                      color: c.grey300,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Ganti Password',
                  style: AppFonts.headingStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 18),

                Text(
                  'PASSWORD SEKARANG',
                  style: AppFonts.satoshiStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: c.textTertiary.withValues(alpha: isDark ? 0.38 : 1.0),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                AppTextField(
                  controller: currentPw,
                  obscureText: true,
                  hintText: 'Masukkan password saat ini',
                ),
                const SizedBox(height: 14),

                Text(
                  'PASSWORD BARU',
                  style: AppFonts.satoshiStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: c.textTertiary.withValues(alpha: isDark ? 0.38 : 1.0),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                AppTextField(
                  controller: newPw,
                  obscureText: true,
                  hintText: 'Masukkan password baru',
                ),
                const SizedBox(height: 14),

                Text(
                  'KONFIRMASI PASSWORD BARU',
                  style: AppFonts.satoshiStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: c.textTertiary.withValues(alpha: isDark ? 0.38 : 1.0),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                AppTextField(
                  controller: confirmPw,
                  obscureText: true,
                  hintText: 'Ulangi password baru',
                ),
                const SizedBox(height: 22),

                AppButton(
                  label: 'Perbarui Password',
                  onTap: () {
                    if (newPw.text == confirmPw.text && newPw.text.isNotEmpty) {
                      Get.back();
                      Get.snackbar(
                        'Sukses',
                        'Password berhasil diperbarui!',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.primary500,
                        colorText: AppColors.white,
                        margin: const EdgeInsets.all(AppSpacing.md),
                        borderRadius: 12,
                      );
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );

    currentPw.dispose();
    newPw.dispose();
    confirmPw.dispose();
  }

  Future<void> _showLinkEmailSheet(BuildContext context, bool isDark) async {
    final c = AppC.of(context);
    final emailController = TextEditingController(text: linkedEmail);
    final otpController = TextEditingController();
    var otpSent = false;
    String? errorMessage;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) => Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: BoxDecoration(
              color: c.surfaceElevated,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: c.grey300,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    linkedEmail == null ? 'Tautkan Email' : 'Ganti Email',
                    style: AppFonts.headingStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    otpSent
                        ? 'Masukkan kode OTP 6 digit yang dikirim ke ${emailController.text.trim()}.'
                        : 'Email akan diverifikasi dengan kode OTP sebelum ditautkan ke akun.',
                    style: AppFonts.satoshiStyle(
                      fontSize: 12.5,
                      color: c.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: emailController,
                    enabled: !otpSent,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    labelText: 'Alamat email',
                    hintText: 'nama@email.com',
                    prefixIcon: const Icon(FluentIcons.mail_24_regular),
                  ),
                  if (otpSent) ...[
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      labelText: 'Kode OTP',
                      hintText: '000000',
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          otpController.clear();
                          setModalState(() {
                            errorMessage = null;
                          });
                          Get.snackbar(
                            'OTP Dikirim Ulang',
                            'Kode baru telah dikirim ke ${emailController.text.trim()}',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        child: const Text('Kirim ulang OTP'),
                      ),
                    ),
                  ],
                  if (errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      errorMessage!,
                      style: AppFonts.satoshiStyle(
                        fontSize: 12,
                        color: AppColors.error500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: FilledButton(
                      onPressed: () {
                        final email = emailController.text.trim();
                        if (!otpSent) {
                          if (!GetUtils.isEmail(email)) {
                            setModalState(() {
                              errorMessage =
                                  'Masukkan alamat email yang valid.';
                            });
                            return;
                          }
                          setModalState(() {
                            otpSent = true;
                            errorMessage = null;
                          });
                          return;
                        }

                        if (!RegExp(r'^\d{6}$').hasMatch(otpController.text)) {
                          setModalState(() {
                            errorMessage =
                                'Kode OTP harus terdiri dari 6 digit.';
                          });
                          return;
                        }

                        setState(() {
                          linkedEmail = email;
                        });
                        Get.back();
                        Get.snackbar(
                          'Email Terverifikasi',
                          '$email berhasil ditautkan ke akun.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.primary500,
                          colorText: AppColors.white,
                          margin: const EdgeInsets.all(AppSpacing.md),
                          borderRadius: 12,
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary500,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                      child: Text(otpSent ? 'Verifikasi OTP' : 'Kirim OTP'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    emailController.dispose();
    otpController.dispose();
  }

  void _showLogoutConfirmSheet(BuildContext context, bool isDark) {
    final c = AppC.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
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
                  color: c.grey300,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
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
                    color: AppColors.danger100,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.logout,
                    size: 20,
                    color: AppColors.error500,
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
                          color: c.textPrimary,
                        ),
                      ),
                      Text(
                        'Selesaikan sesi aktif Anda',
                        style: AppFonts.satoshiStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.white54
                              : AppColors.textSecondary,
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
                color: c.textSecondary,
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
                          await Future<void>.delayed(
                            const Duration(milliseconds: 600),
                          );
                          Get.offAllNamed(Routes.LOGIN);
                          Get.snackbar(
                            'Berhasil Keluar',
                            'Sampai jumpa kembali di Rembugan!',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppColors.primary500,
                            colorText: AppColors.white,
                            margin: const EdgeInsets.all(AppSpacing.md),
                            borderRadius: 12,
                          );
                        },
                        loadingWidget: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.error500,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        'Ya, Keluar',
                        style: AppFonts.satoshiStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
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
                        color: AppColors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: c.border,
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: AppFonts.satoshiStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: c.textSecondary,
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
