import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../../../routes/app_pages.dart';
import '../../team/controllers/team_controller.dart';
import '../../team/views/workspace_detail_view.dart';
import 'social_components.dart';

enum _NotificationTab { all, activity, collaboration }

enum _NotificationKind { social, collaboration }

class _NotificationItem {
  const _NotificationItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.kind,
    this.actionLabel,
    this.priority = false,
    this.avatarAsset,
  });

  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final _NotificationKind kind;
  final String? actionLabel;
  final bool priority;
  final String? avatarAsset;
}

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  _NotificationTab _tab = _NotificationTab.all;

  static const _items = [
    _NotificationItem(
      title: '2 pelamar baru menunggu persetujuan',
      subtitle: 'Rembugan App - Flutter Dev dan UI Designer',
      time: '5m',
      icon: FluentIcons.person_add_24_regular,
      kind: _NotificationKind.collaboration,
      actionLabel: 'Tinjau',
      priority: true,
    ),
    _NotificationItem(
      title: 'Aisyah mention kamu di Workspace UI Sprint',
      subtitle: '"@Dede cek flow applicant terbaru ya"',
      time: '12m',
      icon: FluentIcons.mention_24_regular,
      kind: _NotificationKind.collaboration,
      actionLabel: 'Buka',
      priority: true,
    ),
    _NotificationItem(
      title: 'Deadline task Integrasi API besok',
      subtitle: 'Workspace Rembugan App - butuh review hari ini',
      time: '35m',
      icon: Icons.calendar_today_outlined,
      kind: _NotificationKind.collaboration,
      actionLabel: 'Buka',
      priority: true,
    ),
    _NotificationItem(
      title: 'Raka menyukai postinganmu',
      subtitle: 'Postingan tentang onboarding AI extraction',
      time: '1j',
      icon: FluentIcons.heart_24_regular,
      kind: _NotificationKind.social,
      avatarAsset: 'lib/assets/img/avatar.png',
    ),
    _NotificationItem(
      title: 'Nadia mulai mengikuti kamu',
      subtitle: 'UI/UX Designer - DKV',
      time: '2j',
      icon: FluentIcons.person_24_regular,
      kind: _NotificationKind.social,
      avatarAsset: 'lib/assets/img/avatar.png',
    ),
    _NotificationItem(
      title: 'File baru diunggah',
      subtitle: 'api_spec_v4.pdf - Workspace Hackathon EduCollab',
      time: '3j',
      icon: FluentIcons.document_24_regular,
      kind: _NotificationKind.collaboration,
      actionLabel: 'Buka',
    ),
  ];

  List<_NotificationItem> get _visibleItems {
    return switch (_tab) {
      _NotificationTab.activity =>
        _items.where((item) => item.kind == _NotificationKind.social).toList(),
      _NotificationTab.collaboration =>
        _items
            .where((item) => item.kind == _NotificationKind.collaboration)
            .toList(),
      _NotificationTab.all => _items,
    };
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
    final collabCount = _items
        .where((item) => item.kind == _NotificationKind.collaboration)
        .length;

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
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          _NotificationTabs(
            active: _tab,
            collabCount: collabCount,
            onChanged: (tab) => setState(() => _tab = tab),
          ),
          const SizedBox(height: 16),
          if (_visibleItems.isNotEmpty && _tab == _NotificationTab.all) ...[
            _PriorityBanner(count: collabCount),
            const SizedBox(height: 14),
          ],
          if (_visibleItems.isEmpty)
            _buildEmptyState(c)
          else
            ...List.generate(_visibleItems.length, (index) {
              final item = _visibleItems[index];
              final isLast = index == _visibleItems.length - 1;
              return Column(
                children: [
                  _NotificationTile(item: item),
                  if (!isLast) Divider(height: 1, color: c.border.withValues(alpha: 0.4)),
                ],
              );
            }),
        ],
      ),
    );
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
                      color: active
                          ? c.textPrimary
                          : AppColors.warning700,
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
  const _NotificationTile({required this.item});

  final _NotificationItem item;

  bool get _isCollab => item.kind == _NotificationKind.collaboration;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!_isCollab)
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: c.primarySoft,
                  backgroundImage: AssetImage(
                    item.avatarAsset ?? 'lib/assets/img/avatar.png',
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: c.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary100,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      item.icon,
                      size: 10,
                      color: item.icon == FluentIcons.heart_24_regular
                          ? AppColors.error500
                          : AppColors.info600,
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.warning50,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(item.icon, size: 18, color: AppColors.warning700),
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
                item.time,
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
            item.subtitle,
            style: AppFonts.satoshiStyle(
              fontSize: 12,
              height: 1.35,
              color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (item.actionLabel != null) ...[
            const SizedBox(width: 12),
            InkWell(
              onTap: () {
                if (item.actionLabel == 'Tinjau') {
                  final teamCtrl = Get.isRegistered<TeamController>()
                      ? Get.find<TeamController>()
                      : Get.put(TeamController());
                  final ws = teamCtrl.workspaces.firstWhere(
                    (w) => w.name == 'Rembugan App',
                    orElse: () => teamCtrl.workspaces.first,
                  );
                  teamCtrl.openWorkspace(ws);
                  Get.to<void>(() => const WorkspaceDetailView());
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final context = Get.context;
                    if (context != null) {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: AppColors.transparent,
                        builder: (_) => ApplicantSheet(ctrl: teamCtrl, ws: ws),
                      );
                    }
                  });
                } else {
                  Get.toNamed(Routes.TEAM);
                }
              },
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
                  item.actionLabel!,
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
