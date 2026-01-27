import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/cart_stub_service.dart';

class CartPlaceholderScreen extends ConsumerWidget {
  const CartPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final totalAmount = ref.read(cartProvider.notifier).totalAmount;

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
                         title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                         subtitle: Text('${item.product.unitType} x ${item.quantity}'),
                         trailing: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Text('₹${item.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                             IconButton(
                               icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 18),
                               onPressed: () {
                                 ref.read(cartProvider.notifier).removeFromCart(item.product.id);
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
                        color: Colors.black.withOpacity(0.05),
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
}
