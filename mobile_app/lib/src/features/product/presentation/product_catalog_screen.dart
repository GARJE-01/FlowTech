import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/product_service.dart';
import '../data/cart_stub_service.dart';
import '../domain/product_model.dart';
import 'product_detail_bottom_sheet.dart';

class ProductCatalogScreen extends ConsumerStatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  ConsumerState<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends ConsumerState<ProductCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  ProductFilter _filter = ProductFilter();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showProductDetail(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => ProductDetailBottomSheet(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = ref.watch(filteredProductsProvider(_filter));
    final categories = ref.watch(productCategoriesProvider);
    final cartCount = ref.watch(cartProvider).fold<int>(0, (sum, item) => sum + (item.quantity as int));

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Order'),
        actions: [
          // Sort Button Mock
          IconButton(onPressed: () {}, icon: const Icon(LucideIcons.arrowUpDown)),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(LucideIcons.search),
                suffixIcon: _filter.query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                           setState(() {
                            _filter = _filter.copyWith(query: '');
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (val) {
                setState(() {
                  _filter = _filter.copyWith(query: val);
                });
              },
            ),
          ),

          // 2. Filters (Categories + Stock)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Available Only'),
                  selected: _filter.onlyAvailable,
                  onSelected: (val) {
                    setState(() => _filter = _filter.copyWith(onlyAvailable: val));
                  },
                ),
                const SizedBox(width: 8),
                ...categories.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: _filter.category == cat,
                    onSelected: (val) {
                      setState(() => _filter = _filter.copyWith(category: val ? cat : null));
                    },
                  ),
                )),
              ],
            ),
          ),
          
          const Divider(height: 24),

          // 3. Product List
          Expanded(
            child: filteredProducts.isEmpty 
              ? Center(child: Text('No products found', style: TextStyle(color: Colors.grey[500])))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredProducts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    final isOutOfStock = product.stockStatus == ProductStockStatus.outOfStock;
                    final isLowStock = product.stockStatus == ProductStockStatus.lowStock;

                    return Opacity(
                      opacity: isOutOfStock ? 0.6 : 1.0,
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[200]!),
                        ),
                        child: InkWell(
                          onTap: () => _showProductDetail(product),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Placeholder Image
                                Container(
                                  width: 60, height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(LucideIcons.package, color: Colors.grey[400]),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      Text('${product.category} • ${product.unitType}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          if (isOutOfStock)
                                             const Text('Out of Stock', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold))
                                          else if (isLowStock)
                                             const Text('Low Stock', style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold))
                                          else 
                                             const Text('Available', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('₹${product.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Icon(LucideIcons.plusCircle, color: Theme.of(context).primaryColor, size: 20),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
      floatingActionButton: cartCount > 0 ? FloatingActionButton.extended(
        onPressed: () => context.push('/cart'),
        icon: const Icon(LucideIcons.shoppingCart),
        label: Text('View Cart ($cartCount)'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ) : null,
    );
  }
}
