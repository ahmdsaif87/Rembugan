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
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: controller.goBack,
                    icon: const Icon(
                      FluentIcons.chevron_left_24_regular,
                      color: AppColors.primary500,
                      size: 25,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
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

class _EmailStep extends StatelessWidget {
  final ForgotPasswordController controller;

  const _EmailStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKeyNim,
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
                'Masukkan NIM akunmu untuk menerima instruksi\npengaturan ulang kata sandi.',
          ),
          const SizedBox(height: 24),
          AppTextField(
            controller: controller.nimController,
            labelText: 'NIM',
            hintText: '23090122',
            keyboardType: TextInputType.number,
            validator: (value) {
              final nim = value?.trim() ?? '';
              if (nim.isEmpty) return 'NIM wajib diisi';
              if (nim.length < 5) return 'NIM minimal 5 karakter';
              return null;
            },
          ),
          const SizedBox(height: 20),
          AppButton(label: 'Kirim', onTap: controller.onSendOtp),
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
    final displayNim = controller.nim.isEmpty ? '*****' : controller.nim;

    return Column(
      children: [
        const SizedBox(height: 54),
        Lottie.asset(
          'lib/assets/animations/Email.json',
          width: 170,
          height: 140,
          fit: BoxFit.contain,
          repeat: true,
        ),
        const SizedBox(height: 10),
        _Title(
          title: 'Cek Email Anda',
            subtitle: 'Kode OTP telah dikirim ke NIM $displayNim',
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
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedBorder: OutlineInputBorder(
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
        AppButton(label: 'Kirim', onTap: controller.onVerifyOtp),
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
          const SizedBox(height: 142),
          const _Title(
            title: 'Buat Kata Sandi Baru',
            subtitle: 'Buat kata sandi baru untuk mengamankan akunmu.',
          ),
          const SizedBox(height: 32),
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
          const SizedBox(height: 24),
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
                return null;
              },
            ),
          ),
          const SizedBox(height: 28),
          AppButton(
            label: 'Simpan Kata Sandi',
            onTap: controller.onResetPassword,
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
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        hidden ? FluentIcons.eye_off_24_regular : FluentIcons.eye_24_regular,
        color: AppColors.grey400,
        size: 22,
      ),
    );
  }
}
