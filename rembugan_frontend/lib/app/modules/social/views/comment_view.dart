import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_avatar.dart';
import '../controllers/comment_controller.dart';

void showCommentsSheet(BuildContext context, String showcaseId) {
  final controller = Get.put(CommentController(showcaseId), tag: showcaseId);
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.75,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        child: _CommentSheet(controller: controller),
      ),
    ),
  ).then((_) {
    Future(() => Get.delete<CommentController>(tag: showcaseId));
  });
}

class _CommentSheet extends StatelessWidget {
  final CommentController controller;
  const _CommentSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: Column(
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: c.borderStrong,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Get.delete<CommentController>(tag: controller.showcaseId);
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(FluentIcons.chevron_down_24_regular),
                      ),
                      Expanded(
                        child: Text(
                          'Komentar',
                          textAlign: TextAlign.center,
                          style: AppFonts.headingStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: c.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: c.border.withValues(alpha: 0.4)),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.comments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(FluentIcons.chat_24_regular, size: 48, color: c.grey300),
                        const SizedBox(height: 12),
                        Text('Belum ada komentar', style: AppFonts.satoshiStyle(
                          fontSize: 14, color: c.textSecondary,
                        )),
                      ],
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.sm),
                  children: controller.comments.map((comment) => _buildCommentTile(context, comment)).toList(),
                );
              }),
            ),
            _ReplyComposer(controller: controller),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentTile(BuildContext context, Comment comment) {
    final c = AppC.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: comment.photoUrl != null ? NetworkImage(comment.photoUrl!) : null,
            child: comment.photoUrl == null ? Text(
              comment.fullName.isNotEmpty ? comment.fullName[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ) : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.fullName,
                      style: AppFonts.satoshiStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      comment.timeAgo,
                      style: AppFonts.satoshiStyle(fontSize: 12, color: c.textTertiary),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  comment.content,
                  style: AppFonts.satoshiStyle(fontSize: 13, height: 1.45, color: c.textPrimary),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _CommentAction(
                      icon: FluentIcons.arrow_reply_24_regular,
                      label: 'Balas',
                      onTap: () {
                        controller.setReplyingTo(comment.id, fullName: comment.fullName);
                      },
                    ),
                  ],
                ),
                if (comment.replies.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...comment.replies.map((reply) => _buildReplyTile(context, reply)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyTile(BuildContext context, Reply reply) {
    final c = AppC.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm, top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 2, height: 44,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(color: c.border, borderRadius: BorderRadius.circular(1)),
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: CircleAvatar(
              radius: 10,
              backgroundImage: reply.photoUrl != null ? NetworkImage(reply.photoUrl!) : null,
              child: reply.photoUrl == null ? Text(
                reply.fullName.isNotEmpty ? reply.fullName[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
              ) : null,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${reply.fullName} ',
                      style: AppFonts.satoshiStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.textPrimary),
                    ),
                    TextSpan(
                      text: reply.content,
                      style: AppFonts.satoshiStyle(fontSize: 12, color: c.textSecondary, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CommentAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: AppSpacing.xxs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: c.textSecondary),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppFonts.satoshiStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReplyComposer extends StatelessWidget {
  final CommentController controller;
  const _ReplyComposer({required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(color: c.surface),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            if (controller.replyingTo.value == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(FluentIcons.arrow_reply_24_regular, size: 14, color: c.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Membalas ${controller.replyTargetName.value}',
                    style: AppFonts.satoshiStyle(fontSize: 12, color: c.textSecondary),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: controller.cancelReply,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(FluentIcons.dismiss_24_regular, size: 16, color: c.textSecondary),
                    ),
                  ),
                ],
              ),
            );
          }),
          Row(
            children: [
              const AppAvatar(radius: 18),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller.contentCtrl,
                  focusNode: controller.focusNode,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: c.surfaceSecondary,
                    hintText: 'Tulis komentar...',
                    hintStyle: AppFonts.satoshiStyle(fontSize: 13.5, color: c.textTertiary),
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 13.5),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: BorderSide(color: c.border.withValues(alpha: 0.8), width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: BorderSide(color: c.textPrimary.withValues(alpha: 0.4), width: 1.2),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: BorderSide(color: c.border.withValues(alpha: 0.8), width: 1.0),
                    ),
                  ),
                  style: AppFonts.satoshiStyle(fontSize: 13.5, color: c.textPrimary),
                ),
              ),
              const SizedBox(width: 10),
              Obx(
                () => Material(
                  color: AppColors.transparent,
                  child: InkWell(
                    onTap: controller.isSubmitting.value ? null : controller.submitComment,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: controller.isSubmitting.value
                            ? c.grey300
                            : AppColors.primary500,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Center(
                        child: controller.isSubmitting.value
                            ? SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: c.textSecondary),
                              )
                            : Icon(FluentIcons.send_24_filled, size: 16, color: c.surface),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
