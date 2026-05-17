import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_chrome.dart';
import '../../../routes/app_pages.dart';
import '../controllers/team_controller.dart';

class TeamView extends GetView<TeamController> {
  const TeamView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppLayeredBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
      ),
      bottomNavigationBar: const AppBottomNav(current: AppNavDestination.team),
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
              style: AppFonts.generalSansStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Pusat kendali proyek dan tim Anda.',
              style: AppFonts.generalSansStyle(
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
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            FluentIcons.alert_24_regular,
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
          icon: FluentIcons.briefcase_24_filled,
          count: '3',
          label: 'Tim Aktif',
          color: AppColors.primary,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          icon: FluentIcons.checkmark_circle_24_filled,
          count: '5',
          label: 'Tugas Selesai',
          color: const Color(0xFF16A34A),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
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
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
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
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: AppFonts.generalSansStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: AppFonts.generalSansStyle(
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
          style: AppFonts.generalSansStyle(
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
            style: AppFonts.generalSansStyle(
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
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
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
              color: isUrgent
                  ? const Color(0xFFFEF2F2)
                  : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              FluentIcons.circle_24_regular,
              color: isUrgent
                  ? const Color(0xFFDC2626)
                  : AppColors.textSecondary,
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
                  style: AppFonts.generalSansStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  team,
                  style: AppFonts.generalSansStyle(
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
              color: isUrgent
                  ? const Color(0xFFFEF2F2)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              dueDate,
              style: AppFonts.generalSansStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isUrgent
                    ? const Color(0xFFDC2626)
                    : AppColors.textSecondary,
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
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  category,
                  style: AppFonts.generalSansStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Icon(
                FluentIcons.more_vertical_24_regular,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppFonts.generalSansStyle(
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
                style: AppFonts.generalSansStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppFonts.generalSansStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
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
                    return Positioned(
                      left: index * 16.0,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundImage: const AssetImage('lib/assets/img/avatar.png'),
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
                      child: const Icon(
                        FluentIcons.send_24_filled,
                        color: AppColors.textPrimary,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Get.snackbar('Info', 'Membuka workspace tim...');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Buka',
                        style: AppFonts.generalSansStyle(
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
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
            child: _buildNavItem(FluentIcons.home_24_regular, 'Beranda', false),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(Routes.EXPLORE),
            child: _buildNavItem(
              FluentIcons.globe_24_regular,
              'Jelajah',
              false,
            ),
          ),
          _buildCenterFAB(),
          _buildNavItem(FluentIcons.apps_24_filled, 'Proyek', true),
          GestureDetector(
            onTap: () => Get.toNamed(Routes.PROFILE),
            child: _buildNavItem(
              FluentIcons.person_24_regular,
              'Profil',
              false,
            ),
          ),
        ],
      ),
    );
  }

  // Center FAB in nav bar
  Widget _buildCenterFAB() {
    return GestureDetector(
      onTap: () {
        // TODO: handle create action
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF4A1521),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          FluentIcons.add_24_filled,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? AppColors.primary : AppColors.textSecondary,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppFonts.generalSansStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
