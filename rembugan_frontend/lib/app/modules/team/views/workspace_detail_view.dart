import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
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
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
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
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${ws.memberCount} anggota - $online online - Chat & Kanban',
            style: AppFonts.satoshiStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(FluentIcons.more_horizontal_24_regular, size: 20),
          onPressed: () => _showWorkspaceActions(controller, Get.context!, ws),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(color: AppColors.border, height: 0.5),
      ),
    );
  }

  Widget _tabs() {
    const labels = ['Group Chat', 'Kanban'];

    return Container(
      color: Colors.white,
      child: Obx(
        () => Row(
          children: List.generate(labels.length, (i) {
            final active = controller.detailTabIndex.value == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.changeDetailTab(i),
                child: Container(
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: active
                            ? AppColors.textPrimary
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Text(
                    labels[i],
                    style: AppFonts.satoshiStyle(
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      color: active
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
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

class _ApplicantSheet extends StatelessWidget {
  const _ApplicantSheet({required this.ctrl, required this.ws});

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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(16),
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
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ApplicantCard(
                    applicant: applicant,
                    onAccept: () {
                      ctrl.approveApplicant(applicant);
                      Get.snackbar(
                        'Pelamar diterima',
                        '${applicant.name} masuk ke workspace.',
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(16),
                      );
                    },
                    onReject: () {
                      ctrl.rejectApplicant(applicant);
                      Get.snackbar(
                        'Lamaran ditolak',
                        '${applicant.name} tidak masuk ke workspace.',
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(16),
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

  void _showWorkspaceActions(BuildContext context, WorkspaceModel ws) {
    final pendingApplicants = controller.applicantsFor(ws.id);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
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
      backgroundColor: Colors.transparent,
      builder: (_) => _ApplicantSheet(ctrl: controller, ws: ws),
    );
  }

  void _showEndCollaborationSheet(BuildContext context, WorkspaceModel ws) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
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
            margin: const EdgeInsets.all(16),
          );
        },
      ),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(999),
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
              Expanded(child: _SheetButton(label: 'Terima', onTap: onAccept)),
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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warning50,
              borderRadius: BorderRadius.circular(16),
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
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
          color: const Color(0xFFD4D9E2),
          borderRadius: BorderRadius.circular(999),
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
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
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
          color: outlined ? Colors.white : color,
          borderRadius: BorderRadius.circular(13),
          border: outlined ? Border.all(color: AppColors.border) : null,
        ),
        child: Text(
          label,
          style: AppFonts.satoshiStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: outlined ? color : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _DiscussionTab extends StatelessWidget {
  const _DiscussionTab({required this.ctrl});
  final TeamController ctrl;

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
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tulis pesan...',
                        hintStyle: AppFonts.satoshiStyle(
                          fontSize: 13,
                          color: AppColors.textTertiary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 9),
                        isDense: true,
                      ),
                      style: AppFonts.satoshiStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    FluentIcons.send_24_filled,
                    size: 15,
                    color: Colors.white,
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
        padding: const EdgeInsets.symmetric(vertical: 8),
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
                      topLeft: const Radius.circular(14),
                      topRight: const Radius.circular(14),
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
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (msg.attachment != null) ...[
                        const SizedBox(height: 5),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FluentIcons.attach_24_regular,
                              size: 11,
                              color: msg.isMe
                                  ? Colors.white54
                                  : AppColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              msg.attachment!,
                              style: AppFonts.satoshiStyle(
                                fontSize: 11,
                                color: msg.isMe
                                    ? Colors.white54
                                    : AppColors.textTertiary,
                              ),
                            ),
                          ],
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
          () => ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 88),
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
        Positioned(
          right: 20,
          bottom: 20,
          child: GestureDetector(
            onTap: () => _showAddTaskSheet(context),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    FluentIcons.add_24_regular,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tambah Tugas',
                    style: AppFonts.satoshiStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
    final titleCtrl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                    color: const Color(0xFFD4D9E2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Tambah Tugas',
                style: AppFonts.headingStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: titleCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Nama tugas...',
                    hintStyle: AppFonts.satoshiStyle(
                      fontSize: 14,
                      color: AppColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: AppFonts.satoshiStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: GestureDetector(
                  onTap: () {
                    if (titleCtrl.text.trim().isNotEmpty) {
                      ctrl.tasks.add(
                        WorkspaceTask(
                          title: titleCtrl.text.trim(),
                          assignee: 'Saya',
                          deadline: '-',
                          status: 'Todo',
                        ),
                      );
                    }
                    Navigator.pop(context);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Simpan',
                      style: AppFonts.satoshiStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
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
      width: 250,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 7),
              Text(
                title,
                style: AppFonts.satoshiStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${tasks.length}',
                style: AppFonts.satoshiStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (tasks.isEmpty)
            Text(
              'Belum ada tugas.',
              style: AppFonts.satoshiStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            )
          else
            ...tasks.map(
              (task) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _KanbanTaskCard(task: task),
              ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title,
            style: AppFonts.satoshiStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                FluentIcons.person_24_regular,
                size: 12,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  task.assignee,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.satoshiStyle(
                    fontSize: 10.5,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                task.deadline,
                style: AppFonts.satoshiStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
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
      'fig' => const Color(0xFF8B5CF6),
      'png' || 'jpg' => AppColors.info500,
      _ => AppColors.textTertiary,
    };
  }

  Color _fileBg(String type) {
    return switch (type) {
      'pdf' => AppColors.danger50,
      'fig' => const Color(0xFFF5F3FF),
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
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _fileBg(f.type),
                        borderRadius: BorderRadius.circular(10),
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
          right: 20,
          bottom: 20,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
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
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Unggah File',
                    style: AppFonts.satoshiStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

