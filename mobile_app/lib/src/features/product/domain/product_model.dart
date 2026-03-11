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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'unitType': unitType,
    'price': price,
    'stockStatus': stockStatus.index,
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'].toString(),
    name: json['name'],
    category: json['category'],
    unitType: json['unitType'] ?? 'Unit',
    price: json['price'].toDouble(),
    stockStatus: ProductStockStatus.values[json['stockStatus'] ?? 0],
  );
}

