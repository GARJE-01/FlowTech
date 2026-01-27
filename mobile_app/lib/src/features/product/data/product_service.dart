import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/product_model.dart';

// Mock Data
final _initialProducts = [
  Product(id: '1', name: 'UltraTech Cement', category: 'Cement', unitType: 'Bag', price: 350, stockStatus: ProductStockStatus.available),
  Product(id: '2', name: 'Ambuja Cement', category: 'Cement', unitType: 'Bag', price: 340, stockStatus: ProductStockStatus.lowStock),
  Product(id: '3', name: 'Tata Steel TMT', category: 'Steel', unitType: 'Ton', price: 45000, stockStatus: ProductStockStatus.available),
  Product(id: '4', name: 'Asian Paints Royale', category: 'Paints', unitType: 'Bucket (20L)', price: 8500, stockStatus: ProductStockStatus.available),
  Product(id: '5', name: 'Finolex Pipes', category: 'Plumbing', unitType: 'Bundle', price: 1200, stockStatus: ProductStockStatus.outOfStock),
  Product(id: '6', name: 'Berger Primer', category: 'Paints', unitType: 'Bucket (10L)', price: 2200, stockStatus: ProductStockStatus.available),
  Product(id: '7', name: 'Dr. Fixit', category: 'Chemicals', unitType: 'Can (5L)', price: 950, stockStatus: ProductStockStatus.available),
  Product(id: '8', name: 'Jindal Panther', category: 'Steel', unitType: 'Ton', price: 46000, stockStatus: ProductStockStatus.lowStock),
];

class ProductService extends StateNotifier<List<Product>> {
  ProductService() : super(_initialProducts);
}

final productProvider = StateNotifierProvider<ProductService, List<Product>>((ref) {
  return ProductService();
});

// Providers for Filtering
final productCategoriesProvider = Provider<List<String>>((ref) {
  final products = ref.watch(productProvider);
  return products.map((p) => p.category).toSet().toList()..sort();
});

final filteredProductsProvider = Provider.family<List<Product>, ProductFilter>((ref, filter) {
  final allProducts = ref.watch(productProvider);
  return allProducts.where((p) {
    // 1. Search Query
    if (filter.query.isNotEmpty && !p.name.toLowerCase().contains(filter.query.toLowerCase())) {
      return false;
    }
    // 2. Category
    if (filter.category != null && p.category != filter.category) {
      return false;
    }
    // 3. Stock Status
    if (filter.onlyAvailable && p.stockStatus == ProductStockStatus.outOfStock) {
      return false; 
    }
    return true;
  }).toList();
});

class ProductFilter {
  final String query;
  final String? category;
  final bool onlyAvailable;

  ProductFilter({this.query = '', this.category, this.onlyAvailable = false});
  
  ProductFilter copyWith({String? query, String? category, bool? onlyAvailable}) {
    return ProductFilter(
      query: query ?? this.query,
      category: category ?? this.category, // Pass null to clear
      onlyAvailable: onlyAvailable ?? this.onlyAvailable,
    );
  }
}
