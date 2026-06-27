import 'package:get/get.dart';

import '../../../core/services/api_client.dart';

class ChatRoom {
  final String roomId;
  final String type;
  final String name;
  final String? otherUserId;
  final String? photoUrl;
  final String lastMessage;
  final String lastTime;
  final int unread;
  ChatRoom({
    required this.roomId,
    required this.type,
    required this.name,
    this.otherUserId,
    this.photoUrl,
    this.lastMessage = '',
    this.lastTime = '',
    this.unread = 0,
  });
}

class ChatController extends GetxController {
  final ApiClient _api = Get.find();

  var filterIndex = 1.obs;
  final rooms = <ChatRoom>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRooms();
  }

  List<ChatRoom> get filteredRooms {
    if (filterIndex.value == 0) {
      return rooms.where((r) => r.unread > 0).toList();
    }
    return rooms;
  }

  void changeFilter(int index) => filterIndex.value = index;

  Future<void> fetchRooms() async {
    isLoading.value = true;
    try {
      final res = await _api.get('/chat/rooms');
      final body = res.data as Map<String, dynamic>? ?? {};
      final data = body['data'] as List<dynamic>? ?? [];
      rooms.assignAll(data.map((r) => ChatRoom(
        roomId: r['room_id'] as String? ?? '',
        type: r['type'] as String? ?? 'dm',
        name: r['name'] as String? ?? '',
        otherUserId: r['other_user_id'] as String?,
        photoUrl: r['photo_url'] as String?,
        lastMessage: r['last_message'] as String? ?? '',
        lastTime: r['last_time'] as String? ?? '',
        unread: r['unread'] as int? ?? 0,
      )));
    } catch (_) {}
    isLoading.value = false;
  }
}
