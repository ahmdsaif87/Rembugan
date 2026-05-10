import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/theme.dart';
import '../../../routes/app_pages.dart';
import '../controllers/team_controller.dart';

class TeamView extends GetView<TeamController> {
  const TeamView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Off-white clean background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              _buildHeader(),
              const SizedBox(height: 24),

              // ── Quick Stats (Dashboard Style) ──
              _buildQuickStats(),
              const SizedBox(height: 28),

              // ── Section: Urgent Tasks ──
              _buildSectionHeader('Tugas Prioritas', 'Lihat Semua'),
              const SizedBox(height: 12),
              _buildUrgentTasks(),
              const SizedBox(height: 28),

              // ── Section: My Teams (Workspace Folders) ──
              _buildSectionHeader('Workspace Tim', 'Tambah'),
              const SizedBox(height: 12),
              _buildWorkspaceTeams(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // 1. Header
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workspace',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Pusat kendali proyek dan tim Anda.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 5,
              ),
            ],
          ),
          child: const PhosphorIcon(
            PhosphorIconsRegular.bell,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
      ],
    );
  }

  // 2. Quick Stats
  Widget _buildQuickStats() {
    return Row(
      children: [
        _buildStatCard(
          icon: PhosphorIconsFill.briefcase,
          count: '3',
          label: 'Tim Aktif',
          color: AppColors.primary,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          icon: PhosphorIconsFill.checkCircle,
          count: '5',
          label: 'Tugas Selesai',
          color: const Color(0xFF16A34A),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required PhosphorIconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: PhosphorIcon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 3. Section Header
  Widget _buildSectionHeader(String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            actionText,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  // 4. Urgent Tasks
  Widget _buildUrgentTasks() {
    return Column(
      children: [
        _buildTaskItem(
          title: 'Slicing UI Dashboard',
          team: 'Rembugan Dev',
          dueDate: 'Hari ini',
          isUrgent: true,
        ),
        const SizedBox(height: 12),
        _buildTaskItem(
          title: 'Review Competitor App',
          team: 'UI/UX Designers',
          dueDate: 'Besok',
          isUrgent: false,
        ),
      ],
    );
  }

  Widget _buildTaskItem({
    required String title,
    required String team,
    required String dueDate,
    required bool isUrgent,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isUrgent ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.circle_outlined,
              color: isUrgent ? const Color(0xFFDC2626) : AppColors.textSecondary,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  team,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isUrgent ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              dueDate,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isUrgent ? const Color(0xFFDC2626) : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 5. Workspace Teams
  Widget _buildWorkspaceTeams() {
    return Column(
      children: [
        _buildWorkspaceCard(
          title: 'Rembugan Dev Team',
          category: 'Mobile App',
          progress: 0.7,
          members: [
            'https://i.pravatar.cc/100?img=60',
            'https://i.pravatar.cc/100?img=47',
            'https://i.pravatar.cc/100?img=33',
          ],
        ),
        const SizedBox(height: 16),
        _buildWorkspaceCard(
          title: 'UI/UX Designers',
          category: 'Design System',
          progress: 0.4,
          members: [
            'https://i.pravatar.cc/100?img=47',
            'https://i.pravatar.cc/100?img=33',
          ],
        ),
      ],
    );
  }

  Widget _buildWorkspaceCard({
    required String title,
    required String category,
    required double progress,
    required List<String> members,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  category,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const PhosphorIcon(PhosphorIconsRegular.dotsThreeVertical, color: AppColors.textSecondary, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress Proyek',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
          
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Members
              SizedBox(
                height: 28,
                width: 100,
                child: Stack(
                  children: members.asMap().entries.map((entry) {
                    final index = entry.key;
                    final url = entry.value;
                    return Positioned(
                      left: index * 16.0,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundImage: NetworkImage(url),
                        backgroundColor: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Action Buttons
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.toNamed(Routes.ROOM_CHAT),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const PhosphorIcon(PhosphorIconsFill.paperPlaneTilt, color: AppColors.textPrimary, size: 16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Get.snackbar('Info', 'Membuka workspace tim...');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Buka',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 6. Bottom Navigation Bar
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
            color: Colors.black.withOpacity(0.05),
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
          _buildNavItem(PhosphorIconsFill.briefcase, 'Tim', true),
          GestureDetector(
            onTap: () => Get.toNamed(Routes.PROFILE),
            child: _buildNavItem(PhosphorIconsRegular.user, 'Profil', false),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(PhosphorIconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PhosphorIcon(
          icon,
          color: isActive ? AppColors.primary : AppColors.textSecondary,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
