import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/app_chrome.dart';
import '../controllers/team_controller.dart';
import 'widgets/qr_code_sheet.dart';

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
              child: Obx(() {
                switch (controller.detailTabIndex.value) {
                  case 1:
                    return _TaskTab(ctrl: controller);
                  default:
                    return _DiscussionTab(ctrl: controller);
                }
              }),
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
        onEndCollaboration: () {
          Navigator.pop(context);
          _showEndCollaborationSheet(context, ws);
        },
      ),
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
        onConfirm: () {
          controller.endCollaboration(ws);
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
    required this.onEndCollaboration,
  });

  final WorkspaceModel ws;
  final List<WorkspaceApplicant> pendingApplicants;
  final VoidCallback onManageApplicants;
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
          ] else
            const _ActionTile(
              icon: FluentIcons.people_team_24_regular,
              title: 'Kolaborasi aktif',
              subtitle: 'Gunakan Group Chat dan Kanban untuk kerja bareng tim.',
            ),
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
                    onAccept: () {
                      ctrl.approveApplicant(applicant);
                      AppToast.success('${applicant.name} masuk ke workspace.', title: 'Pelamar diterima');
                    },
                    onReject: () {
                      ctrl.rejectApplicant(applicant);
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
  const _DiscussionTab({required this.ctrl});
  final TeamController ctrl;

  @override
  State<_DiscussionTab> createState() => _DiscussionTabState();
}

class _DiscussionTabState extends State<_DiscussionTab> {
  late final TextEditingController _msgCtrl;
  late final TeamController _ctrl;

  @override
  void initState() {
    super.initState();
    _msgCtrl = TextEditingController();
    _ctrl = widget.ctrl;
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Column(
      children: [
        // Messages
        Expanded(
          child: Obx(
            () => ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              itemCount: _ctrl.discussions.length,
              itemBuilder: (_, i) => _Bubble(msg: _ctrl.discussions[i]),
            ),
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
                                      _ctrl.attachGroupFile(
                                        'GEMASTIK_PitchDeck.png',
                                        '3.2 MB',
                                      );
                                      Get.back();
                                      AppToast.success('GEMASTIK_PitchDeck.png berhasil dipilih', title: 'File Dilampirkan');
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
                                      _ctrl.attachGroupFile(
                                        'Revisi_Proposal_v3.pdf',
                                        '2.1 MB',
                                      );
                                      Get.back();
                                      AppToast.success('Revisi_Proposal_v3.pdf berhasil dipilih', title: 'File Dilampirkan');
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

                          _ctrl.discussions.add(
                            DiscussionMessage(
                              sender: 'Dede',
                              body: text,
                              time: 'Just now',
                              isMe: true,
                              attachment: _ctrl.attachedGroupFileName.value,
                            ),
                          );

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

class _Bubble extends StatelessWidget {
  const _Bubble({required this.msg});
  final DiscussionMessage msg;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    if (msg.isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Center(
          child: Text(
            msg.body,
            style: AppFonts.satoshiStyle(
              fontSize: 11,
              color: c.textTertiary,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: msg.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!msg.isMe) ...[
            const AppAvatar(radius: 13),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: msg.isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!msg.isMe)
                  Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          msg.sender,
                          style: AppFonts.satoshiStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: c.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          msg.time,
                          style: AppFonts.satoshiStyle(
                            fontSize: 10,
                            color: c.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: msg.isMe
                        ? AppColors.primary500
                        : c.surfaceSecondary,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(AppRadius.md),
                      topRight: const Radius.circular(AppRadius.md),
                      bottomLeft: Radius.circular(msg.isMe ? 14 : 4),
                      bottomRight: Radius.circular(msg.isMe ? 4 : 14),
                    ),
                    border: msg.isMe
                        ? null
                        : Border.all(color: c.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        Container(
                          width: 200,
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: msg.isMe
                                ? AppColors.white.withValues(alpha: 0.12)
                                : c.card,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                            border: Border.all(
                              color: msg.isMe
                                  ? AppColors.white.withValues(alpha: 0.2)
                                  : c.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                msg.attachment!.endsWith('.png') ||
                                        msg.attachment!.endsWith('.jpg')
                                    ? FluentIcons.image_24_regular
                                    : FluentIcons.document_24_regular,
                                color: msg.isMe
                                    ? AppColors.white
                                    : AppColors.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      msg.attachment!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppFonts.satoshiStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: msg.isMe
                                            ? AppColors.white
                                            : c.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '2.4 MB',
                                        style: AppFonts.satoshiStyle(
                                          fontSize: 9,
                                          color: msg.isMe
                                              ? AppColors.white.withValues(
                                                  alpha: 0.7,
                                                )
                                              : c.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                FluentIcons.arrow_download_24_regular,
                                color: msg.isMe
                                    ? AppColors.white70
                                    : c.textSecondary,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (msg.isMe)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      msg.time,
                      style: AppFonts.satoshiStyle(
                        fontSize: 10,
                        color: c.textTertiary,
                      ),
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
  const _TaskTab({required this.ctrl});
  final TeamController ctrl;

  static const _sections = [
    _SectionConfig('To Do', AppColors.info500, 'Todo', 'Belum ada tugas'),
    _SectionConfig('In Progress', AppColors.warning700, 'In Progress', 'Belum ada tugas dikerjakan'),
    _SectionConfig('Done', AppColors.success600, 'Done', 'Belum ada tugas selesai'),
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
                label: const Text('Tambah Tugas'),
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

  static const _allStatuses = ['Todo', 'In Progress', 'Done'];

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
                      onTap: () {
                        ctrl.tasks[taskIndex] = WorkspaceTask(
                          title: task.title,
                          assignee: task.assignee,
                          deadline: task.deadline,
                          status: status,
                          isDone: status == 'Done',
                        );
                        Navigator.pop(context);
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
                  onTap: () {
                    ctrl.tasks.removeAt(taskIndex);
                    Navigator.pop(context);
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
      case 'Todo':
        return AppColors.info500;
      case 'In Progress':
        return AppColors.warning700;
      default:
        return AppColors.success600;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Todo':
        return FluentIcons.document_24_regular;
      case 'In Progress':
        return FluentIcons.clock_24_regular;
      default:
        return FluentIcons.checkmark_24_regular;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'Todo':
        return 'To Do';
      case 'In Progress':
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
  String selectedAssignee = 'Saya';
  String selectedPriority = 'Sedang';

  final List<String> assignees = ['Saya', 'Dede', 'Raka', 'Cameron', 'Aisyah'];
  final List<String> priorities = ['Rendah', 'Sedang', 'Tinggi'];

  final List<String> suggestions = [
    'Setup API Login',
    'Review UI Home',
    'Testing Workspace',
  ];

  @override
  void initState() {
    super.initState();
    final t = widget.existingTask;
    if (t != null) {
      titleCtrl.text = t.title;
      deadlineCtrl.text = t.deadline;
      selectedAssignee = t.assignee;
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: c.grey50,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: c.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedAssignee,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, size: 18),
                            style: AppFonts.satoshiStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: c.textPrimary,
                            ),
                              items: assignees.map((name) {
                                return DropdownMenuItem(
                                  value: name,
                                  child: Text(name),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    selectedAssignee = val;
                                  });
                                }
                              },
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
                              final months = [
                                'Jan',
                                'Feb',
                                'Mar',
                                'Apr',
                                'Mei',
                                'Jun',
                                'Jul',
                                'Agu',
                                'Sep',
                                'Okt',
                                'Nov',
                                'Des',
                              ];
                              final formattedDate =
                                  "${picked.day} ${months[picked.month - 1]} ${picked.year}";
                              deadlineCtrl.text = formattedDate;
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
                onTap: () {
                  if (titleCtrl.text.trim().isEmpty) return;
                  final t = WorkspaceTask(
                    title: titleCtrl.text.trim(),
                    assignee: selectedAssignee,
                    deadline: deadlineCtrl.text.trim().isNotEmpty
                        ? deadlineCtrl.text.trim()
                        : '-',
                    status: _isEditing ? widget.existingTask!.status : 'Todo',
                  );
                  if (_isEditing) {
                    widget.ctrl.tasks[widget.taskIndex!] = t;
                  } else {
                    widget.ctrl.tasks.add(t);
                  }
                  Navigator.pop(context);
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
                          Row(
                            children: [
                              Icon(
                                FluentIcons.person_24_regular,
                                size: 12,
                                color: c.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                task.assignee,
                                style: AppFonts.satoshiStyle(
                                  fontSize: 11,
                                  color: c.textTertiary,
                                ),
                              ),
                              if (task.deadline != '-') ...[
                                const SizedBox(width: 12),
                                Icon(
                                  FluentIcons.calendar_24_regular,
                                  size: 12,
                                  color: task.deadline == 'Hari ini'
                                      ? AppColors.danger500
                                      : c.textTertiary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  task.deadline,
                                  style: AppFonts.satoshiStyle(
                                    fontSize: 11,
                                    fontWeight: task.deadline == 'Hari ini'
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: task.deadline == 'Hari ini'
                                        ? AppColors.danger500
                                        : c.textTertiary,
                                  ),
                                ),
                              ],
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


