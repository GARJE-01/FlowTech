import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/product_model.dart';
import '../../../core/storage/storage_service.dart';


class ProductService extends StateNotifier<List<Product>> {
  final StorageService _storage;

  ProductService(this._storage) : super([]) {
    _loadProducts();
  }

  void _loadProducts() {
    state = _storage.loadProducts();
  }

  void syncProducts(List<Product> newProducts) {
    state = newProducts;
    _storage.saveProducts(newProducts);
  }
}

final productProvider = StateNotifierProvider<ProductService, List<Product>>((ref) {
  // Overridden in main.dart
  throw UnimplementedError('StorageService must be overridden');
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
