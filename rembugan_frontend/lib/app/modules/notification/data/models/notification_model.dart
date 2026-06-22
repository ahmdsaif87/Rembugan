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
