import 'dart:async';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/app_chrome.dart';
import '../../../core/widgets/preview_page.dart';
import '../controllers/team_controller.dart';
import 'widgets/qr_code_sheet.dart';

String _formatDeadline(String raw) {
  if (raw == '-' || raw.isEmpty) return raw;
  final dt = DateTime.tryParse(raw);
  if (dt == null) return raw;
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  return "${dt.day} ${months[dt.month - 1]} ${dt.year}";
}

class WorkspaceDetailView extends GetView<TeamController> {
  const WorkspaceDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Obx(() {
      final ws = controller.selectedWorkspace.value;
      if (ws == null) {
        return Scaffold(
          backgroundColor: c.background,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FluentIcons.people_team_24_regular,
                  size: 48,
                  color: c.grey300,
                ),
                const SizedBox(height: 12),
                Text(
                  'Workspace tidak ditemukan',
                  style: AppFonts.satoshiStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return Scaffold(
        backgroundColor: c.background,
        appBar: _appBar(c, ws),
        body: Column(
          children: [
            _tabs(c),
            Expanded(
              child: Obx(() => IndexedStack(
                index: controller.detailTabIndex.value,
                children: const [
                  _DiscussionTab(),
                  _TaskTab(),
                ],
              )),
            ),
          ],
        ),
      );
    });
  }

  PreferredSizeWidget _appBar(AppC c, WorkspaceModel ws) {
    final online = ws.members.where((m) => m.isOnline).length;

    return AppBar(
      backgroundColor: c.surface,
      elevation: 0,
      surfaceTintColor: AppColors.transparent,
      leading: IconButton(
        icon: const Icon(FluentIcons.arrow_left_24_regular, size: 20),
        onPressed: Get.back,
      ),
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ws.name,
            style: AppFonts.headingStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${ws.memberCount} anggota · $online online',
            style: AppFonts.satoshiStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: c.textTertiary,
            ),
          ),
        ],
      ),
      actions: [
        Tooltip(
          message: 'Lainnya',
          child: IconButton(
            icon: const Icon(FluentIcons.more_horizontal_24_regular, size: 20),
            onPressed: () => _showWorkspaceActions(Get.context!, ws),
          ),
        ),
      ],
    );
  }

  Widget _tabs(AppC c) {
    const labels = ['Group Chat', 'Kanban'];

    return Container(
      color: c.surface,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(AppSpacing.xxs),
        decoration: BoxDecoration(
          color: c.grey100,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Obx(
          () => Row(
            children: List.generate(labels.length, (i) {
              final active = controller.detailTabIndex.value == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.changeDetailTab(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: active ? c.surface : AppColors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: AppColors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          i == 0
                              ? (active
                                    ? FluentIcons.chat_24_filled
                                    : FluentIcons.chat_24_regular)
                              : (active
                                    ? FluentIcons.board_24_filled
                                    : FluentIcons.board_24_regular),
                          size: 16,
                          color: active
                              ? c.textPrimary
                              : c.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          labels[i],
                          style: AppFonts.satoshiStyle(
                            fontSize: 13,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: active
                                ? c.textPrimary
                                : c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void _showWorkspaceActions(BuildContext context, WorkspaceModel ws) {
    final pendingApplicants = controller.applicantsFor(ws.id);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.transparent,
      builder: (_) => _WorkspaceActionSheet(
        ws: ws,
        pendingApplicants: pendingApplicants,
        onManageApplicants: () {
          Navigator.pop(context);
          _showApplicantSheet(context, ws);
        },
        onMemberList: () {
          Navigator.pop(context);
          _showMemberListSheet(context, ws);
        },
        onEndCollaboration: () {
          Navigator.pop(context);
          _showEndCollaborationSheet(context, ws);
        },
      ),
    );
  }

  void _showMemberListSheet(BuildContext context, WorkspaceModel ws) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => _MemberListSheet(ctrl: controller, ws: ws),
    );
  }

  void _showApplicantSheet(BuildContext context, WorkspaceModel ws) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => ApplicantSheet(ctrl: controller, ws: ws),
    );
  }

  void _showEndCollaborationSheet(BuildContext context, WorkspaceModel ws) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.transparent,
      builder: (_) => _EndCollaborationSheet(
        ws: ws,
        onConfirm: () async {
          await controller.endCollaboration(ws);
          Navigator.pop(context);
          Get.back<void>();
          AppToast.success('${ws.name} dipindahkan ke History.', title: 'Kolaborasi selesai');
        },
      ),
    );
  }
}

// â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
//  DISCUSSION TAB
// â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”

class _WorkspaceActionSheet extends StatelessWidget {
  const _WorkspaceActionSheet({
    required this.ws,
    required this.pendingApplicants,
    required this.onManageApplicants,
    required this.onMemberList,
    required this.onEndCollaboration,
  });

  final WorkspaceModel ws;
  final List<WorkspaceApplicant> pendingApplicants;
  final VoidCallback onManageApplicants;
  final VoidCallback onMemberList;
  final VoidCallback onEndCollaboration;

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SheetHandle(),
          const SizedBox(height: 18),
          _SheetHeader(
            title: 'Kelola workspace',
            subtitle: ws.isOwned
                ? 'Atur lamaran dan status kolaborasi proyek.'
                : 'Workspace ini berisi chat tim dan board tugas.',
          ),
          const SizedBox(height: 14),
          _ActionTile(
            icon: FluentIcons.qr_code_24_regular,
            title: 'Bagikan QR Proyek',
            subtitle: 'Scan untuk bergabung ke workspace ini.',
            onTap: () {
              Navigator.pop(context);
              QrCodeSheet.show(
                workspaceId: ws.id,
                workspaceName: ws.name,
              );
            },
          ),
          const SizedBox(height: 8),
          _ActionTile(
            icon: FluentIcons.people_team_24_regular,
            title: 'Anggota Workspace',
            subtitle: '${ws.memberCount} anggota · ${ws.isOwned ? "Ketua bisa kelola" : "Lihat anggota"}',
            onTap: onMemberList,
          ),
          const SizedBox(height: 8),
          if (ws.isOwned) ...[
            _ActionTile(
              icon: FluentIcons.person_add_24_regular,
              title: 'Lamaran masuk',
              subtitle: '${pendingApplicants.length} pelamar menunggu review',
              trailing: pendingApplicants.isEmpty ? null : 'Tinjau',
              onTap: pendingApplicants.isEmpty ? null : onManageApplicants,
            ),
            const SizedBox(height: 8),
            _ActionTile(
              icon: FluentIcons.archive_24_regular,
              title: 'Akhiri kolaborasi',
              subtitle: 'Bersihkan tugas dan chat, lalu pindahkan ke History.',
              danger: true,
              onTap: onEndCollaboration,
            ),
          ],
        ],
      ),
    );
  }
}

class ApplicantSheet extends StatelessWidget {
  const ApplicantSheet({super.key, required this.ctrl, required this.ws});

  final TeamController ctrl;
  final WorkspaceModel ws;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return _SheetShell(
      child: Obx(() {
        final applicants = ctrl.applicantsFor(ws.id);

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 18),
            const _SheetHeader(
              title: 'Lamaran masuk',
              subtitle: 'Terima anggota yang cocok, atau tolak dengan cepat.',
            ),
            const SizedBox(height: 14),
            if (applicants.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: c.surfaceSecondary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: c.border),
                ),
                child: Text(
                  'Semua lamaran sudah ditinjau.',
                  style: AppFonts.satoshiStyle(
                    fontSize: 13,
                    color: c.textSecondary,
                  ),
                ),
              )
            else
              ...applicants.map(
                (applicant) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _ApplicantCard(
                    applicant: applicant,
                    onAccept: () async {
                      await ctrl.approveApplicant(applicant);
                      AppToast.success('${applicant.name} masuk ke workspace.', title: 'Pelamar diterima');
                    },
                    onReject: () async {
                      await ctrl.rejectApplicant(applicant);
                      AppToast.info('${applicant.name} tidak masuk ke workspace.', title: 'Lamaran ditolak');
                    },
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  const _ApplicantCard({
    required this.applicant,
    required this.onAccept,
    required this.onReject,
  });

  final WorkspaceApplicant applicant;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: c.surfaceSecondary,
                child: Text(
                  applicant.name.substring(0, 1),
                  style: AppFonts.satoshiStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applicant.name,
                      style: AppFonts.satoshiStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      applicant.role,
                      style: AppFonts.satoshiStyle(
                        fontSize: 11,
                        color: c.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            applicant.note,
            style: AppFonts.satoshiStyle(
              fontSize: 12,
              height: 1.35,
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: applicant.skills
                .map(
                  (skill) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: c.surfaceSecondary,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: c.border),
                    ),
                    child: Text(
                      skill,
                      style: AppFonts.satoshiStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SheetButton(
                  label: 'Tolak',
                  onTap: onReject,
                  danger: true,
                  outlined: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SheetButton(label: 'Terima', onTap: onAccept),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EndCollaborationSheet extends StatelessWidget {
  const _EndCollaborationSheet({required this.ws, required this.onConfirm});

  final WorkspaceModel ws;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SheetHandle(),
          const SizedBox(height: 18),
          const _SheetHeader(
            title: 'Akhiri kolaborasi?',
            subtitle:
                'Workspace akan masuk History. Tugas dan obrolan aktif dibersihkan dari sistem.',
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.warning50,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.warning200),
            ),
            child: Text(
              ws.name,
              style: AppFonts.satoshiStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.warning800,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SheetButton(
                  label: 'Batalkan',
                  outlined: true,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SheetButton(
                  label: 'Akhiri',
                  danger: true,
                  onTap: onConfirm,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MemberListSheet extends StatelessWidget {
  const _MemberListSheet({required this.ctrl, required this.ws});

  final TeamController ctrl;
  final WorkspaceModel ws;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final members = ws.members;
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SheetHandle(),
          const SizedBox(height: 18),
          const _SheetHeader(
            title: 'Anggota Workspace',
            subtitle: 'Ketua bisa mengeluarkan anggota dari workspace.',
          ),
          const SizedBox(height: 14),
          if (members.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Tidak ada anggota',
                  style: AppFonts.satoshiStyle(fontSize: 13, color: c.textTertiary),
                ),
              ),
            )
          else
            ...members.map((member) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: c.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: c.surfaceSecondary,
                      backgroundImage: member.photoUrl != null
                          ? NetworkImage(member.photoUrl!) as ImageProvider
                          : null,
                      child: member.photoUrl == null
                          ? Text(
                              member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                              style: AppFonts.satoshiStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: AppFonts.satoshiStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            member.role,
                            style: AppFonts.satoshiStyle(fontSize: 11, color: c.textTertiary),
                          ),
                        ],
                      ),
                    ),
                    if (ws.isOwned && member.role != 'Ketua')
                      GestureDetector(
                        onTap: () async {
                          final pid = int.tryParse(ws.id);
                          if (pid == null) return;
                          final ok = await ctrl.kickMemberLocal(pid, member.id);
                          if (ok && context.mounted) {
                            Navigator.pop(context);
                            AppToast.success('${member.name} dikeluarkan dari workspace.');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.danger50,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            'Kick',
                            style: AppFonts.satoshiStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.danger600),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SheetShell extends StatelessWidget {
  const _SheetShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.only(top: 80),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        child: child,
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Center(
      child: Container(
        width: 38,
        height: 4,
        decoration: BoxDecoration(
          color: c.grey300,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppFonts.headingStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: c.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppFonts.satoshiStyle(
            fontSize: 12,
            height: 1.4,
            color: c.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.danger = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailing;
  final bool danger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final color = danger ? AppColors.danger600 : c.textPrimary;
    return Material(
      color: c.surfaceSecondary,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppFonts.satoshiStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppFonts.satoshiStyle(
                        fontSize: 11,
                        color: c.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                Text(
                  trailing!,
                  style: AppFonts.satoshiStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.info600,
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

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.label,
    required this.onTap,
    this.danger = false,
    this.outlined = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool danger;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final color = danger ? AppColors.danger600 : AppColors.primary500;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: outlined ? c.surface : color,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: outlined ? Border.all(color: c.border) : null,
        ),
        child: Text(
          label,
          style: AppFonts.satoshiStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: outlined ? color : AppColors.white,
          ),
        ),
      ),
    );
  }
}

class _DiscussionTab extends StatefulWidget {
  const _DiscussionTab();

  @override
  State<_DiscussionTab> createState() => _DiscussionTabState();
}

class _DiscussionTabState extends State<_DiscussionTab> {
  late final TextEditingController _msgCtrl;
  late final TeamController _ctrl;
  final _scrollCtrl = ScrollController();
  final _userScrolledUp = false.obs;
  StreamSubscription? _discSub;
  StreamSubscription? _loadingSub;

  @override
  void initState() {
    super.initState();
    _msgCtrl = TextEditingController();
    _ctrl = Get.find<TeamController>();
    _discSub = _ctrl.discussions.listen((_) {
      if (_scrollCtrl.hasClients) {
        final isNearBottom = _scrollCtrl.position.maxScrollExtent - _scrollCtrl.position.pixels < 50;
        if (isNearBottom) _afterFrame(_scrollToBottom);
      }
    });
    _loadingSub = _ctrl.isLoading.listen((loading) {
      if (!loading) _afterFrame(_scrollToBottom);
    });
    _scrollCtrl.addListener(_onScrollChanged);
  }

  double? _lastExtent;
  double? _lastPixels;

  void _onScrollChanged() {
    if (!_scrollCtrl.hasClients) return;
    final pixels = _scrollCtrl.position.pixels;
    final extent = _scrollCtrl.position.maxScrollExtent;

    if (_lastExtent != null && extent > _lastExtent!) {
      final wasNearBottom = (_lastExtent! - _lastPixels!) < 50;
      if (wasNearBottom) _afterFrame(_scrollToBottom);
    }

    _userScrolledUp.value = extent - pixels > 50;
    _lastExtent = extent;
    _lastPixels = pixels;
  }

  @override
  void dispose() {
    _discSub?.cancel();
    _loadingSub?.cancel();
    _scrollCtrl.removeListener(_onScrollChanged);
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void _afterFrame(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) => fn());
  }

  bool _isSameDay(String a, String b) {
    try {
      final da = DateTime.parse(a).toLocal();
      final db = DateTime.parse(b).toLocal();
      return da.year == db.year && da.month == db.month && da.day == db.day;
    } catch (_) {
      return true;
    }
  }

  int _discussionItemCount(List<DiscussionMessage> msgs) {
    if (msgs.isEmpty) return 0;
    int seps = 1;
    for (int i = 1; i < msgs.length; i++) {
      if (!_isSameDay(msgs[i - 1].time, msgs[i].time)) seps++;
    }
    return msgs.length + seps;
  }

  String? _lookupSenderPhoto(String senderName) {
    final ws = _ctrl.selectedWorkspace.value;
    if (ws == null) return null;
    final member = ws.members.cast<WorkspaceMember?>().firstWhere(
      (m) => m!.name == senderName,
      orElse: () => null,
    );
    return member?.photoUrl;
  }

  bool _isConsecutive(DiscussionMessage a, DiscussionMessage b) {
    if (a.sender != b.sender) return false;
    try {
      final ta = DateTime.parse(a.time);
      final tb = DateTime.parse(b.time);
      return tb.difference(ta).inMinutes < 5;
    } catch (_) {
      return false;
    }
  }

  Widget _buildDiscussionItem(AppC c, int target, List<DiscussionMessage> msgs) {
    int current = 0;
    String? prevDate;
    for (int i = 0; i < msgs.length; i++) {
      final msg = msgs[i];
      final msgDate = _dateKey(msg.time);
      final needsSep = msgDate != prevDate;
      if (needsSep) {
        if (current == target) {
          return _DiscussionDateSeparator(c: c, date: msg.time);
        }
        current++;
        prevDate = msgDate;
      }
      if (current == target) {
        final photoUrl = _lookupSenderPhoto(msg.sender) ?? msg.senderPhotoUrl;
        final isFirst = i == 0 || !_isConsecutive(msgs[i - 1], msg);
        final isLast = i == msgs.length - 1 || !_isConsecutive(msg, msgs[i + 1]);
        return _Bubble(
          msg: msg,
          senderPhotoUrl: photoUrl,
          isFirstInGroup: isFirst,
          isLastInGroup: isLast,
        );
      }
      current++;
    }
    return const SizedBox.shrink();
  }

  String? _dateKey(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.year}-${dt.month}-${dt.day}';
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Column(
      children: [
        // Messages
        Expanded(
          child: Stack(
            children: [
              Obx(() {
                final msgs = _ctrl.discussions;
                if (msgs.isEmpty) return const SizedBox.shrink();
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  itemCount: _discussionItemCount(msgs),
                  itemBuilder: (_, i) => _buildDiscussionItem(c, i, msgs),
                );
              }),
              Obx(() {
                if (!_userScrolledUp.value) return const SizedBox.shrink();
                return Positioned(
                  right: 16,
                  bottom: 16,
                  child: Material(
                    color: AppColors.transparent,
                    child: InkWell(
                      onTap: () {
                        _userScrolledUp.value = false;
                        _scrollToBottom();
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: c.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          FluentIcons.chevron_down_24_regular,
                          color: c.textPrimary,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                );
                  }),
            ],
          ),
        ),

        // Input
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: c.surface,
            border: Border(
              top: BorderSide(color: c.border, width: 0.5),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Attachment Preview Chip Row
                Obx(() {
                  if (_ctrl.attachedGroupFileName.value == null) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: c.grey50,
                      border: Border(
                        bottom: BorderSide(color: c.border, width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: c.surface,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                            border: Border.all(color: c.border),
                          ),
                          child: Icon(
                            _ctrl.attachedGroupFileName.value!.endsWith(
                                      '.png',
                                    ) ||
                                    _ctrl.attachedGroupFileName.value!.endsWith(
                                      '.jpg',
                                    )
                                ? FluentIcons.image_24_regular
                                : FluentIcons.document_24_regular,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _ctrl.attachedGroupFileName.value!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.satoshiStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: c.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _ctrl.attachedGroupFileSize.value ?? '2.4 MB',
                                style: AppFonts.satoshiStyle(
                                  fontSize: 11,
                                  color: c.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _ctrl.removeGroupAttachment(),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.xxs),
                            decoration: BoxDecoration(
                              color: c.border,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              FluentIcons.dismiss_12_filled,
                              color: c.textSecondary,
                              size: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Input Row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      // Plus/Attachment Button
                      GestureDetector(
                        onTap: () {
                          Get.bottomSheet(
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: c.surface,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(AppRadius.lg),
                                  topRight: Radius.circular(AppRadius.lg),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: c.border,
                                      borderRadius: BorderRadius.circular(AppRadius.xxs),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Lampirkan File & Dokumen',
                                    style: AppFonts.satoshiStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: c.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  AppListItem(
                                    leading: const Icon(
                                      FluentIcons.image_24_regular,
                                      color: AppColors.primary,
                                    ),
                                    title: 'Foto & Media',
                    onTap: () {
                                        Get.back();
                                        _ctrl.uploadAndSendFile();
                                      },
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    AppListItem(
                                      leading: const Icon(
                                        FluentIcons.document_24_regular,
                                        color: AppColors.primary,
                                      ),
                                      title: 'Dokumen & File PDF',
                                      onTap: () {
                                        Get.back();
                                        _ctrl.uploadAndSendFile();
                                      },
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: c.surface,
                            border: Border.all(color: c.border),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(
                            FluentIcons.add_24_regular,
                            color: c.textSecondary,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Text Field
                      Expanded(
                        child: TextField(
                          controller: _msgCtrl,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: c.surfaceSecondary,
                            hintText: 'Tulis pesan...',
                            hintStyle: AppFonts.satoshiStyle(
                              fontSize: 14,
                              color: c.textTertiary.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              borderSide: BorderSide(
                                color: c.border.withValues(alpha: 0.8),
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              borderSide: BorderSide(
                                color: c.textPrimary.withValues(
                                  alpha: 0.4,
                                ),
                                width: 1.2,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              borderSide: BorderSide(
                                color: c.border.withValues(alpha: 0.8),
                                width: 1.0,
                              ),
                            ),
                          ),
                          style: AppFonts.satoshiStyle(
                            fontSize: 14,
                            color: c.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Send Button
                      GestureDetector(
                        onTap: () {
                          final text = _msgCtrl.text.trim();
                          if (text.isEmpty &&
                              _ctrl.attachedGroupFileName.value == null)
                            return;
                          _ctrl.sendMessage(text);
                          _msgCtrl.clear();
                          _ctrl.removeGroupAttachment();
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary500,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: const Center(
                            child: Icon(
                              FluentIcons.send_24_filled,
                              size: 16,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DiscussionDateSeparator extends StatelessWidget {
  const _DiscussionDateSeparator({required this.c, required this.date});
  final AppC c;
  final String date;

  @override
  Widget build(BuildContext context) {
    final sep = dateSeparator(date);
    if (sep.isEmpty) return const SizedBox.shrink();
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: c.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.border.withValues(alpha: 0.6)),
          ),
          child: Text(
            sep,
            style: AppFonts.satoshiStyle(
              fontSize: 12, color: c.textSecondary, fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.msg,
    this.senderPhotoUrl,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
  });
  final DiscussionMessage msg;
  final String? senderPhotoUrl;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  bool _isPdfUrl(DiscussionMessage m) {
    final name = m.attachment?.name?.toLowerCase() ?? '';
    final url = m.attachment?.url.toLowerCase() ?? '';
    return name.endsWith('.pdf') || url.contains('.pdf');
  }

  BorderRadius _bubbleRadius(bool isMe) {
    if (isMe) {
      if (isFirstInGroup && isLastInGroup) {
        return const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        );
      } else if (isFirstInGroup) {
        return const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(4),
        );
      } else if (isLastInGroup) {
        return const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        );
      } else {
        return const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(4),
        );
      }
    } else {
      if (isFirstInGroup && isLastInGroup) {
        return const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        );
      } else if (isFirstInGroup) {
        return const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(16),
        );
      } else if (isLastInGroup) {
        return const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        );
      } else {
        return const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(16),
        );
      }
    }
  }

  EdgeInsets _bubblePadding() {
    if (msg.attachment != null) {
      return const EdgeInsets.symmetric(horizontal: 10, vertical: 8);
    }
    return const EdgeInsets.symmetric(horizontal: 13, vertical: 9);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    if (msg.isSystem && msg.attachment == null) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
            child: Center(
              child: Text(
                msg.body,
                style: AppFonts.satoshiStyle(
                  fontSize: 11,
                  color: c.textTertiary,
                ),
              ),
            ),
          ),
        ],
      );
    }

    final topPad = isFirstInGroup ? 4.0 : 1.0;
    final bottomPad = isLastInGroup ? 4.0 : 1.0;

    return Padding(
      padding: EdgeInsets.only(top: topPad, bottom: bottomPad),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: msg.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!msg.isMe && isFirstInGroup) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: AppAvatar(radius: 13, photoUrl: senderPhotoUrl),
            ),
            const SizedBox(width: 8),
          ],
          if (!msg.isMe && !isFirstInGroup)
            const SizedBox(width: 34),
          IntrinsicWidth(
            child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: _bubblePadding(),
              decoration: BoxDecoration(
                color: msg.isMe
                    ? AppColors.primary500
                    : c.surfaceSecondary,
                borderRadius: _bubbleRadius(msg.isMe),
                border: msg.isMe
                    ? null
                    : Border.all(color: c.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!msg.isMe && isFirstInGroup)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        msg.sender,
                        style: AppFonts.satoshiStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: msg.isMe
                              ? AppColors.white70
                              : AppColors.primary500,
                        ),
                      ),
                    ),
                  Text(
                    msg.body,
                    style: AppFonts.satoshiStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: msg.isMe
                          ? AppColors.white
                          : c.textPrimary,
                    ),
                  ),
                  if (msg.attachment != null) ...[
                    const SizedBox(height: 8),
                    if (isImageUrl(msg.attachment!.url))
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ImagePreviewPage(url: msg.attachment!.url, filename: msg.attachment!.name),
                        )),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            msg.attachment!.url,
                            width: 200,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                width: 200, height: 140,
                                color: c.surfaceSecondary,
                              );
                            },
                            errorBuilder: (_, __, ___) => _buildFileCard(context, c, msg),
                          ),
                        ),
                      )
                    else if (_isPdfUrl(msg))
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => PdfPreviewPage(url: msg.attachment!.url, filename: msg.attachment!.name),
                        )),
                        child: _buildFileCard(context, c, msg),
                      )
                    else
                      GestureDetector(
                        onTap: () async {
                          try {
                            await openFile(msg.attachment!.url, msg.attachment!.name);
                          } catch (_) {
                            if (context.mounted) Get.snackbar('Gagal', 'Gagal membuka file');
                          }
                        },
                        child: _buildFileCard(context, c, msg),
                      ),
                  ],
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      formatTimeOnly(msg.time),
                      style: AppFonts.satoshiStyle(
                        fontSize: 10,
                        color: msg.isMe
                            ? AppColors.white.withValues(alpha: 0.7)
                            : c.textTertiary,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (msg.isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildFileCard(BuildContext context, AppC c, DiscussionMessage msg) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: msg.isMe ? AppColors.white.withValues(alpha: 0.12) : c.card,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(
          color: msg.isMe ? AppColors.white.withValues(alpha: 0.2) : c.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            msg.attachment!.url.contains('.png') || msg.attachment!.url.contains('.jpg')
                ? FluentIcons.image_24_regular
                : FluentIcons.document_24_regular,
            color: msg.isMe ? AppColors.white : AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.attachment!.name ?? 'File',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.satoshiStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: msg.isMe ? AppColors.white : c.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatBytes(msg.attachment!.size),
                  style: AppFonts.satoshiStyle(
                    fontSize: 9,
                    color: msg.isMe
                        ? AppColors.white.withValues(alpha: 0.7)
                        : c.textTertiary,
                  ),
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
//  TASK TAB
// â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”

class _TaskTab extends StatelessWidget {
  const _TaskTab();

  TeamController get ctrl => Get.find();

  static const _sections = [
    _SectionConfig('To Do', AppColors.info500, 'todo', 'Belum ada tugas'),
    _SectionConfig('In Progress', AppColors.warning700, 'doing', 'Belum ada tugas dikerjakan'),
    _SectionConfig('Done', AppColors.success600, 'done', 'Belum ada tugas selesai'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Obx(
            () => ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              children: [
                for (final section in _sections) ...[
                  _KanbanSection(
                    config: section,
                    tasks: ctrl.tasks.where((t) => t.status == section.status).toList(),
                    onTaskTap: (task) => _showTaskActions(task, context),
                  ),
                  const SizedBox(height: 12),
                  Divider(height: 1, color: AppC.of(context).border.withValues(alpha: 0.3)),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () => _showAddTaskSheet(context),
                icon: const Icon(FluentIcons.add_24_regular, size: 16),
                label: const Text('Tambah Tugas', overflow: TextOverflow.visible),
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
          ),
        ),
      ],
    );
  }

  void _showTaskActions(WorkspaceTask task, BuildContext context) {
    final idx = ctrl.tasks.indexWhere((t) => t == task);
    if (idx == -1) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => _TaskActionSheet(
        task: ctrl.tasks[idx],
        taskIndex: idx,
        ctrl: ctrl,
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => _AddTaskSheet(ctrl: ctrl),
    );
  }
}

class _SectionConfig {
  final String title;
  final Color color;
  final String status;
  final String emptyHint;
  const _SectionConfig(this.title, this.color, this.status, this.emptyHint);
}

class _TaskActionSheet extends StatelessWidget {
  const _TaskActionSheet({
    required this.task,
    required this.taskIndex,
    required this.ctrl,
  });

  final WorkspaceTask task;
  final int taskIndex;
  final TeamController ctrl;

  static const _allStatuses = ['todo', 'doing', 'done'];

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SheetHandle(),
          const SizedBox(height: 18),
          Text(
            task.title,
            style: AppFonts.satoshiStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor(task.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              _statusLabel(task.status),
              style: AppFonts.satoshiStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _statusColor(task.status),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Pindahkan ke',
            style: AppFonts.satoshiStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ...(_allStatuses
              .where((s) => s != task.status)
              .map((status) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ActionTile(
                      icon: _statusIcon(status),
                      title: _statusLabel(status),
                      subtitle: '',
                      onTap: () async {
                        await ctrl.moveTask(task.id, status);
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                  ))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SheetButton(
                  label: 'Edit Tugas',
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: AppColors.transparent,
                      builder: (_) => _AddTaskSheet(
                        ctrl: ctrl,
                        existingTask: task,
                        taskIndex: taskIndex,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SheetButton(
                  label: 'Hapus',
                  danger: true,
                  onTap: () async {
                    await ctrl.deleteTask(task.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'todo':
        return AppColors.info500;
      case 'doing':
        return AppColors.warning700;
      default:
        return AppColors.success600;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'todo':
        return FluentIcons.document_24_regular;
      case 'doing':
        return FluentIcons.clock_24_regular;
      default:
        return FluentIcons.checkmark_24_regular;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'todo':
        return 'To Do';
      case 'doing':
        return 'In Progress';
      default:
        return 'Done';
    }
  }
}

class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet({
    required this.ctrl,
    this.existingTask,
    this.taskIndex,
  });

  final TeamController ctrl;
  final WorkspaceTask? existingTask;
  final int? taskIndex;

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final titleCtrl = TextEditingController();
  final deadlineCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  bool isExpanded = false;
  late List<String> memberNames;
  late Map<String, String> memberIdByName;
  late List<String> memberIds;
  final selectedMemberIds = <String>{};
  String selectedPriority = 'Sedang';
  DateTime? selectedDeadline;

  final List<String> priorities = ['Rendah', 'Sedang', 'Tinggi'];

  final List<String> suggestions = [
    'Setup API Login',
    'Review UI Home',
    'Testing Workspace',
  ];

  @override
  void initState() {
    super.initState();
    final members = widget.ctrl.selectedWorkspace.value?.members ?? [];
    memberNames = members.map((m) => m.name).toList();
    memberIds = members.map((m) => m.id).toList();
    memberIdByName = {for (final m in members) m.name: m.id};
    final t = widget.existingTask;
    if (t != null) {
      titleCtrl.text = t.title;
      deadlineCtrl.text = _formatDeadline(t.deadline);
      selectedDeadline = DateTime.tryParse(t.deadline);
      for (final uid in t.assigneeIds) {
        if (memberIds.contains(uid)) {
          selectedMemberIds.add(uid);
        }
      }
    }
  }

  bool get _isEditing => widget.existingTask != null;

  @override
  void dispose() {
    titleCtrl.dispose();
    deadlineCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  void _showAssigneePicker() {
    final c = AppC.of(context);
    final localSelected = {...selectedMemberIds};
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: c.grey300,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pilih Anggota',
                    style: AppFonts.satoshiStyle(
                      fontSize: 16, fontWeight: FontWeight.w700, color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...memberNames.map((name) {
                    final uid = memberIdByName[name] ?? '';
                    final selected = localSelected.contains(uid);
                    return InkWell(
                      onTap: () {
                        setSheetState(() {
                          if (selected) {
                            localSelected.remove(uid);
                          } else {
                            localSelected.add(uid);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              selected ? Icons.check_box : Icons.check_box_outline_blank,
                              size: 22,
                              color: selected ? AppColors.primary500 : c.textTertiary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.satoshiStyle(
                                  fontSize: 14, color: c.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedMemberIds.clear();
                          selectedMemberIds.addAll(localSelected);
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary500,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: c.grey300,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isEditing ? 'Edit Tugas' : 'Tambah Tugas Baru',
              style: AppFonts.headingStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Text(
                  'Saran:',
                  style: AppFonts.satoshiStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                color: c.textTertiary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: suggestions.map((sug) {
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.xxs),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            titleCtrl.text = sug;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: c.surfaceSecondary,
                            borderRadius: BorderRadius.circular(
                              AppRadius.lg,
                            ),
                            border: Border.all(
                              color: c.border.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                          child: Text(
                            sug,
                            style: AppFonts.satoshiStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: c.textSecondary,
                            ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Text(
              'NAMA TUGAS',
              style: AppFonts.satoshiStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: c.textTertiary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleCtrl,
              autofocus: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: c.grey50,
                hintText: 'Apa yang perlu dikerjakan?',
                hintStyle: AppFonts.satoshiStyle(
                  fontSize: 13.5,
                  color: c.textTertiary,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: BorderSide(color: c.border, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: BorderSide(
                    color: c.textPrimary.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: BorderSide(color: c.border, width: 1),
                ),
              ),
              style: AppFonts.satoshiStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            if (!isExpanded)
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = true;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                  child: Row(
                    children: [
                      Icon(
                        FluentIcons.add_circle_24_regular,
                        size: 16,
                        color: c.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tambah detail (Assignee, Prioritas, Deadline)',
                        style: AppFonts.satoshiStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DITUGASKAN KE',
                          style: AppFonts.satoshiStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          color: c.textTertiary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _showAssigneePicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: c.grey50,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(color: c.border),
                          ),
                          child: selectedMemberIds.isEmpty
                              ? Text(
                                  'Pilih anggota...',
                                  style: AppFonts.satoshiStyle(
                                    fontSize: 13,
                                    color: c.textTertiary,
                                  ),
                                )
                              : SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: selectedMemberIds.map((uid) {
                                      final idx = memberIds.indexOf(uid);
                                      final name = idx >= 0 ? memberNames[idx] : '';
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: Chip(
                                          label: Text(
                                            name,
                                            style: AppFonts.satoshiStyle(
                                              fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary700,
                                            ),
                                          ),
                                          backgroundColor: AppColors.primary50,
                                          deleteIcon: Icon(FluentIcons.dismiss_24_regular, size: 14, color: AppColors.primary500),
                                          onDeleted: () {
                                            setState(() => selectedMemberIds.remove(uid));
                                          },
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                          padding: EdgeInsets.zero,
                                          labelPadding: const EdgeInsets.only(left: 6),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                        ),
                      ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DEADLINE',
                          style: AppFonts.satoshiStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          color: c.textTertiary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                        TextField(
                          controller: deadlineCtrl,
                          readOnly: true,
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2030),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: AppColors.primary500,
                                      onPrimary: AppColors.white,
                                      onSurface: c.textPrimary,
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.primary500,
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              selectedDeadline = picked;
                              final months = [
                                'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
                                'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
                              ];
                              deadlineCtrl.text =
                                  "${picked.day} ${months[picked.month - 1]} ${picked.year}";
                            }
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: c.grey50,
                            hintText: 'Pilih tanggal...',
                            hintStyle: AppFonts.satoshiStyle(
                              fontSize: 13,
                              color: c.textTertiary,
                            ),
                            suffixIcon: Icon(
                              FluentIcons.calendar_24_regular,
                              size: 16,
                              color: c.textSecondary,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.sm,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              borderSide: BorderSide(
                                color: c.border,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              borderSide: BorderSide(
                                color: c.textPrimary.withValues(
                                  alpha: 0.4,
                                ),
                                width: 1.2,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              borderSide: BorderSide(
                                color: c.border,
                                width: 1,
                              ),
                            ),
                          ),
                          style: AppFonts.satoshiStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: c.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Text(
                'PRIORITAS TUGAS',
                style: AppFonts.satoshiStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: c.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: priorities.map((p) {
                  final active = selectedPriority == p;
                  Color activeColor;
                  Color activeBg;
                  if (p == 'Tinggi') {
                    activeColor = AppColors.danger700;
                    activeBg = AppColors.danger50;
                  } else if (p == 'Sedang') {
                    activeColor = AppColors.warning700;
                    activeBg = AppColors.warning50;
                  } else {
                    activeColor = AppColors.success700;
                    activeBg = AppColors.success50;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPriority = p;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: active ? activeBg : c.surface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: active ? activeColor : c.border,
                            width: active ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          p,
                          style: AppFonts.satoshiStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: active
                                ? activeColor
                                : c.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              Text(
                'DESKRIPSI TUGAS',
                style: AppFonts.satoshiStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: c.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: c.grey50,
                  hintText: 'Deskripsi singkat (opsional)...',
                  hintStyle: AppFonts.satoshiStyle(
                    fontSize: 13,
                    color: c.textTertiary,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: BorderSide(color: c.border, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: BorderSide(
                      color: c.textPrimary.withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: BorderSide(color: c.border, width: 1),
                  ),
                ),
                style: AppFonts.satoshiStyle(
                  fontSize: 13,
                  color: c.textPrimary,
                ),
              ),
            ],
            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 44,
              child: GestureDetector(
                onTap: () async {
                  if (titleCtrl.text.trim().isEmpty) return;
                  final title = titleCtrl.text.trim();
                  final deadline = selectedDeadline != null
                      ? '${selectedDeadline!.year.toString().padLeft(4, '0')}-${selectedDeadline!.month.toString().padLeft(2, '0')}-${selectedDeadline!.day.toString().padLeft(2, '0')}'
                      : deadlineCtrl.text.trim().isNotEmpty
                          ? deadlineCtrl.text.trim()
                          : null;
                  if (_isEditing) {
                    await widget.ctrl.updateTask(
                      widget.existingTask!.id,
                      title: title,
                      assigneeIds: selectedMemberIds.toList(),
                      deadline: deadline,
                    );
                  } else {
                    await widget.ctrl.createTask(
                      title,
                      selectedMemberIds.toList(),
                      deadline,
                    );
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary500,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    _isEditing ? 'Simpan' : 'Tambah Tugas',
                    style: AppFonts.satoshiStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KanbanSection extends StatelessWidget {
  const _KanbanSection({
    required this.config,
    required this.tasks,
    required this.onTaskTap,
  });

  final _SectionConfig config;
  final List<WorkspaceTask> tasks;
  final ValueChanged<WorkspaceTask> onTaskTap;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 10),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: config.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                config.title,
                style: AppFonts.satoshiStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 20,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: config.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${tasks.length}',
                  style: AppFonts.satoshiStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: config.color,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Cards or empty state
        if (tasks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: c.grey50,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: c.border.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    config.status == 'Todo'
                        ? FluentIcons.document_24_regular
                        : config.status == 'In Progress'
                            ? FluentIcons.clock_24_regular
                            : FluentIcons.checkmark_circle_24_regular,
                    size: 28,
                    color: c.grey300,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    config.emptyHint,
                    style: AppFonts.satoshiStyle(
                      fontSize: 12,
                      color: c.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: tasks
                .map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _KanbanTaskCard(
                      key: ObjectKey(task),
                      task: task,
                      color: config.color,
                      onTap: () => onTaskTap(task),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _KanbanTaskCard extends StatelessWidget {
  const _KanbanTaskCard({
    super.key,
    required this.task,
    required this.color,
    required this.onTap,
  });

  final WorkspaceTask task;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final isDone = task.status == 'Done';
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: isDone ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: c.border.withValues(alpha: 0.4)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 4,
                    color: isDone ? AppColors.success300 : color,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: AppFonts.satoshiStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDone ? c.textTertiary : c.textPrimary,
                              height: 1.3,
                            ).copyWith(
                              decoration: isDone ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (task.assigneeNames.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: task.assigneeNames.map((name) {
                                  return Container(
                                    constraints: const BoxConstraints(maxWidth: 140),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: c.grey50,
                                      borderRadius: BorderRadius.circular(AppRadius.pill),
                                    ),
                                    child: Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppFonts.satoshiStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: c.textSecondary,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          if (task.deadline != '-' && task.deadline.isNotEmpty)
                            Row(
                              children: [
                                Icon(
                                  FluentIcons.calendar_24_regular,
                                  size: 12,
                                  color: c.textTertiary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDeadline(task.deadline),
                                  style: AppFonts.satoshiStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: c.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (!isDone)
                    Container(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        FluentIcons.chevron_right_24_regular,
                        size: 18,
                        color: c.textTertiary.withValues(alpha: 0.4),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        FluentIcons.checkmark_24_filled,
                        size: 16,
                        color: AppColors.success500,
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
// â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
//  FILE TAB
// â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”


