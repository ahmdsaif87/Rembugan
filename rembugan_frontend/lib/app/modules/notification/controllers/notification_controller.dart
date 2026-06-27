import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/services/chat_socket_service.dart';
import '../data/models/notification_model.dart';
import '../data/repositories/notification_repository.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repo = NotificationRepository();
  StreamSubscription? _notifSub;

  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    fetchUnreadCount();
    _listenWebSocket();
  }

  void _listenWebSocket() {
    try {
      final socket = Get.find<ChatSocketService>();
      _notifSub = socket.onNotification.listen((data) {
        try {
          final notif = NotificationModel.fromJson(data);
          notifications.insert(0, notif);
          if (!notif.isRead) {
            unreadCount.value++;
          }
        } catch (e) {
          debugPrint('NotificationController WS error: $e');
        }
      });
    } catch (_) {}
  }

  @override
  void onClose() {
    _notifSub?.cancel();
    super.onClose();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    final items = await _repo.getNotifications();
    notifications.assignAll(items);
    isLoading.value = false;
  }

  Future<void> fetchUnreadCount() async {
    final count = await _repo.getUnreadCount();
    unreadCount.value = count;
  }

  int get collabCount =>
      notifications.where((n) => isCollaboration(n.type)).length;

  Future<void> markAsRead(int id) async {
    final ok = await _repo.markAsRead(id);
    if (ok) {
      final idx = notifications.indexWhere((n) => n.id == id);
      if (idx != -1) {
        notifications[idx] = NotificationModel(
          id: notifications[idx].id,
          type: notifications[idx].type,
          title: notifications[idx].title,
          content: notifications[idx].content,
          isRead: true,
          link: notifications[idx].link,
          createdAt: notifications[idx].createdAt,
        );
        notifications.refresh();
        fetchUnreadCount();
      }
    }
  }

  Future<void> markAllAsRead() async {
    final ok = await _repo.markAllAsRead();
    if (ok) {
      for (var i = 0; i < notifications.length; i++) {
        if (!notifications[i].isRead) {
          notifications[i] = NotificationModel(
            id: notifications[i].id,
            type: notifications[i].type,
            title: notifications[i].title,
            content: notifications[i].content,
            isRead: true,
            link: notifications[i].link,
            createdAt: notifications[i].createdAt,
          );
        }
      }
      notifications.refresh();
      unreadCount.value = 0;
    }
  }

  Future<bool> acceptConnectionRequest(int notificationId, int connectionId) async {
    final ok = await _repo.acceptConnection(connectionId);
    if (ok) {
      await markAsRead(notificationId);
      fetchNotifications();
    }
    return ok;
  }

  Future<bool> rejectConnectionRequest(int notificationId, int connectionId) async {
    final ok = await _repo.rejectConnection(connectionId);
    if (ok) {
      await markAsRead(notificationId);
      fetchNotifications();
    }
    return ok;
  }

  static bool isCollaboration(String type) {
    return switch (type) {
      'application_received' || 'application_accepted' || 'application_rejected'
      || 'chat' || 'group_chat_tag' || 'task_assigned'
      || 'deadline_reminder' || 'file_uploaded' || 'role_approved' => true,
      _ => false,
    };
  }

  static bool isSocial(String type) => !isCollaboration(type);
}
