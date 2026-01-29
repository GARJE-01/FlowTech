
enum NotificationType { order, payment, shop, system }

class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final String? relatedId; // OrderId, PaymentId, ShopId
  final DateTime timestamp;
  final bool isNew;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.relatedId,
    required this.timestamp,
    this.isNew = true,
  });

  NotificationModel copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    String? relatedId,
    DateTime? timestamp,
    bool? isNew,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      relatedId: relatedId ?? this.relatedId,
      timestamp: timestamp ?? this.timestamp,
      isNew: isNew ?? this.isNew,
    );
  }
}
