import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/shop_service.dart';
import '../domain/shop_model.dart';
import '../../order/data/order_service.dart';

class ShopDetailScreen extends ConsumerWidget {
  final String shopId;

  const ShopDetailScreen({
    required this.shopId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch all shops to react to changes (like deactivation)
    final shops = ref.watch(shopProvider);
    
    // Find our shop
    final shop = shops.firstWhere(
      (s) => s.id == shopId,
      orElse: () => Shop(
        id: 'error', name: 'Not Found', ownerName: '', mobileNumber: '', address: '', cityId: '',
      ),
    );

    if (shop.id == 'error') {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Shop not found')));
    }

    final isActive = shop.status == ShopStatus.active;

    return Scaffold(
      appBar: AppBar(
        title: Text(shop.name),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                color: isActive ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Details Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                       _buildDetailRow(LucideIcons.user, 'Owner', shop.ownerName),
                       const Divider(height: 24),
                       if (shop.gstNumber != null && shop.gstNumber!.isNotEmpty) ...[
                          _buildDetailRow(LucideIcons.receipt, 'GST Number', shop.gstNumber!),
                          const Divider(height: 24),
                       ],
                       _buildDetailRow(LucideIcons.phone, 'Mobile', shop.mobileNumber),
                       const Divider(height: 24),
                       _buildDetailRow(LucideIcons.mapPin, 'Address', shop.address),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Actions
            if (isActive)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilledButton.icon(
                   onPressed: () {
                     ref.read(draftOrderProvider.notifier).startNewDraft(
                       shopId: shop.id,
                       shopName: shop.name,
                       cityId: shop.cityId,
                     );
                     context.push('/products');
                  },
                  icon: const Icon(LucideIcons.shoppingCart),
                  label: const Text('Place New Order'),
                ),
              ),

             const SizedBox(height: 24),

             // 3. Stats / History Placeholder
             Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Order History',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
             ),
             const SizedBox(height: 8),
             _buildOrderHistory(context, ref, shop.id),

             // 4. Danger Zone (Deactivate)
             if (isActive)
              Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton(
                  onPressed: () => _confirmDeactivation(context, ref, shop.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Deactivate Shop'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderHistory(BuildContext context, WidgetRef ref, String shopId) {
    final allOrders = ref.watch(orderListProvider);
    final shopOrders = allOrders.where((o) => o.shopId == shopId).toList();
    shopOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (shopOrders.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(LucideIcons.clock, size: 32, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text('No orders yet', style: TextStyle(color: Colors.grey[500])),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: shopOrders.take(5).length, // Show up to 5 recent orders
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final order = shopOrders[index];
        return Card(
          child: ListTile(
            title: Text('Order #${order.id.substring(order.id.length - 6)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('₹${order.totalAmount.toStringAsFixed(0)} - ${order.status.name.toUpperCase()}'),
            trailing: const Icon(LucideIcons.chevronRight),
            onTap: () => context.push('/orders/${order.id}'),
          ),
        );
      },
    );
  }

  void _confirmDeactivation(BuildContext context, WidgetRef ref, String shopId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Shop?'),
        content: const Text('This will prevent new orders for this shop. You can reactivate it later from the Admin panel only.'),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              ref.read(shopProvider.notifier).deactivateShop(shopId);
              context.pop(); // Close dialog
              context.pop(); // Back to list
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }
}
