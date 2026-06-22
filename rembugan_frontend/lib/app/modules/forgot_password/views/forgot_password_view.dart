import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_chrome.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Obx(
          () => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: controller.goBack,
                      icon: const Icon(
                        FluentIcons.chevron_left_24_regular,
                        color: AppColors.primary500,
                        size: 25,
                      ),
                    ),
                    const Spacer(),
                    _StepIndicator(current: controller.step.value, total: 4),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildStep(controller.step.value),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int step) {
    return switch (step) {
      0 => _EmailStep(key: const ValueKey(0), controller: controller),
      1 => _OtpStep(key: const ValueKey(1), controller: controller),
      2 => _PasswordStep(key: const ValueKey(2), controller: controller),
      3 => _SuccessStep(key: const ValueKey(3), controller: controller),
      _ => const SizedBox(key: ValueKey(4)),
    };
  }
}

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;

  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final isActive = i <= current;
        return Container(
          width: 8,
          height: 8,
          margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary500 : c.grey300,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _EmailStep extends StatelessWidget {
  final ForgotPasswordController controller;

  const _EmailStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKeyEmail,
      child: Column(
        children: [
          const SizedBox(height: 4),
          Image.asset(
            'lib/assets/img/forgot_password.png',
            width: 260,
            height: 260,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 14),
          const _Title(
            title: 'Lupa kata sandi?',
            subtitle:
                'Masukkan email akunmu untuk menerima instruksi\npengaturan ulang kata sandi.',
          ),
          const SizedBox(height: 24),
          AppTextField(
            controller: controller.emailController,
            labelText: 'Email',
            hintText: 'nanda@gmail.com',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) return 'Email wajib diisi';
              if (!email.contains('@')) return 'Email tidak valid';
              return null;
            },
          ),
          const SizedBox(height: 20),
          Obx(
            () => AppButton(
              label: 'Kirim',
              onTap: controller.isLoading.value ? null : controller.onSendOtp,
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpStep extends StatelessWidget {
  final ForgotPasswordController controller;

  const _OtpStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final displayEmail = controller.email.isEmpty ? '*****@***.***' : controller.email;

    return Column(
      children: [
        const SizedBox(height: 54),
        Lottie.asset(
          'lib/assets/animations/Email.json',
          width: 170,
          height: 140,
          fit: BoxFit.contain,
          repeat: false,
        ),
        const SizedBox(height: 10),
        _Title(
          title: 'Cek email kamu',
          subtitle:
              'Kode OTP telah dikirim ke $displayEmail. Email biasanya tiba dalam 1-2 menit. Periksa juga folder spam.',
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            controller.otpControllers.length,
            (index) => Padding(
              padding: EdgeInsets.only(
                right: index == controller.otpControllers.length - 1 ? 0 : 8,
              ),
              child: SizedBox(
                width: 52,
                height: 60,
                child: TextField(
                  controller: controller.otpControllers[index],
                  focusNode: controller.otpFocusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: AppFonts.satoshiStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: c.grey900,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(1),
                  ],
                  onChanged: (value) => controller.onOtpChanged(index, value),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: c.grey100,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: c.grey200),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: c.grey200),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.primary500,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Obx(
          () => AppButton(
            label: 'Kirim',
            onTap: controller.isLoading.value ? null : controller.onVerifyOtp,
          ),
        ),
        const SizedBox(height: 20),
        Obx(() {
          final seconds = controller.resendSeconds.value;
          return GestureDetector(
            onTap: seconds == 0 ? controller.resendOtp : null,
            child: Text.rich(
              TextSpan(
                text: 'Tidak menerima email? ',
                children: [
                  TextSpan(
                    text: seconds == 0
                        ? 'Kirim ulang'
                        : 'Kirim ulang ($seconds)',
                    style: AppFonts.satoshiStyle(
                      fontWeight: FontWeight.w600,
                      color: seconds == 0
                          ? AppColors.primary500
                          : c.grey900,
                    ),
                  ),
                ],
              ),
              style: AppFonts.satoshiStyle(
                fontSize: 14,
                color: c.grey500,
              ),
            ));
        }),
      ],
    );
  }
}

class _PasswordStep extends StatelessWidget {
  final ForgotPasswordController controller;

  const _PasswordStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKeyReset,
      child: Column(
        children: [
          const SizedBox(height: 92),
          const _Title(
            title: 'Buat Kata Sandi Baru',
            subtitle: 'Buat kata sandi baru untuk mengamankan akunmu. Gunakan kata sandi yang kuat dan berbeda dari akun lain.',
          ),
          const SizedBox(height: 24),
          Obx(
            () => AppTextField(
              controller: controller.newPasswordController,
              labelText: 'Kata Sandi Baru',
              hintText: 'Masukan kata sandi baru',
              obscureText: controller.isNewPasswordHidden.value,
              suffixIcon: _PasswordVisibilityButton(
                hidden: controller.isNewPasswordHidden.value,
                onTap: controller.toggleNewPasswordVisibility,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kata sandi baru wajib diisi';
                }
                if (value.length < 6) {
                  return 'Kata sandi minimal 6 karakter';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => AppTextField(
              controller: controller.confirmPasswordController,
              labelText: 'Konfirmasi kata sandi',
              hintText: 'Masukkan ulang kata sandi baru',
              obscureText: controller.isConfirmPasswordHidden.value,
              suffixIcon: _PasswordVisibilityButton(
                hidden: controller.isConfirmPasswordHidden.value,
                onTap: controller.toggleConfirmPasswordVisibility,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Konfirmasi kata sandi wajib diisi';
                }
                if (value != controller.newPasswordController.text) {
                  return 'Kata sandi tidak cocok';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 24),
          Obx(
            () => AppButton(
              label: 'Simpan Kata Sandi',
              onTap: controller.isLoading.value ? null : controller.onResetPassword,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessStep extends StatelessWidget {
  final ForgotPasswordController controller;

  const _SuccessStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 92),
        Lottie.asset(
          'lib/assets/animations/password.json',
          width: 210,
          height: 180,
          fit: BoxFit.contain,
          repeat: false,
        ),
        const SizedBox(height: 24),
        const _Title(
          title: 'Kata Sandi Berhasil\nDiubah',
          subtitle:
              'Kata sandi baru telah berhasil disimpan. Silakan masuk\nkembali ke akunmu.',
        ),
        const SizedBox(height: 26),
        AppButton(label: 'Masuk kembali', onTap: controller.backToLogin),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Title({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppFonts.satoshiStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: c.grey900,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppFonts.satoshiStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: c.grey500,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _PasswordVisibilityButton extends StatelessWidget {
  const _PasswordVisibilityButton({required this.hidden, required this.onTap});

  final bool hidden;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        hidden ? FluentIcons.eye_off_24_regular : FluentIcons.eye_24_regular,
        color: c.grey400,
        size: 22,
      ),
    );
  }
}
