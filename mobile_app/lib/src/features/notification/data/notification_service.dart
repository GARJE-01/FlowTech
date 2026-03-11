import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../domain/notification_model.dart';

class NotificationNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationNotifier() : super([]);

  void syncNotifications(List<NotificationModel> notifications) {
    state = notifications;
  }

  void addNotification({
    required NotificationType type,
    required String title,
    required String message,
    String? relatedId,
  }) {
    final newNotification = NotificationModel(
      id: const Uuid().v4(),
      type: type,
      title: title,
      message: message,
      relatedId: relatedId,
      timestamp: DateTime.now(),
      isNew: true,
    );
    state = [newNotification, ...state];
  }

  void markAllAsRead() {
    state = [
      for (final n in state) n.copyWith(isNew: false),
    ];
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, List<NotificationModel>>((ref) {
  return NotificationNotifier();
});
