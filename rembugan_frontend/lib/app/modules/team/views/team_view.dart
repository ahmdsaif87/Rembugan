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

              // ── Content ──
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    // WORKSPACE SAYA
                    if (owned.isNotEmpty) ...[
                      _sectionLabel('WORKSPACE SAYA'),
                      ...owned.map(
                        (ws) => _WorkspaceRow(ws: ws, onTap: () => _open(ws)),
                      ),
                    ],
                    // DIIKUTI
                    if (joined.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _sectionLabel('DIIKUTI'),
                      ...joined.map(
                        (ws) => _WorkspaceRow(ws: ws, onTap: () => _open(ws)),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // AKTIVITAS
                    _sectionTitle('Aktivitas Terkini'),
                    const SizedBox(height: 12),
                    ...controller.recentActivities.asMap().entries.expand((e) {
                      final item = _ActivityItem(
                        activity: e.value,
                        isLast: e.key == controller.recentActivities.length - 1,
                      );
                      if (e.key == 0) return [item];
                      return [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Divider(height: 1, color: _divider),
                        ),
                        item,
                      ];
                    }),
                  ],
                ),
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

  @override
  Widget build(BuildContext context) {
    final ws = widget.ws;
    final pending = ws.totalTasks - ws.doneTasks;
    final hasUnread = ws.unreadCount > 0;

    final subtitleWidget = Text(
      ws.activityCue ?? ws.lastActivity,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppFonts.satoshiStyle(
        fontSize: 12,
        color: hasUnread ? AppColors.textSecondary : AppColors.textTertiary,
        fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
      ),
    );

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
            color: _hovered ? AppColors.borderStrong : AppColors.border,
          ),
          boxShadow: _pressed ? const [] : AppShadows.soft,
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
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Row(
                children: [
                  // ── Workspace icon + status dot ──
                  Stack(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: ws.isOwned
                              ? _ink.withValues(alpha: 0.05)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          ws.name.substring(0, 1).toUpperCase(),
                          style: AppFonts.headingStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            color: _ink,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _accentDot,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.background,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // ── Name + subtitle ──
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
                                  fontSize: 15,
                                  fontWeight: hasUnread
                                      ? FontWeight.w600
                                      : FontWeight.w600,
                                  color: _ink,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                ws.category,
                                style: AppFonts.satoshiStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: _faint,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        subtitleWidget,
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ── Right: badges + meta ──
                  _WorkspaceMetaStack(
                    unread: ws.unreadCount,
                    pendingTasks: pending,
                    applicants: ws.applicants,
                  ),

                  const SizedBox(width: 8),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      FluentIcons.chevron_right_24_regular,
                      size: 17,
                      color: AppColors.textSecondary,
                    ),
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

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  COUNT BADGE (semantic color)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _WorkspaceMetaStack extends StatelessWidget {
  const _WorkspaceMetaStack({
    required this.unread,
    required this.pendingTasks,
    required this.applicants,
  });

  final int unread;
  final int pendingTasks;
  final int applicants;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      if (unread > 0)
        _WorkspaceMetaPill(
          icon: FluentIcons.chat_24_regular,
          value: unread,
          label: 'unread',
          color: _blue,
          background: _blueBg,
        ),
      if (pendingTasks > 0)
        _WorkspaceMetaPill(
          icon: FluentIcons.task_list_ltr_24_regular,
          value: pendingTasks,
          label: 'task',
          color: _amber,
          background: _amberBg,
        ),
      if (applicants > 0)
        _WorkspaceMetaPill(
          icon: FluentIcons.person_add_24_regular,
          value: applicants,
          label: 'pelamar',
          color: _green,
          background: _greenBg,
        ),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < items.length && i < 2; i++) ...[
          if (i > 0) const SizedBox(height: 5),
          items[i],
        ],
      ],
    );
  }
}

class _WorkspaceMetaPill extends StatelessWidget {
  const _WorkspaceMetaPill({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final int value;
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            '$value',
            style: AppFonts.satoshiStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppFonts.satoshiStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ACTIVITY ITEM (typed)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({required this.activity, this.isLast = false});
  final RecentActivity activity;
  final bool isLast;

  (IconData, Color, Color) get _visual => switch (activity.type) {
    'message' => (FluentIcons.chat_24_regular, _blue, _blueBg),
    'file' => (FluentIcons.document_24_regular, _amber, _amberBg),
    'task' => (FluentIcons.checkmark_circle_24_regular, _green, _greenBg),
    'member' => (
      FluentIcons.person_add_24_regular,
      _ink,
      const Color(0xFFF3F4F6),
    ),
    'mention' => (FluentIcons.mention_24_regular, _blue, _blueBg),
    _ => (FluentIcons.pulse_24_regular, _faint, const Color(0xFFF3F4F6)),
  };

  @override
  Widget build(BuildContext context) {
    final (icon, color, bg) = _visual;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon circle (tinted)
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.text,
                  style: AppFonts.satoshiStyle(
                    fontSize: 13.5,
                    color: _ink,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      activity.workspace,
                      style: AppFonts.satoshiStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _sub,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: _faint,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      activity.time,
                      style: AppFonts.satoshiStyle(fontSize: 11, color: _faint),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
