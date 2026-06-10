import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme.dart';

class ForgotPasswordController extends GetxController {
  // Step state: 0 for Entering Email, 1 for Resetting Password
  final step = 0.obs;

  // Controllers
  final emailOrNimController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Password visibility
  final isNewPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;

  // Form Keys
  final formKeyEmail = GlobalKey<FormState>();
  final formKeyReset = GlobalKey<FormState>();

  void toggleNewPasswordVisibility() {
    isNewPasswordHidden.value = !isNewPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  void onSendResetLink() {
    if (formKeyEmail.currentState!.validate()) {
      Get.showOverlay(
        asyncFunction: () async {
          // Simulate network call
          await Future<void>.delayed(const Duration(seconds: 1));
          step.value = 1; // Proceed to reset step
          Get.snackbar(
            'Verifikasi Sukses',
            'Silakan masukkan kata sandi baru Anda.',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        loadingWidget: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  void onResetPassword() {
    if (formKeyReset.currentState!.validate()) {
      if (newPasswordController.text != confirmPasswordController.text) {
        Get.snackbar(
          'Kesalahan',
          'Konfirmasi kata sandi tidak cocok.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.danger50,
          colorText: AppColors.danger700,
        );
        return;
      }

      Get.showOverlay(
        asyncFunction: () async {
          // Simulate password reset
          await Future<void>.delayed(const Duration(seconds: 1));
          Get.back(); // Dismiss loading
          Get.back(); // Go back to login screen
          Get.snackbar(
            'Kata Sandi Diperbarui',
            'Kata sandi Anda berhasil diubah. Silakan masuk kembali.',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
        },
        loadingWidget: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  @override
  void onClose() {
    emailOrNimController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
