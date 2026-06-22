import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/api_client.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  late final _api = Get.find<ApiClient>();

  Future<List<NotificationModel>> getNotifications({int page = 1, int limit = 20}) async {
    try {
      final response = await _api.get('/notifications/', queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      });
      final data = response.data as Map<String, dynamic>;
      final items = data['data'] as List<dynamic>? ?? [];
      return items.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('NotificationRepository.getNotifications error: $e');
      return [];
    }
  }

  Future<bool> markAsRead(int notificationId) async {
    try {
      await _api.put('/notifications/$notificationId/read');
      return true;
    } catch (e) {
      debugPrint('NotificationRepository.markAsRead error: $e');
      return false;
    }
  }
}
