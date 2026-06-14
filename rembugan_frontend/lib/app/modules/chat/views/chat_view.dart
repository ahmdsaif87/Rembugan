import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
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
                  final chats = controller.filteredChats;

                  if (chats.isEmpty) {
                    return const AppEmptyState(
                      icon: FluentIcons.chat_empty_24_regular,
                      title: 'Belum ada pesan',
                      message:
                          'Percakapan baru akan muncul di sini setelah Anda mulai berkolaborasi.',
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 18),
                    itemCount: chats.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: 84,
                      color: c.border.withValues(alpha: 0.4),
                    ),
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      return _buildChatItem(
                        c: c,
                        name: chat.name,
                        message: chat.message,
                        time: chat.time,
                        avatarUrl: chat.avatarUrl,
                        isUnread: chat.isUnread,
                        unreadCount: chat.unreadCount,
                      );
                    },
                  );
                }),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Text(
                    'Your personal messages are end-to-end encrypted',
                    style: AppFonts.satoshiStyle(
                      fontSize: 11,
                      color: c.textTertiary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(current: AppNavDestination.none),
    );
  }

  Widget _buildHeader(AppC c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(
        children: [
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
                // const SizedBox(height: 4),
                // Text(
                //   'Jaga koordinasi tim tetap rapi.',
                //   style: AppFonts.satoshiStyle(
                //     fontSize: 12,
                //     color: AppColors.textSecondary,
                //   ),
                // ),
              ],
            ),
          ),
          const AppIconButton(icon: FluentIcons.compose_24_regular),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppC c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari percakapan',
          prefixIcon: Icon(
            FluentIcons.search_24_regular,
            color: c.textSecondary,
            size: 20,
          ),
          suffixIcon: Icon(
            FluentIcons.options_24_regular,
            color: c.textTertiary,
            size: 20,
          ),
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
            border: Border.all(
              color: isActive ? c.border : AppColors.transparent,
            ),
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

  Widget _buildChatItem({
    required AppC c,
    required String name,
    required String message,
    required String time,
    required String avatarUrl,
    required bool isUnread,
    int unreadCount = 0,
  }) {
    return Material(
      color: c.background,
      child: InkWell(
        onTap: () => Get.toNamed(Routes.ROOM_CHAT),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: c.primarySoft,
                    backgroundImage: const AssetImage(
                      'lib/assets/img/avatar.png',
                    ),
                  ),
                  Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: AppColors.success,
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
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.satoshiStyle(
                              fontSize: 15,
                              fontWeight: isUnread
                                  ? FontWeight.w600
                                  : FontWeight.w600,
                              color: c.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          time,
                          style: AppFonts.satoshiStyle(
                            fontSize: 11,
                            fontWeight: isUnread
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isUnread
                                ? AppColors.primary
                                : c.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.satoshiStyle(
                              fontSize: 13,
                              fontWeight: isUnread
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isUnread
                                  ? AppColors.textPrimary
                                  : c.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: 10),
                          Container(
                            constraints: const BoxConstraints(minWidth: 22),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 5,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unreadCount.toString(),
                              textAlign: TextAlign.center,
                              style: AppFonts.satoshiStyle(
                                color: c.surface,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
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
