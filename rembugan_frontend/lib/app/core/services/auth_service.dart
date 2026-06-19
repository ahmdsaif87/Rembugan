import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../models/user_model.dart';
import 'api_client.dart';

class AuthService extends GetxService {
  final _api = Get.find<ApiClient>();

  final isLoggedIn = false.obs;
  final currentUser = Rxn<UserModel>();
  final isLoading = false.obs;

  Future<void> init() async {
    final token = await _api.getToken();
    if (token == null || token.isEmpty) return;

    try {
      final res = await _api.get('/auth/me');
      final data = res.data['data'];
      if (data != null) {
        currentUser.value = UserModel.fromJson(data);
        isLoggedIn.value = true;
      }
    } on DioException {
      await _api.clearToken();
    }
  }

  Future<String?> register({
    required String email,
    required String password,
    required String fullName,
    String? interest,
  }) async {
    isLoading.value = true;
    try {
      final res = await _api.post('/auth/register', data: {
        'email': email,
        'password': password,
        'full_name': fullName,
        'interest': interest,
      });

      final data = res.data['data'];

      return null;
    } on DioException catch (e) {
      final detail = e.response?.data['detail'];
      return detail?.toString() ?? 'Terjadi kesalahan. Coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> registerVerifyOtp({
    required String email,
    required String otp,
  }) async {
    isLoading.value = true;
    try {
      await _api.post('/auth/register/verify-otp', data: {
        'email': email,
        'otp': otp,
      });
      return null;
    } on DioException catch (e) {
      final detail = e.response?.data['detail'];
      return detail?.toString() ?? 'Verifikasi OTP gagal.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      final res = await _api.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final data = res.data['data'];
      final token = data['access_token'] as String;

      await _api.saveToken(token);
      currentUser.value = UserModel(
        id: data['user_id'],
        email: email,
        fullName: data['full_name'],
        handle: data['handle'] ?? '',
        interest: data['interest'],
        isOnboarded: data['is_onboarded'] ?? false,
      );
      isLoggedIn.value = true;

      return null;
    } on DioException catch (e) {
      final detail = e.response?.data['detail'];
      return detail?.toString() ?? 'Terjadi kesalahan. Coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> sendOtp(String email) async {
    isLoading.value = true;
    try {
      await _api.post('/auth/email/send-otp', data: {'email': email});
      return null;
    } on DioException catch (e) {
      final detail = e.response?.data['detail'];
      return detail?.toString() ?? 'Gagal mengirim OTP.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> verifyOtp(String email, String otp) async {
    isLoading.value = true;
    try {
      await _api.post('/auth/email/verify-otp', data: {
        'email': email,
        'otp': otp,
      });
      currentUser.value = currentUser.value?.copyWith(
        email: email,
        emailVerified: true,
      );
      return null;
    } on DioException catch (e) {
      final detail = e.response?.data['detail'];
      return detail?.toString() ?? 'Verifikasi gagal.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> forgotPasswordSendOtp(String email) async {
    isLoading.value = true;
    try {
      await _api.post('/auth/forgot-password/send-otp', data: {'email': email});
      return null;
    } on DioException catch (e) {
      final detail = e.response?.data['detail'];
      return detail?.toString() ?? 'Gagal mengirim OTP.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> forgotPasswordReset({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    isLoading.value = true;
    try {
      await _api.post('/auth/forgot-password/reset', data: {
        'email': email,
        'otp': otp,
        'new_password': newPassword,
      });
      return null;
    } on DioException catch (e) {
      final detail = e.response?.data['detail'];
      return detail?.toString() ?? 'Reset password gagal.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> clearSession() async {
    await _api.clearToken();
    currentUser.value = null;
    isLoggedIn.value = false;
  }

  Future<void> logout() async {
    await _api.clearToken();
    currentUser.value = null;
    isLoggedIn.value = false;
    Get.offAllNamed('/onboarding');
  }
}
