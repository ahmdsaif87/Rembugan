import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../../../core/widgets/app_toast.dart';

enum LoginErrorType { invalidCredentials, network, server, unknown }

class LoginController extends GetxController {
  final _auth = Get.find<AuthService>();

  final emailOrNimController = TextEditingController();
  final passwordController = TextEditingController();
  final isPasswordHidden = true.obs;
  final isLoading = false.obs;
  final formKey = GlobalKey<FormState>();

  final errorMessage = Rxn<String>();
  final errorType = Rx<LoginErrorType?>(null);
  final emailOrNimError = Rxn<String>();
  final passwordError = Rxn<String>();

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void clearError() {
    errorMessage.value = null;
    errorType.value = null;
    emailOrNimError.value = null;
    passwordError.value = null;
  }

  void _setCredentialsError(String msg) {
    final lowerMsg = msg.toLowerCase();
    if (lowerMsg.contains('nim') || lowerMsg.contains('email') || lowerMsg.contains('tidak ditemukan') || lowerMsg.contains('user not found')) {
      emailOrNimError.value = msg;
    } else if (lowerMsg.contains('password') || lowerMsg.contains('sandi') || lowerMsg.contains('salah') || lowerMsg.contains('incorrect')) {
      passwordError.value = msg;
    } else {
      errorMessage.value = msg;
    }
  }

  void onLogin() async {
    if (!formKey.currentState!.validate()) return;
    clearError();
    isLoading.value = true;

    try {
      final error = await _auth.login(
        identifier: emailOrNimController.text.trim(),
        password: passwordController.text,
      );

      if (error != null) {
        _setCredentialsError(error);
        errorType.value = LoginErrorType.invalidCredentials;
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
    } on DioException catch (e) {
      final detail = e.response?.data?['detail']?.toString() ?? '';
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        errorMessage.value = 'Tidak dapat terhubung ke server. Periksa koneksi internet.';
        errorType.value = LoginErrorType.network;
      } else if (e.response?.statusCode == 401) {
        _setCredentialsError(detail);
        errorType.value = LoginErrorType.invalidCredentials;
      } else if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
        errorMessage.value = 'Server sedang sibuk. Coba lagi nanti.';
        errorType.value = LoginErrorType.server;
      } else {
        errorMessage.value = detail.isEmpty ? 'Terjadi kesalahan. Coba lagi.' : detail;
        errorType.value = LoginErrorType.unknown;
      }
    } catch (_) {
      errorMessage.value = 'Terjadi kesalahan. Coba lagi.';
      errorType.value = LoginErrorType.unknown;
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
