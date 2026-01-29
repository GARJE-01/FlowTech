import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/payment_model.dart';
import '../../order/data/order_service.dart'; // To link with orders if needed or just mock
import 'dart:math';

import '../../notification/data/notification_service.dart';
import '../../notification/domain/notification_model.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart'; // Already imported
// import 'dart:math'; // Already imported

class PaymentNotifier extends StateNotifier<List<Payment>> {
  final Ref ref;

  PaymentNotifier(this.ref) : super([]) {
    _initMockData();
  }

  void _initMockData() {
    // Generate some mock payments based on assumed orders/invoices
    state = [
      Payment(
        paymentId: 'PAY-101',
        invoiceId: 'INV-2024-001',
        shopId: 'SHOP-1',
        shopName: 'Krishna General Store',
        totalBillAmount: 15000,
        amountReceived: 0,
      ),
      Payment(
        paymentId: 'PAY-102',
        invoiceId: 'INV-2024-002',
        shopId: 'SHOP-2',
        shopName: 'Priya Supermarket',
        totalBillAmount: 8500,
        amountReceived: 5000,
        lastPaymentDate: DateTime.now().subtract(const Duration(days: 2)),
        lastPaymentMode: PaymentMode.upi,
      ),
      Payment(
        paymentId: 'PAY-103',
        invoiceId: 'INV-2024-003',
        shopId: 'SHOP-3',
        shopName: 'Laxmi Traders',
        totalBillAmount: 22000,
        amountReceived: 22000,
        lastPaymentDate: DateTime.now().subtract(const Duration(days: 5)),
        lastPaymentMode: PaymentMode.check,
      ),
    ];
  }

  // --- Read Methods ---
  List<Payment> getPaymentsByShop(String shopId) {
    return state.where((p) => p.shopId == shopId).toList();
  }

  Payment? getPaymentByInvoice(String invoiceId) {
    return state.where((p) => p.invoiceId == invoiceId).firstOrNull;
  }
  
  List<Payment> getPaymentsByStatus(PaymentStatus status) {
    return state.where((p) => p.status == status).toList();
  }

  // --- Admin Simulation Methods (Dev Only) ---
  void simulatePaymentReference(String invoiceId, double amount, PaymentMode mode) {
    state = [
      for (final p in state)
        if (p.invoiceId == invoiceId)
          p.copyWith(
            amountReceived: min(p.totalBillAmount, p.amountReceived + amount),
            lastPaymentDate: DateTime.now(),
            lastPaymentMode: mode,
          )
        else
          p
    ];
    ref.read(notificationProvider.notifier).addNotification(
      type: NotificationType.payment,
      title: 'Payment Received',
      message: 'Received ₹${amount.toStringAsFixed(0)} for Invoice #$invoiceId via ${mode.name.toUpperCase()}',
      relatedId: invoiceId,
    );
  }

  // Debug: Reset
  void resetPayment(String invoiceId) {
    state = [
       for (final p in state)
        if (p.invoiceId == invoiceId)
          p.copyWith(amountReceived: 0, lastPaymentDate: null, lastPaymentMode: null)
        else
          p
    ];
  }
}

final paymentProvider = StateNotifierProvider<PaymentNotifier, List<Payment>>((ref) {
  return PaymentNotifier(ref);
});
