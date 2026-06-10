import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSurfaceColors.surfaceWhite,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 24, 14, AppSpacing.xl),
          children: [
            _buildBackButton(),
            const SizedBox(height: 38),
            _buildHeader(),
            const SizedBox(height: 50),
            _buildFormContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => Get.back(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text.rich(
          TextSpan(
            text: 'Selamat Datang di\n',
            children: [
              TextSpan(
                text: 'Rembugan.',
                style: AppFonts.headingStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary800,
                  height: 1.18,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: AppFonts.headingStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: AppColors.grey900,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Masuk dan jelajahi berbagai peluang kolaborasi.',
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

  Widget _buildFormContent() {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputLabel('Email atau NIM'),
          const SizedBox(height: AppSpacing.xs),
          _buildEmailOrNimField(),
          const SizedBox(height: 28),
          _buildInputLabel('Kata Sandi'),
          const SizedBox(height: AppSpacing.xs),
          _buildPasswordField(),
          const SizedBox(height: 18),
          _buildForgotPasswordLink(),
          const SizedBox(height: 22),
          _buildActionButtons(),
          const SizedBox(height: 24),
          _buildOrDivider(),
          const SizedBox(height: 24),
          _buildGoogleButton(),
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
      decoration: const InputDecoration(
        hintText: 'nanda@gmail.com atau 23090122',
        prefixIcon: null,
        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Obx(
      () => TextFormField(
        controller: controller.passwordController,
        obscureText: controller.isPasswordHidden.value,
        style: AppTextStyles.bodyMedium(color: AppTextColors.textPrimaryBlack),
        decoration: InputDecoration(
          hintText: 'Masukan kata sandi',
          suffixIcon: GestureDetector(
            onTap: controller.togglePasswordVisibility,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Icon(
                controller.isPasswordHidden.value
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

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: controller.onForgotPassword,
        child: Text(
          'Lupa kata sandi',
          style: AppTextStyles.button(
            fontSize: 14,
            color: AppTextColors.textLinks,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return GestureDetector(
      onTap: controller.onLogin,
      child: Container(
        width: double.infinity,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary500,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(
          'Masuk',
          style: AppTextStyles.button(
            fontSize: 16,
            color: AppTextColors.textPrimaryWhite,
          ),
        ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.grey200, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'Atau',
            style: AppTextStyles.bodySmall(
              color: AppTextColors.textSecondaryDarkGrey,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.grey200, thickness: 1)),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return GestureDetector(
      onTap: controller.onGoogleLogin,
      child: Container(
        width: double.infinity,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.grey300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('lib/assets/icons/google.png', width: 22, height: 22),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Masuk dengan Google',
              style: AppTextStyles.button(
                fontSize: 14,
                color: AppTextColors.textPrimaryBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
