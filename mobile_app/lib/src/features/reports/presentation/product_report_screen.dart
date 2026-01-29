import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../reports/data/reports_service.dart';

class ProductReportScreen extends ConsumerWidget {
  const ProductReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportService = ref.watch(reportsServiceProvider);
    final reports = reportService.getProductReports();

    return Scaffold(
      appBar: AppBar(title: const Text('Product Performance')),
      body: reports.isEmpty
          ? const Center(child: Text('No product sales data available'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final product = reports[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: Colors.pink.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      alignment: Alignment.center,
                      child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.pink)),
                    ),
                    title: Text(product.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${product.ordersCount} transactions involving this item'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${product.quantitySold} Units', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('₹${product.totalRevenue.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
