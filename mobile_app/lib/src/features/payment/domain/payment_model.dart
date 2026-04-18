enum PaymentMode { cash, upi, bankTransfer, check, credit }

class Payment {
  final String id;
  final String orderId;
  final String shopId;
  final String salesmanId;
  final double amount;
  final PaymentMode paymentMode;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.orderId,
    required this.shopId,
    required this.salesmanId,
    required this.amount,
    required this.paymentMode,
    required this.createdAt,
  });

  Payment copyWith({
    String? id,
    String? orderId,
    String? shopId,
    String? salesmanId,
    double? amount,
    PaymentMode? paymentMode,
    DateTime? createdAt,
  }) {
    return Payment(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      shopId: shopId ?? this.shopId,
      salesmanId: salesmanId ?? this.salesmanId,
      amount: amount ?? this.amount,
      paymentMode: paymentMode ?? this.paymentMode,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'shopId': shopId,
      'salesmanId': salesmanId,
      'amount': amount,
      'paymentMode': paymentMode.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      orderId: json['orderId'] ?? json['order_id'],
      shopId: json['shopId']?.toString() ?? json['shop_id']?.toString() ?? '',
      salesmanId: json['salesmanId'] ?? json['salesman_id'],
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMode: _parsePaymentMode(json['paymentMode'] ?? json['payment_mode']),
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
    );
  }

  static PaymentMode _parsePaymentMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'cash': return PaymentMode.cash;
      case 'upi': return PaymentMode.upi;
      case 'bank':
      case 'banktransfer': return PaymentMode.bankTransfer;
      case 'check': return PaymentMode.check;
      case 'credit': return PaymentMode.credit;
      default: return PaymentMode.cash;
    }
  }
}
