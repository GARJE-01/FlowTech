import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../order/domain/order_model.dart';
import '../../order/data/order_service.dart'; // To listen to orders? Or just call explicitly.
import '../domain/invoice_model.dart';

import 'package:printing/printing.dart'; // For sharing
import 'pdf_generator_service.dart'; // Generator

class InvoiceNotifier extends StateNotifier<List<Invoice>> {
  InvoiceNotifier() : super([]);

  // Generate Invoice from Order
  void generateInvoiceForOrder(Order order) {
    if (state.any((inv) => inv.orderId == order.id)) return; // Already exists

    final invoice = Invoice(
      invoiceId: 'FT-2026-${(state.length + 1001)}',
      orderId: order.id,
      shopName: order.shopName,
      shopAddress: '123, Market Road, ${order.cityId}', // Mock
      shopGST: '27ABCDE1234F1Z5', // Mock
      cityName: order.cityId, // Just using ID as name for now
      salesmanName: 'Aditya', // Mock user
      invoiceDate: DateTime.now(),
      items: order.items,
      subtotal: order.subtotalAmount,
      gstAmount: order.gstAmount,
      grandTotal: order.totalAmount,
    );

    state = [...state, invoice];
  }

  Invoice? getInvoiceByOrderId(String orderId) {
    return state.where((inv) => inv.orderId == orderId).firstOrNull;
  }
}

final invoiceProvider = StateNotifierProvider<InvoiceNotifier, List<Invoice>>((ref) {
  return InvoiceNotifier();
});


// ...
// Mock Share Service -> Real Share Service
final invoiceShareProvider = Provider((ref) => InvoiceShareService());

class InvoiceShareService {
  final _generator = PdfGeneratorService();

  Future<void> shareInvoicePdf(Invoice invoice) async {
    final bytes = await _generator.generateInvoicePdf(invoice);
    
    // Printing package handles the cross-platform share sheet
    await Printing.sharePdf(
      bytes: bytes, 
      filename: '${invoice.invoiceId}.pdf'
    );
  }
  
  Future<void> shareInvoiceImage(Invoice invoice) async {
     // TODO: Implement Image share (Convert PDF page to image using printing/pdf package)
     // For now, share PDF as fallback or mock
     await shareInvoicePdf(invoice); 
  }
}
