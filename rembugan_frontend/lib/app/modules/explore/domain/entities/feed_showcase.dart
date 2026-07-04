class FeedShowcase {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhoto;
  final String? authorMajor;
  final String? authorFaculty;
  final String content;
  final List<String> mediaUrls;
  final List<String> tags;
  int likesCount;
  int commentsCount;
  bool likedByMe;
  final int matchScore;
  final String? connectionStatus;
  final String createdAt;

  FeedShowcase({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorPhoto,
    this.authorMajor,
    this.authorFaculty,
    required this.content,
    required this.mediaUrls,
    required this.tags,
    required this.likesCount,
    required this.commentsCount,
    required this.likedByMe,
    required this.matchScore,
    this.connectionStatus,
    required this.createdAt,
  });

  String get subtitle {
    final major = authorMajor ?? authorFaculty ?? '';
    final time = _timeAgo(createdAt);
    if (major.isEmpty) return time;
    return '$major • $time';
  }

  static String _timeAgo(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}j';
      if (diff.inDays < 7) return '${diff.inDays}h';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}mg';
      return '${(diff.inDays / 30).floor()}bln';
    } catch (_) {
      return '';
    }
  }
}
