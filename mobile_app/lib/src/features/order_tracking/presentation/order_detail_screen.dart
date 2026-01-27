import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../order/domain/order_model.dart';
import '../../order/data/order_service.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({required this.orderId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allOrders = ref.watch(orderListProvider);
    
    // Find order
    final Order? order = allOrders.where((o) => o.id == orderId).firstOrNull;

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: const Center(child: Text('Order not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        actions: [
          if (order.status == OrderStatus.pending || order.status == OrderStatus.draft)
            IconButton(
              icon: const Icon(LucideIcons.edit),
              onPressed: () {
                // TODO: Implement Edit Mode (Load into Draft and Navigate to Cart?)
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit functionality coming soon.')));
              },
            ),
             
          // Debug Actions
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'approve') {
                ref.read(orderListProvider.notifier).simulateAdminAction(orderId, true);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order Approved (Simulated)')));
              } else if (value == 'reject') {
                ref.read(orderListProvider.notifier).simulateAdminAction(orderId, false);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order Rejected (Simulated)')));
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(value: 'approve', child: Text('Simulate Approve (Dev)')),
                const PopupMenuItem(value: 'reject', child: Text('Simulate Reject (Dev)')),
              ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             // 1. Header Info
             Container(
               padding: const EdgeInsets.all(20),
               color: Colors.white,
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text('Order #${order.id.substring(order.id.length - 6)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                       _buildStatusBadge(order.status),
                     ],
                   ),
                   const SizedBox(height: 8),
                   Text(order.shopName, style: const TextStyle(fontSize: 16)),
                   const SizedBox(height: 4),
                   Text(DateFormat('MMM dd, yyyy • hh:mm a').format(order.createdAt), style: TextStyle(color: Colors.grey[600])),
                 ],
               ),
             ),
             const SizedBox(height: 12),
             
             // 2. Line Items
             Container(
               color: Colors.white,
               padding: const EdgeInsets.all(20),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const Text('Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                   const SizedBox(height: 16),
                   const Divider(),
                   ...order.items.map((item) => Padding(
                     padding: const EdgeInsets.symmetric(vertical: 12),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w500)),
                               Text('${item.quantity} x ₹${item.pricePerUnit}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                             ],
                           ),
                         ),
                         Text('₹${item.lineTotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                       ],
                     ),
                   )),
                   const Divider(),
                 ],
               ),
             ),
             const SizedBox(height: 12),

             // 3. Summary
             Container(
               color: Colors.white,
               padding: const EdgeInsets.all(20),
               child: Column(
                 children: [
                   _buildSummaryRow('Subtotal', order.subtotalAmount),
                   const SizedBox(height: 8),
                   _buildSummaryRow('GST (18%)', order.gstAmount),
                   const SizedBox(height: 16),
                   const Divider(),
                   const SizedBox(height: 8),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text('Grand Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                       Text('₹${order.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                     ],
                   ),
                 ],
               ),
             ),

             if (order.status == OrderStatus.rejected) ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                   child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Rejection Reason', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Stock limits exceeded for this shop category.', style: TextStyle(color: Colors.black87)),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              // TODO: Implement Duplicate Logic
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Duplicate functionality coming soon.')));
                            },
                            child: const Text('Duplicate & Edit'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
             ],
             const SizedBox(height: 40),
           ],
         ),
      ),
    );
  }
  
  Widget _buildSummaryRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text('₹${value.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    switch (status) {
      case OrderStatus.approved: color = Colors.green; break;
      case OrderStatus.rejected: color = Colors.red; break;
      case OrderStatus.pending: color = Colors.orange; break;
      default: color = Colors.grey; break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status.name.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
