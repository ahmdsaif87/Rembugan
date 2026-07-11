import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'api_client.dart';

class FcmService extends GetxService {
  final _api = Get.find<ApiClient>();
  final fcmToken = Rxn<String>();

  Future<void> init() async {
    final messaging = FirebaseMessaging.instance;

    final notifSettings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('FCM permission: ${notifSettings.authorizationStatus}');

    final token = await messaging.getToken();
    if (token != null) {
      fcmToken.value = token;
      await _registerToken(token);
    }

    messaging.onTokenRefresh.listen((newToken) {
      fcmToken.value = newToken;
      _registerToken(newToken);
    });

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    final initialMsg = await messaging.getInitialMessage();
    if (initialMsg != null) {
      _handleNotificationTap(initialMsg);
    }
  }

  Future<void> _registerToken(String token) async {
    try {
      await _api.post('/notifications/fcm-token', data: {
        'token': token,
        'platform': 'android',
      });
      debugPrint('FCM token registered');
    } catch (e) {
      debugPrint('FCM token register error: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('FCM foreground: ${message.notification?.title}');
  }

  void _handleNotificationTap(RemoteMessage message) {
    final link = message.data['link'] as String?;
    if (link == null) return;
    debugPrint('FCM tap link: $link');
  }

  Future<void> deleteToken() async {
    try {
      final token = fcmToken.value;
      if (token != null) {
        await _api.delete('/notifications/fcm-token?token=$token');
      }
    } catch (_) {}
    fcmToken.value = null;
  }
}
