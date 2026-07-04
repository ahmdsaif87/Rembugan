import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api_client.dart';

class Comment {
  final int id;
  final String userId;
  final String fullName;
  final String? photoUrl;
  final String content;
  final String createdAt;
  final List<Reply> replies;

  Comment({
    required this.id,
    required this.userId,
    required this.fullName,
    this.photoUrl,
    required this.content,
    required this.createdAt,
    required this.replies,
  });

  String get timeAgo => _timeAgo(createdAt);

  static String _timeAgo(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}j';
      if (diff.inDays < 7) return '${diff.inDays}h';
      return '${(diff.inDays / 7).floor()}mg';
    } catch (_) {
      return '';
    }
  }
}

class Reply {
  final int id;
  final String userId;
  final String fullName;
  final String? photoUrl;
  final String content;
  final String createdAt;

  Reply({
    required this.id,
    required this.userId,
    required this.fullName,
    this.photoUrl,
    required this.content,
    required this.createdAt,
  });

  String get timeAgo => Comment._timeAgo(createdAt);
}

class CommentController extends GetxController {
  final ApiClient _api = Get.find();

  final comments = <Comment>[].obs;
  final isLoading = true.obs;
  final isSubmitting = false.obs;
  final contentCtrl = TextEditingController();
  final focusNode = FocusNode();
  final replyingTo = RxnInt();
  final replyTargetName = ''.obs;

  final String showcaseId;

  CommentController(this.showcaseId);

  @override
  void onInit() {
    super.onInit();
    fetchComments();
  }

  @override
  void onClose() {
    contentCtrl.dispose();
    focusNode.dispose();
    super.onClose();
  }

  void setReplyingTo(int? commentId, {String fullName = ''}) {
    replyingTo.value = commentId;
    replyTargetName.value = fullName;
    focusNode.requestFocus();
  }

  void cancelReply() {
    replyingTo.value = null;
    replyTargetName.value = '';
    contentCtrl.clear();
  }

  Future<void> fetchComments() async {
    isLoading.value = true;
    try {
      final res = await _api.get('/showcase/$showcaseId');
      final body = (res.data as Map<String, dynamic>? ?? {})['data'] as Map<String, dynamic>? ?? {};
      final rawComments = body['comments'] as List<dynamic>? ?? [];
      comments.assignAll(rawComments.map((c) {
        final raw = c as Map<String, dynamic>;
        final rawReplies = raw['replies'] as List<dynamic>? ?? [];
        return Comment(
          id: raw['id'] as int? ?? 0,
          userId: raw['user_id'] as String? ?? '',
          fullName: raw['full_name'] as String? ?? '',
          photoUrl: raw['photo_url'] as String?,
          content: raw['content'] as String? ?? '',
          createdAt: raw['created_at'] as String? ?? '',
          replies: rawReplies.map((r) {
            final rr = r as Map<String, dynamic>;
            return Reply(
              id: rr['id'] as int? ?? 0,
              userId: rr['user_id'] as String? ?? '',
              fullName: rr['full_name'] as String? ?? '',
              photoUrl: rr['photo_url'] as String?,
              content: rr['content'] as String? ?? '',
              createdAt: rr['created_at'] as String? ?? '',
            );
          }).toList(),
        );
      }));
    } catch (e) {
      debugPrint('CommentController.fetchComments error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitComment() async {
    if (isSubmitting.value) return;
    final text = contentCtrl.text.trim();
    if (text.isEmpty) return;
    isSubmitting.value = true;
    final parentId = replyingTo.value;
    try {
      await _api.post('/showcase/$showcaseId/comment', data: {
        'content': text,
        if (parentId != null) 'parent_id': parentId,
      });
      contentCtrl.clear();
      cancelReply();
      await fetchComments();
    } catch (e) {
      debugPrint('CommentController.submitComment error: $e');
    } finally {
      isSubmitting.value = false;
    }
  }
}
