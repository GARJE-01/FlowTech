import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../order/data/order_service.dart'; // Import OrderService

class CartPlaceholderScreen extends ConsumerWidget {
  const CartPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use draftOrderProvider directly
    final draftOrder = ref.watch(draftOrderProvider);
    final cartItems = draftOrder?.items ?? [];
    final totalAmount = draftOrder?.totalAmount ?? 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Cart')),
      body: cartItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.shoppingCart, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Your cart is empty'),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                         title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                         subtitle: Text('${item.unitType} x ${item.quantity}'),
                         trailing: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Text('₹${item.lineTotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                             IconButton(
                               icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 18),
                               onPressed: () {
                                 ref.read(draftOrderProvider.notifier).removeItem(item.productId);
                               },
                             ),
                           ],
                         ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:', style: TextStyle(fontSize: 18)),
                      Text('₹${totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
} // Correct class end
