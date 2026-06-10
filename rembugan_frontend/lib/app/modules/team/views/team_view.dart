import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_chrome.dart';
import '../controllers/team_controller.dart';
import 'workspace_detail_view.dart';

// ── Semantic palette (desaturated, subtle) ──
const _ink = AppColors.grey900;
const _sub = AppColors.grey500;
const _faint = AppColors.grey400;

const _green = AppColors.success600; // online/success
const _amber = AppColors.warning700; // pending/deadline
const _amberBg = AppColors.warning50;
const _blue = AppColors.info500; // mention/activity
const _blueBg = AppColors.info50;
const _red = AppColors.danger500; // urgent

class TeamView extends GetView<TeamController> {
  const TeamView({super.key});

  @override
  Widget build(BuildContext context) {
    final owned = controller.ownedWorkspaces;
    final joined = controller.joinedWorkspaces;
    final total = controller.workspaces.length;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: AppLayeredBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Proyek Tim',
                            style: AppFonts.headingStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: _green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '$total workspace',
                                style: AppFonts.satoshiStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Search
                    AppIconButton(
                      icon: FluentIcons.search_24_regular,
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Tab Buttons ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.grey200)),
                  ),
                  child: Obx(
                    () => Row(
                      children: [
                        _buildTabButton('Workspace Saya', controller.workspaceTabIndex.value == 0, 0),
                        _buildTabButton('Diikuti', controller.workspaceTabIndex.value == 1, 1),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Content ──
              Expanded(
                child: Obx(() {
                  final list = controller.workspaceTabIndex.value == 0
                      ? owned
                      : joined;

                  if (list.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              controller.workspaceTabIndex.value == 0
                                  ? FluentIcons.briefcase_24_regular
                                  : FluentIcons.people_team_24_regular,
                              size: 36,
                              color: _faint,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              controller.workspaceTabIndex.value == 0
                                  ? 'Belum ada workspace milikmu'
                                  : 'Belum mengikuti workspace',
                              style: AppFonts.satoshiStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _sub,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.workspaceTabIndex.value == 0
                                  ? 'Buat workspace baru untuk memulai kolaborasi.'
                                  : 'Gabung ke workspace tim untuk berkolaborasi.',
                              textAlign: TextAlign.center,
                              style: AppFonts.satoshiStyle(
                                fontSize: 12,
                                color: _faint,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
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
      bottomNavigationBar: const AppBottomNav(current: AppNavDestination.team),
    );
  }

  void _open(WorkspaceModel ws) {
    controller.openWorkspace(ws);
    Get.to<void>(() => const WorkspaceDetailView());
  }

  Widget _buildTabButton(String label, bool active, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.workspaceTabIndex.value = index,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 40,
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? AppColors.primary500 : AppColors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppFonts.satoshiStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: active ? AppColors.grey900 : AppColors.grey400,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.primary50
                      : AppColors.grey100,
                  borderRadius: BorderRadius.circular(AppRadius.xxs),
                ),
                child: Text(
                  index == 0
                      ? '${controller.ownedWorkspaces.length}'
                      : '${controller.joinedWorkspaces.length}',
                  style: AppFonts.satoshiStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: active ? AppColors.primary500 : AppColors.grey500,
                  ),
                ),
              ),
            ],
          ),
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
  bool _pressed = false;
  bool _hovered = false;

  Color get _accentDot {
    if (widget.ws.urgency == 'overdue') return _red;
    if (widget.ws.urgency == 'deadline') return _amber;
    return _green;
  }

  // Generates a beautiful gradient based on workspace name
  LinearGradient _generateWorkspaceGradient(String name) {
    final hash = name.hashCode;

    // Premium desaturated slate, navy, teal, violet gradient pairings
    final List<List<Color>> palettes = [
      [AppColors.grey800, AppColors.grey600], // Slate Charcoal
      [AppColors.grey900, AppColors.grey700], // Dark Indigo Slate
      [AppColors.primary900, AppColors.primary700], // Deep Royal Violet
      [AppColors.success900, AppColors.success700], // Rich Emerald Teal
      [AppColors.grey900, AppColors.grey700], // Warm Stone
      [AppColors.primary900, AppColors.primary700], // Deep Navy
    ];

    final palette = palettes[hash.abs() % palettes.length];
    return LinearGradient(
      colors: palette,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Overlapping circular member avatar stack
  Widget _buildMemberPresenceStack(List<WorkspaceMember> members) {
    if (members.isEmpty) return const SizedBox.shrink();

    final limit = members.take(3).toList();
    final double stackWidth = (14.0 * (limit.length - 1)) + 20.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 20,
          width: stackWidth,
          child: Stack(
            children: limit.asMap().entries.map((entry) {
              final index = entry.key;
              final member = entry.value;
              final initials = member.initials.isNotEmpty
                  ? member.initials
                  : (member.name.isNotEmpty
                        ? member.name.substring(0, 1).toUpperCase()
                        : '?');

              final hash = member.name.hashCode;
              final List<Color> colors = [
                AppColors.grey600, // Slate
                AppColors.grey500, // Light Slate
                AppColors.info500, // Blue
                AppColors.success500, // Emerald
                AppColors.primary400, // Violet
                AppColors.primary400, // Pink
                AppColors.warning500, // Amber
              ];
              final circleColor = colors[hash.abs() % colors.length];

              return Positioned(
                left: index * 14.0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.05),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (members.length > 3) ...[
          const SizedBox(width: 4),
          Text(
            '+${members.length - 3}',
            style: AppFonts.satoshiStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _faint,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ws = widget.ws;
    final pending = ws.totalTasks - ws.doneTasks;
    final hasUnread = ws.unreadCount > 0;
    final double progress = ws.totalTasks > 0
        ? ws.doneTasks / ws.totalTasks
        : 0.0;

    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      scale: _pressed ? 0.985 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: _pressed
              ? const []
              : (_hovered
                    ? [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : AppShadows.soft),
        ),
        child: Material(
          color: AppColors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: InkWell(
            onHighlightChanged: (value) => setState(() => _pressed = value),
            onHover: (value) => setState(() => _hovered = value),
            splashColor: AppColors.primary.withValues(alpha: 0.06),
            highlightColor: AppColors.primary.withValues(alpha: 0.035),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Row 1: Workspace Icon + Name/Category + Chevron ──
                  Row(
                    children: [
                      // Avatar/Icon
                      Stack(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: _generateWorkspaceGradient(ws.name),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withValues(
                                    alpha: 0.08,
                                  ),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              ws.name.substring(0, 1).toUpperCase(),
                              style: AppFonts.headingStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 11,
                              height: 11,
                              decoration: BoxDecoration(
                                color: _accentDot,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.background,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),

                      // Name + Category
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    ws.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppFonts.satoshiStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: _ink,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xxs,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.grey100,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.xxs,
                                    ),
                                  ),
                                  child: Text(
                                    ws.category,
                                    style: AppFonts.satoshiStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: _sub,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  ws.userRole,
                                  style: AppFonts.satoshiStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: _faint,
                                  ),
                                ),
                                _buildMemberPresenceStack(ws.members),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Chevron right
                      const Icon(
                        FluentIcons.chevron_right_24_regular,
                        size: 18,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),

                  // ── Row 1.5: Progress Bar Subtle ──
                  if (ws.totalTasks > 0) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 3.5,
                              backgroundColor: AppColors.grey200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progress < 0.35
                                    ? AppColors
                                          .error500 // Merah
                                    : (progress < 0.75
                                          ? AppColors
                                                .warning500 // Kuning
                                          : AppColors.success500), // Hijau
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: AppFonts.satoshiStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: progress < 0.35
                                ? AppColors.error500
                                : (progress < 0.75
                                      ? AppColors
                                            .warning700 // Darker yellow for text readability
                                      : AppColors.success500),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),

                  // ── Row 2: Last Activity / status singkat ──
                  if (ws.activityCue != null || ws.lastActivity.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Text(
                        ws.activityCue ?? ws.lastActivity,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.satoshiStyle(
                          fontSize: 13,
                          color: hasUnread
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: hasUnread
                              ? FontWeight.w600
                              : FontWeight.w400,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // ── Row 3: Bottom badges: unread message, task count ──
                  Row(
                    children: [
                      // Horizontal items stack
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (ws.unreadCount > 0)
                              _WorkspaceMetaPill(
                                icon: FluentIcons.chat_24_regular,
                                value: '${ws.unreadCount} unread',
                                color: _blue,
                                background: _blueBg,
                              ),
                            if (pending > 0)
                              _WorkspaceMetaPill(
                                icon: FluentIcons.task_list_ltr_24_regular,
                                value: '$pending task',
                                color: _amber,
                                background: _amberBg,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Last updated metadata
                      Text(
                        ws.lastActivity,
                        style: AppFonts.satoshiStyle(
                          fontSize: 11,
                          color: _faint,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkspaceMetaPill extends StatelessWidget {
  const _WorkspaceMetaPill({
    required this.icon,
    required this.value,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String value;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: AppFonts.satoshiStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
