import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../domain/invoice_model.dart';
import '../data/invoice_service.dart';
import '../../payment/data/payment_service.dart';
import 'package:go_router/go_router.dart';

class InvoiceScreen extends ConsumerWidget {
  final String orderId;

  const InvoiceScreen({required this.orderId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoice = ref.watch(invoiceProvider.notifier).getInvoiceByOrderId(orderId);

    if (invoice == null) {
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
               _showShareOptions(context, ref, invoice);
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.indianRupee),
            tooltip: 'View Payment Status',
            onPressed: () {
               final payment = ref.read(paymentProvider.notifier).getPaymentByInvoice(invoice.invoiceId);
               if (payment != null) {
                 context.push('/payment-details/${payment.paymentId}');
               } else {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No payment record found for this invoice (Mock Data mismatch)')));
                 // Fallback for demo: Go to list
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
                        Text('# ${invoice.invoiceId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Date: ${DateFormat('dd-MM-yyyy').format(invoice.invoiceDate)}', style: const TextStyle(fontSize: 12)),
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
                          Text(invoice.shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(invoice.shopAddress, style: const TextStyle(fontSize: 12)),
                          Text('GSTIN: ${invoice.shopGST}', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                     Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('DETAILS:', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Order ID: ...${invoice.orderId.substring(invoice.orderId.length - 6)}', style: const TextStyle(fontSize: 12)),
                          Text('Salesman: ${invoice.salesmanName}', style: const TextStyle(fontSize: 12)),
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
                    ...invoice.items.map((item) => TableRow(
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
                      Text('₹${invoice.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 4),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('CGST (9%):', style: TextStyle(fontSize: 12)),
                      Text('₹${(invoice.gstAmount / 2).toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                    ]),
                     Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('SGST (9%):', style: TextStyle(fontSize: 12)),
                      Text('₹${(invoice.gstAmount / 2).toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                    ]),
                    const SizedBox(height: 12),
                    Divider(color: Colors.black.withOpacity(0.5)),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('GRAND TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('₹${invoice.grandTotal.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).primaryColor)),
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

  void _showShareOptions(BuildContext context, WidgetRef ref, Invoice invoice) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             const Text('Share Invoice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
             const SizedBox(height: 16),
             ListTile(
               leading: const Icon(LucideIcons.fileText),
               title: const Text('Share as PDF'),
               onTap: () async {
                 Navigator.pop(context);
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating PDF...')));
                 await ref.read(invoiceShareProvider).shareInvoicePdf(invoice);
                 if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice shared successfully (Mock)')));
               },
             ),
             ListTile(
               leading: const Icon(LucideIcons.image),
               title: const Text('Share as Image'),
                onTap: () async {
                 Navigator.pop(context);
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating Image...')));
                 await ref.read(invoiceShareProvider).shareInvoiceImage(invoice);
                 if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice shared successfully (Mock)')));
               },
             ),
           ],
        ),
      ),
    );
  }
}
