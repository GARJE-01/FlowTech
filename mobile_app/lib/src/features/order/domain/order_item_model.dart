class OrderItem {
  final String productId;
  final String productName;
  final String unitType;
  final double pricePerUnit;
  final int quantity;
  
  // Computed property
  double get lineTotal => pricePerUnit * quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.unitType,
    required this.pricePerUnit,
    required this.quantity,
  });

  OrderItem copyWith({
    String? productId,
    String? productName,
    String? unitType,
    double? pricePerUnit,
    int? quantity,
  }) {
    return OrderItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unitType: unitType ?? this.unitType,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      quantity: quantity ?? this.quantity,
    );
  }
}
