
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import '../../features/auth/data/auth_service.dart';
import '../../features/shop/data/shop_service.dart';
import '../../features/product/data/product_service.dart';
import '../../features/order/data/order_service.dart';
import '../../features/shop/domain/shop_model.dart';
import '../../features/product/domain/product_model.dart';
import '../../features/order/domain/order_model.dart';
import '../../features/order/domain/order_item_model.dart';
import '../../features/notification/data/notification_service.dart';
import '../../features/notification/domain/notification_model.dart';
import '../../features/payment/data/payment_service.dart';
import '../../features/payment/domain/payment_model.dart';

class SyncService {
  final ApiClient _apiClient;
  final Ref _ref;

  SyncService(this._apiClient, this._ref);

  Future<bool> performFullSync() async {
    final authState = _ref.read(authProvider);
    if (!authState.isAuthenticated) return false;

    final salesmanId = authState.user!.id;
    final result = await _apiClient.get("/data/sync", queryParams: {"salesmanId": salesmanId});

    if (result['success'] == true) {
      final data = result['data'];

      // 1. Sync Shops
      final List<Shop> shops = (data['shops'] as List).map((s) => Shop(
        id: s['id'].toString(),
        name: s['shopName'],
        ownerName: s['ownerName'],
        mobileNumber: s['mobileNumber'],
        address: s['address'],
        cityId: "1", // Manual mapping for now, or update schema
        gstNumber: s['gstNumber'],
        status: s['isActive'] ? ShopStatus.active : ShopStatus.inactive,
        outstandingBalance: (s['outstandingBalance'] ?? s['outstanding_balance'] ?? 0).toDouble(),
      )).toList();
      _ref.read(shopProvider.notifier).syncShops(shops);

      // 2. Sync Products (Flattening Variants)
      final List<Product> products = [];
      for (final p in (data['products'] as List)) {
        for (final v in (p['variants'] as List)) {
          products.add(Product(
            id: v['id'].toString(),
            name: "${p['name']} - ${v['variantName'] ?? ''}",
            category: p['category'],
            unitType: "Unit",
            price: v['price'].toDouble(),
            stockStatus: v['currentStock'] > 5 ? ProductStockStatus.available : 
                        v['currentStock'] > 0 ? ProductStockStatus.lowStock : ProductStockStatus.outOfStock,
          ));
        }
      }
      _ref.read(productProvider.notifier).syncProducts(products);

      // 3. Sync Orders
      final List<Order> orders = (data['orders'] as List).map((o) {
        final List<OrderItem> orderItems = [];
        if (o['items'] != null) {
          for (final i in o['items']) {
             // In real app we'd map variantId to full product details. Here we assume we have basic data or default names if missing.
             // We can find the product name from the synced products list since we just synced it above!
             final product = products.firstWhere(
                (p) => p.id == i['variantId'].toString(), 
                orElse: () => Product(id: i['variantId'].toString(), name: 'Unknown Product', category: '', price: 0, stockStatus: ProductStockStatus.outOfStock, unitType: 'Unit')
             );
             orderItems.add(OrderItem(
               productId: product.id,
               productName: product.name,
               unitType: product.unitType,
               pricePerUnit: i['price'].toDouble(),
               quantity: i['quantity'],
             ));
          }
        }
        
        return Order(
          id: o['id'],
          shopId: o['shopId'].toString(),
          shopName: shops.firstWhere((s) => s.id == o['shopId'].toString(), orElse: () => Shop(id: o['shopId'].toString(), name: 'Unknown Shop', ownerName: '', address: '', mobileNumber: '', cityId: '')).name,
          cityId: "1",
          items: orderItems,
          totalAmount: o['totalAmount'].toDouble(),
          subtotalAmount: o['totalAmount'].toDouble() / 1.18, // Rough reverse engineer since subtotal/gst not saved separately in simple DB schema
          gstAmount: o['totalAmount'].toDouble() - (o['totalAmount'].toDouble() / 1.18),
          paidAmount: (o['paidAmount'] ?? o['paid_amount'] ?? 0).toDouble(),
          status: _mapStatus(o['status']),
          createdAt: DateTime.parse(o['createdAt']),
        );
      }).toList();
      _ref.read(orderListProvider.notifier).syncOrders(orders);

      // 4. Sync Notifications
      if (data['notifications'] != null) {
        final List<NotificationModel> notifications = (data['notifications'] as List)
            .map((n) => NotificationModel.fromJson(n))
            .toList();
        _ref.read(notificationProvider.notifier).syncNotifications(notifications);
      }

      // 5. Sync Payments
      if (data['payments'] != null) {
        final List<Payment> payments = (data['payments'] as List)
            .map((p) => Payment.fromJson(p))
            .toList();
        _ref.read(paymentProvider.notifier).syncPayments(payments);
      }

      return true;
    }
    return false;
  }

  OrderStatus _mapStatus(String status) {
    switch (status) {
      case 'pending': return OrderStatus.pending;
      case 'approved': return OrderStatus.approved;
      case 'rejected': return OrderStatus.rejected;
      case 'delivered': return OrderStatus.delivered;
      default: return OrderStatus.pending;
    }
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SyncService(apiClient, ref);
});
