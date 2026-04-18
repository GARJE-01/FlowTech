import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../order/domain/order_model.dart';
import '../../order/data/order_service.dart';
import '../../city/data/city_service.dart';

class BillsScreen extends ConsumerWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cityState = ref.watch(cityProvider);
    final allOrders = ref.watch(orderListProvider);
    
    // Filter by city and ONLY approved status
    final approvedOrders = allOrders
        .where((o) => o.cityId == cityState.selectedCity?.id && o.status == OrderStatus.approved)
        .toList();

    // Sort by Date Descending
    approvedOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills / Invoices'),
      ),
      body: approvedOrders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(LucideIcons.fileText, size: 64, color: Colors.grey[300]),
                   const SizedBox(height: 16),
                   Text('No generated bills yet.', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                   const SizedBox(height: 8),
                   Text('Only approved orders will appear here.', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: approvedOrders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = approvedOrders[index];
                return _buildBillCard(context, order);
              },
            ),
    );
  }

  Widget _buildBillCard(BuildContext context, Order order) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to Invoice Details
          context.push('/invoices/${order.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.shopName, 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Invoice #...${order.id.substring(order.id.length - 6)}', 
                          style: TextStyle(color: Colors.grey[600], fontSize: 12)
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.receipt, color: Theme.of(context).primaryColor, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text('Balance Due', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      const SizedBox(height: 4),
                       Text(
                        '₹${order.balanceAmount.toStringAsFixed(0)}', 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: order.balanceAmount > 0 ? Colors.red : Colors.green)
                      ),
                    ],
                  ),
                   Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Total Bill: ₹${order.totalAmount.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                      const SizedBox(height: 4),
                      _buildPaymentStatusBadge(order),
                    ],
                  ),
                ],
              ),
              if (order.balanceAmount > 0) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push('/record-payment/${order.id}');
                    },
                    icon: const Icon(LucideIcons.indianRupee, size: 16),
                    label: const Text('Record Payment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentStatusBadge(Order order) {
    Color color;
    String label;
    if (order.paidAmount <= 0) {
      color = Colors.red;
      label = 'UNPAID';
    } else if (order.paidAmount < order.totalAmount) {
      color = Colors.orange;
      label = 'PARTIAL';
    } else {
      color = Colors.green;
      label = 'PAID';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }
}
