import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSurfaceColors.surfaceWhite,
      body: SafeArea(
        child: Obx(
          () => ListView(
            padding: const EdgeInsets.fromLTRB(14, 24, 14, AppSpacing.xl),
            children: [
              _buildBackButton(),
              const SizedBox(height: 38),
              _buildHeader(),
              const SizedBox(height: 50),
              controller.step.value == 0
                  ? _buildEmailForm()
                  : _buildResetPasswordForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          if (controller.step.value == 1) {
            controller.step.value = 0;
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

  Widget _buildHeader() {
    final title = controller.step.value == 0 ? 'Lupa Kata Sandi' : 'Kata Sandi Baru';
    final subtitle = controller.step.value == 0
        ? 'Masukkan email atau NIM terdaftar Anda untuk menerima instruksi pemulihan.'
        : 'Silakan masukkan kata sandi baru Anda untuk memperbarui kata sandi akun.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppFonts.headingStyle(
            fontSize: 27,
            fontWeight: FontWeight.w800,
            color: AppColors.primary800,
            height: 1.18,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppFonts.satoshiStyle(
            fontSize: 15,
            color: AppColors.grey600,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return Form(
      key: controller.formKeyEmail,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputLabel('Email atau NIM'),
          const SizedBox(height: AppSpacing.xs),
          _buildEmailOrNimField(),
          const SizedBox(height: 32),
          _buildActionButton('Kirim Tautan Atur Ulang', controller.onSendResetLink),
        ],
      ),
    );
  }

  Widget _buildResetPasswordForm() {
    return Form(
      key: controller.formKeyReset,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputLabel('Kata Sandi Baru'),
          const SizedBox(height: AppSpacing.xs),
          _buildNewPasswordField(),
          const SizedBox(height: 24),
          _buildInputLabel('Konfirmasi Kata Sandi Baru'),
          const SizedBox(height: AppSpacing.xs),
          _buildConfirmPasswordField(),
          const SizedBox(height: 32),
          _buildActionButton('Simpan Kata Sandi', controller.onResetPassword),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.button(color: AppTextColors.textPrimaryBlack),
    );
  }

  Widget _buildEmailOrNimField() {
    return TextFormField(
      controller: controller.emailOrNimController,
      keyboardType: TextInputType.emailAddress,
      style: AppTextStyles.bodyMedium(color: AppTextColors.textPrimaryBlack),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Kolom ini wajib diisi';
        }
        return null;
      },
      decoration: const InputDecoration(
        hintText: 'nanda@gmail.com atau 23090122',
        prefixIcon: null,
        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }

  Widget _buildNewPasswordField() {
    return Obx(
      () => TextFormField(
        controller: controller.newPasswordController,
        obscureText: controller.isNewPasswordHidden.value,
        style: AppTextStyles.bodyMedium(color: AppTextColors.textPrimaryBlack),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Masukkan kata sandi baru';
          }
          if (value.length < 6) {
            return 'Kata sandi minimal 6 karakter';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: 'Masukkan kata sandi baru',
          suffixIcon: GestureDetector(
            onTap: controller.toggleNewPasswordVisibility,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Icon(
                controller.isNewPasswordHidden.value
                    ? FluentIcons.eye_off_24_regular
                    : FluentIcons.eye_24_regular,
                color: AppIconColors.iconGrey,
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

  Widget _buildConfirmPasswordField() {
    return Obx(
      () => TextFormField(
        controller: controller.confirmPasswordController,
        obscureText: controller.isConfirmPasswordHidden.value,
        style: AppTextStyles.bodyMedium(color: AppTextColors.textPrimaryBlack),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Ulangi kata sandi baru';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: 'Masukkan ulang kata sandi baru',
          suffixIcon: GestureDetector(
            onTap: controller.toggleConfirmPasswordVisibility,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Icon(
                controller.isConfirmPasswordHidden.value
                    ? FluentIcons.eye_off_24_regular
                    : FluentIcons.eye_24_regular,
                color: AppIconColors.iconGrey,
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

  Widget _buildActionButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary500,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(
          label,
          style: AppTextStyles.button(
            fontSize: 16,
            color: AppTextColors.textPrimaryWhite,
          ),
        ),
      ),
    );
  }
}
