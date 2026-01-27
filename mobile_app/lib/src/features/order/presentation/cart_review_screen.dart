import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/order_service.dart';
import '../../product/domain/product_model.dart'; // To get product list for names if needed, or stick to OrderItem data
import '../../shop/data/shop_service.dart'; // To get shop details if needed

class CartReviewScreen extends ConsumerWidget {
  const CartReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftOrder = ref.watch(draftOrderProvider);

    if (draftOrder == null || draftOrder.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review Order')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.shoppingCart, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text('Your cart is empty', style: TextStyle(color: Colors.grey[500])),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Order'),
      ),
      body: Column(
        children: [
          // 1. Shop Details Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            child: Row(
              children: [
                const Icon(LucideIcons.store, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(draftOrder.shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Order ID: ...${draftOrder.id.substring(draftOrder.id.length - 6)}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 2. Line Items
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: draftOrder.items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = draftOrder.items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('${item.unitType}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('@ ₹${item.pricePerUnit.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                      ),
                      
                      // Quantity Controls
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(LucideIcons.minus, size: 16),
                              onPressed: () {
                                ref.read(draftOrderProvider.notifier).updateItemQuantity(item.productId, item.quantity - 1);
                              },
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              padding: EdgeInsets.zero,
                            ),
                            Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(LucideIcons.plus, size: 16),
                              onPressed: () {
                                ref.read(draftOrderProvider.notifier).updateItemQuantity(item.productId, item.quantity + 1);
                              },
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Line Total & Remove
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹${item.lineTotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 16),
                            onPressed: () {
                              ref.read(draftOrderProvider.notifier).removeItem(item.productId);
                            },
                             constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                             padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // 3. Totals Section
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
            child: Column(
              children: [
                _buildSummaryRow('Subtotal', draftOrder.subtotalAmount),
                const SizedBox(height: 8),
                _buildSummaryRow('GST (18%)', draftOrder.gstAmount),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Grand Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('₹${draftOrder.totalAmount.toStringAsFixed(0)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                  ],
                ),
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.push('/products'), // Add more
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('Add More'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: () {
                          ref.read(orderListProvider.notifier).submitOrder(draftOrder);
                          ref.read(draftOrderProvider.notifier).clearDraft();
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Order sent to admin for approval.')),
                          );
                          
                          // Navigate to Order Tracking (Feature 8)
                          context.go('/orders');
                        },
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('Submit Order'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text('₹${value.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
