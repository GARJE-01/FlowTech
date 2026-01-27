import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shop/data/shop_service.dart';
import '../../shop/domain/shop_model.dart';
import '../../city/data/city_service.dart';
import '../../order/data/order_service.dart';

class OrderShopSelectionScreen extends ConsumerWidget {
  const OrderShopSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cityState = ref.watch(cityProvider);
    final allShops = ref.watch(shopProvider);
    
    // Filter active shops for selected city
    final shops = allShops.where((s) => 
      s.cityId == cityState.selectedCity?.id && 
      s.status == ShopStatus.active
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Shop'),
      ),
      body: shops.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.store, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text('No active shops found in this city.'),
              ],
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: shops.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final shop = shops[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Text(shop.name[0], style: TextStyle(color: Theme.of(context).primaryColor)),
                  ),
                  title: Text(shop.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(shop.ownerName),
                  trailing: const Icon(LucideIcons.chevronRight),
                  onTap: () {
                    // Start Draft
                    ref.read(draftOrderProvider.notifier).startNewDraft(
                      shopId: shop.id,
                      shopName: shop.name,
                      cityId: shop.cityId,
                    );
                    
                    // Navigate to Catalog
                    context.replace('/products'); // Replace to avoid back loop to selection? Or push? 
                    // Push might be better so user can change shop if they made mistake.
                    // But if they go back from products, they might expect to cancel order?
                    // Let's use pushReplacement to act as "New Order Flow Started".
                    // Actually, push is safer for navigation stack sanity generally unless strict wizard.
                    // Let's use push, so Back from Products goes to Shop Selection.
                  },
                ),
              );
            },
          ),
    );
  }
}
