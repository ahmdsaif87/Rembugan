import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_chrome.dart';
import '../controllers/team_controller.dart';

class WorkspaceDetailView extends GetView<TeamController> {
  const WorkspaceDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ws = controller.selectedWorkspace.value;
      if (ws == null) return const SizedBox.shrink();
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _appBar(ws),
        body: Column(
          children: [
            _tabs(),
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

  PreferredSizeWidget _appBar(WorkspaceModel ws) {
    final online = ws.members.where((m) => m.isOnline).length;

    return AppBar(
      backgroundColor: AppColors.white,
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
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${ws.memberCount} anggota · $online online',
            style: AppFonts.satoshiStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(FluentIcons.more_horizontal_24_regular, size: 20),
          onPressed: () => _showWorkspaceActions(Get.context!, ws),
        ),
      ],
    );
  }

  Widget _tabs() {
    const labels = ['Group Chat', 'Kanban'];

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(AppSpacing.xxs),
        decoration: BoxDecoration(
          color: AppColors.grey100,
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
                      color: active ? AppColors.white : AppColors.transparent,
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
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
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
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
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
          Get.snackbar(
            'Kolaborasi selesai',
            '${ws.name} dipindahkan ke History.',
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(AppSpacing.md),
          );
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
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  'Semua lamaran sudah ditinjau.',
                  style: AppFonts.satoshiStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
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
                      Get.snackbar(
                        'Pelamar diterima',
                        '${applicant.name} masuk ke workspace.',
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(AppSpacing.md),
                      );
                    },
                    onReject: () {
                      ctrl.rejectApplicant(applicant);
                      Get.snackbar(
                        'Lamaran ditolak',
                        '${applicant.name} tidak masuk ke workspace.',
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(AppSpacing.md),
                      );
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.surfaceSecondary,
                child: Text(
                  applicant.name.substring(0, 1),
                  style: AppFonts.satoshiStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applicant.name,
                      style: AppFonts.satoshiStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      applicant.role,
                      style: AppFonts.satoshiStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            applicant.note,
            style: AppFonts.satoshiStyle(
              fontSize: 12,
              height: 1.35,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: applicant.skills
                .map(
                  (skill) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      skill,
                      style: AppFonts.satoshiStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
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
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.only(top: 80),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
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
    return Center(
      child: Container(
        width: 38,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.grey300,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppFonts.headingStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppFonts.satoshiStyle(
            fontSize: 12,
            height: 1.4,
            color: AppColors.textTertiary,
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
    final color = danger ? AppColors.danger600 : AppColors.textPrimary;
    return Material(
      color: AppColors.surfaceSecondary,
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
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppFonts.satoshiStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
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
    final color = danger ? AppColors.danger600 : AppColors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: outlined ? AppColors.white : color,
          borderRadius: BorderRadius.circular(13),
          border: outlined ? Border.all(color: AppColors.border) : null,
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

class _DiscussionTab extends StatelessWidget {
  _DiscussionTab({required this.ctrl});
  final TeamController ctrl;
  final TextEditingController _msgCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Messages
        Expanded(
          child: Obx(
            () => ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              itemCount: ctrl.discussions.length,
              itemBuilder: (_, i) => _Bubble(msg: ctrl.discussions[i]),
            ),
          ),
        ),

        // Input
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border(
              top: BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Attachment Preview Chip Row
                Obx(() {
                  if (ctrl.attachedGroupFileName.value == null) {
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
                      color: AppColors.grey50,
                      border: Border(
                        bottom: BorderSide(color: AppColors.border, width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Icon(
                            ctrl.attachedGroupFileName.value!.endsWith(
                                      '.png',
                                    ) ||
                                    ctrl.attachedGroupFileName.value!.endsWith(
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
                                ctrl.attachedGroupFileName.value!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.satoshiStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                ctrl.attachedGroupFileSize.value ?? '2.4 MB',
                                style: AppFonts.satoshiStyle(
                                  fontSize: 11,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => ctrl.removeGroupAttachment(),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.xxs),
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              FluentIcons.dismiss_12_filled,
                              color: AppColors.textSecondary,
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
                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.only(
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
                                      color: AppColors.border,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Lampirkan File & Dokumen',
                                    style: AppFonts.satoshiStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
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
                                      ctrl.attachGroupFile(
                                        'GEMASTIK_PitchDeck.png',
                                        '3.2 MB',
                                      );
                                      Get.back();
                                      Get.snackbar(
                                        'File Dilampirkan',
                                        'GEMASTIK_PitchDeck.png berhasil dipilih',
                                        snackPosition: SnackPosition.TOP,
                                        backgroundColor: AppColors.primary500,
                                        colorText: AppColors.white,
                                      );
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
                                      ctrl.attachGroupFile(
                                        'Revisi_Proposal_v3.pdf',
                                        '2.1 MB',
                                      );
                                      Get.back();
                                      Get.snackbar(
                                        'File Dilampirkan',
                                        'Revisi_Proposal_v3.pdf berhasil dipilih',
                                        snackPosition: SnackPosition.TOP,
                                        backgroundColor: AppColors.primary500,
                                        colorText: AppColors.white,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(
                            FluentIcons.add_24_regular,
                            color: AppColors.textSecondary,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Text Field
                      Expanded(
                        child: TextField(
                          controller: _msgCtrl,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.surfaceSecondary,
                            hintText: 'Tulis pesan...',
                            hintStyle: AppFonts.satoshiStyle(
                              fontSize: 14,
                              color: AppColors.textTertiary.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: 13.5,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              borderSide: BorderSide(
                                color: AppColors.border.withValues(alpha: 0.8),
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              borderSide: BorderSide(
                                color: AppColors.textPrimary.withValues(
                                  alpha: 0.4,
                                ),
                                width: 1.2,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              borderSide: BorderSide(
                                color: AppColors.border.withValues(alpha: 0.8),
                                width: 1.0,
                              ),
                            ),
                          ),
                          style: AppFonts.satoshiStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Send Button
                      GestureDetector(
                        onTap: () {
                          final text = _msgCtrl.text.trim();
                          if (text.isEmpty &&
                              ctrl.attachedGroupFileName.value == null)
                            return;

                          ctrl.discussions.add(
                            DiscussionMessage(
                              sender: 'Dede',
                              body: text,
                              time: 'Just now',
                              isMe: true,
                              attachment: ctrl.attachedGroupFileName.value,
                            ),
                          );

                          _msgCtrl.clear();
                          ctrl.removeGroupAttachment();
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
    if (msg.isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Center(
          child: Text(
            msg.body,
            style: AppFonts.satoshiStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: msg.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!msg.isMe) ...[
            const CircleAvatar(
              radius: 13,
              backgroundImage: AssetImage('lib/assets/img/avatar.png'),
            ),
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
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          msg.sender,
                          style: AppFonts.satoshiStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          msg.time,
                          style: AppFonts.satoshiStyle(
                            fontSize: 10,
                            color: AppColors.textTertiary,
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
                        ? AppColors.textPrimary.withValues(alpha: 0.88)
                        : AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(AppRadius.md),
                      topRight: const Radius.circular(AppRadius.md),
                      bottomLeft: Radius.circular(msg.isMe ? 14 : 4),
                      bottomRight: Radius.circular(msg.isMe ? 4 : 14),
                    ),
                    border: msg.isMe
                        ? null
                        : Border.all(color: AppColors.border),
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
                              : AppColors.textPrimary,
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
                                : AppColors.surfaceWarm,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                            border: Border.all(
                              color: msg.isMe
                                  ? AppColors.white.withValues(alpha: 0.2)
                                  : AppColors.border,
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
                                            : AppColors.textPrimary,
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
                                            : AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                FluentIcons.arrow_download_24_regular,
                                color: msg.isMe
                                    ? AppColors.white70
                                    : AppColors.textSecondary,
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
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      msg.time,
                      style: AppFonts.satoshiStyle(
                        fontSize: 10,
                        color: AppColors.textTertiary,
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

// â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
//  TASK TAB
// â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”

class _TaskTab extends StatelessWidget {
  const _TaskTab({required this.ctrl});
  final TeamController ctrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(
          () => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 88),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _KanbanColumn(
                  title: 'To Do',
                  color: AppColors.info500,
                  tasks: ctrl.tasks.where((t) => t.status == 'Todo').toList(),
                ),
                _KanbanColumn(
                  title: 'In Progress',
                  color: AppColors.warning700,
                  tasks: ctrl.tasks
                      .where((t) => t.status == 'In Progress')
                      .toList(),
                ),
                _KanbanColumn(
                  title: 'Done',
                  color: AppColors.success600,
                  tasks: ctrl.tasks.where((t) => t.status == 'Done').toList(),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: AppSpacing.md,
          bottom: AppSpacing.md,
          child: GestureDetector(
            onTap: () => _showAddTaskSheet(context),
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary500,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    FluentIcons.add_24_regular,
                    size: 14,
                    color: AppColors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tugas',
                    style: AppFonts.satoshiStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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

class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet({required this.ctrl});
  final TeamController ctrl;

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
  void dispose() {
    titleCtrl.dispose();
    deadlineCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
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
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tambah Tugas Baru',
              style: AppFonts.headingStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
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
                    color: AppColors.textTertiary,
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
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSecondary,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                                border: Border.all(
                                  color: AppColors.border.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                              child: Text(
                                sug,
                                style: AppFonts.satoshiStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
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
                color: AppColors.textTertiary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: titleCtrl,
              autofocus: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.grey50,
                hintText: 'Apa yang perlu dikerjakan?',
                hintStyle: AppFonts.satoshiStyle(
                  fontSize: 13.5,
                  color: AppColors.textTertiary,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: BorderSide(color: AppColors.border, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: BorderSide(
                    color: AppColors.textPrimary.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              style: AppFonts.satoshiStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
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
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tambah detail (Assignee, Prioritas, Deadline)',
                        style: AppFonts.satoshiStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
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
                            color: AppColors.textTertiary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.grey50,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedAssignee,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down, size: 18),
                              style: AppFonts.satoshiStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
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
                            color: AppColors.textTertiary,
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
                                      onSurface: AppColors.textPrimary,
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
                            fillColor: AppColors.grey50,
                            hintText: 'Pilih tanggal...',
                            hintStyle: AppFonts.satoshiStyle(
                              fontSize: 13,
                              color: AppColors.textTertiary,
                            ),
                            suffixIcon: Icon(
                              FluentIcons.calendar_24_regular,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.sm,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              borderSide: BorderSide(
                                color: AppColors.border,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              borderSide: BorderSide(
                                color: AppColors.textPrimary.withValues(
                                  alpha: 0.4,
                                ),
                                width: 1.2,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              borderSide: BorderSide(
                                color: AppColors.border,
                                width: 1,
                              ),
                            ),
                          ),
                          style: AppFonts.satoshiStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
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
                  color: AppColors.textTertiary,
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
                          color: active ? activeBg : AppColors.white,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: active ? activeColor : AppColors.border,
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
                                : AppColors.textSecondary,
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
                  color: AppColors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.grey50,
                  hintText: 'Deskripsi singkat (opsional)...',
                  hintStyle: AppFonts.satoshiStyle(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: BorderSide(color: AppColors.border, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: BorderSide(
                      color: AppColors.textPrimary.withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: BorderSide(color: AppColors.border, width: 1),
                  ),
                ),
                style: AppFonts.satoshiStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 44,
              child: GestureDetector(
                onTap: () {
                  if (titleCtrl.text.trim().isNotEmpty) {
                    widget.ctrl.tasks.add(
                      WorkspaceTask(
                        title: titleCtrl.text.trim(),
                        assignee: selectedAssignee,
                        deadline: deadlineCtrl.text.trim().isNotEmpty
                            ? deadlineCtrl.text.trim()
                            : '-',
                        status: 'Todo',
                      ),
                    );
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
                    'Tambah Tugas',
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

class _KanbanColumn extends StatelessWidget {
  const _KanbanColumn({
    required this.title,
    required this.color,
    required this.tasks,
  });

  final String title;
  final Color color;
  final List<WorkspaceTask> tasks;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: AppFonts.satoshiStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxs,
                  vertical: 1.5,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  '${tasks.length}',
                  style: AppFonts.satoshiStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (tasks.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              alignment: Alignment.center,
              child: Text(
                'Belum ada tugas',
                style: AppFonts.satoshiStyle(
                  fontSize: 10.5,
                  color: AppColors.textTertiary,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                  child: _KanbanTaskCard(task: tasks[index]),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _KanbanTaskCard extends StatelessWidget {
  const _KanbanTaskCard({required this.task});

  final WorkspaceTask task;

  @override
  Widget build(BuildContext context) {
    final String priority = (task.title.length % 3 == 0)
        ? 'Tinggi'
        : (task.title.length % 3 == 1 ? 'Sedang' : 'Rendah');
    final Color priorityColor = priority == 'Tinggi'
        ? AppColors.danger700
        : (priority == 'Sedang' ? AppColors.warning700 : AppColors.success700);

    final String initials = task.assignee.isNotEmpty
        ? task.assignee.split(' ').map((p) => p[0]).take(2).join().toUpperCase()
        : 'Saya';

    final hasComments = task.title.length % 2 == 0;
    final commentsCount = task.title.length % 3 + 1;

    Color deadlineColor;
    if (task.deadline == 'Hari ini') {
      deadlineColor = AppColors.danger500;
    } else if (task.deadline == 'Besok') {
      deadlineColor = AppColors.warning600;
    } else {
      deadlineColor = AppColors.textSecondary;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.soft,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 3.5, color: priorityColor),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(2, 10, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            priority.toUpperCase(),
                            style: AppFonts.satoshiStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: priorityColor,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const Spacer(),
                          if (hasComments) ...[
                            Icon(
                              FluentIcons.chat_24_regular,
                              size: 10,
                              color: AppColors.textTertiary.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            const SizedBox(width: 1.5),
                            Text(
                              '$commentsCount',
                              style: AppFonts.satoshiStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textTertiary,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Icon(
                            Icons.drag_handle,
                            size: 12,
                            color: AppColors.textTertiary.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        task.title,
                        style: AppFonts.satoshiStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 0.5,
                        color: AppColors.border.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: AppColors.grey100,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials,
                              style: AppFonts.satoshiStyle(
                                fontSize: 7.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              task.assignee,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.satoshiStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            FluentIcons.calendar_24_regular,
                            size: 10.5,
                            color: deadlineColor,
                          ),
                          const SizedBox(width: 1.5),
                          Text(
                            task.deadline,
                            style: AppFonts.satoshiStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: deadlineColor,
                            ),
                          ),
                        ],
                      ),
                    ],
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
// â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
//  FILE TAB
// â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”

class _FileTab extends StatelessWidget {
  const _FileTab({required this.ctrl});
  final TeamController ctrl;

  IconData _fileIcon(String type) {
    return switch (type) {
      'pdf' => FluentIcons.document_pdf_24_regular,
      'fig' => FluentIcons.design_ideas_24_regular,
      'png' || 'jpg' => FluentIcons.image_24_regular,
      _ => FluentIcons.document_24_regular,
    };
  }

  Color _fileColor(String type) {
    return switch (type) {
      'pdf' => AppColors.danger500,
      'fig' => AppColors.primary400,
      'png' || 'jpg' => AppColors.info500,
      _ => AppColors.textTertiary,
    };
  }

  Color _fileBg(String type) {
    return switch (type) {
      'pdf' => AppColors.danger50,
      'fig' => AppColors.primary50,
      'png' || 'jpg' => AppColors.info50,
      _ => AppColors.surfaceSecondary,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(
          () => ListView.builder(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
            itemCount: ctrl.files.length,
            itemBuilder: (_, i) {
              final f = ctrl.files[i];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _fileBg(f.type),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        _fileIcon(f.type),
                        size: 16,
                        color: _fileColor(f.type),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f.name,
                            style: AppFonts.satoshiStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${f.uploader} Â· ${f.size} Â· ${f.date}',
                            style: AppFonts.satoshiStyle(
                              fontSize: 11,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      FluentIcons.more_vertical_24_regular,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Positioned(
          right: AppSpacing.lg,
          bottom: AppSpacing.lg,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primary500,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    FluentIcons.arrow_upload_24_regular,
                    size: 16,
                    color: AppColors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Unggah File',
                    style: AppFonts.satoshiStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
