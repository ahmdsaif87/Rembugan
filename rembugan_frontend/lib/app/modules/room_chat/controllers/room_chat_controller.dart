import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatMessage {
  final String text;
  final String time;
  final bool isMe;
  final String avatarUrl;
  final String? fileName;
  final String? fileSize;
  final Map<String, dynamic>? sharedPost;

  ChatMessage({
    required this.text,
    required this.time,
    required this.isMe,
    required this.avatarUrl,
    this.fileName,
    this.fileSize,
    this.sharedPost,
  });
}

class RoomChatController extends GetxController {
  final messageController = TextEditingController();
  final messages = <ChatMessage>[
    ChatMessage(
      text: 'Halo! Ada yang bisa dibantu untuk proyek Rembugan?',
      time: '18.35',
      isMe: false,
      avatarUrl: 'https://i.pravatar.cc/100?img=60',
    ),
    ChatMessage(
      text: 'Iya Raka, ini lagi nyiapin berkas draft proposalnya.',
      time: '18.36',
      isMe: true,
      avatarUrl: 'lib/assets/img/avatar.png',
    ),
    ChatMessage(
      text: 'Eh Raka, poster lomba Creative Fest 2026 ini menarik banget deh buat kita ikutin bareng. Coba cek postingan ini:',
      time: '18.38',
      isMe: true,
      avatarUrl: 'lib/assets/img/avatar.png',
      sharedPost: {
        'name': 'Cameron Williamson',
        'subtitle': 'D4 Teknik Informatika',
        'content': 'Ada yang tertarik gabung tim buat ikut Creative Fest 2026? Kuota tim tinggal 1 slot lagi buat backend developer. Kita rencana pake FastAPI + PostgreSQL. Yang minat silakan cek profil atau langsung chat ya! 🚀🚀',
        'imageAsset': 'lib/assets/img/contoh poster1.jpeg',
      },
    ),
  ].obs;

  final attachedFileName = RxnString();
  final attachedFileSize = RxnString();

  void attachFile(String name, String size) {
    attachedFileName.value = name;
    attachedFileSize.value = size;
  }

  void removeAttachment() {
    attachedFileName.value = null;
    attachedFileSize.value = null;
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty && attachedFileName.value == null) return;

    messages.add(
      ChatMessage(
        text: text,
        time: 'Just now',
        isMe: true,
        avatarUrl: 'lib/assets/img/avatar.png',
        fileName: attachedFileName.value,
        fileSize: attachedFileSize.value,
      ),
    );

    messageController.clear();
    removeAttachment();
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}
