import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/storage_service.dart';
import '../domain/payment_model.dart';
import '../../order/data/order_service.dart';
import '../../../core/network/api_client.dart';
import '../../auth/data/auth_service.dart';
import '../../shop/data/shop_service.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart'; // Already imported
// import 'dart:math'; // Already imported

class PaymentNotifier extends StateNotifier<List<Payment>> {
  final Ref ref;
  final StorageService _storage;

  PaymentNotifier(this.ref, this._storage) : super([]) {
    _loadPayments();
  }

  void _loadPayments() {
    final loaded = _storage.loadPayments();
    if (loaded.isNotEmpty) {
      state = loaded;
    }
  }

  void syncPayments(List<Payment> newPayments) {
    state = newPayments;
    _storage.savePayments(newPayments);
  }

  // --- Read Methods ---
  List<Payment> getPaymentsByShop(String shopId) {
    return state.where((p) => p.shopId == shopId).toList();
  }

  List<Payment> getPaymentsByOrder(String orderId) {
    return state.where((p) => p.orderId == orderId).toList();
  }

  double getTotalPaidForOrder(String orderId) {
    return state
        .where((p) => p.orderId == orderId)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  Future<bool> addPayment({
    required String orderId,
    required String shopId,
    required double amount,
    required PaymentMode mode,
  }) async {
    final apiClient = ref.read(apiClientProvider);
    final authState = ref.read(authProvider);
    
    if (!authState.isAuthenticated) return false;

    final data = {
      "orderId": orderId,
      "shopId": shopId,
      "salesmanId": authState.user!.id,
      "amount": amount,
      "paymentMode": mode.name.toLowerCase(),
    };

    final result = await apiClient.post("/payments/create", data);

    if (result['success'] == true) {
      // Create local payment object
      final newPayment = Payment(
        id: result['paymentId'],
        orderId: orderId,
        shopId: shopId,
        salesmanId: authState.user!.id,
        amount: amount,
        paymentMode: mode,
        createdAt: DateTime.now(),
      );

      // Update state
      state = [...state, newPayment];
      _storage.savePayments(state);

      // Update Order and Shop local state to avoid waiting for sync
      ref.read(orderListProvider.notifier).updateOrderPayment(orderId, amount);
      ref.read(shopProvider.notifier).updateShopBalance(shopId, -amount); // Deduct from outstanding

      return true;
    }
    return false;
  }
}

final paymentProvider = StateNotifierProvider<PaymentNotifier, List<Payment>>((ref) {
  throw UnimplementedError('StorageService must be overridden in main.dart');
});
