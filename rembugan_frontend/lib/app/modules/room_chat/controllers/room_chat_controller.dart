import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/chat_socket_service.dart';
import '../../chat/controllers/chat_controller.dart';

class ChatMessage {
  final String id;
  final String text;
  final String time;
  final bool isMe;
  final String senderName;
  final String? senderPhotoUrl;
  final String type;
  final String? attachmentUrl;
  final String? attachmentName;
  final int? attachmentSize;
  final String? replyToId;

  ChatMessage({
    this.id = '',
    required this.text,
    required this.time,
    required this.isMe,
    this.senderName = '',
    this.senderPhotoUrl,
    this.type = 'text',
    this.attachmentUrl,
    this.attachmentName,
    this.attachmentSize,
    this.replyToId,
  });
}

class RoomChatController extends GetxController {
  final ApiClient _api = Get.find();
  final ChatSocketService _socket = Get.find();
  StreamSubscription? _wsSub;

  late final ChatRoom room;

  final messageController = TextEditingController();
  final messages = <ChatMessage>[].obs;
  final isUploading = false.obs;
  final isLoading = true.obs;
  final isWsConnected = false.obs;

  late final String _myId;

  @override
  void onInit() {
    super.onInit();
    room = Get.arguments as ChatRoom;
    _myId = _resolveMyId();
    _init();
  }

  String _resolveMyId() {
    try {
      final auth = Get.find<AuthService>();
      return auth.currentUser.value?.id ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<void> _init() async {
    await _socket.connect(room.roomId);
    isWsConnected.value = true;
    _wsSub?.cancel();
    _wsSub = _socket.onMessage.listen(_receiveMessage);
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    isLoading.value = true;
    try {
      final res = await _api.get('/chat/history/${room.roomId}?limit=50');
      final body = res.data as Map<String, dynamic>? ?? {};
      final data = body['data'] as List<dynamic>? ?? [];
      final myId = _myId;
      messages.assignAll(data.map((m) => ChatMessage(
        id: m['id'].toString(),
        text: m['content'] as String? ?? '',
        type: m['type'] as String? ?? 'text',
        time: m['created_at'] as String? ?? '',
        isMe: (m['sender_id'] as String? ?? '') == myId,
        senderName: m['sender_name'] as String? ?? '',
        senderPhotoUrl: m['sender_photo_url'] as String?,
        attachmentUrl: m['attachment_url'] as String?,
        attachmentName: m['attachment_name'] as String?,
        attachmentSize: m['attachment_size'] as int?,
        replyToId: m['reply_to_id'] as String?,
      )));
    } catch (_) {}
    isLoading.value = false;
  }

  void _receiveMessage(Map<String, dynamic> data) {
    final senderId = data['sender_id'] as String? ?? '';
    final isMe = senderId == _myId;
    messages.add(ChatMessage(
      id: data['id'] as String? ?? '',
      text: data['text'] as String? ?? '',
      type: data['type'] as String? ?? 'text',
      time: data['timestamp'] as String? ?? '',
      isMe: isMe,
      senderName: data['sender_name'] as String? ?? (isMe ? 'Saya' : ''),
      senderPhotoUrl: data['sender_photo_url'] as String?,
      attachmentUrl: data['attachment_url'] as String?,
      attachmentName: data['attachment_name'] as String?,
      attachmentSize: data['attachment_size'] as int?,
      replyToId: data['reply_to_id'] as String?,
    ));
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty || !isWsConnected.value) return;
    _socket.send(room.roomId, text);
    messageController.clear();
  }

  Future<void> uploadAndSendFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    Uint8List bytes;
    if (file.bytes != null) {
      bytes = file.bytes!;
    } else if (file.path != null) {
      bytes = await File(file.path!).readAsBytes();
    } else {
      return;
    }

    isUploading.value = true;
    try {
      await _api.uploadImageBytes(
        room.type == 'group'
            ? '/workspace/${room.roomId}/files'
            : '/chat/dm/upload/${room.otherUserId}',
        bytes,
        filename: file.name,
      );
      await fetchHistory();
    } catch (e) {
      debugPrint('uploadAndSendFile error: $e');
    }
    isUploading.value = false;
  }
}
