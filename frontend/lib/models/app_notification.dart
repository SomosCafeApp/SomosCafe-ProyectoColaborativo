/// Notificación real del usuario (GET/PATCH/DELETE /api/notifications).
/// Se llama `AppNotification` (no `Notification`) porque Flutter ya
/// usa ese nombre para su propio sistema de notificaciones de widgets.
class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type; // GENERAL | ORDER | PROMOTION | SYSTEM | REWARD
  final bool isRead;
  final DateTime? createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    DateTime? createdAt;
    final rawDate = json['createdAt'];
    if (rawDate is String) {
      createdAt = DateTime.tryParse(rawDate);
    }

    return AppNotification(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'GENERAL',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: createdAt,
    );
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
