import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/theme.dart';
import '../controllers/room_chat_controller.dart';

class RoomChatView extends GetView<RoomChatController> {
  const RoomChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // ── Chat Messages ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Date Divider
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Hari ini',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // Left Message
                _buildMessageBubble(
                  message: 'lorem ipsum lorem ipsum lorem ipsum lorem awdkowakdokawod awdwa',
                  time: '18.35',
                  isMe: false,
                  avatarUrl: 'https://i.pravatar.cc/100?img=60',
                ),

                const SizedBox(height: 16),

                // Right Message
                _buildMessageBubble(
                  message: 'lorem ipsum lorem ipsum lorem ipsum lorem awdkowakdokawod awdwa',
                  time: '18.35',
                  isMe: true,
                  avatarUrl: 'https://i.pravatar.cc/100?img=33',
                  isRead: true,
                ),
              ],
            ),
          ),

          // ── Input Bar ──
          _buildInputBar(),
        ],
      ),
    );
  }

  // 1. AppBar Widget
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const PhosphorIcon(PhosphorIconsRegular.arrowLeft, color: AppColors.textPrimary),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=60'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dede Fernanda',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Typing...',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.green, // "Typing..." is often green or gray
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
          icon: const PhosphorIcon(PhosphorIconsRegular.dotsThreeVertical, color: AppColors.textPrimary),
          onPressed: () {},
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppColors.border,
          height: 1,
        ),
      ),
    );
  }

  // 2. Message Bubble Widget
  Widget _buildMessageBubble({
    required String message,
    required String time,
    required bool isMe,
    required String avatarUrl,
    bool isRead = false,
  }) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMe) ...[
          CircleAvatar(
            radius: 14,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(width: 8),
        ],
        
        // Message Content
        Flexible(
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFF3B82F6) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                ),
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isMe ? Colors.white : AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isMe && isRead) ...[
                    Text(
                      'Dibaca ',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  Text(
                    time,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        if (isMe) ...[
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 14,
            backgroundImage: NetworkImage(avatarUrl),
          ),
        ],
      ],
    );
  }

  // 3. Input Bar Widget
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Plus Button
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.add,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Text Field
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Ketik pesan',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          
          // Send Button (Optional but good for UX)
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF3B82F6),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: PhosphorIcon(
                PhosphorIconsRegular.paperPlaneTilt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
