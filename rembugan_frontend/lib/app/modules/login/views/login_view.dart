import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_chrome.dart';
import '../../../routes/app_pages.dart';
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
            const SizedBox(height: 8),
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
        onTap: () => Get.offNamed(Routes.ONBOARDING),
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
        SvgPicture.asset(
          'lib/assets/img/logo.svg',
          width: 80,
          height: 80,
        ),
        const SizedBox(height: 8),
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
          Obx(() {
            final msg = controller.errorMessage.value;
            final type = controller.errorType.value;
            if (msg == null) return const SizedBox.shrink();

            final isNetwork = type == LoginErrorType.network;
            final isCredentials = type == LoginErrorType.invalidCredentials;
            final isServer = type == LoginErrorType.server;

            Color bgColor;
            Color borderColor;
            Color iconColor;
            IconData icon;

            if (isNetwork || isServer) {
              bgColor = AppColors.warning50;
              borderColor = AppColors.warning500.withValues(alpha: 0.3);
              iconColor = AppColors.warning500;
              icon = FluentIcons.wifi_off_24_regular;
            } else if (isCredentials) {
              bgColor = AppColors.danger50;
              borderColor = AppColors.error500.withValues(alpha: 0.3);
              iconColor = AppColors.error500;
              icon = FluentIcons.error_circle_24_filled;
            } else {
              bgColor = AppColors.danger50;
              borderColor = AppColors.error500.withValues(alpha: 0.3);
              iconColor = AppColors.error500;
              icon = FluentIcons.error_circle_24_filled;
            }

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 18, color: iconColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      msg,
                      style: AppFonts.satoshiStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: iconColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: controller.clearError,
                    child: Icon(
                      FluentIcons.dismiss_24_regular,
                      size: 16,
                      color: iconColor,
                    ),
                  ),
                ],
              ),
            );
          }),
          AppTextField(
            controller: controller.emailOrNimController,
            labelText: 'Email atau NIM',
            hintText: 'nanda@gmail.com atau 23090122',
            keyboardType: TextInputType.emailAddress,
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
    return Obx(() {
      final loading = controller.isLoading.value;
      return AppButton(
        label: loading ? '' : 'Masuk',
        onTap: loading ? null : controller.onLogin,
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.white,
                ),
              )
            : null,
      );
    });
  }
}
