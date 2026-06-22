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
    final c = AppC.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 24, 14, AppSpacing.xl),
          children: [
            _buildBackButton(),
            const SizedBox(height: 38),
            _buildHeader(c),
            const SizedBox(height: 50),
            _buildFormContent(c),
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

  Widget _buildHeader(AppC c) {
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
                  color: c.textPrimary,
                  height: 1.18,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: AppFonts.headingStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: c.grey900,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Masuk dan jelajahi berbagai peluang kolaborasi.',
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
<<<<<<< Updated upstream
            controller: controller.emailOrNimController,
            labelText: 'Email atau NIM',
            hintText: 'nanda@gmail.com atau 23090122',
            keyboardType: TextInputType.emailAddress,
=======
            controller: controller.emailController,
            labelText: 'NIM / Email',
            hintText: 'Masukkan NIM atau email',
>>>>>>> Stashed changes
          ),
          const SizedBox(height: 28),
          _buildPasswordField(c),
          const SizedBox(height: 18),
          _buildForgotPasswordLink(),
          const SizedBox(height: 22),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildPasswordField(AppC c) {
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
              color: c.grey400,
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
<<<<<<< Updated upstream
    return AppButton(label: 'Masuk', onTap: controller.onLogin);
=======
    return Column(
      children: [
        AppButton(label: 'Masuk', onTap: controller.onLogin),
        const SizedBox(height: 20),
        _buildCampusInfo(),
      ],
    );
  }

  Widget _buildCampusInfo() {
    final c = AppC.of(Get.context!);
    return Center(
      child: Text(
        'Akun disediakan oleh kampus.\nHubungi admin jika belum punya akun.',
        textAlign: TextAlign.center,
        style: AppFonts.satoshiStyle(
          fontSize: 13,
          color: c.grey400,
        ),
      ),
    );
>>>>>>> Stashed changes
  }
}
