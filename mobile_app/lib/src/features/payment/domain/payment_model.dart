
enum PaymentStatus { pending, partiallyPaid, paid }
enum PaymentMode { cash, upi, bankTransfer, check, credit }

class Payment {
  final String paymentId;
  final String invoiceId;
  final String shopId;
  final String shopName;
  final double totalBillAmount;
  final double amountReceived;
  final DateTime? lastPaymentDate;
  final PaymentMode? lastPaymentMode;
  
  // Computed
  double get balanceAmount => totalBillAmount - amountReceived;
  
  PaymentStatus get status {
    if (amountReceived >= totalBillAmount) return PaymentStatus.paid;
    if (amountReceived > 0) return PaymentStatus.partiallyPaid;
    return PaymentStatus.pending;
  }

  Payment({
    required this.paymentId,
    required this.invoiceId,
    required this.shopId,
    required this.shopName,
    required this.totalBillAmount,
    this.amountReceived = 0.0,
    this.lastPaymentDate,
    this.lastPaymentMode,
  });

  Payment copyWith({
    String? paymentId,
    String? invoiceId,
    String? shopId,
    String? shopName,
    double? totalBillAmount,
    double? amountReceived,
    DateTime? lastPaymentDate,
    PaymentMode? lastPaymentMode,
  }) {
    return Payment(
      paymentId: paymentId ?? this.paymentId,
      invoiceId: invoiceId ?? this.invoiceId,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      totalBillAmount: totalBillAmount ?? this.totalBillAmount,
      amountReceived: amountReceived ?? this.amountReceived,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      lastPaymentMode: lastPaymentMode ?? this.lastPaymentMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'invoiceId': invoiceId,
      'shopId': shopId,
      'shopName': shopName,
      'totalBillAmount': totalBillAmount,
      'amountReceived': amountReceived,
      'lastPaymentDate': lastPaymentDate?.toIso8601String(),
      'lastPaymentMode': lastPaymentMode?.index,
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['paymentId'],
      invoiceId: json['invoiceId'],
      shopId: json['shopId'],
      shopName: json['shopName'],
      totalBillAmount: json['totalBillAmount'],
      amountReceived: json['amountReceived'],
      lastPaymentDate: json['lastPaymentDate'] != null ? DateTime.parse(json['lastPaymentDate']) : null,
      lastPaymentMode: json['lastPaymentMode'] != null ? PaymentMode.values[json['lastPaymentMode']] : null,
    );
  }
}
