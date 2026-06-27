class NotificationModel {
  final int id;
  final String type;
  final String title;
  final String content;
  final bool isRead;
  final String? link;
  final String createdAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.isRead,
    this.link,
    required this.createdAt,
  });

  int? get connectionId {
    if (link == null || !link!.startsWith('/connection/')) return null;
    final parts = link!.split('/');
    if (parts.length < 3) return null;
    return int.tryParse(parts[2]);
  }

  String? get profileUserId {
    if (link == null || !link!.startsWith('/profile/')) return null;
    final parts = link!.split('/');
    if (parts.length < 3) return null;
    return parts[2];
  }

  int? get workspaceId {
    if (link == null || !link!.startsWith('/workspace/')) return null;
    final parts = link!.split('/');
    if (parts.length < 3) return null;
    return int.tryParse(parts[2]);
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      link: json['link'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}
