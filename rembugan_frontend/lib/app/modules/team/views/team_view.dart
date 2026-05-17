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

const _green = Color(0xFF22C55E); // online/success
const _greenBg = Color(0xFFECFDF5);
const _amber = Color(0xFFD97706); // pending/deadline
const _amberBg = Color(0xFFFFFBEB);
const _blue = Color(0xFF3B82F6); // mention/activity
const _blueBg = Color(0xFFEFF6FF);
const _red = Color(0xFFEF4444); // urgent
const _redBg = Color(0xFFFEF2F2);

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
                            'Tim Saya',
                            style: AppFonts.headingStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
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
                    const GuestModeBadge(),
                    const SizedBox(width: 6),
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
                    const SizedBox(width: 8),
                    // Collaboration inbox
                    GestureDetector(
                      onTap: () => _showInbox(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE7EAF0)),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              FluentIcons.tray_item_add_24_regular,
                              size: 19,
                              color: _sub,
                            ),
                            if (controller.totalInboxCount > 0)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: const BoxDecoration(
                                    color: _red,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${controller.totalInboxCount}',
                                    style: const TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
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
                        (ws) => _WorkspaceRow(
                          ws: ws,
                          onTap: () => _open(ws),
                        ),
                      ),
                    ],
                    // DIIKUTI
                    if (joined.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _sectionLabel('DIIKUTI'),
                      ...joined.map(
                        (ws) => _WorkspaceRow(
                          ws: ws,
                          onTap: () => _open(ws),
                        ),
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

  void _showInbox(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InboxSheet(items: controller.inboxItems),
    );
  }

  static Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Text(
        text,
        style: AppFonts.generalSansStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
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
          fontWeight: FontWeight.w800,
          color: _ink,
        ),
      ),
    );
  }
}



// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  WORKSPACE ROW (stateful for press depth)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _WorkspaceRow extends StatelessWidget {
  const _WorkspaceRow({required this.ws, required this.onTap});
  final WorkspaceModel ws;
  final VoidCallback onTap;

  Color get _accentDot {
    if (ws.urgency == 'overdue') return _red;
    if (ws.urgency == 'deadline') return _amber;
    return _green;
  }

  @override
  Widget build(BuildContext context) {
    final pending = ws.totalTasks - ws.doneTasks;
    final hasUnread = ws.unreadCount > 0;
    final hasApplicants = ws.applicants > 0;

    final subtitleWidget = Text(
      ws.activityCue ?? ws.lastActivity,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppFonts.generalSansStyle(
        fontSize: 12,
        color: hasUnread
            ? const Color(0xFF6B7280)
            : const Color(0xFFB0B7C2),
        fontWeight:
            hasUnread ? FontWeight.w500 : FontWeight.w400,
      ),
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
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
                      fontWeight: FontWeight.w800,
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
                          style: AppFonts.generalSansStyle(
                            fontSize: 15,
                            fontWeight: hasUnread
                                ? FontWeight.w800
                                : FontWeight.w700,
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
                          style: AppFonts.generalSansStyle(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (hasUnread)
                  _CountBadge(count: ws.unreadCount, color: _ink)
                else if (hasApplicants)
                  _CountBadge(count: ws.applicants, color: _amber)
                else
                  const SizedBox(height: 18),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (pending > 0) ...[
                      Icon(
                        FluentIcons.circle_half_fill_24_regular,
                        size: 10,
                        color: _faint,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '$pending',
                        style: AppFonts.generalSansStyle(
                          fontSize: 10,
                          color: _faint,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            const SizedBox(width: 6),
            const Icon(
              FluentIcons.chevron_right_24_regular,
              size: 16,
              color: Color(0xFFD1D5DB),
            ),
          ],
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

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.color});
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
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
    'member' => (FluentIcons.person_add_24_regular, _ink, const Color(0xFFF3F4F6)),
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
                  style: AppFonts.generalSansStyle(
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
                      style: AppFonts.generalSansStyle(
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
                      style: AppFonts.generalSansStyle(
                        fontSize: 11,
                        color: _faint,
                      ),
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
//  COLLABORATION INBOX (bottom sheet)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _InboxSheet extends StatelessWidget {
  const _InboxSheet({required this.items});
  final List<InboxItem> items;

  (IconData, Color, Color) _visual(String type) => switch (type) {
    'applicant' => (FluentIcons.person_add_24_regular, _amber, _amberBg),
    'mention' => (FluentIcons.mention_24_regular, _blue, _blueBg),
    'task' => (FluentIcons.task_list_ltr_24_regular, _red, _redBg),
    'file' => (FluentIcons.document_24_regular, _green, _greenBg),
    _ => (FluentIcons.tray_item_add_24_regular, _faint, const Color(0xFFF3F4F6)),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 80),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD4D9E2),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  'Inbox',
                  style: AppFonts.headingStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _ink,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${items.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    FluentIcons.dismiss_24_regular,
                    size: 20,
                    color: _sub,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Pelamar, mention, dan update yang perlu tindakan.',
              style: AppFonts.generalSansStyle(
                fontSize: 12,
                color: _faint,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: _divider),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.fromLTRB(
                0, 0, 0,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: _divider),
              itemBuilder: (_, i) {
                final item = items[i];
                final (icon, color, bg) = _visual(item.type);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, size: 16, color: color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: AppFonts.generalSansStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.subtitle,
                              style: AppFonts.generalSansStyle(
                                fontSize: 11,
                                color: _faint,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (item.type == 'applicant') ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _ink,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Review',
                            style: AppFonts.generalSansStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ] else
                        Icon(
                          FluentIcons.chevron_right_24_regular,
                          size: 14,
                          color: const Color(0xFFD1D5DB),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
