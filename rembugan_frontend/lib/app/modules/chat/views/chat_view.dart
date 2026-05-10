import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/theme.dart';
import '../../../routes/app_pages.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            _buildHeader(),

            // ── Search Bar ──
            _buildSearchBar(),

            // ── Filters ──
            _buildFilters(),

            // ── Chat List ──
            Expanded(
              child: Obx(() {
                final chats = controller.filteredChats;
                
                if (chats.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada pesan',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: chats.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    color: AppColors.border,
                    indent: 80, // Indent to align with text
                  ),
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    return _buildChatItem(
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

            // ── Encryption Notice ──
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Your personal messages are end-to-end encrypted',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Bottom Navigation Bar ──
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // 1. Header Widget
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Pesan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          PhosphorIcon(
            PhosphorIconsRegular.pencilSimpleLine,
            color: AppColors.textPrimary,
            size: 26,
          ),
        ],
      ),
    );
  }

  // 2. Search Bar Widget
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            prefixIcon: const PhosphorIcon(
              PhosphorIconsRegular.magnifyingGlass,
              color: AppColors.textSecondary,
              size: 20,
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  // 3. Filters Widget
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Obx(() => Row(
            children: [
              _buildFilterItem('Semua', 1),
              const SizedBox(width: 8),
              _buildFilterItem('Belum dibaca', 0),
            ],
          )),
    );
  }

  Widget _buildFilterItem(String label, int index) {
    final isActive = controller.filterIndex.value == index;
    return GestureDetector(
      onTap: () => controller.changeFilter(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  // 4. Chat Item Widget
  Widget _buildChatItem({
    required String name,
    required String message,
    required String time,
    required String avatarUrl,
    required bool isUnread,
    int unreadCount = 0,
  }) {
    return ListTile(
      onTap: () => Get.toNamed(Routes.ROOM_CHAT),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(avatarUrl),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            time,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isUnread ? FontWeight.bold : FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                  color: isUnread ? AppColors.textPrimary : AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ),
            if (isUnread) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 5. Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () => Get.offAllNamed(Routes.HOME),
            child: _buildNavItem(PhosphorIconsRegular.house, 'Beranda', false),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(Routes.EXPLORE),
            child: _buildNavItem(PhosphorIconsRegular.binoculars, 'Proyek', false),
          ),
          _buildNavItem(PhosphorIconsFill.paperPlaneTilt, 'Pesan', true),
          GestureDetector(
            onTap: () => Get.toNamed(Routes.TEAM),
            child: _buildNavItem(PhosphorIconsRegular.briefcase, 'Tim', false),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(Routes.PROFILE),
            child: _buildNavItem(PhosphorIconsRegular.user, 'Profil', false),
          ),
        ],
      ),
    );
  }

  // Nav Item
  Widget _buildNavItem(PhosphorIconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PhosphorIcon(
          icon,
          color: isActive ? const Color(0xFF4A1521) : AppColors.textSecondary,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? const Color(0xFF4A1521) : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
