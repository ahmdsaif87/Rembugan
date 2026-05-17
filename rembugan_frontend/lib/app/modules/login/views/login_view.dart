import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import '../../../core/theme/theme.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND PALING BAWAH (Warna Paling Gelap)
          Container(
            height: Get.height * 0.45, // Ambil sekitar 45% layar atas
            color: AppColors.textPrimary,
          ),

          // 2. LENGKUNGAN KANAN ATAS (Warna Tengah)
          Positioned(
            top: -50,
            left: -130,
            child: Container(
              width: 450,
              height: 450,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF242424),
              ),
            ),
          ),

          // 3. LENGKUNGAN KIRI BAWAH (Warna Paling Terang)
          Positioned(
            top: -50,
            left: -250,
            child: Container(
              width: 450,
              height: 450,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF353535),
              ),
            ),
          ),

          // 4. KONTEN TEKS HEADER (Tombol Back, Judul, Subjudul)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tombol Kembali
                  _buildBackButton(),

                  const SizedBox(height: 30),

                  // Judul
                  Text(
                    'Selamat Datang di',
                    style: AppFonts.generalSansStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  Text(
                    'Rembugan.',
                    style: AppFonts.generalSansStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Subjudul
                  Text(
                    'Masuk ke akunmu untuk menemukan rekan dan proyek hebat hari ini.',
                    style: AppFonts.generalSansStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. FORM PUTIH (Melengkung ke atas)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: Get.height * 0.73, // Mengambil 65% layar bawah
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: _buildFormContent(),
            ),
          ),
        ],
      ),
    );
  }

  // Tombol kembali (circular container dengan border putih)
  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 1.2,
          ),
        ),
        child: const Center(
          child: Icon(
            FluentIcons.arrow_left_24_regular,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // FORM CONTENT (isi di dalam container putih)
  // ═══════════════════════════════════════════════════════════
  Widget _buildFormContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            // ── Input: Email atau NIM ──
            _buildInputLabel('Email atau NIM'),
            const SizedBox(height: 8),
            _buildEmailOrNimField(),
            const SizedBox(height: 20),

            // ── Input: Kata Sandi ──
            _buildInputLabel('Kata Sandi'),
            const SizedBox(height: 8),
            _buildPasswordField(),
            const SizedBox(height: 10),

            // ── Link Lupa Sandi ──
            _buildForgotPasswordLink(),
            const SizedBox(height: 24),

            // ── Row Tombol Masuk + Biometrik ──
            _buildActionButtons(),
            const SizedBox(height: 24),

            // ── Divider "Atau" ──
            _buildOrDivider(),
            const SizedBox(height: 24),

            // ── Tombol Login Google ──
            _buildGoogleButton(),
            const SizedBox(height: 12),

            // ── Tombol Masuk sebagai Tamu ──
            _buildGuestButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Label untuk input field
  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: AppFonts.generalSansStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  // Input field Email atau NIM
  Widget _buildEmailOrNimField() {
    return TextFormField(
      controller: controller.emailOrNimController,
      keyboardType: TextInputType.emailAddress,
      style: AppFonts.generalSansStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      decoration: const InputDecoration(
        hintText: 'nanda@gmail.com or 23090122',
        prefixIcon: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Icon(
            FluentIcons.contact_card_24_regular,
            color: AppColors.neutralDarker,
            size: 22,
          ),
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 50, minHeight: 0),
      ),
    );
  }

  // Input field Kata Sandi (dengan toggle visibility)
  Widget _buildPasswordField() {
    return Obx(
      () => TextFormField(
        controller: controller.passwordController,
        obscureText: controller.isPasswordHidden.value,
        style: AppFonts.generalSansStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Masukan kata sandi',
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(
              FluentIcons.lock_closed_24_regular,
              color: AppColors.neutralDarker,
              size: 22,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 50,
            minHeight: 0,
          ),
          suffixIcon: GestureDetector(
            onTap: controller.togglePasswordVisibility,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Icon(
                controller.isPasswordHidden.value
                    ? FluentIcons.eye_off_24_regular
                    : FluentIcons.eye_24_regular,
                color: AppColors.neutralDarker,
                size: 20,
              ),
            ),
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 0,
          ),
        ),
      ),
    );
  }

  // Link "Lupa kata sandi"
  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: controller.onForgotPassword,
        child: Text(
          'Lupa kata sandi',
          style: AppFonts.generalSansStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryNormal,
          ),
        ),
      ),
    );
  }

  // Row: Tombol Masuk (Expanded) + Tombol Biometrik (Square)
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Tombol Masuk
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: controller.onLogin,
              child: Text(
                'Masuk',
                style: AppFonts.generalSansStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Divider dengan teks "Atau"
  Widget _buildOrDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppColors.neutralDark, thickness: 0.8),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Atau',
            style: AppFonts.generalSansStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.neutralDarker,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: AppColors.neutralDark, thickness: 0.8),
        ),
      ],
    );
  }

  // Tombol Login with Google
  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: controller.onGoogleLogin,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.neutralDark, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('lib/assets/icons/google.png', width: 22, height: 22),
            const SizedBox(width: 12),
            Text(
              'Login with Google',
              style: AppFonts.generalSansStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tombol Masuk sebagai Tamu
  Widget _buildGuestButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: controller.onGuestLogin,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.neutralDark, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              FluentIcons.guest_24_regular,
              color: AppColors.textPrimary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              'Masuk sebagai tamu',
              style: AppFonts.generalSansStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
