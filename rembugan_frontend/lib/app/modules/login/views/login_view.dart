import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_chrome.dart';
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
          AppTextField(
            controller: controller.emailOrNimController,
            labelText: 'Email atau NIM',
            hintText: 'nanda@gmail.com atau 23090122',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 28),
          _buildPasswordField(),
          const SizedBox(height: 18),
          _buildForgotPasswordLink(),
          const SizedBox(height: 22),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Obx(
      () => AppTextField(
        controller: controller.passwordController,
        labelText: 'Kata Sandi',
        hintText: 'Masukan kata sandi',
        obscureText: controller.isPasswordHidden.value,
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
    return AppButton(label: 'Masuk', onTap: controller.onLogin);
  }
}
