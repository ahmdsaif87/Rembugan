import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../../../routes/app_pages.dart';
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
  });

  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final _NotificationKind kind;
  final String? actionLabel;
  final bool priority;
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
    ),
    _NotificationItem(
      title: 'Nadia mulai mengikuti kamu',
      subtitle: 'UI/UX Designer - DKV',
      time: '2j',
      icon: FluentIcons.person_24_regular,
      kind: _NotificationKind.social,
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

  @override
  Widget build(BuildContext context) {
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
              color: AppColors.textPrimary,
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
          if (_tab == _NotificationTab.all) ...[
            _PriorityBanner(count: collabCount),
            const SizedBox(height: 14),
          ],
          ..._visibleItems.map((item) => _NotificationCard(item: item)),
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
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.textPrimary : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: active ? AppColors.textPrimary : AppColors.border,
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
                    color: active ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: active ? Colors.white : AppColors.warning50,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    '$count',
                    style: AppFonts.satoshiStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: active
                          ? AppColors.textPrimary
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
    return Container(
      padding: const EdgeInsets.all(14),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final _NotificationItem item;

  bool get _isCollab => item.kind == _NotificationKind.collaboration;

  @override
  Widget build(BuildContext context) {
    final foreground = _isCollab ? AppColors.warning700 : AppColors.info600;
    final background = _isCollab ? AppColors.warning50 : AppColors.info50;
    final border = item.priority ? AppColors.warning100 : AppColors.border;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: border),
        boxShadow: item.priority ? AppShadows.soft : const [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, size: 18, color: foreground),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: AppFonts.satoshiStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.time,
                      style: AppFonts.satoshiStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
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
                    color: AppColors.textSecondary,
                  ),
                ),
                if (item.actionLabel != null) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () => Get.toNamed(Routes.TEAM),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          item.actionLabel!,
                          style: AppFonts.satoshiStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
