import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../domain/invoice_model.dart';
import '../../order/domain/order_item_model.dart';

class PdfGeneratorService {
  Future<Uint8List> generateInvoicePdf(Invoice invoice) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(invoice),
              pw.SizedBox(height: 20),
              _buildBillTo(invoice),
              pw.SizedBox(height: 20),
              _buildItemsTable(invoice),
              pw.SizedBox(height: 20),
              _buildTotals(invoice),
              pw.Spacer(),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(Invoice invoice) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('FlowTech Agency', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.Text('123, Industrial Area'),
            pw.Text('Pune, Maharashtra - 411057'),
            pw.Text('GSTIN: 27AABCT1332L1Z6', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('INVOICE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.grey)),
            pw.Text('# ${invoice.invoiceId}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Date: ${DateFormat('dd-MM-yyyy').format(invoice.invoiceDate)}'),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildBillTo(Invoice invoice) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('BILL TO:', style: pw.TextStyle(color: PdfColors.grey, fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.Text(invoice.shopName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.Text(invoice.shopAddress),
              pw.Text('GSTIN: ${invoice.shopGST}'),
            ],
          ),
        ),
        pw.Expanded(
           child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('DETAILS:', style: pw.TextStyle(color: PdfColors.grey, fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.Text('Salesman: ${invoice.salesmanName}'),
              pw.Text('Terms: Credit (7 Days)'),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildItemsTable(Invoice invoice) {
    return pw.Table.fromTextArray(
      headers: ['Item', 'Qty', 'Rate', 'Total'],
      data: invoice.items.map((item) => [
        item.productName,
        '${item.quantity}',
        '${item.pricePerUnit.toStringAsFixed(2)}',
        '${item.lineTotal.toStringAsFixed(2)}',
      ]).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
    );
  }

  pw.Widget _buildTotals(Invoice invoice) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          _buildTotalRow('Subtotal', invoice.subtotal),
          _buildTotalRow('CGST (9%)', invoice.gstAmount / 2),
          _buildTotalRow('SGST (9%)', invoice.gstAmount / 2),
          pw.Divider(),
          _buildTotalRow('Grand Total', invoice.grandTotal, isBold: true, fontSize: 14),
        ],
      ),
    );
  }

  pw.Widget _buildTotalRow(String label, double value, {bool isBold = false, double fontSize = 12}) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text('$label:  ', style: pw.TextStyle(fontSize: fontSize, fontWeight: isBold ? pw.FontWeight.bold : null)),
        pw.Text('${value.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: fontSize, fontWeight: isBold ? pw.FontWeight.bold : null)),
      ],
    );
  }

  pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.Text('Thank you for your business!', style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
        pw.Text('Terms & Conditions: Goods once sold will not be taken back.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
      ],
    );
  }
}
