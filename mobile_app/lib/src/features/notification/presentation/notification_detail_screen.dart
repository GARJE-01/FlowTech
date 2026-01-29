import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../notification/data/notification_service.dart';
import '../../notification/domain/notification_model.dart';

class NotificationDetailScreen extends ConsumerWidget {
  final String notificationId;

  const NotificationDetailScreen({required this.notificationId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);
    final notificationMaybe = notifications.where((n) => n.id == notificationId).firstOrNull;

    if (notificationMaybe == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notification')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.orange),
                const SizedBox(height: 16),
                Text('Notification not found', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Looking for ID: "$notificationId"', style: const TextStyle(fontFamily: 'monospace')),
                const SizedBox(height: 8),
                Text('Available IDs (${notifications.length}):', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: ListView(
                     children: notifications.map((n) => Text(n.id, style: const TextStyle(fontSize: 10))).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Go Back'),
                )
              ],
            ),
          ),
        ),
      );
    }

    final notification = notificationMaybe!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
               children: [
                 _buildIcon(notification),
                 const SizedBox(width: 16),
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         _getCategoryLabel(notification.type),
                         style: TextStyle(
                           color: Colors.grey[600],
                           fontSize: 12,
                           fontWeight: FontWeight.bold,
                           letterSpacing: 1,
                         ),
                       ),
                       const SizedBox(height: 4),
                       Text(
                         DateFormat('dd MMM yyyy, hh:mm a').format(notification.timestamp),
                         style: TextStyle(color: Colors.grey[400], fontSize: 12),
                       ),
                     ],
                   ),
                 ),
               ],
             ),
             const SizedBox(height: 24),
             Text(
               notification.title,
               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
             ),
             const SizedBox(height: 16),
             Container(
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: Colors.grey[50],
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: Colors.grey[200]!),
               ),
               child: Text(
                 notification.message,
                 style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
               ),
             ),
             const Spacer(),
             
             if (notification.relatedId != null)
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton.icon(
                   style: ElevatedButton.styleFrom(
                     padding: const EdgeInsets.symmetric(vertical: 16),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                   ),
                   icon: const Icon(LucideIcons.arrowRight),
                   label: Text(_getActionLabel(notification.type)),
                   onPressed: () => _handleAction(context, notification),
                 ),
               ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(NotificationModel notification) {
    IconData icon;
    Color color;

    switch (notification.type) {
      case NotificationType.order:
        icon = LucideIcons.shoppingBag;
        color = Colors.blue;
        break;
      case NotificationType.payment:
        icon = LucideIcons.indianRupee;
        color = Colors.green;
        break;
      case NotificationType.shop:
        icon = LucideIcons.store;
        color = Colors.purple;
        break;
      case NotificationType.system:
      default:
        icon = LucideIcons.bell;
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 32),
    );
  }

  String _getCategoryLabel(NotificationType type) {
    switch (type) {
      case NotificationType.order: return 'ORDER UPDATE';
      case NotificationType.payment: return 'PAYMENT ALERT';
      case NotificationType.shop: return 'SHOP UPDATE';
      case NotificationType.system: return 'SYSTEM MESSAGE';
    }
  }

  String _getActionLabel(NotificationType type) {
    switch (type) {
      case NotificationType.order: return 'View Order Details';
      case NotificationType.payment: return 'View Payment Details';
      case NotificationType.shop: return 'View Shop Profile';
      default: return 'View Details';
    }
  }

  void _handleAction(BuildContext context, NotificationModel notification) {
    switch (notification.type) {
      case NotificationType.order:
         context.push('/orders/${notification.relatedId}');
         break;
      case NotificationType.payment:
         // If relatedId is invoiceId, we might need to find paymentId, 
         // but for now context.push('/payments') or if we have paymentId
         // The simulation sends 'invoiceId' as relatedId.
         // Let's just go to list for safety or assume relatedId IS paymentId if changed.
         // Actually in service: relatedId: invoiceId. 
         // Ideally we should look up the payment.
         // For now, simpler:
         context.push('/payments');
         break;
      case NotificationType.shop:
         // context.push('/shops/${notification.relatedId}'); // If ID supported
         context.push('/shops');
         break;
      default:
         break;
    }
  }
}
