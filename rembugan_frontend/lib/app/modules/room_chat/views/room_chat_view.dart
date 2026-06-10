import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_chrome.dart';
import '../controllers/room_chat_controller.dart';

class RoomChatView extends GetView<RoomChatController> {
  const RoomChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: AppLayeredBackground(
        child: Column(
          children: [
            // ── Chat Messages ──
            Expanded(
              child: Obx(
                () => ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: controller.messages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          child: Text(
                            'Hari ini',
                            style: AppFonts.satoshiStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }

                    final msg = controller.messages[index - 1];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _buildMessageBubble(
                        message: msg.text,
                        time: msg.time,
                        isMe: msg.isMe,
                        avatarUrl: msg.avatarUrl,
                        fileName: msg.fileName,
                        fileSize: msg.fileSize,
                        sharedPost: msg.sharedPost,
                        isRead: true,
                      ),
                    );
                  },
                ),
              ),
            ),

            // ── Input Bar ──
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  // 1. AppBar Widget
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white.withValues(alpha: 0.96),
      elevation: 0,
      surfaceTintColor: AppColors.transparent,
      leading: IconButton(
        icon: const Icon(
          FluentIcons.chevron_left_24_regular,
          color: AppColors.textPrimary,
        ),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('lib/assets/img/avatar.png'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Raka Pratama',
                  style: AppFonts.satoshiStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Typing...',
                  style: AppFonts.satoshiStyle(
                    fontSize: 12,
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            FluentIcons.more_vertical_24_regular,
            color: AppColors.textPrimary,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  // 2. Message Bubble Widget
  Widget _buildMessageBubble({
    required String message,
    required String time,
    required bool isMe,
    required String avatarUrl,
    String? fileName,
    String? fileSize,
    Map<String, dynamic>? sharedPost,
    bool isRead = false,
  }) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMe) ...[
          CircleAvatar(
            radius: 14,
            backgroundImage: const AssetImage('lib/assets/img/avatar.png'),
          ),
          const SizedBox(width: 8),
        ],

        // Message Content
        Flexible(
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.textPrimary : AppColors.surface,
                  border: isMe ? null : Border.all(color: AppColors.border),
                  boxShadow: isMe ? AppShadows.soft : const [],
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(AppRadius.md),
                    topRight: const Radius.circular(AppRadius.md),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    // Render message text if not empty
                    if (message.isNotEmpty)
                      Text(
                        message,
                        style: AppFonts.satoshiStyle(
                          fontSize: 14,
                          color: isMe ? AppColors.white : AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),

                    // Render shared post preview card if present
                    if (sharedPost != null) ...[
                      if (message.isNotEmpty) const SizedBox(height: 10),
                      Container(
                        width: 250,
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: AppColors.grey200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Shared post header (Avatar + Name)
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundImage: NetworkImage(
                                    sharedPost['avatarUrl'] ??
                                        'https://i.pravatar.cc/100?img=33',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sharedPost['name'] ?? '',
                                        style: AppFonts.satoshiStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        sharedPost['subtitle'] ?? '',
                                        style: AppFonts.satoshiStyle(
                                          fontSize: 9.5,
                                          color: AppColors.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Text caption of post (truncated)
                            Text(
                              sharedPost['content'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.satoshiStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                                height: 1.35,
                              ),
                            ),
                            if (sharedPost['imageAsset'] != null) ...[
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.xs,
                                ),
                                child: Image.asset(
                                  sharedPost['imageAsset'],
                                  height: 110,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Divider(height: 1, color: AppColors.grey200.withValues(alpha: 0.4)),
                            const SizedBox(height: 6),
                            Center(
                              child: Text(
                                'Lihat Postingan',
                                style: AppFonts.satoshiStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Render attachment file card if present
                    if (fileName != null) ...[
                      if (message.isNotEmpty) const SizedBox(height: 8),
                      Container(
                        width: 220,
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: isMe
                              ? AppColors.white.withValues(alpha: 0.12)
                              : AppColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                          border: Border.all(
                            color: isMe
                                ? AppColors.white.withValues(alpha: 0.2)
                                : AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              fileName.endsWith('.png') ||
                                      fileName.endsWith('.jpg')
                                  ? FluentIcons.image_24_regular
                                  : FluentIcons.document_24_regular,
                              color: isMe ? AppColors.white : AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fileName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppFonts.satoshiStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isMe
                                          ? AppColors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    fileSize ?? '1.2 MB',
                                    style: AppFonts.satoshiStyle(
                                      fontSize: 10,
                                      color: isMe
                                          ? AppColors.white.withValues(
                                              alpha: 0.7,
                                            )
                                          : AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              FluentIcons.arrow_download_24_regular,
                              color: isMe
                                  ? AppColors.white70
                                  : AppColors.textSecondary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isMe && isRead) ...[
                    Text(
                      'Dibaca ',
                      style: AppFonts.satoshiStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Icon(
                      FluentIcons.checkmark_24_regular,
                      color: AppColors.success,
                      size: 12,
                    ),
                  ] else ...[
                    Text(
                      time,
                      style: AppFonts.satoshiStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        if (isMe) ...[
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 14,
            backgroundImage: const AssetImage('lib/assets/img/avatar.png'),
          ),
        ],
      ],
    );
  }

  // 3. Input Bar Widget
  Widget _buildInputBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Attachment Preview Chip Row
        Obx(() {
          if (controller.attachedFileName.value == null) {
            return const SizedBox.shrink();
          }
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: const BoxDecoration(
              color: AppColors.grey50,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(
                    controller.attachedFileName.value!.endsWith('.png') ||
                            controller.attachedFileName.value!.endsWith('.jpg')
                        ? FluentIcons.image_24_regular
                        : FluentIcons.document_24_regular,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.attachedFileName.value!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.satoshiStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        controller.attachedFileSize.value ?? '1.2 MB',
                        style: AppFonts.satoshiStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.removeAttachment(),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xxs),
                    decoration: const BoxDecoration(
                      color: AppColors.border,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      FluentIcons.dismiss_12_filled,
                      color: AppColors.textSecondary,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        // Input Field and Buttons Row
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: const BoxDecoration(
            color: AppColors.white,
          ),
          child: Row(
            children: [
              // Plus/Attachment Button
              GestureDetector(
                onTap: () {
                  Get.bottomSheet(
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(AppRadius.lg),
                          topRight: Radius.circular(AppRadius.lg),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Lampirkan File & Dokumen',
                            style: AppFonts.satoshiStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          AppListItem(
                            leading: const Icon(
                              FluentIcons.image_24_regular,
                              color: AppColors.primary,
                            ),
                            title: 'Foto & Media',
                            onTap: () {
                              controller.attachFile(
                                'Design_Mockup.png',
                                '2.4 MB',
                              );
                              Get.back();
                              Get.snackbar(
                                'File Dilampirkan',
                                'Design_Mockup.png berhasil dipilih',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: AppColors.primary500,
                                colorText: AppColors.white,
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppListItem(
                            leading: const Icon(
                              FluentIcons.document_24_regular,
                              color: AppColors.primary,
                            ),
                            title: 'Dokumen & File PDF',
                            onTap: () {
                              controller.attachFile(
                                'Draft_Proposal_v2.pdf',
                                '1.8 MB',
                              );
                              Get.back();
                              Get.snackbar(
                                'File Dilampirkan',
                                'Draft_Proposal_v2.pdf berhasil dipilih',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: AppColors.primary500,
                                colorText: AppColors.white,
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    FluentIcons.add_24_regular,
                    color: AppColors.textSecondary,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Text Field
              Expanded(
                child: TextField(
                  controller: controller.messageController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surface,
                    hintText: 'Ketik pesan',
                    hintStyle: AppFonts.satoshiStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 13.5,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: BorderSide(
                        color: AppColors.border.withValues(alpha: 0.8),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: BorderSide(
                        color: AppColors.textPrimary.withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: BorderSide(
                        color: AppColors.border.withValues(alpha: 0.8),
                        width: 1.0,
                      ),
                    ),
                  ),
                  style: AppFonts.satoshiStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              // Send Button
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => controller.sendMessage(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary500,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Center(
                    child: Icon(
                      FluentIcons.send_24_filled,
                      color: AppColors.white,
                      size: 20,
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
