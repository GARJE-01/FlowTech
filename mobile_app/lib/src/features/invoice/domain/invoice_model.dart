import '../../order/domain/order_model.dart';
import '../../order/domain/order_item_model.dart';

class Invoice {
  final String invoiceId;
  final String orderId;
  final String shopName;
  final String shopAddress; // Mock
  final String shopGST; // Mock
  final String cityName;
  final String salesmanName;
  final DateTime invoiceDate;
  final List<OrderItem> items;
  final double subtotal;
  final double gstAmount;
  final double grandTotal;

  Invoice({
    required this.invoiceId,
    required this.orderId,
    required this.shopName,
    required this.shopAddress,
    required this.shopGST,
    required this.cityName,
    required this.salesmanName,
    required this.invoiceDate,
    required this.items,
    required this.subtotal,
    required this.gstAmount,
    required this.grandTotal,
  });
}
