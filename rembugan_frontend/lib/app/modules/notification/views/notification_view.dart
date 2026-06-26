import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../../../routes/app_pages.dart';

import '../../social/views/social_components.dart';
import '../../team/controllers/team_controller.dart';
import '../../team/views/workspace_detail_view.dart';
import '../controllers/notification_controller.dart';
import '../data/models/notification_model.dart';

enum _NotificationTab { all, activity, collaboration }

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  _NotificationTab _tab = _NotificationTab.all;
  late final NotificationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<NotificationController>();
  }

  List<NotificationModel> get _visibleItems {
    final all = _ctrl.notifications;
    return switch (_tab) {
      _NotificationTab.activity =>
        all.where((n) => NotificationController.isSocial(n.type)).toList(),
      _NotificationTab.collaboration =>
        all.where((n) => NotificationController.isCollaboration(n.type)).toList(),
      _NotificationTab.all => all,
    };
  }

  IconData _iconForType(String type) {
    return switch (type) {
      'like' => FluentIcons.heart_24_regular,
      'comment' => FluentIcons.comment_24_regular,
      'connection_request' => FluentIcons.person_add_24_regular,
      'connection_accepted' => FluentIcons.person_12_regular,
      'application_received' => FluentIcons.person_add_24_regular,
      'application_accepted' => FluentIcons.checkmark_24_regular,
      'application_rejected' => FluentIcons.dismiss_24_regular,
      'chat' => FluentIcons.chat_24_regular,
      'group_chat_tag' => FluentIcons.mention_24_regular,
      _ => FluentIcons.alert_24_regular,
    };
  }

  bool _isCollab(String type) => NotificationController.isCollaboration(type);

  String _relativeTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'br';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}j';
      if (diff.inDays < 7) return '${diff.inDays}h';
      return '${(diff.inDays / 7).floor()}mg';
    } catch (_) {
      return '';
    }
  }

  String? _actionLabel(String type) {
    return switch (type) {
      'application_received' => 'Tinjau',
      'application_accepted' || 'application_rejected' => 'Buka',
      _ => null,
    };
  }

  void _handleAction(String type, String? link) {
    if (type == 'application_received') {
      final teamCtrl = Get.isRegistered<TeamController>()
          ? Get.find<TeamController>()
          : Get.put(TeamController());

      WorkspaceModel? ws;
      if (link != null) {
        final parts = link.split('/');
        if (parts.length >= 3) {
          final wsId = parts[2];
          ws = teamCtrl.workspaces.firstWhereOrNull((w) => w.id == wsId);
        }
      }
      ws ??= teamCtrl.workspaces.firstOrNull;

      if (ws != null) {
        teamCtrl.openWorkspace(ws);
        Get.to<void>(() => const WorkspaceDetailView());
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final context = Get.context;
          if (context != null) {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: AppColors.transparent,
              builder: (_) => ApplicantSheet(ctrl: teamCtrl, ws: ws!),
            );
          }
        });
      } else {
        Get.toNamed(Routes.TEAM);
      }
    } else {
      Get.toNamed(Routes.TEAM);
    }
  }

  Widget _buildEmptyState(AppC c) {
    final icon = switch (_tab) {
      _NotificationTab.activity => FluentIcons.heart_24_regular,
      _NotificationTab.collaboration => FluentIcons.people_team_24_regular,
      _NotificationTab.all => FluentIcons.alert_24_regular,
    };
    final title = switch (_tab) {
      _NotificationTab.activity => 'Belum ada aktivitas',
      _NotificationTab.collaboration => 'Belum ada kolaborasi',
      _NotificationTab.all => 'Belum ada notifikasi',
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64, horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: c.grey300),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppFonts.satoshiStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Notifikasi akan muncul di sini saat ada yang berinteraksi denganmu.',
              textAlign: TextAlign.center,
              style: AppFonts.satoshiStyle(
                fontSize: 14,
                color: c.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);

    return Obx(() {
      final visible = _visibleItems;
      final collabCount = _ctrl.collabCount;

      return SocialScaffold(
        title: 'Notifikasi',
        subtitle: 'Update sosial dan kolaborasi',
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Tandai dibaca',
              style: AppFonts.interStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
          ),
        ],
        child: _ctrl.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                children: [
                  _NotificationTabs(
                    active: _tab,
                    collabCount: collabCount,
                    onChanged: (tab) => setState(() => _tab = tab),
                  ),
                  const SizedBox(height: 16),
                  if (visible.isNotEmpty && _tab == _NotificationTab.all)
                    _PriorityBanner(count: collabCount),
                  const SizedBox(height: 14),
                  if (visible.isEmpty)
                    _buildEmptyState(c)
                  else
                    ...List.generate(visible.length, (index) {
                      final item = visible[index];
                      final isLast = index == visible.length - 1;
                      return Column(
                        children: [
                          _NotificationTile(
                            item: item,
                            icon: _iconForType(item.type),
                            isCollab: _isCollab(item.type),
                            time: _relativeTime(item.createdAt),
                            actionLabel: _actionLabel(item.type),
                            onAction: _actionLabel(item.type) != null
                                ? () => _handleAction(item.type, item.link)
                                : null,
                          ),
                          if (!isLast) Divider(height: 1, color: c.border.withValues(alpha: 0.4)),
                        ],
                      );
                    }),
                ],
              ),
      );
    });
  }
}

class _NotificationTabs extends StatelessWidget {
  const _NotificationTabs({
    required this.active,
    required this.collabCount,
    required this.onChanged,
  });

  final _NotificationTab active;
  final int collabCount;
  final ValueChanged<_NotificationTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TabPill(
          label: 'Semua',
          active: active == _NotificationTab.all,
          onTap: () => onChanged(_NotificationTab.all),
        ),
        const SizedBox(width: 8),
        _TabPill(
          label: 'Aktivitas',
          active: active == _NotificationTab.activity,
          onTap: () => onChanged(_NotificationTab.activity),
        ),
        const SizedBox(width: 8),
        _TabPill(
          label: 'Kolaborasi',
          count: collabCount,
          active: active == _NotificationTab.collaboration,
          onTap: () => onChanged(_NotificationTab.collaboration),
        ),
      ],
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.active,
    required this.onTap,
    this.count,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.primary500 : c.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: active ? AppColors.primary500 : c.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.satoshiStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active ? c.surface : c.textSecondary,
                  ),
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: active ? c.surface : AppColors.warning50,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    '$count',
                    style: AppFonts.satoshiStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: active ? c.textPrimary : AppColors.warning700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityBanner extends StatelessWidget {
  const _PriorityBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning50,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.warning100),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(
              FluentIcons.alert_24_regular,
              size: 18,
              color: AppColors.warning700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$count update kolaborasi perlu dicek',
              style: AppFonts.satoshiStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.icon,
    required this.isCollab,
    required this.time,
    this.actionLabel,
    this.onAction,
  });

  final NotificationModel item;
  final IconData icon;
  final bool isCollab;
  final String time;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!isCollab)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: c.primarySoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 18, color: AppColors.primary500),
            )
          else
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.warning50,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, size: 18, color: AppColors.warning700),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: AppFonts.satoshiStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: AppFonts.satoshiStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: c.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  item.content,
                  style: AppFonts.satoshiStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(width: 12),
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: c.borderStrong, width: 1),
                ),
                child: Text(
                  actionLabel!,
                  style: AppFonts.satoshiStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
