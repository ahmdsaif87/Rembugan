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
      debugPrint('NotificationRepository.getNotifications response: ${response.data}');
      final data = response.data as Map<String, dynamic>;
      final pagination = data['data'] as Map<String, dynamic>;
      final items = pagination['data'] as List<dynamic>? ?? [];
      return items.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('NotificationRepository.getNotifications error: $e');
      debugPrintStack();
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

  Future<bool> markAllAsRead() async {
    try {
      await _api.put('/notifications/read-all');
      return true;
    } catch (e) {
      debugPrint('NotificationRepository.markAllAsRead error: $e');
      return false;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _api.get('/notifications/unread-count');
      final data = response.data as Map<String, dynamic>;
      final result = data['data'] as Map<String, dynamic>? ?? {};
      return result['unread_count'] as int? ?? 0;
    } catch (e) {
      debugPrint('NotificationRepository.getUnreadCount error: $e');
      return 0;
    }
  }

  Future<bool> acceptConnection(int connectionId) async {
    try {
      await _api.put('/connections/accept/$connectionId');
      return true;
    } catch (e) {
      debugPrint('NotificationRepository.acceptConnection error: $e');
      return false;
    }
  }

  Future<bool> rejectConnection(int connectionId) async {
    try {
      await _api.put('/connections/reject/$connectionId');
      return true;
    } catch (e) {
      debugPrint('NotificationRepository.rejectConnection error: $e');
      return false;
    }
  }
}
