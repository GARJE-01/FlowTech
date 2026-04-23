import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../order/data/order_service.dart';
import '../../order/domain/order_model.dart';
import '../../auth/data/auth_service.dart';
import '../../shop/data/shop_service.dart';
import '../../shop/domain/shop_model.dart';
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
            tooltip: 'Share Invoice',
            onPressed: () async {
              final shop = ref.read(shopProvider).where((s) => s.id == order.shopId).firstOrNull;
              final salesmanName = ref.read(authProvider).user?.name ?? 'Unknown Salesman';
              await _shareInvoice(context, order, shop, salesmanName);
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.indianRupee),
            tooltip: 'View Payment Status',
            onPressed: () {
               final orderPayments = ref.read(paymentProvider).where((p) => p.orderId == order.id).toList();
               if (orderPayments.isNotEmpty) {
                 showModalBottomSheet(
                   context: context,
                   shape: const RoundedRectangleBorder(
                     borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                   ),
                   builder: (context) {
                     return _buildPaymentHistorySheet(context, orderPayments, order);
                   }
                 );
               } else {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No payment record found for this order')));
                 context.go('/payments'); 
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
                          Consumer(
                            builder: (context, ref, child) {
                               final shop = ref.watch(shopProvider).where((s) => s.id == order.shopId).firstOrNull;
                               return Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Text('${order.shopName} (${shop?.ownerName ?? "Unknown Owner"})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                   Text(shop?.address ?? 'Address not provided', style: const TextStyle(fontSize: 12)),
                                 ],
                               );
                            }
                          ),
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
                          Consumer(
                            builder: (context, ref, _) {
                               final userName = ref.watch(authProvider).user?.name ?? 'Unknown Salesman';
                               return Text('Salesman: $userName', style: const TextStyle(fontSize: 12));
                            }
                          ),
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

// --- Share Invoice ---
  Future<void> _shareInvoice(BuildContext context, Order order, Shop? shop, String salesmanName) async {
    try {
      // Show loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Generating invoice PDF...'), duration: Duration(seconds: 1)),
        );
      }

      final pdf = pw.Document();
      final dateStr = DateFormat('dd-MM-yyyy').format(order.createdAt);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Header
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  color: PdfColors.blue50,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('FlowTech Agency', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18, color: PdfColors.blue700)),
                          pw.Text('123, Industrial Area', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('Pune, Maharashtra - 411057', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('Ph: +91 98765 43210', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('GSTIN: 27AABCT1332L1Z6', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('INVOICE', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.grey)),
                          pw.Text('# ...${order.id.substring(order.id.length - 6)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('Date: $dateStr', style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.Divider(),

                // Bill To
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('BILL TO:', style: pw.TextStyle(color: PdfColors.grey, fontSize: 9, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 4),
                          pw.Text('${order.shopName} (${shop?.ownerName ?? "Unknown"})', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
                          pw.Text(shop?.address ?? 'Address not provided', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('GSTIN: ${shop?.gstNumber ?? "N/A"}', style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('SALESMAN: $salesmanName', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('Terms: Credit (7 Days)', style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.Divider(),

                // Items Table
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 16),
                  child: pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(3),
                      1: const pw.FlexColumnWidth(1),
                      2: const pw.FlexColumnWidth(1.5),
                      3: const pw.FlexColumnWidth(1.5),
                    },
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('ITEM', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('QTY', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('RATE', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('TOTAL', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                        ],
                      ),
                      ...order.items.map((item) => pw.TableRow(
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(item.productName, style: const pw.TextStyle(fontSize: 10))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('${item.quantity}', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 10))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Rs.${item.pricePerUnit.toStringAsFixed(2)}', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 10))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Rs.${item.lineTotal.toStringAsFixed(2)}', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 10))),
                        ],
                      )),
                    ],
                  ),
                ),

                pw.SizedBox(height: 12),

                // Totals
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(right: 16),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Subtotal: Rs.${order.subtotalAmount.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 11)),
                        pw.Text('CGST (9%): Rs.${(order.gstAmount / 2).toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 11)),
                        pw.Text('SGST (9%): Rs.${(order.gstAmount / 2).toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 11)),
                        pw.Divider(),
                        pw.Text('GRAND TOTAL: Rs.${order.totalAmount.toStringAsFixed(0)}',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: PdfColors.blue700)),
                      ],
                    ),
                  ),
                ),

                pw.Spacer(),

                // Footer
                pw.Container(
                  color: PdfColors.grey100,
                  padding: const pw.EdgeInsets.all(14),
                  child: pw.Column(
                    children: [
                      pw.Text('Thank you for your business!', style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Terms & Conditions: Goods once sold will not be taken back. Interest @ 18% p.a. after due date.',
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Share via native sheet
      final pdfBytes = await pdf.save();
      await Printing.sharePdf(bytes: pdfBytes, filename: 'Invoice-${order.id}.pdf');

    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate invoice: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

// ---- Payment History Sheet ----

  Widget _buildPaymentHistorySheet(BuildContext context, List<dynamic> payments, Order order) {
    payments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Payment History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(LucideIcons.x), onPressed: () => Navigator.of(context).pop()),
            ],
          ),
          Text(
            'Remaining Balance: ₹${order.balanceAmount.toStringAsFixed(0)}',
            style: TextStyle(fontSize: 14, color: order.balanceAmount > 0 ? Colors.red : Colors.green),
          ),
          const Divider(),
          const SizedBox(height: 10),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: payments.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final payment = payments[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.withOpacity(0.1),
                    child: const Icon(LucideIcons.checkCircle2, color: Colors.green),
                  ),
                  title: Text('Amount: ₹${payment.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(DateFormat('dd MMM yy, hh:mm a').format(payment.createdAt)),
                  trailing: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/payment-details/${payment.id}');
                    },
                    child: const Text("View"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
