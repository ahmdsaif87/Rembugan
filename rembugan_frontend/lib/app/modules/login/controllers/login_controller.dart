import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rembugan/app/routes/app_pages.dart';

class LoginController extends GetxController {
  // Controllers untuk input field
  final emailOrNimController = TextEditingController();
  final passwordController = TextEditingController();

  // Observable untuk toggle visibility password
  final isPasswordHidden = true.obs;

  // Form key untuk validasi
  final formKey = GlobalKey<FormState>();

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void onLogin() {
    if (formKey.currentState!.validate()) {
      // TODO: Implementasi logika login
      Get.snackbar('Login', 'Berhasil Masuk!');
      Get.offAllNamed(Routes.PERSONALIZATION);
    }
  }

  void onGoogleLogin() {
    // TODO: Implementasi login Google
    Get.snackbar('Google', 'Fitur login Google sedang dalam pengembangan');
  }

  void onForgotPassword() {
    // TODO: Navigasi ke halaman lupa sandi
    Get.snackbar('Lupa Sandi', 'Fitur lupa sandi sedang dalam pengembangan');
  }

  @override
  void onClose() {
    emailOrNimController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
