import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';

class ForgotPasswordController extends GetxController {
  final step = 0.obs;
  final resendSeconds = 13.obs;

  final emailController = TextEditingController();
  final otpControllers = List.generate(4, (_) => TextEditingController());
  final otpFocusNodes = List.generate(4, (_) => FocusNode());
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isNewPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;

  final formKeyEmail = GlobalKey<FormState>();
  final formKeyReset = GlobalKey<FormState>();

  Timer? _resendTimer;

  String get email => emailController.text.trim();

  void goBack() {
    if (step.value == 0) {
      Get.back();
      return;
    }
    step.value--;
  }

  void onSendEmail() {
    if (formKeyEmail.currentState?.validate() != true) return;
    step.value = 1;
    _startResendTimer();
  }

  void onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < otpFocusNodes.length - 1) {
      otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      otpFocusNodes[index - 1].requestFocus();
    }
  }

  void onVerifyOtp() {
    final code = otpControllers.map((controller) => controller.text).join();
    if (code.length != otpControllers.length) {
      Get.snackbar(
        'Kode belum lengkap',
        'Masukkan 4 digit kode yang dikirim ke email Anda.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    step.value = 2;
  }

  void resendOtp() {
    if (resendSeconds.value > 0) return;
    for (final controller in otpControllers) {
      controller.clear();
    }
    otpFocusNodes.first.requestFocus();
    _startResendTimer();
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordHidden.toggle();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.toggle();
  }

  void onResetPassword() {
    if (formKeyReset.currentState?.validate() != true) return;
    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Kata sandi tidak cocok',
        'Pastikan kedua kata sandi yang dimasukkan sama.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger50,
        colorText: AppColors.danger700,
      );
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    step.value = 3;
  }

  Future<void> backToLogin() async {
    step.value = 4;
    await Future<void>.delayed(const Duration(milliseconds: 280));
    Get.back<void>();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    resendSeconds.value = 13;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds.value == 0) {
        timer.cancel();
      } else {
        resendSeconds.value--;
      }
    });
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    emailController.dispose();
    for (final controller in otpControllers) {
      controller.dispose();
    }
    for (final focusNode in otpFocusNodes) {
      focusNode.dispose();
    }
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
