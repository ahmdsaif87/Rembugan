import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/skeleton.dart';
import '../controllers/comment_controller.dart';

Future<void> showCommentsSheet(BuildContext context, String showcaseId) {
  final controller = Get.put(CommentController(showcaseId), tag: showcaseId);
  return showModalBottomSheet<void>(
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
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
            const SizedBox(height: 12),
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(FluentIcons.dismiss_24_regular, size: 22, color: c.textSecondary),
                    ),
                  ),
                ),
                Text(
                  'Komentar',
                  style: AppFonts.headingStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      Divider(height: 1, color: c.border.withValues(alpha: 0.4)),
      Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    child: SkeletonFeed(),
                  );
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
                  padding: const EdgeInsets.symmetric(vertical: 4),
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
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppAvatar(
            photoUrl: comment.photoUrl,
            radius: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppFonts.satoshiStyle(fontSize: 13, color: c.textPrimary),
                    children: [
                      TextSpan(
                        text: '${comment.fullName}  ',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: comment.content),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      comment.timeAgo,
                      style: AppFonts.satoshiStyle(fontSize: 11, color: c.textTertiary),
                    ),
                    const SizedBox(width: 14),
                    InkWell(
                      onTap: () => controller.setReplyingTo(comment.id, fullName: comment.fullName),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          'Balas',
                          style: AppFonts.satoshiStyle(
                            fontSize: 11, fontWeight: FontWeight.w600, color: c.textTertiary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (comment.replies.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  ...comment.replies.map((reply) => _buildReplyTile(context, reply, comment.id)),
                ],
                const SizedBox(height: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyTile(BuildContext context, Reply reply, int parentCommentId) {
    final c = AppC.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: AppAvatar(photoUrl: reply.photoUrl, radius: 12),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppFonts.satoshiStyle(fontSize: 12, color: c.textPrimary, height: 1.35),
                    children: [
                      TextSpan(
                        text: '${reply.fullName}  ',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (reply.replyToName != null)
                        TextSpan(
                          text: '${reply.replyToName} ',
                          style: TextStyle(color: AppColors.primary500, fontWeight: FontWeight.w500),
                        ),
                      TextSpan(text: reply.content),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      reply.timeAgo,
                      style: AppFonts.satoshiStyle(fontSize: 11, color: c.textTertiary),
                    ),
                    const SizedBox(width: 14),
                    InkWell(
                      onTap: () => controller.setReplyingTo(parentCommentId, fullName: reply.fullName),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          'Balas',
                          style: AppFonts.satoshiStyle(
                            fontSize: 11, fontWeight: FontWeight.w600, color: c.textTertiary,
                          ),
                        ),
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

class _ReplyComposer extends StatelessWidget {
  final CommentController controller;
  const _ReplyComposer({required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.border.withValues(alpha: 0.4))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            if (controller.replyingTo.value == null) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary500.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(FluentIcons.arrow_reply_24_regular, size: 14, color: AppColors.primary500),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Membalas ${controller.replyTargetName.value}',
                      style: AppFonts.satoshiStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: controller.cancelReply,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(FluentIcons.dismiss_24_regular, size: 16, color: AppColors.primary500),
                    ),
                  ),
                ],
              ),
            );
          }),
          Row(
            children: [
              const AppAvatar(radius: 16),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller.contentCtrl,
                  focusNode: controller.focusNode,
                  decoration: InputDecoration(
                    hintText: controller.replyingTo.value != null
                        ? 'Tulis balasan...'
                        : 'Tulis komentar...',
                    hintStyle: AppFonts.satoshiStyle(fontSize: 14, color: c.textTertiary),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    filled: true,
                    fillColor: c.surfaceSecondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: c.primarySoft, width: 1),
                    ),
                  ),
                  style: AppFonts.satoshiStyle(fontSize: 14, color: c.textPrimary),
                  minLines: 1,
                  maxLines: 4,
                ),
              ),
              const SizedBox(width: 8),
              Obx(
                () => GestureDetector(
                  onTap: !controller.canSubmit.value || controller.isSubmitting.value
                      ? null
                      : controller.submitComment,
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: controller.canSubmit.value ? AppColors.primary500 : c.grey200,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: controller.isSubmitting.value
                          ? SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: c.surface),
                            )
                          : Icon(Icons.send_rounded, size: 16, color: c.surface),
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
