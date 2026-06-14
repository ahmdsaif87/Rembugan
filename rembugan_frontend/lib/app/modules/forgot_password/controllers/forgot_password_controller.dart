import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/theme/theme.dart';

class ForgotPasswordController extends GetxController {
  final _auth = Get.find<AuthService>();

  final step = 0.obs;
  final resendSeconds = 60.obs;

  final nimController = TextEditingController();
  final otpControllers = List.generate(6, (_) => TextEditingController());
  final otpFocusNodes = List.generate(6, (_) => FocusNode());
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isNewPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;

  final formKeyNim = GlobalKey<FormState>();
  final formKeyReset = GlobalKey<FormState>();

  Timer? _resendTimer;

  String get nim => nimController.text.trim();

  void goBack() {
    if (step.value == 0) {
      Get.back();
      return;
    }
    step.value--;
  }

  void onSendOtp() async {
    if (formKeyNim.currentState?.validate() != true) return;

    final error = await _auth.forgotPasswordSendOtp(nim);
    if (error != null) {
      Get.snackbar('Gagal', error, snackPosition: SnackPosition.BOTTOM);
      return;
    }

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
    final code = otpControllers.map((c) => c.text).join();
    if (code.length != otpControllers.length) {
      Get.snackbar(
        'Kode belum lengkap',
        'Masukkan 6 digit kode yang dikirim ke email Anda.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    step.value = 2;
  }

  void resendOtp() async {
    if (resendSeconds.value > 0) return;

    for (final c in otpControllers) {
      c.clear();
    }
    otpFocusNodes.first.requestFocus();

    final error = await _auth.forgotPasswordSendOtp(nim);
    if (error != null) {
      Get.snackbar('Gagal', error, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    _startResendTimer();
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordHidden.toggle();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.toggle();
  }

  void onResetPassword() async {
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

    final otp = otpControllers.map((c) => c.text).join();
    FocusManager.instance.primaryFocus?.unfocus();

    final error = await _auth.forgotPasswordReset(
      nim: nim,
      otp: otp,
      newPassword: newPasswordController.text,
    );

    if (error != null) {
      Get.snackbar('Gagal', error, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    step.value = 3;
  }

  Future<void> backToLogin() async {
    step.value = 4;
    await Future<void>.delayed(const Duration(milliseconds: 280));
    Get.back<void>();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    resendSeconds.value = 60;
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
    nimController.dispose();
    for (final c in otpControllers) {
      c.dispose();
    }
    for (final fn in otpFocusNodes) {
      fn.dispose();
    }
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
