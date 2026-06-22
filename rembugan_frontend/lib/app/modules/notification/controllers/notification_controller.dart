import 'package:get/get.dart';
import '../data/models/notification_model.dart';
import '../data/repositories/notification_repository.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repo = NotificationRepository();

  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    final items = await _repo.getNotifications();
    notifications.assignAll(items);
    isLoading.value = false;
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
      }
    }
  }

  static bool isCollaboration(String type) {
    return switch (type) {
      'application_received' || 'application_accepted' || 'application_rejected' || 'chat' || 'group_chat_tag' => true,
      _ => false,
    };
  }

  static bool isSocial(String type) => !isCollaboration(type);
}
