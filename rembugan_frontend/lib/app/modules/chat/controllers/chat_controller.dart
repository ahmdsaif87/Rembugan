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
      name: 'Dede Fernanda',
      message: 'Lorem ipsum lorem ipsum lorem ipsum lorem..adwaddwa.',
      time: '18.30',
      avatarUrl: 'https://i.pravatar.cc/100?img=60',
      isUnread: true,
      unreadCount: 1,
    ),
    ChatModel(
      name: 'Dede Fernanda',
      message: 'Lorem ipsum lorem ipsum lorem ipsum lorem..adwaddwa.',
      time: '18.30',
      avatarUrl: 'https://i.pravatar.cc/100?img=60',
      isUnread: false,
    ),
    ChatModel(
      name: 'Dede Fernanda',
      message: 'Lorem ipsum lorem ipsum lorem ipsum lorem..adwaddwa.',
      time: '18.30',
      avatarUrl: 'https://i.pravatar.cc/100?img=60',
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
