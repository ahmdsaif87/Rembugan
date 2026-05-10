import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:rembugan_frontend/app/routes/app_pages.dart';

import '../../../core/theme/theme.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            _buildHeader(),

            // ── Tabs ──
            _buildTabs(),
            const Divider(height: 1, color: AppColors.border),

            // ── Feed (Scrollable) ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  _buildPostCard(
                    avatarUrl: 'https://i.pravatar.cc/100?img=33',
                    name: 'Cameron Williamson',
                    subtitle: 'D4 Teknik Informatika • 2 jam yang lalu',
                    content:
                        'lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet',
                    hasImage: true,
                    imageUrl: 'https://picsum.photos/id/20/400/250',
                  ),
                  const Divider(height: 32, color: AppColors.border),
                  _buildPostCard(
                    avatarUrl: 'https://i.pravatar.cc/100?img=12',
                    name: 'Marvin McKinney',
                    subtitle: 'D4 Teknik Informatika • 2 jam yang lalu',
                    content:
                        'lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet',
                    hasImage: false,
                  ),
                  const Divider(height: 32, color: AppColors.border),
                  _buildPostCard(
                    avatarUrl: 'https://i.pravatar.cc/100?img=12',
                    name: 'Marvin McKinney',
                    subtitle: 'D4 Teknik Informatika • 2 jam yang lalu',
                    content:
                        'lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet',
                    hasImage: false,
                  ),
                  const Divider(height: 32, color: AppColors.border),
                  _buildPostCard(
                    avatarUrl: 'https://i.pravatar.cc/100?img=33',
                    name: 'Cameron Williamson',
                    subtitle: 'D4 Teknik Informatika • 2 jam yang lalu',
                    content:
                        'lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet',
                    hasImage: true,
                    imageUrl: 'https://picsum.photos/id/20/400/250',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── Floating Action Button ──
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

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
            'Rembugan.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            children: [
              Stack(
                children: [
                  PhosphorIcon(
                    PhosphorIconsRegular.bell,
                    color: AppColors.textPrimary,
                    size: 26,
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              PhosphorIcon(
                PhosphorIconsRegular.magnifyingGlass,
                color: AppColors.textPrimary,
                size: 26,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Tabs Widget
  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Untukmu',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(height: 2, color: AppColors.textPrimary),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Mengikuti',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Container(height: 2, color: Colors.transparent),
            ],
          ),
        ),
      ],
    );
  }

  // 3. Post Card Widget
  Widget _buildPostCard({
    required String avatarUrl,
    required String name,
    required String subtitle,
    required String content,
    required bool hasImage,
    String? imageUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Post
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Ikuti',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              PhosphorIcon(
                PhosphorIconsRegular.dotsThreeVertical,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Konten Teks
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // Gambar Post (Jika ada)
          if (hasImage && imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Interaksi (Like, Comment, Share)
          Row(
            children: [
              _buildInteractionItem(PhosphorIconsRegular.heart, '120'),
              const SizedBox(width: 24),
              _buildInteractionItem(PhosphorIconsRegular.chatCircle, '20'),
              const SizedBox(width: 24),
              PhosphorIcon(
                PhosphorIconsRegular.paperPlaneTilt,
                color: AppColors.textSecondary,
                size: 22,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Item Interaksi
  Widget _buildInteractionItem(PhosphorIconData icon, String count) {
    return Row(
      children: [
        PhosphorIcon(icon, color: AppColors.textSecondary, size: 22),
        const SizedBox(width: 6),
        Text(
          count,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // 4. Floating Action Button
  Widget _buildFAB() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF4A1521), // Warna gelap seperti di gambar
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.add, color: Colors.white, size: 28),
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
          _buildNavItem(PhosphorIconsFill.house, 'Beranda', true),
          GestureDetector(
            onTap: () => Get.toNamed(Routes.EXPLORE),
            child: _buildNavItem(PhosphorIconsRegular.binoculars, 'Proyek', false),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(Routes.CHAT),
            child: _buildNavItem(PhosphorIconsRegular.paperPlaneTilt, 'Pesan', false),
          ),
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
