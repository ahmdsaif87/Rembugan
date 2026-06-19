import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../../../core/widgets/app_toast.dart';

class RegisterController extends GetxController {
  final _auth = Get.find<AuthService>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final fullNameController = TextEditingController();
  final otpController = TextEditingController();
  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;
  final formKey = GlobalKey<FormState>();
  final otpFormKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  final showOtpStep = false.obs;

  String _registeredEmail = '';

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  Future<void> onRegister() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    final error = await _auth.register(
      email: emailController.text.trim(),
      password: passwordController.text,
      fullName: fullNameController.text.trim(),
    );
    isLoading.value = false;

    if (error != null) {
      AppToast.error(error, title: 'Registrasi Gagal');
      return;
    }

    _registeredEmail = emailController.text.trim();
    showOtpStep.value = true;
    AppToast.success('Kode OTP terkirim ke $_registeredEmail', title: 'Cek Email');
  }

  Future<void> onVerifyOtp() async {
    if (!otpFormKey.currentState!.validate()) return;

    isLoading.value = true;
    final error = await _auth.registerVerifyOtp(
      email: _registeredEmail,
      otp: otpController.text.trim(),
    );
    isLoading.value = false;

    if (error != null) {
      AppToast.error(error, title: 'Verifikasi Gagal');
      return;
    }

    AppToast.success('Email berhasil diverifikasi! Silakan masuk.', title: 'Registrasi');
    Get.offNamed(Routes.LOGIN);
  }

  void resendOtp() {
    AppToast.info('Fitur kirim ulang OTP belum tersedia');
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    fullNameController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
