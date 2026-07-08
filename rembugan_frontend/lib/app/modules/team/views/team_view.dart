import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_chrome.dart';
import '../../../routes/app_pages.dart';
import '../../main_shell/controllers/main_shell_controller.dart';
import '../controllers/team_controller.dart';
import 'workspace_detail_view.dart';

const _green = AppColors.success600; // online/success
const _amber = AppColors.warning700; // pending/deadline
const _blue = AppColors.info500; // mention/activity
const _red = AppColors.danger500; // urgent

class TeamView extends GetView<TeamController> {
  const TeamView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);

    return Scaffold(
      backgroundColor: c.background,
      body: AppLayeredBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Proyek Tim',
                            style: AppFonts.headingStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: c.textPrimary,
                              height: 1.1,
                            ),
                          ),
                        ),
                        Tooltip(
                          message: 'Scan QR Proyek',
                          child: IconButton(
                            icon: const Icon(
                              FluentIcons.scan_dash_24_regular,
                              size: 22,
                            ),
                            onPressed: () => Get.toNamed(Routes.SCAN),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () => Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: _green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${controller.workspaces.length} workspace',
                            style: AppFonts.satoshiStyle(
                              fontSize: 12,
                              color: c.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Chip Filters ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Obx(
                  () => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(c, 'Semua', 0),
                        const SizedBox(width: 8),
                        _buildFilterChip(c, 'Punya Saya', 1),
                        const SizedBox(width: 8),
                        _buildFilterChip(c, 'Diikuti', 2),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Content ──
              Expanded(
                child: Obx(() {
                  final list = controller.filteredWorkspaces;

                  if (list.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: c.primarySoft,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                controller.workspaceFilter.value == 1
                                    ? FluentIcons.briefcase_24_regular
                                    : FluentIcons.people_team_24_regular,
                                size: 32,
                                color: AppColors.primary500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              controller.workspaceFilter.value == 1
                                  ? 'Belum ada workspace'
                                  : controller.workspaceFilter.value == 2
                                      ? 'Belum mengikuti workspace'
                                      : 'Belum ada workspace',
                              style: AppFonts.satoshiStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: c.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              controller.workspaceFilter.value == 1
                                  ? 'Buat tawaran lewat tombol +\ndi Jelajah untuk memulai.'
                                  : controller.workspaceFilter.value == 2
                                      ? 'Apply ke tawaran di Jelajah\natau scan QR untuk bergabung.'
                                      : 'Buat tawaran lewat tombol + di Jelajah\natau apply untuk bergabung.',
                              textAlign: TextAlign.center,
                              style: AppFonts.satoshiStyle(
                                fontSize: 13,
                                color: c.textSecondary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 22),
                            SizedBox(
                              width: 180,
                              height: 42,
                              child: ElevatedButton.icon(
                                onPressed: () => Get.find<MainShellController>().changeTab(1),
                                icon: const Icon(FluentIcons.search_24_regular, size: 16),
                                label: Text(
                                  'Jelajahi Proyek',
                                  style: AppFonts.satoshiStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary500,
                                  foregroundColor: AppColors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, AppSpacing.xl),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final ws = list[index];
                      return _WorkspaceRow(ws: ws, onTap: () => _open(ws));
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),

    );
  }

  void _open(WorkspaceModel ws) {
    controller.openWorkspace(ws);
    Get.to<void>(() => const WorkspaceDetailView());
  }

  Widget _buildFilterChip(AppC c, String label, int filter) {
    final active = controller.workspaceFilter.value == filter;
    int count;
    switch (filter) {
      case 1: count = controller.ownedWorkspaces.length;
      case 2: count = controller.joinedWorkspaces.length;
      default: count = controller.workspaces.length;
    }
    return GestureDetector(
      onTap: () => controller.workspaceFilter.value = filter,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary500 : c.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: active ? AppColors.primary500 : c.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppFonts.satoshiStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? AppColors.white : c.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.white.withValues(alpha: 0.2)
                    : c.grey100,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                '$count',
                style: AppFonts.satoshiStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: active ? AppColors.white : c.grey500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  WORKSPACE ROW (stateful for press depth)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _WorkspaceRow extends StatefulWidget {
  const _WorkspaceRow({required this.ws, required this.onTap});
  final WorkspaceModel ws;
  final VoidCallback onTap;

  @override
  State<_WorkspaceRow> createState() => _WorkspaceRowState();
}

class _WorkspaceRowState extends State<_WorkspaceRow> {
  Color get _accentDot {
    if (widget.ws.urgency == 'overdue') return _red;
    if (widget.ws.urgency == 'deadline') return _amber;
    return _green;
  }

  LinearGradient _workspaceGradient(String name) {
    final hash = name.hashCode;
    final palettes = [
      [const Color(0xFF4F5B73), const Color(0xFF374151)],
      [const Color(0xFF6C5CE7), const Color(0xFF4E61F6)],
      [const Color(0xFF059669), const Color(0xFF10B981)],
      [const Color(0xFF7C3AED), const Color(0xFF8B5CF6)],
    ];
    final colors = palettes[hash.abs() % palettes.length];
    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final ws = widget.ws;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Row 1: Icon + Name/Category + Unread + Chevron ──
                Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: _workspaceGradient(ws.name),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            ws.name.substring(0, 1).toUpperCase(),
                            style: AppFonts.satoshiStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -1,
                          right: -1,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: _accentDot,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: c.surface,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ws.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.satoshiStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: c.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ws.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.satoshiStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: c.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (ws.unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _blue,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          '${ws.unreadCount}',
                          style: AppFonts.satoshiStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 4),
                    Icon(
                      FluentIcons.chevron_right_24_regular,
                      size: 18,
                      color: c.textTertiary,
                    ),
                  ],
                ),

                // ── Row 2: Activity + Members + Timestamp ──
                if (ws.activityCue != null || ws.lastActivity.isNotEmpty || ws.members.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ws.activityCue ?? ws.lastActivity,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.satoshiStyle(
                            fontSize: 12,
                            color: ws.unreadCount > 0
                                ? c.textPrimary
                                : c.textSecondary,
                            fontWeight: ws.unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (ws.members.isNotEmpty) ...[
                        Text(
                          '${ws.members.length} anggota',
                          style: AppFonts.satoshiStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: c.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        ws.lastActivity,
                        style: AppFonts.satoshiStyle(
                          fontSize: 11,
                          color: c.grey400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}


