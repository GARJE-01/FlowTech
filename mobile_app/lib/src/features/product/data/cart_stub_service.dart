import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../order/data/order_service.dart';
import '../domain/product_model.dart';

// REPLACED BY OrderService (features/order)
// This file acts as a bridge for legacy calls or we can deprecate it.
// The prompt said "Cart Review Screen (Main Screen of Feature 7)".
// So we should redirect usage here to the new system.

class CartStubService {
   // Deprecated
}

// We can make the provider point to the DraftOrderNotifier for simple item counting
final cartProvider = Provider<List<dynamic>>((ref) { // Using dynamic to avoid circular deps if needed, or import OrderItems
   final draft = ref.watch(draftOrderProvider);
   return draft?.items ?? [];
});

// Helper to bridge "Add to Cart"
final cartActionsProvider = Provider((ref) {
  return CartActions(ref);
});

class CartActions {
  final Ref ref;
  CartActions(this.ref);

  void addToCart(Product product, int quantity) {
     ref.read(draftOrderProvider.notifier).addItem(product, quantity);
  }
}
