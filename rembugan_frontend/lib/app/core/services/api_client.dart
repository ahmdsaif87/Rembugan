import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/api_config.dart';
import '../widgets/app_toast.dart';

class ApiClient extends GetxService {
  late final dio.Dio _dio;
  final _storage = const FlutterSecureStorage();

  @override
  void onInit() {
    super.onInit();
    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    ));

    _dio.interceptors.addAll([
      _AuthInterceptor(_storage),
      _ErrorInterceptor(),
      if (kDebugMode)
        PrettyDioLogger(requestBody: true, responseBody: true),
    ]);
  }

  dio.Dio get client => _dio;

  Future<String?> getToken() => _storage.read(key: ApiConfig.tokenKey);

  Future<void> saveToken(String token) =>
      _storage.write(key: ApiConfig.tokenKey, value: token);

  Future<void> clearToken() => _storage.delete(key: ApiConfig.tokenKey);

  Future<dio.Response> get(String path, {Map<String, dynamic>? queryParameters}) =>
      _dio.get(path, queryParameters: queryParameters);

  Future<dio.Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<dio.Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  Future<dio.Response> patch(String path, {dynamic data}) =>
      _dio.patch(path, data: data);

  Future<dio.Response> delete(String path) => _dio.delete(path);

  Future<String?> uploadImageBytes(
    String path,
    Uint8List bytes,
    String filename,
  ) async {
    final formData = dio.FormData.fromMap({
      'file': dio.MultipartFile.fromBytes(bytes, filename: filename),
    });
    final res = await _dio.post(path, data: formData);
    final data = res.data['data'] as Map<String, dynamic>?;
    return data?['url'] as String?;
  }
}

class _AuthInterceptor extends dio.Interceptor {
  final FlutterSecureStorage _storage;

  _AuthInterceptor(this._storage);

  @override
  void onRequest(dio.RequestOptions options, dio.RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: ApiConfig.tokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(dio.DioException err, dio.ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await _storage.delete(key: ApiConfig.tokenKey);
      Get.offAllNamed('/onboarding');
      AppToast.warning('Silakan login kembali.', title: 'Sesi Berakhir');
      return;
    }
    handler.next(err);
  }
}

class _ErrorInterceptor extends dio.Interceptor {
  @override
  void onError(dio.DioException err, dio.ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;

    if (statusCode == 429) {
      AppToast.warning('Coba lagi dalam beberapa menit.', title: 'Terlalu Banyak Request');
    } else if (err.type == dio.DioExceptionType.connectionTimeout ||
        err.type == dio.DioExceptionType.receiveTimeout) {
      AppToast.warning('Koneksi lambat. Coba lagi.', title: 'Timeout');
    } else if (err.type == dio.DioExceptionType.connectionError) {
      AppToast.warning('Periksa koneksi internet kamu.', title: 'Tidak Ada Koneksi');
    }

    handler.next(err);
  }
}
