import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_chrome.dart';
import '../../../routes/app_pages.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: AppLayeredBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(c),
              _buildSearchBar(c),
              _buildFilters(c),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const _ChatShimmer();
                  }
                  final chats = controller.filteredRooms;
                  if (chats.isEmpty) {
                    return const AppEmptyState(
                      icon: FluentIcons.chat_empty_24_regular,
                      title: 'Belum ada pesan',
                      message: 'Percakapan baru akan muncul di sini setelah Anda mulai berkolaborasi.',
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: controller.fetchRooms,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 18),
                      itemCount: chats.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        indent: 84,
                        color: c.border.withValues(alpha: 0.4),
                      ),
                      itemBuilder: (context, index) {
                        final chat = chats[index];
                        return _buildChatItem(c: c, chat: chat);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppC c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 10),
      child: Row(
        children: [
          IconButton(
            icon: Icon(FluentIcons.chevron_left_24_regular, color: c.textPrimary),
            onPressed: () => Get.back(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pesan',
                  style: AppFonts.satoshiStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          AppIconButton(
            icon: FluentIcons.compose_24_regular,
            onTap: _showNewMessageSheet,
          ),
        ],
      ),
    );
  }

  void _showNewMessageSheet() {
    final c = AppC.of(Get.context!);
    final api = Get.find<ApiClient>();
    final currentUid = Get.find<AuthService>().currentUser.value?.id;
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) {
        return FutureBuilder<dynamic>(
          future: api.get('/connections/$currentUid'),
          builder: (context, snap) {
            final connections = (snap.data?.data is Map && snap.data!.data['data'] is List)
                ? (snap.data!.data['data'] as List).cast<Map<String, dynamic>>()
                : <Map<String, dynamic>>[];
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: c.border, borderRadius: BorderRadius.circular(2)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Row(
                      children: [
                        Text(
                          'Pesan Baru',
                          style: AppFonts.satoshiStyle(fontSize: 18, fontWeight: FontWeight.w600, color: c.textPrimary),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Icon(FluentIcons.dismiss_24_regular, color: c.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (snap.connectionState != ConnectionState.done)
                    const Expanded(child: Center(child: CircularProgressIndicator()))
                  else if (connections.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          'Belum ada koneksi',
                          style: AppFonts.satoshiStyle(fontSize: 14, color: c.textSecondary),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: connections.length,
                        separatorBuilder: (_, __) => Divider(height: 1, indent: 64, color: c.border.withValues(alpha: 0.3)),
                        itemBuilder: (_, i) {
                          final conn = connections[i];
                          final uid = conn['user_id'] as String? ?? '';
                          final name = conn['full_name'] as String? ?? '';
                          final photo = conn['photo_url'] as String?;
                          final sorted = [currentUid, uid]..sort();
                          final roomId = 'dm_${sorted[0]}_${sorted[1]}';
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 4),
                            leading: CircleAvatar(
                              radius: 22,
                              backgroundImage: photo != null ? NetworkImage(photo) as ImageProvider : null,
                              child: photo == null ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?') : null,
                            ),
                            title: Text(
                              name,
                              style: AppFonts.satoshiStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary),
                            ),
                            subtitle: Text(
                              '@${conn['handle'] as String? ?? ''}',
                              style: AppFonts.satoshiStyle(fontSize: 12, color: c.textSecondary),
                            ),
                            onTap: () {
                              Get.back();
                              Get.toNamed(Routes.ROOM_CHAT, arguments: ChatRoom(
                                roomId: roomId,
                                type: 'dm',
                                name: name,
                                otherUserId: uid,
                                photoUrl: photo,
                              ));
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchBar(AppC c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari percakapan',
          prefixIcon: Icon(FluentIcons.search_24_regular, color: c.textSecondary, size: 20),
          suffixIcon: Icon(FluentIcons.options_24_regular, color: c.textTertiary, size: 20),
          filled: true,
          fillColor: c.surface,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide(color: c.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(AppC c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
      child: AppSurface(
        padding: const EdgeInsets.all(AppSpacing.xxs),
        radius: AppRadius.lg,
        color: c.surfaceWarm,
        shadow: const [],
        child: Obx(
          () => Row(
            children: [
              _buildFilterItem(c, 'Semua', 1),
              _buildFilterItem(c, 'Belum dibaca', 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterItem(AppC c, String label, int index) {
    final isActive = controller.filterIndex.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeFilter(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? c.surface : AppColors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: isActive ? AppShadows.soft : const [],
            border: Border.all(color: isActive ? c.border : AppColors.transparent),
          ),
          child: Text(
            label,
            style: AppFonts.satoshiStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? AppColors.primary500 : c.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatItem({required AppC c, required ChatRoom chat}) {
    return Material(
      color: c.background,
      child: InkWell(
        onTap: () async {
          controller.markRead(chat.roomId);
          await Get.toNamed(Routes.ROOM_CHAT, arguments: chat);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Row(
            children: [
              if (chat.unread > 0)
                Container(
                  width: 8, height: 8,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                )
              else
                const SizedBox(width: 20),
              Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: c.primarySoft,
                    backgroundImage: chat.type == 'group'
                        ? null
                        : (chat.photoUrl != null
                            ? NetworkImage(chat.photoUrl!) as ImageProvider
                            : null),
                    child: chat.type == 'group' || chat.photoUrl == null
                        ? Text(chat.name.isNotEmpty ? chat.name[0].toUpperCase() : '?')
                        : null,
                  ),
                  if (chat.type == 'dm')
                    Positioned(
                      right: 1, bottom: 1,
                      child: Container(
                        width: 11, height: 11,
                        decoration: BoxDecoration(
                          color: chat.isOnline ? AppColors.success : AppColors.textSecondary,
                          shape: BoxShape.circle,
                          border: Border.all(color: c.surface, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.satoshiStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: c.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          relativeTime(chat.lastTime),
                          style: AppFonts.satoshiStyle(
                            fontSize: 11,
                            fontWeight: chat.unread > 0 ? FontWeight.w600 : FontWeight.w500,
                            color: chat.unread > 0 ? AppColors.primary : c.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.lastMessage,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.satoshiStyle(
                              fontSize: 13,
                              fontWeight: chat.unread > 0 ? FontWeight.w600 : FontWeight.w400,
                              color: chat.unread > 0 ? c.textPrimary : c.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ),
                        if (chat.unread > 0) ...[
                          const SizedBox(width: 10),
                          Container(
                            constraints: const BoxConstraints(minWidth: 22),
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              chat.unread.toString(),
                              textAlign: TextAlign.center,
                              style: AppFonts.satoshiStyle(
                                color: c.surface, fontSize: 10, fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatShimmer extends StatelessWidget {
  const _ChatShimmer();
  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
