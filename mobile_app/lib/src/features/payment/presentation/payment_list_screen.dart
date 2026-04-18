import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/payment_service.dart';
import '../domain/payment_model.dart';
import '../../order/data/order_service.dart';
import '../../order/domain/order_model.dart'; // Added missing import

class PaymentListScreen extends ConsumerWidget {
  const PaymentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allPayments = ref.watch(paymentProvider);
    final allOrders = ref.watch(orderListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
      ),
      body: allPayments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(LucideIcons.history, size: 64, color: Colors.grey[300]),
                   const SizedBox(height: 16),
                   Text('No payment transactions found.', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: allPayments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final payment = allPayments[index];
                final order = allOrders.where((o) => o.id == payment.orderId).firstOrNull;
                
                return _buildTransactionCard(context, payment, order);
              },
            ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, Payment payment, Order? order) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), 
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.arrowDownLeft, color: Colors.green, size: 20),
        ),
        title: Text(
          order?.shopName ?? 'Order #...${payment.orderId.substring(payment.orderId.length.clamp(0, 6))}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Via ${payment.paymentMode.name.toUpperCase()}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Text(DateFormat('MMM dd, yyyy • hh:mm a').format(payment.createdAt), style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${payment.amount.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
            ),
            const Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey),
          ],
        ),
        onTap: () => context.push('/payment-details/${payment.id}'),
      ),
    );
  }
}

