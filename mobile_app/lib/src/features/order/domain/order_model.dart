import 'order_item_model.dart';

enum OrderStatus { draft, pending, approved, rejected }

class Order {
  final String id;
  final String shopId;
  final String shopName;
  final String cityId;
  final List<OrderItem> items;
  final double subtotalAmount;
  final double gstAmount;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Order({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.cityId,
    required this.items,
    required this.subtotalAmount,
    required this.gstAmount,
    required this.totalAmount,
    this.status = OrderStatus.draft,
    required this.createdAt,
    this.updatedAt,
  });

  Order copyWith({
    String? id,
    String? shopId,
    String? shopName,
    String? cityId,
    List<OrderItem>? items,
    double? subtotalAmount,
    double? gstAmount,
    double? totalAmount,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      cityId: cityId ?? this.cityId,
      items: items ?? this.items,
      subtotalAmount: subtotalAmount ?? this.subtotalAmount,
      gstAmount: gstAmount ?? this.gstAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
