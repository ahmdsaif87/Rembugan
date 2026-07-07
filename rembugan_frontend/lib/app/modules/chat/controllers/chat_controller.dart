import 'dart:async';
import 'package:get/get.dart';

import '../../../core/services/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/chat_socket_service.dart';

class ChatRoom {
  final String roomId;
  final String type;
  final String name;
  final String? otherUserId;
  final String? photoUrl;
  final String lastMessage;
  final String lastTime;
  final int unread;
  final bool isOnline;
  ChatRoom({
    required this.roomId,
    required this.type,
    required this.name,
    this.otherUserId,
    this.photoUrl,
    this.lastMessage = '',
    this.lastTime = '',
    this.unread = 0,
    this.isOnline = false,
  });

  ChatRoom copyWith({String? lastMessage, String? lastTime, int? unread, bool? isOnline}) {
    return ChatRoom(
      roomId: roomId, type: type, name: name,
      otherUserId: otherUserId, photoUrl: photoUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastTime: lastTime ?? this.lastTime,
      unread: unread ?? this.unread,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

class ChatController extends GetxController {
  final ApiClient _api = Get.find();
  final ChatSocketService _socket = Get.find();
  StreamSubscription? _feedSub;

  var filterIndex = 1.obs;
  final rooms = <ChatRoom>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRooms();
    _feedSub = _socket.onFeed.listen(_handleFeedMessage);
  }

  @override
  void onClose() {
    _feedSub?.cancel();
    super.onClose();
  }

  void _handleFeedMessage(Map<String, dynamic> data) {
    final roomId = data['room_id'] as String?;
    if (roomId == null) return;
    final idx = rooms.indexWhere((r) => r.roomId == roomId);
    
    if (idx == -1) {
      // Room baru, fetch ulang seluruh list
      fetchRooms();
      return;
    }

    final myId = Get.find<AuthService>().currentUser.value?.id;
    final senderId = data['sender_id'] as String?;
    final isMe = senderId != null && senderId == myId;

    final lastMsg = data['attachment_name'] as String? ?? data['text'] as String? ?? '';

    final updatedRoom = rooms[idx].copyWith(
      lastMessage: lastMsg,
      lastTime: data['timestamp'] as String? ?? '',
      unread: isMe ? rooms[idx].unread : rooms[idx].unread + 1,
    );

    // Hapus dari posisi lama dan taruh paling atas
    rooms.removeAt(idx);
    rooms.insert(0, updatedRoom);
  }

  int get totalUnread => rooms.fold(0, (sum, r) => sum + r.unread);

  List<ChatRoom> get filteredRooms {
    if (filterIndex.value == 0) {
      return rooms.where((r) => r.unread > 0).toList();
    }
    return rooms;
  }

  void changeFilter(int index) => filterIndex.value = index;

  Future<void> markRead(String roomId) async {
    final idx = rooms.indexWhere((r) => r.roomId == roomId);
    if (idx != -1) rooms[idx] = rooms[idx].copyWith(unread: 0);
    try {
      await _api.post('/chat/rooms/$roomId/read');
    } catch (_) {}
  }

  Future<void> fetchRooms() async {
    isLoading.value = rooms.isEmpty;
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
        isOnline: r['is_online'] as bool? ?? false,
      )));
    } catch (_) {}
    isLoading.value = false;
  }
}
