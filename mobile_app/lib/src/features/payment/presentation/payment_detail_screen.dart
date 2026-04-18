import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../domain/payment_model.dart';
import '../data/payment_service.dart';
import '../../order/data/order_service.dart';

class PaymentDetailScreen extends ConsumerWidget {
  final String paymentId;

  const PaymentDetailScreen({required this.paymentId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(paymentProvider);
    final payment = payments.where((p) => p.id == paymentId).firstOrNull;

    if (payment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Details')),
        body: const Center(child: Text('Payment Record Not Found')),
      );
    }

    final order = ref.watch(orderListProvider).where((o) => o.id == payment.orderId).firstOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status/Amount Header
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.checkCircle2, color: Colors.green, size: 48),
                  ),
                  const SizedBox(height: 16),
                  const Text('Payment Received', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text('₹${payment.amount.toStringAsFixed(2)}', 
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ),
            const SizedBox(height: 40),

            const Text('Transaction Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                   _buildRow('Transaction ID', payment.id.substring(0, 8).toUpperCase()),
                   _buildRow('Payment Mode', payment.paymentMode.name.toUpperCase()),
                   _buildRow('Date & Time', DateFormat('dd MMM yyyy, hh:mm a').format(payment.createdAt)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('Order Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildRow('Shop Name', order?.shopName ?? 'N/A'),
                  _buildRow('Order No', '#...${payment.orderId.substring(payment.orderId.length.clamp(0, 6))}'),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(LucideIcons.arrowLeft),
                label: const Text('Back to History'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}

