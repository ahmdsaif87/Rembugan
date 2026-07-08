import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const String localBaseUrl = 'http://localhost:8000';
  static const String remoteBaseUrl = 'https://rembugan.onrender.com';

  static String get baseUrl =>
      kReleaseMode ? remoteBaseUrl : _compileTimeBaseUrl;

  static String get _compileTimeBaseUrl => String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: localBaseUrl,
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static const String tokenKey = 'access_token';
}
