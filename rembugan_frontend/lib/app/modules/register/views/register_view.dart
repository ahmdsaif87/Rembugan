import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_chrome.dart';
import '../../../routes/app_pages.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 24, 14, AppSpacing.xl),
          children: [
            _buildBackButton(),
            const SizedBox(height: 38),
            Obx(() => controller.showOtpStep.value
                ? _buildOtpStep(c)
                : _buildRegisterStep(c)),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          if (controller.showOtpStep.value) {
            controller.showOtpStep.value = false;
          } else {
            Get.back();
          }
        },
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            FluentIcons.chevron_left_24_regular,
            color: AppColors.primary500,
            size: 23,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterStep(AppC c) {
    return Column(
      children: [
        _buildHeader(c),
        const SizedBox(height: 50),
        _buildFormContent(c),
      ],
    );
  }

  Widget _buildOtpStep(AppC c) {
    return Column(
      children: [
        _buildOtpHeader(c),
        const SizedBox(height: 50),
        _buildOtpForm(c),
      ],
    );
  }

  Widget _buildHeader(AppC c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text.rich(
          TextSpan(
            text: 'Buat Akun\n',
            style: AppFonts.headingStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: c.grey900,
              height: 1.2,
            ),
            children: [
              TextSpan(
                text: 'Rembugan.',
                style: AppFonts.headingStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: c.textPrimary,
                  height: 1.18,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Daftar dan mulai berkolaborasi dengan tim impianmu.',
          textAlign: TextAlign.center,
          style: AppFonts.satoshiStyle(
            fontSize: 15,
            color: c.grey600,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpHeader(AppC c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          FluentIcons.mail_24_regular,
          color: AppColors.primary500,
          size: 48,
        ),
        const SizedBox(height: 20),
        Text(
          'Verifikasi Email',
          textAlign: TextAlign.center,
          style: AppFonts.headingStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Kode OTP telah dikirim ke email kamu.\nCek inbox atau spam.',
          textAlign: TextAlign.center,
          style: AppFonts.satoshiStyle(
            fontSize: 15,
            color: c.grey600,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildFormContent(AppC c) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            controller: controller.fullNameController,
            labelText: 'Nama Lengkap',
            hintText: 'Nanda Pratama',
            keyboardType: TextInputType.name,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Nama lengkap wajib diisi' : null,
          ),
          const SizedBox(height: 28),
          AppTextField(
            controller: controller.emailController,
            labelText: 'Email',
            hintText: 'nanda@gmail.com',
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
              if (!v.contains('@')) return 'Email tidak valid';
              return null;
            },
          ),
          const SizedBox(height: 28),
          _buildPasswordField(c),
          const SizedBox(height: 28),
          _buildConfirmPasswordField(c),
          const SizedBox(height: 30),
          _buildRegisterButton(),
          const SizedBox(height: 20),
          _buildLoginLink(),
        ],
      ),
    );
  }

  Widget _buildOtpForm(AppC c) {
    return Form(
      key: controller.otpFormKey,
      child: Column(
        children: [
          AppTextField(
            controller: controller.otpController,
            labelText: 'Kode OTP',
            hintText: '000000',
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Kode OTP wajib diisi';
              if (v.trim().length != 6) return 'Kode OTP harus 6 digit';
              return null;
            },
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: controller.resendOtp,
              child: Text(
                'Kirim ulang OTP',
                style: AppTextStyles.button(
                  fontSize: 14,
                  color: AppTextColors.textLinks,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          _buildVerifyButton(),
        ],
      ),
    );
  }

  Widget _buildPasswordField(AppC c) {
    return Obx(
      () => AppTextField(
        controller: controller.passwordController,
        labelText: 'Kata Sandi',
        hintText: 'Minimal 8 karakter',
        obscureText: controller.isPasswordHidden.value,
        suffixIcon: GestureDetector(
          onTap: controller.togglePasswordVisibility,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Icon(
              controller.isPasswordHidden.value
                  ? FluentIcons.eye_off_24_regular
                  : FluentIcons.eye_24_regular,
              color: c.grey400,
              size: 20,
            ),
          ),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Kata sandi wajib diisi';
          if (v.length < 8) return 'Minimal 8 karakter';
          return null;
        },
      ),
    );
  }

  Widget _buildConfirmPasswordField(AppC c) {
    return Obx(
      () => AppTextField(
        controller: controller.confirmPasswordController,
        labelText: 'Konfirmasi Kata Sandi',
        hintText: 'Ulangi kata sandi',
        obscureText: controller.isConfirmPasswordHidden.value,
        suffixIcon: GestureDetector(
          onTap: controller.toggleConfirmPasswordVisibility,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Icon(
              controller.isConfirmPasswordHidden.value
                  ? FluentIcons.eye_off_24_regular
                  : FluentIcons.eye_24_regular,
              color: c.grey400,
              size: 20,
            ),
          ),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Konfirmasi kata sandi wajib diisi';
          if (v != controller.passwordController.text) return 'Kata sandi tidak cocok';
          return null;
        },
      ),
    );
  }

  Widget _buildRegisterButton() {
    return AppButton(
      label: 'Daftar',
      onTap: controller.onRegister,
    );
  }

  Widget _buildVerifyButton() {
    return AppButton(
      label: 'Verifikasi',
      onTap: controller.onVerifyOtp,
    );
  }

  Widget _buildLoginLink() {
    final c = AppC.of(Get.context!);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah punya akun? ',
          style: AppFonts.satoshiStyle(
            fontSize: 14,
            color: c.grey600,
          ),
        ),
        GestureDetector(
          onTap: () => Get.offNamed(Routes.LOGIN),
          child: Text(
            'Masuk',
            style: AppTextStyles.button(
              fontSize: 14,
              color: AppTextColors.textLinks,
            ),
          ),
        ),
      ],
    );
  }
}
