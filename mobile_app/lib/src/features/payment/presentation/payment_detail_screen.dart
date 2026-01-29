import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/payment_model.dart';
import '../data/payment_service.dart';

class PaymentDetailScreen extends ConsumerWidget {
  final String paymentId;

  const PaymentDetailScreen({required this.paymentId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(paymentProvider);
    final payment = payments.where((p) => p.paymentId == paymentId).firstOrNull;

    if (payment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Details')),
        body: const Center(child: Text('Payment Record Not Found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Overview Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('Balance Due', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    const SizedBox(height: 8),
                    Text('₹${payment.balanceAmount.toStringAsFixed(0)}', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: payment.balanceAmount > 0 ? Colors.red : Colors.green)),
                    const SizedBox(height: 16),
                    _buildStatusBadge(payment.status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Invoice Info
            const Text('Invoice Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                children: [
                  _buildRow('Shop Name', payment.shopName),
                  _buildRow('Invoice No', payment.invoiceId),
                  _buildRow('Total Bill', '₹${payment.totalBillAmount.toStringAsFixed(0)}', isValueBold: true),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // 3. Payment History / Info
            const Text('Payment Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
             Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                children: [
                  _buildRow('Amount Received', '₹${payment.amountReceived.toStringAsFixed(0)}', color: Colors.green),
                  if (payment.lastPaymentDate != null)
                    _buildRow('Last Payment', payment.lastPaymentDate!.toString().split(' ')[0]),
                  if (payment.lastPaymentMode != null)
                     _buildRow('Mode', payment.lastPaymentMode!.name.toUpperCase()),
                ],
              ),
            ),

             // 4. Admin Simulation (Dev Only)
             const SizedBox(height: 40),
             const Divider(),
             const Padding(
               padding: EdgeInsets.symmetric(vertical: 8.0),
               child: Text('Admin Simulation (Dev Only)', style: TextStyle(color: Colors.grey, fontSize: 12)),
             ),
             Row(
               children: [
                 Expanded(
                   child: OutlinedButton(
                     onPressed: payment.balanceAmount <= 0 ? null : () {
                       ref.read(paymentProvider.notifier).simulatePaymentReference(payment.invoiceId, 1000, PaymentMode.cash);
                       // Show toast/snackbar
                     },
                     child: const Text('Pay ₹1000'),
                   ),
                 ),
                 const SizedBox(width: 12),
                 Expanded(
                   child: ElevatedButton(
                     onPressed: payment.balanceAmount <= 0 ? null : () {
                         ref.read(paymentProvider.notifier).simulatePaymentReference(payment.invoiceId, payment.balanceAmount, PaymentMode.upi);
                     },
                     child: const Text('Full Settle'),
                   ),
                 ),
               ],
             ),
             TextButton(onPressed: () => ref.read(paymentProvider.notifier).resetPayment(payment.invoiceId), child: const Text('Reset Payment'))
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isValueBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(fontWeight: isValueBold ? FontWeight.bold : FontWeight.normal, color: color)),
        ],
      ),
    );
  }
  
  Widget _buildStatusBadge(PaymentStatus status) {
    Color color;
    String label;
    switch (status) {
      case PaymentStatus.paid: color = Colors.green; label = 'PAID'; break;
      case PaymentStatus.partiallyPaid: color = Colors.orange; label = 'PARTIALLY PAID'; break;
      case PaymentStatus.pending: color = Colors.red; label = 'PAYMENT PENDING'; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }
}
