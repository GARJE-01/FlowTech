import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flowtech_salesman/src/core/storage/storage_service.dart';
import 'package:flowtech_salesman/src/features/shop/domain/shop_model.dart';
import 'package:flowtech_salesman/src/features/shop/data/shop_service.dart';
import 'package:flowtech_salesman/src/features/order/domain/order_model.dart';
import 'package:flowtech_salesman/src/features/order/data/order_service.dart';
import 'package:flowtech_salesman/src/features/product/domain/product_model.dart';
import 'package:flowtech_salesman/src/features/payment/data/payment_service.dart';
import 'package:flowtech_salesman/src/features/payment/domain/payment_model.dart';
import 'package:flowtech_salesman/src/features/invoice/data/invoice_service.dart';
import 'package:flowtech_salesman/src/features/notification/data/notification_service.dart';
import 'package:flowtech_salesman/src/core/network/api_client.dart';
import 'package:flowtech_salesman/src/features/auth/data/auth_service.dart';

void main() {
  late ProviderContainer container;
  late StorageService storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    storage = StorageService(prefs);

    container = ProviderContainer(
      overrides: [
        storageServiceProvider.overrideWith((ref) => storage),
        // Mock API client if necessary to prevent real network calls
        apiClientProvider.overrideWith((ref) => ApiClient(storage)),
        shopProvider.overrideWith((ref) => ShopService(storage, ref)),
        orderListProvider.overrideWith((ref) => OrderListNotifier(ref, storage)),
        paymentProvider.overrideWith((ref) => PaymentNotifier(ref, storage)),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Order Flow (Draft to Rejected/Approved)', () {
    test('Can create a draft order, add items, and update totals', () {
      final draftNotifier = container.read(draftOrderProvider.notifier);
      
      // 1. Start Draft
      draftNotifier.startNewDraft(shopId: 's1', shopName: 'Test Shop', cityId: 'c1');
      Order? draft = container.read(draftOrderProvider);
      
      expect(draft, isNotNull);
      expect(draft!.status, OrderStatus.draft);
      expect(draft.items.length, 0);

      // 2. Add Product
      final product = Product(id: 'p1', name: 'Product A', category: 'Cat', price: 100, stockStatus: ProductStockStatus.available, unitType: 'Unit');
      draftNotifier.addItem(product, 2);
      
      final updatedDraft = container.read(draftOrderProvider);
      expect(updatedDraft!.items.length, 1);
      expect(updatedDraft.items[0].quantity, 2);
      expect(updatedDraft.subtotalAmount, 200.0);
      expect(updatedDraft.gstAmount, 36.0); // 18% of 200
      expect(updatedDraft.totalAmount, 236.0);
    });

    test('Can submit draft and transition order to pending then approved/rejected', () async {
      final draftNotifier = container.read(draftOrderProvider.notifier);
      final orderListNotifier = container.read(orderListProvider.notifier);

      // Create Draft
      draftNotifier.startNewDraft(shopId: 's1', shopName: 'Test Shop', cityId: 'c1');
      draftNotifier.addItem(Product(id: 'p1', name: 'Product A', category: 'Cat', price: 100, stockStatus: ProductStockStatus.available, unitType: 'Unit'), 1);
      final draft = container.read(draftOrderProvider)!;

      // Submit Order (Bypassing API in local mock or letting it fail gracefully. We use simulateAdminAction to test local state transition)
      // Since ApiClient expects real backend, we will directly push an order to simulate Sync or Submit
      orderListNotifier.syncOrders([draft.copyWith(status: OrderStatus.pending, id: 'order-123')]);
      
      final orders = container.read(orderListProvider);
      expect(orders.length, 1);
      expect(orders[0].status, OrderStatus.pending);

      // Simulate Admin Reject
      orderListNotifier.simulateAdminAction('order-123', false);
      expect(container.read(orderListProvider)[0].status, OrderStatus.rejected);

      // Simulate Admin Approve
      orderListNotifier.simulateAdminAction('order-123', true);
      expect(container.read(orderListProvider)[0].status, OrderStatus.approved);
    });
  });

  group('Shop Management', () {
    test('Can sync and update shop status', () async {
      final shopNotifier = container.read(shopProvider.notifier);
      
      shopNotifier.syncShops([
        Shop(id: 's1', name: 'Shop 1', ownerName: 'Owner', mobileNumber: '1', address: 'Add', cityId: 'city1', status: ShopStatus.active),
      ]);

      expect(container.read(shopProvider).length, 1);
      expect(container.read(shopProvider)[0].status, ShopStatus.active);

      // Update balances
      shopNotifier.updateShopBalance('s1', 500.0);
      expect(container.read(shopProvider)[0].outstandingBalance, 500.0);
    });
  });

  group('Payments & Bills Management', () {
    test('Can record payment and update balances securely', () {
      final paymentNotifier = container.read(paymentProvider.notifier);
      final ordersNotifier = container.read(orderListProvider.notifier);

      // Add a mock order requiring payment
      ordersNotifier.syncOrders([
        Order(id: 'ord-1', shopId: 's1', shopName: 'Shop', cityId: '1', items: [], subtotalAmount: 100, gstAmount: 18, totalAmount: 118, paidAmount: 0, status: OrderStatus.approved, createdAt: DateTime.now())
      ]);

      expect(container.read(orderListProvider)[0].balanceAmount, 118.0);

      // Mock a backend synchronization for this new payment
      paymentNotifier.syncPayments([
        Payment(id: 'p1', orderId: 'ord-1', shopId: 's1', salesmanId: 'sal-1', amount: 50, paymentMode: PaymentMode.cash, createdAt: DateTime.now())
      ]);

      // Check payment was recorded
      final payments = container.read(paymentProvider);
      expect(payments.length, 1);
      expect(payments[0].amount, 50.0);

      // We explicitly call updateOrderPayment as it normally happens in UI or backend sync
      ordersNotifier.updateOrderPayment('ord-1', 50.0);

      final updatedOrder = container.read(orderListProvider)[0];
      expect(updatedOrder.paidAmount, 50.0);
      expect(updatedOrder.balanceAmount, 68.0);
    });
  });
}
