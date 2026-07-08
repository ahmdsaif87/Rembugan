import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const String remoteBaseUrl = 'https://rembugan.onrender.com';

  static const String _compileTimeBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static String get baseUrl =>
      kReleaseMode ? remoteBaseUrl : _compileTimeBaseUrl;

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static const String tokenKey = 'access_token';
  static const String onboardingSeenKey = 'onboarding_seen';
}
