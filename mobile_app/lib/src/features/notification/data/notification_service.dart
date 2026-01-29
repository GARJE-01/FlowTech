import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../domain/notification_model.dart';

class NotificationNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationNotifier() : super([]) {
    _loadMockNotifications();
  }

  void _loadMockNotifications() {
    state = [
      NotificationModel(
        id: 'NOTIF-001',
        type: NotificationType.system,
        title: 'Welcome to FlowTech',
        message: 'Your account has been set up successfully.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isNew: false,
      ),
      NotificationModel(
        id: 'NOTIF-002',
        type: NotificationType.order,
        title: 'Order Approved',
        message: 'Order #ORD-2024-001 for Gupta Store has been approved.',
        relatedId: 'ORD-2024-001',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        isNew: true,
      ),
      NotificationModel(
        id: 'NOTIF-003',
        type: NotificationType.payment,
        title: 'Payment Received',
        message: 'Received ₹5000 from Priya Supermarket.',
        relatedId: 'PAY-102',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isNew: true,
      ),
    ];
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
