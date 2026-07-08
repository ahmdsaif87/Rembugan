import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../../../core/widgets/app_toast.dart';

class LoginController extends GetxController {
  final _auth = Get.find<AuthService>();

  final emailOrNimController = TextEditingController();
  final passwordController = TextEditingController();
  final isPasswordHidden = true.obs;
  final isLoading = false.obs;
  final errorMessage = Rxn<String>();
  final formKey = GlobalKey<FormState>();

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void clearError() {
    errorMessage.value = null;
  }

  void onLogin() async {
    if (!formKey.currentState!.validate()) return;
    errorMessage.value = null;
    isLoading.value = true;

    try {
      final error = await _auth.login(
        identifier: emailOrNimController.text.trim(),
        password: passwordController.text,
      );

      if (error != null) {
        errorMessage.value = error;
        return;
      }

      final userName = _auth.currentUser.value?.fullName ?? '';
      AppToast.success(
        'Selamat datang kembali${userName.isNotEmpty ? ', $userName' : ''}',
      );

      final user = _auth.currentUser.value;
      if (user != null && !user.isOnboarded) {
        Get.offAllNamed(Routes.PERSONALIZATION);
      } else {
        Get.offAllNamed(Routes.HOME);
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan. Coba lagi.';
    } finally {
      isLoading.value = false;
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
