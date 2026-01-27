import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../product/domain/product_model.dart';
import '../../route/data/visit_service.dart';
import '../domain/order_model.dart';
import '../domain/order_item_model.dart';
import '../../shop/domain/shop_model.dart';

class OrderService extends StateNotifier<List<Order>> {
  final Ref ref;
  Order? _currentDraftOrder;

  OrderService(this.ref) : super([]);

  Order? get currentDraftOrder => _currentDraftOrder;

  // Initialize a new draft for a specific shop
  void startNewOrder(Shop shop) {
    if (_currentDraftOrder != null && _currentDraftOrder!.shopId == shop.id) {
       // Resume existing draft if same shop
       return;
    }
    
    // Create new draft
    _currentDraftOrder = Order(
      id: const Uuid().v4(),
      shopId: shop.id,
      shopName: shop.name,
      cityId: shop.cityId,
      items: [],
      subtotalAmount: 0,
      gstAmount: 0,
      totalAmount: 0,
      status: OrderStatus.draft,
      createdAt: DateTime.now(),
    );
    // Notify listeners if we were exposing draft directly (but here we just manage it internally or via a separate provider)
    // Actually, we should probably expose draft via a separate provider or state.
    // For simplicity, let's treat the state of this notifier as the LIST of orders (history/pending).
    // And have a separate provider for "Draft Order State" or manage it here and expose a getter.
    // But StateNotifier only exposes `state`.
    // Let's make `currentDraftOrder` accessible via a separate provider that reads this service/method?
    // Or better: Use a separate Notifier for the Draft.
  }
}

// 1. Draft Order Notifier (Manages the active cart/order being built)
class DraftOrderNotifier extends StateNotifier<Order?> {
  DraftOrderNotifier() : super(null);

  bool get hasDraft => state != null;

  void startNewDraft({required String shopId, required String shopName, required String cityId}) {
    // If draft exists for another shop, warn user? (For now, overwrite or simple reset)
    state = Order(
      id: const Uuid().v4(),
      shopId: shopId,
      shopName: shopName,
      cityId: cityId,
      items: [],
      subtotalAmount: 0,
      gstAmount: 0,
      totalAmount: 0,
      status: OrderStatus.draft,
      createdAt: DateTime.now(),
    );
  }

  void addItem(Product product, int quantity) {
    if (state == null) return;
    
    final currentItems = [...state!.items];
    final existingIndex = currentItems.indexWhere((i) => i.productId == product.id);

    if (existingIndex >= 0) {
      // Update existing
      final oldItem = currentItems[existingIndex];
      final newQuantity = oldItem.quantity + quantity;
      currentItems[existingIndex] = oldItem.copyWith(quantity: newQuantity);
    } else {
      // Add new
      currentItems.add(OrderItem(
        productId: product.id,
        productName: product.name,
        unitType: product.unitType,
        pricePerUnit: product.price,
        quantity: quantity,
      ));
    }
    
    _updateStateWithItems(currentItems);
  }

  void updateItemQuantity(String productId, int quantity) {
    if (state == null) return;
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final currentItems = state!.items.map((item) {
      if (item.productId == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    _updateStateWithItems(currentItems);
  }

  void removeItem(String productId) {
    if (state == null) return;
    final currentItems = state!.items.where((i) => i.productId != productId).toList();
    _updateStateWithItems(currentItems);
  }

  void _updateStateWithItems(List<OrderItem> items) {
    if (state == null) return;

    double subtotal = 0;
    for (final item in items) {
      subtotal += item.lineTotal;
    }
    
    // Mock GST 18%
    final gst = subtotal * 0.18;
    final total = subtotal + gst;

    state = state!.copyWith(
      items: items,
      subtotalAmount: subtotal,
      gstAmount: gst,
      totalAmount: total,
      updatedAt: DateTime.now(),
    );
  }
  
  void clearDraft() {
    state = null;
  }
}

final draftOrderProvider = StateNotifierProvider<DraftOrderNotifier, Order?>((ref) {
  return DraftOrderNotifier();
});

// 2. All Orders Manager (Persisted List)
class OrderListNotifier extends StateNotifier<List<Order>> {
  final Ref ref;

  OrderListNotifier(this.ref) : super([]);
  
  void submitOrder(Order draftOrder) {
    // 1. Change status
    final submittedOrder = draftOrder.copyWith(
      status: OrderStatus.pending,
      updatedAt: DateTime.now(),
    );

    // 2. Add to list
    state = [submittedOrder, ...state];

    // 3. Update Visit Status
    ref.read(visitProvider.notifier).markOrderPlaced(draftOrder.shopId);
  }
  // 4. Mock Admin Action
  void simulateAdminAction(String orderId, bool approve) {
    state = [
      for (final order in state)
        if (order.id == orderId)
          order.copyWith(
            status: approve ? OrderStatus.approved : OrderStatus.rejected,
            updatedAt: DateTime.now(),
          )
        else
          order
    ];
  }
}

final orderListProvider = StateNotifierProvider<OrderListNotifier, List<Order>>((ref) {
  return OrderListNotifier(ref);
});
