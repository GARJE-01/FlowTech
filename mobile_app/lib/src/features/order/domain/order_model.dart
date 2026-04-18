import 'order_item_model.dart';

enum OrderStatus { draft, pending, approved, rejected, delivered }


class Order {
  final String id;
  final String shopId;
  final String shopName;
  final String cityId;
  final List<OrderItem> items;
  final double subtotalAmount;
  final double gstAmount;
  final double totalAmount;
  final double paidAmount;

  double get balanceAmount => totalAmount - paidAmount;
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
    this.paidAmount = 0.0,
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
    double? paidAmount,
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
      paidAmount: paidAmount ?? this.paidAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'shopName': shopName,
      'cityId': cityId,
      'items': items.map((i) => i.toJson()).toList(),
      'subtotalAmount': subtotalAmount,
      'gstAmount': gstAmount,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'status': status.index,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      shopId: json['shopId'],
      shopName: json['shopName'],
      cityId: json['cityId'],
      items: (json['items'] as List).map((i) => OrderItem.fromJson(i)).toList(),
      subtotalAmount: json['subtotalAmount'],
      gstAmount: (json['gstAmount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      status: OrderStatus.values[json['status'] ?? 0],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
