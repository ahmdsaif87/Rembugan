import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_chrome.dart';
import '../controllers/team_controller.dart';
import 'workspace_detail_view.dart';

// ── Semantic palette (desaturated, subtle) ──
const _ink = Color(0xFF111827);
const _sub = Color(0xFF6B7280);
const _faint = Color(0xFF9CA3AF);
const _divider = Color(0xFFE7EAF0);

const _green = AppColors.success600; // online/success
const _greenBg = AppColors.success50;
const _amber = AppColors.warning700; // pending/deadline
const _amberBg = AppColors.warning50;
const _blue = AppColors.info500; // mention/activity
const _blueBg = AppColors.info50;
const _red = AppColors.danger500; // urgent
const _redBg = AppColors.danger50;

class TeamView extends GetView<TeamController> {
  const TeamView({super.key});

  @override
  Widget build(BuildContext context) {
    final owned = controller.ownedWorkspaces;
    final joined = controller.joinedWorkspaces;
    final total = controller.workspaces.length;
    final onlineAll = controller.workspaces
        .expand((w) => w.members)
        .where((m) => m.isOnline)
        .toSet()
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
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
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE7EAF0)),
                        ),
                        child: const Icon(
                          FluentIcons.search_24_regular,
                          size: 18,
                          color: _sub,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Tab Buttons ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Obx(() => Row(
                  children: [
                    _TabButton(
                      label: 'Workspace Saya',
                      count: owned.length,
                      active: controller.workspaceTabIndex.value == 0,
                      onTap: () => controller.workspaceTabIndex.value = 0,
                    ),
                    const SizedBox(width: 8),
                    _TabButton(
                      label: 'Diikuti',
                      count: joined.length,
                      active: controller.workspaceTabIndex.value == 1,
                      onTap: () => controller.workspaceTabIndex.value = 1,
                    ),
                  ],
                )),
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
                    padding: const EdgeInsets.only(bottom: 24),
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

  static Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Text(
        text,
        style: AppFonts.satoshiStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: _faint,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  static Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        text,
        style: AppFonts.headingStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _ink,
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  TAB BUTTON
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 40,
          decoration: BoxDecoration(
            color: active ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? Colors.black : _divider,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppFonts.satoshiStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: active
                      ? Colors.white.withValues(alpha: 0.2)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$count',
                  style: AppFonts.satoshiStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : _faint,
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
      [const Color(0xFF1E293B), const Color(0xFF475569)], // Slate Charcoal
      [const Color(0xFF0F172A), const Color(0xFF334155)], // Dark Indigo Slate
      [const Color(0xFF2E1065), const Color(0xFF5B21B6)], // Deep Royal Violet
      [const Color(0xFF064E3B), const Color(0xFF0F766E)], // Rich Emerald Teal
      [const Color(0xFF1C1917), const Color(0xFF44403C)], // Warm Stone
      [const Color(0xFF172554), const Color(0xFF1E3A8A)], // Deep Navy
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
                  : (member.name.isNotEmpty ? member.name.substring(0, 1).toUpperCase() : '?');
              
              final hash = member.name.hashCode;
              final List<Color> colors = [
                const Color(0xFF475569), // Slate
                const Color(0xFF64748B), // Light Slate
                const Color(0xFF3B82F6), // Blue
                const Color(0xFF10B981), // Emerald
                const Color(0xFF8B5CF6), // Violet
                const Color(0xFFEC4899), // Pink
                const Color(0xFFF59E0B), // Amber
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
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
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
                      color: Colors.white,
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
    final double progress = ws.totalTasks > 0 ? ws.doneTasks / ws.totalTasks : 0.0;

    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      scale: _pressed ? 0.985 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xFFFAFAFA) : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: _pressed
                ? _ink
                : (_hovered ? AppColors.borderStrong : AppColors.border),
            width: _pressed ? 1.5 : 1.0,
          ),
          boxShadow: _pressed
              ? const []
              : (_hovered
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : AppShadows.soft),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            onHighlightChanged: (value) => setState(() => _pressed = value),
            onHover: (value) => setState(() => _hovered = value),
            splashColor: AppColors.primary.withValues(alpha: 0.06),
            highlightColor: AppColors.primary.withValues(alpha: 0.035),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
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
                                color: Colors.white,
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
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(5),
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
                              backgroundColor: const Color(0xFFE5E7EB),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progress < 0.35
                                    ? const Color(0xFFEF4444) // Merah
                                    : (progress < 0.75
                                        ? const Color(0xFFF59E0B) // Kuning
                                        : const Color(0xFF10B981)), // Hijau
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
                                ? const Color(0xFFEF4444)
                                : (progress < 0.75
                                    ? const Color(0xFFD97706) // Darker yellow for text readability
                                    : const Color(0xFF10B981)),
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
                          color: hasUnread ? AppColors.textPrimary : AppColors.textSecondary,
                          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
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


