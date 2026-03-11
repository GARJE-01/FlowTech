import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../order/data/order_service.dart';
import '../../order/domain/order_model.dart';
import '../../payment/data/payment_service.dart';
import 'package:go_router/go_router.dart';

class InvoiceScreen extends ConsumerWidget {
  final String orderId;

  const InvoiceScreen({required this.orderId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allOrders = ref.watch(orderListProvider);
    final Order? order = allOrders.where((o) => o.id == orderId).firstOrNull;

    if (order == null || order.status != OrderStatus.approved) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invoice')),
        body: const Center(child: Text('Invoice not found or not generated yet.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Preview'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.share2),
            onPressed: () {
               // Mock share implementation -> Could pass order to a new orderShareProvider
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share functionality coming soon')));
               // _showShareOptions(context, ref, order);
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.indianRupee),
            tooltip: 'View Payment Status',
            onPressed: () {
               // We would look up payment by order.id ideally, but for now mock navigation
               final payment = ref.read(paymentProvider).where((p) => p.invoiceId == order.id).firstOrNull;
               if (payment != null) {
                 context.push('/payment-details/${payment.paymentId}');
               } else {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No payment record found for this order')));
                 context.push('/payments'); 
               }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Header ---
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.blue[50], // Light blue header
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FlowTech Agency', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).primaryColor)),
                         const SizedBox(height: 4),
                         const Text('123, Industrial Area', style: TextStyle(fontSize: 12)),
                         const Text('Pune, Maharashtra - 411057', style: TextStyle(fontSize: 12)),
                         const Text('Ph: +91 98765 43210', style: TextStyle(fontSize: 12)),
                         const Text('GSTIN: 27AABCT1332L1Z6', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('INVOICE', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text('# ...${order.id.substring(order.id.length - 6)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Date: ${DateFormat('dd-MM-yyyy').format(order.createdAt)}', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // --- Bill To ---
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('BILL TO:', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(order.shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Text('Address not provided', style: TextStyle(fontSize: 12)),
                          const Text('GSTIN: N/A', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                     Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('DETAILS:', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Order ID: ...${order.id.substring(order.id.length - 6)}', style: const TextStyle(fontSize: 12)),
                          const Text('Salesman: User', style: TextStyle(fontSize: 12)),
                          const Text('Terms: Credit (7 Days)', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- Items Table ---
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(3),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1.5),
                    3: FlexColumnWidth(1.5),
                  },
                  children: [
                    const TableRow(
                       children: [
                         Padding(padding: EdgeInsets.only(bottom: 8), child: Text('ITEM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                         Padding(padding: EdgeInsets.only(bottom: 8), child: Text('QTY', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                         Padding(padding: EdgeInsets.only(bottom: 8), child: Text('RATE', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                         Padding(padding: EdgeInsets.only(bottom: 8), child: Text('TOTAL', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                       ]
                    ),
                    ...order.items.map((item) => TableRow(
                      children: [
                        Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text(item.productName, style: const TextStyle(fontSize: 12))),
                        Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text('${item.quantity}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))),
                        Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text('₹${item.pricePerUnit}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12))),
                        Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text('₹${item.lineTotal}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12))),
                      ],
                    )),
                  ],
                ),
              ),
              const Divider(),

              // --- Totals ---
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Subtotal:', style: TextStyle(fontSize: 12)),
                      Text('₹${order.subtotalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 4),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('CGST (9%):', style: TextStyle(fontSize: 12)),
                      Text('₹${(order.gstAmount / 2).toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                    ]),
                     Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('SGST (9%):', style: TextStyle(fontSize: 12)),
                      Text('₹${(order.gstAmount / 2).toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                    ]),
                    const SizedBox(height: 12),
                    Divider(color: Colors.black.withOpacity(0.5)),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('GRAND TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('₹${order.totalAmount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).primaryColor)),
                    ]),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              // --- Footer ---
              Container(
                color: Colors.grey[100],
                padding: const EdgeInsets.all(20),
                child: const Column(
                  children: [
                    Text('Thank you for your business!', style: TextStyle(fontStyle: FontStyle.italic)),
                    SizedBox(height: 8),
                    Text('Terms & Conditions: Goods once sold will not be taken back. Interest @ 18% p.a. will be charged if bill is not paid within due date.', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Placeholder for _showShareOptions if implemented later
}
