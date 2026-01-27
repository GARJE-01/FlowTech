import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../domain/product_model.dart';
import '../data/cart_stub_service.dart'; // Bridge
import '../data/cart_stub_service.dart';

class ProductDetailBottomSheet extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailBottomSheet({required this.product, super.key});

  @override
  ConsumerState<ProductDetailBottomSheet> createState() => _ProductDetailBottomSheetState();
}

class _ProductDetailBottomSheetState extends ConsumerState<ProductDetailBottomSheet> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isOutOfStock = product.stockStatus == ProductStockStatus.outOfStock;
    final isLowStock = product.stockStatus == ProductStockStatus.lowStock;

    return Container(

      // Ensure it respects bottom padding (safe area)
      padding: EdgeInsets.only(
        left: 20, 
        right: 20, 
        top: 20, 
        bottom: MediaQuery.of(context).viewInsets.bottom + 20
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Expanded(
                 child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(product.category, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
                  ],
                 ),
               ),
               IconButton(
                 onPressed: () => context.pop(),
                 icon: const Icon(Icons.close),
               ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Stock Status Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOutOfStock ? Colors.red.withOpacity(0.1) : (isLowStock ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isOutOfStock ? 'Out of Stock' : (isLowStock ? 'Low Stock' : 'Available'),
                  style: TextStyle(
                    color: isOutOfStock ? Colors.red : (isLowStock ? Colors.orange : Colors.green),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '₹${product.price.toStringAsFixed(0)}', 
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
              ),
              Text(' /${product.unitType}', style: TextStyle(color: Colors.grey[500])),
            ],
          ),
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Quantity Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                icon: const Icon(LucideIcons.minus),
              ),
              Container(
                width: 80,
                alignment: Alignment.center,
                child: Text('$_quantity', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              IconButton.filledTonal(
                onPressed: !isOutOfStock ? () => setState(() => _quantity++) : null,
                icon: const Icon(LucideIcons.plus),
              ),
            ],
          ),

          const SizedBox(height: 24),
          
          FilledButton(
            onPressed: isOutOfStock ? null : () {
              ref.read(cartActionsProvider).addToCart(product, _quantity);
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Added $_quantity ${product.unitType}(s) to cart')),
              );
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: isOutOfStock ? Colors.grey[300] : Theme.of(context).primaryColor,
            ),
             child: Text(isOutOfStock ? 'Currently Unavailable' : 'Add to Cart - ₹${(product.price * _quantity).toStringAsFixed(0)}'),
          ),
        ],
      ),
    );
  }
}
