import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final _auth = Get.find<AuthService>();

  final emailOrNimController = TextEditingController();
  final passwordController = TextEditingController();
  final isPasswordHidden = true.obs;
  final formKey = GlobalKey<FormState>();

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void onLogin() async {
    if (!formKey.currentState!.validate()) return;

    final error = await _auth.login(
      identifier: emailOrNimController.text.trim(),
      password: passwordController.text,
    );

    if (error != null) {
      Get.snackbar('Login Gagal', error,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    Get.snackbar('Login', 'Berhasil Masuk!');

    final user = _auth.currentUser.value;
    if (user != null && !user.isOnboarded) {
      Get.offAllNamed(Routes.PERSONALIZATION);
    } else {
      Get.offAllNamed(Routes.HOME);
    }
  }

  void onForgotPassword() {
    Get.toNamed(Routes.FORGOT_PASSWORD);
  }

  @override
  void onClose() {
    emailOrNimController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
