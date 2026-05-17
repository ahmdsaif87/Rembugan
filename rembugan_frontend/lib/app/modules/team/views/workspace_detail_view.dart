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
                  case 1: return _TaskTab(ctrl: controller);
                  case 2: return _FileTab(ctrl: controller);
                  default: return _DiscussionTab(ctrl: controller);
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
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${ws.memberCount} anggota · $online online',
            style: AppFonts.generalSansStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            FluentIcons.more_horizontal_24_regular,
            size: 20,
          ),
          onPressed: () {},
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(color: AppColors.border, height: 0.5),
      ),
    );
  }

  Widget _tabs() {
    const labels = ['Diskusi', 'Tugas', 'File'];

    return Container(
      color: Colors.white,
      child: Obx(
        () => Row(
          children: List.generate(3, (i) {
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
                    style: AppFonts.generalSansStyle(
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
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

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  DISCUSSION TAB
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

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
              itemBuilder: (_, i) =>
                  _Bubble(msg: ctrl.discussions[i]),
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
                        hintStyle: AppFonts.generalSansStyle(
                          fontSize: 13,
                          color: AppColors.textTertiary,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 9),
                        isDense: true,
                      ),
                      style: AppFonts.generalSansStyle(
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
            style: AppFonts.generalSansStyle(
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
        mainAxisAlignment:
            msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
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
              crossAxisAlignment:
                  msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!msg.isMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          msg.sender,
                          style: AppFonts.generalSansStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          msg.time,
                          style: AppFonts.generalSansStyle(
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
                        style: AppFonts.generalSansStyle(
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
                              style: AppFonts.generalSansStyle(
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
                      style: AppFonts.generalSansStyle(
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

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  TASK TAB
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _TaskTab extends StatelessWidget {
  const _TaskTab({required this.ctrl});
  final TeamController ctrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(
          () => ListView.builder(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
            itemCount: ctrl.tasks.length,
            itemBuilder: (_, i) {
              final t = ctrl.tasks[i];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: t.isDone ? AppColors.success : Colors.white,
                        border: Border.all(
                          color: t.isDone
                              ? AppColors.success
                              : AppColors.borderStrong,
                          width: 1.5,
                        ),
                      ),
                      child: t.isDone
                          ? const Icon(Icons.check,
                              size: 11, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.title,
                            style: AppFonts.generalSansStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: t.isDone
                                  ? AppColors.textTertiary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${t.assignee} · ${t.deadline}',
                            style: AppFonts.generalSansStyle(
                              fontSize: 11,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
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
                  const Icon(FluentIcons.add_24_regular,
                      size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    'Tambah Tugas',
                    style: AppFonts.generalSansStyle(
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
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                  fontWeight: FontWeight.w800,
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
                    hintStyle: AppFonts.generalSansStyle(
                      fontSize: 14,
                      color: AppColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: AppFonts.generalSansStyle(
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
                      ctrl.tasks.add(WorkspaceTask(
                        title: titleCtrl.text.trim(),
                        assignee: 'Saya',
                        deadline: '-',
                        status: 'Todo',
                      ));
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
                      style: AppFonts.generalSansStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
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

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  FILE TAB
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

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
      'pdf' => const Color(0xFFEF4444),
      'fig' => const Color(0xFF8B5CF6),
      'png' || 'jpg' => const Color(0xFF3B82F6),
      _ => AppColors.textTertiary,
    };
  }

  Color _fileBg(String type) {
    return switch (type) {
      'pdf' => const Color(0xFFFEF2F2),
      'fig' => const Color(0xFFF5F3FF),
      'png' || 'jpg' => const Color(0xFFEFF6FF),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                            style: AppFonts.generalSansStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${f.uploader} · ${f.size} · ${f.date}',
                            style: AppFonts.generalSansStyle(
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
                  const Icon(FluentIcons.arrow_upload_24_regular,
                      size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    'Unggah File',
                    style: AppFonts.generalSansStyle(
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
