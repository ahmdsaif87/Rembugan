import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_chrome.dart';

import '../controllers/room_chat_controller.dart';

class RoomChatView extends GetView<RoomChatController> {
  const RoomChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: _buildAppBar(c),
      body: AppLayeredBackground(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const _ChatShimmer();
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: controller.messages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          child: Text(
                            'Hari ini',
                            style: AppFonts.satoshiStyle(
                              fontSize: 12, color: c.textSecondary, fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }
                    final msg = controller.messages[index - 1];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _buildMessageBubble(c: c, msg: msg),
                    );
                  },
                );
              }),
            ),
            _buildInputBar(c),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppC c) {
    final room = controller.room;
    return AppBar(
      backgroundColor: c.surface.withValues(alpha: 0.96),
      elevation: 0,
      surfaceTintColor: AppColors.transparent,
      leading: Tooltip(
        message: 'Kembali',
        child: IconButton(
          icon: Icon(FluentIcons.chevron_left_24_regular, color: c.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: c.primarySoft,
            backgroundImage: room.photoUrl != null
                ? NetworkImage(room.photoUrl!) as ImageProvider
                : null,
            child: room.photoUrl == null
                ? Text(room.name.isNotEmpty ? room.name[0].toUpperCase() : '?')
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name,
                  style: AppFonts.satoshiStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: c.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: const [],
    );
  }

  Widget _buildMessageBubble({required AppC c, required ChatMessage msg}) {
    final room = controller.room;
    final isGroup = room.type == 'group';
    final otherPhoto = !msg.isMe && isGroup ? room.photoUrl : null;
    final ts = relativeTime(msg.time);
    return Row(
      mainAxisAlignment: msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!msg.isMe && isGroup)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: c.grey100,
              backgroundImage: otherPhoto != null ? NetworkImage(otherPhoto) as ImageProvider : null,
              child: otherPhoto == null
                  ? Text(msg.senderName.isNotEmpty ? msg.senderName[0].toUpperCase() : '?')
                  : null,
            ),
          ),
        Flexible(
          child: Column(
            crossAxisAlignment: msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: msg.isMe ? AppColors.primary500 : c.surface,
                  border: msg.isMe ? null : Border.all(color: c.border),
                  boxShadow: msg.isMe ? AppShadows.soft : const [],
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(AppRadius.md),
                    topRight: const Radius.circular(AppRadius.md),
                    bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
                    bottomRight: Radius.circular(msg.isMe ? 4 : 16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (msg.text.isNotEmpty && msg.type != 'file')
                      Text(
                        msg.text,
                        style: AppFonts.satoshiStyle(
                          fontSize: 14, color: msg.isMe ? AppColors.white : c.textPrimary, height: 1.4,
                        ),
                      ),
                    if (msg.attachmentUrl != null) ...[
                      if (msg.text.isNotEmpty || msg.type == 'file') const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {/* TODO: open file url */},
                        child: Container(
                          width: 220,
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: msg.isMe ? c.surface.withValues(alpha: 0.12) : c.surfaceSecondary,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                            border: Border.all(
                              color: msg.isMe ? c.surface.withValues(alpha: 0.2) : c.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                (msg.attachmentName?.endsWith('.png') == true ||
                                        msg.attachmentName?.endsWith('.jpg') == true)
                                    ? FluentIcons.image_24_regular
                                    : FluentIcons.document_24_regular,
                                color: msg.isMe ? AppColors.white : AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      msg.attachmentName ?? 'File',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppFonts.satoshiStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: msg.isMe ? AppColors.white : c.textPrimary,
                                      ),
                                    ),
                                    if (msg.attachmentSize != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        '${(msg.attachmentSize! / 1024 / 1024).toStringAsFixed(1)} MB',
                                        style: AppFonts.satoshiStyle(
                                          fontSize: 10,
                                          color: msg.isMe
                                              ? AppColors.white.withValues(alpha: 0.7)
                                              : c.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Icon(
                                FluentIcons.arrow_download_24_regular,
                                color: msg.isMe ? AppColors.white70 : c.textSecondary,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (ts.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(ts, style: AppFonts.satoshiStyle(fontSize: 10, color: c.textSecondary)),
              ],
            ],
          ),
        ),
        if (msg.isMe && isGroup) const SizedBox(width: 30),
      ],
    );
  }

  Widget _buildInputBar(AppC c) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() {
          if (!controller.isUploading.value) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            color: c.grey50,
            child: Row(
              children: [
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                const SizedBox(width: 12),
                Text('Mengupload...', style: AppFonts.satoshiStyle(fontSize: 13, color: c.textSecondary)),
              ],
            ),
          );
        }),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(color: c.surface),
          child: Row(
            children: [
              Material(
                color: AppColors.transparent,
                child: InkWell(
                  onTap: () => controller.uploadAndSendFile(),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: c.surface,
                      border: Border.all(color: c.border),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(FluentIcons.add_24_regular, color: c.textSecondary, size: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller.messageController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: c.surface,
                    hintText: 'Ketik pesan',
                    hintStyle: AppFonts.satoshiStyle(fontSize: 14, color: c.textSecondary.withValues(alpha: 0.6)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 13.5),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: BorderSide(color: c.border.withValues(alpha: 0.8), width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: BorderSide(color: c.textPrimary.withValues(alpha: 0.4), width: 1.2),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: BorderSide(color: c.border.withValues(alpha: 0.8), width: 1.0),
                    ),
                  ),
                  style: AppFonts.satoshiStyle(fontSize: 14, color: c.textPrimary),
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: AppColors.transparent,
                child: InkWell(
                  onTap: () => controller.sendMessage(),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary500,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Center(
                      child: Icon(FluentIcons.send_24_filled, color: AppColors.white, size: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
