enum ProductStockStatus { available, lowStock, outOfStock }

class Product {
  final String id;
  final String name;
  final String category;
  final String unitType;
  final double price;
  final ProductStockStatus stockStatus;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.unitType,
    required this.price,
    required this.stockStatus,
  });
}
