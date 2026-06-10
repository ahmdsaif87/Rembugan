import 'package:get/get.dart';

class ChatModel {
  final String name;
  final String message;
  final String time;
  final String avatarUrl;
  final bool isUnread;
  final int unreadCount;

  ChatModel({
    required this.name,
    required this.message,
    required this.time,
    required this.avatarUrl,
    required this.isUnread,
    this.unreadCount = 0,
  });
}

class ChatController extends GetxController {
  // 0: Belum dibaca, 1: Semua
  var filterIndex = 1.obs;

  // Dummy Chat Data
  var allChats = <ChatModel>[
    ChatModel(
      name: 'Raka Pratama',
      message: 'Eh Raka, poster lomba Creative Fest 2026 ini menarik banget...',
      time: '18.38',
      avatarUrl: 'lib/assets/img/avatar.png',
      isUnread: false,
    ),
    ChatModel(
      name: 'Aisyah Rahma',
      message:
          'Halo! Progres wireframe buat menu project udah selesai nih, bisa tolong dicek?',
      time: '17.45',
      avatarUrl: 'https://i.pravatar.cc/100?img=49',
      isUnread: true,
      unreadCount: 1,
    ),
    ChatModel(
      name: 'Nadia Saputri',
      message:
          'FastAPI backend-nya udah aku deploy ke Railway ya, nanti tinggal kita integrasi sama Flutter.',
      time: 'Kemarin',
      avatarUrl: 'https://i.pravatar.cc/100?img=47',
      isUnread: false,
    ),
    ChatModel(
      name: 'Dede Fernanda',
      message:
          'Siap Dede, nanti malam kita kumpul di Discord buat bahas mockups & database ya!',
      time: '2 hari lalu',
      avatarUrl: 'https://i.pravatar.cc/100?img=12',
      isUnread: true,
      unreadCount: 3,
    ),
  ].obs;

  List<ChatModel> get filteredChats {
    if (filterIndex.value == 0) {
      return allChats.where((chat) => chat.isUnread).toList();
    } else {
      return allChats;
    }
  }

  void changeFilter(int index) {
    filterIndex.value = index;
  }
}
