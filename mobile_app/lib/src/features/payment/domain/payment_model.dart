
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
}
