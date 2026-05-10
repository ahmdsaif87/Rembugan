import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/theme.dart';
import '../../../routes/app_pages.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Off-white
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Cover & Profile Pic ──
              _buildHeader(),

              const SizedBox(height: 12),

              // ── Bio & Info ──
              _buildUserInfo(),

              const SizedBox(height: 12),

              // ── Interests ──
              _buildInterests(),

              const SizedBox(height: 12),

              // ── Postings ──
              _buildPostings(),

              const SizedBox(height: 12),

              // ── Experience / Collab History ──
              _buildCollabHistory(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // 1. Header (Cover & Avatar)
  Widget _buildHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Cover Image
        Container(
          height: 120,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryHover, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Opacity(
            opacity: 0.1,
            child: Image.network(
              'https://www.transparenttextures.com/patterns/cubes.png',
              repeat: ImageRepeat.repeat,
            ),
          ),
        ),
        // Profile Avatar
        Positioned(
          bottom: -40,
          left: 24,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=60'),
            ),
          ),
        ),
        // Edit Button
        Positioned(
          bottom: 12,
          right: 24,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: const PhosphorIcon(
              PhosphorIconsRegular.pencilSimple,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  // 2. User Info
  Widget _buildUserInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 48, left: 24, right: 24, bottom: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dede Fernanda',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'Fullstack Developer | Flutter & Node.js Enthusiast',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const PhosphorIcon(PhosphorIconsRegular.mapPin, color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 4),
              Text(
                'Malang, Indonesia',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 16),
              const PhosphorIcon(PhosphorIconsRegular.link, color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 4),
              Text(
                'github.com/dedef',
                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF2563EB)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Bio
          Text(
            'About',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Saya seorang software engineer yang berfokus pada pengembangan aplikasi mobile menggunakan Flutter. Suka berkolaborasi dalam proyek open source dan membangun produk yang berdampak.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // 3. Interests
  Widget _buildInterests() {
    final interests = ['Flutter', 'Dart', 'Node.js', 'UI/UX', 'Open Source', 'Firebase'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Interests',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: interests.map((interest) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  interest,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Postings Section ──
  Widget _buildPostings() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Postingan Saya',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildPostItem(
            content: 'Baru saja menyelesaikan slicing UI untuk halaman Chat dan Room Chat! Desainnya makin clean dan modern. 🚀 #Flutter #UIUX',
            time: '2 jam yang lalu',
            likes: 12,
            comments: 4,
          ),
          const Divider(height: 24, color: AppColors.border),
          _buildPostItem(
            content: 'Mencari tim untuk kolaborasi di Hackathon bulan depan. Ada yang tertarik? Skill yang dibutuhkan: UI/UX Designer & Backend Dev.',
            time: '1 hari yang lalu',
            likes: 24,
            comments: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildPostItem({
    required String content,
    required String time,
    required int likes,
    required int comments,
  }) {
    return GestureDetector(
      onTap: () {
        Get.snackbar('Info', 'Detail postingan akan segera hadir!');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Row(
                children: [
                  const PhosphorIcon(PhosphorIconsRegular.thumbsUp, color: AppColors.textSecondary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    likes.toString(),
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  const PhosphorIcon(PhosphorIconsRegular.chatCircle, color: AppColors.textSecondary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    comments.toString(),
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4. Collaboration History
  Widget _buildCollabHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Riwayat Kolaborasi',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildCollabItem(
            role: 'Lead Developer',
            project: 'Rembugan App',
            duration: 'Jan 2026 - Sekarang',
            description: 'Membangun arsitektur aplikasi dan mengimplementasikan fitur chat real-time.',
          ),
          const Divider(height: 24, color: AppColors.border),
          _buildCollabItem(
            role: 'UI/UX Designer',
            project: 'E-Commerce Redesign',
            duration: 'Okt 2025 - Des 2025',
            description: 'Membuat wireframe dan high-fidelity prototype untuk aplikasi e-commerce.',
          ),
        ],
      ),
    );
  }

  Widget _buildCollabItem({
    required String role,
    required String project,
    required String duration,
    required String description,
  }) {
    return GestureDetector(
      onTap: () {
        Get.snackbar('Info', 'Detail kolaborasi akan segera hadir!');
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF2F8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const PhosphorIcon(
              PhosphorIconsRegular.briefcase,
              color: Color(0xFFDB2777),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  project,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  duration,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
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
          GestureDetector(
            onTap: () => Get.toNamed(Routes.CHAT),
            child: _buildNavItem(PhosphorIconsRegular.paperPlaneTilt, 'Pesan', false),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(Routes.TEAM),
            child: _buildNavItem(PhosphorIconsRegular.briefcase, 'Tim', false),
          ),
          _buildNavItem(PhosphorIconsFill.user, 'Profil', true),
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
