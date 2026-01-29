import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../reports/data/reports_service.dart';

class ShopReportScreen extends ConsumerWidget {
  const ShopReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportService = ref.watch(reportsServiceProvider);
    final reports = reportService.getShopReports();

    return Scaffold(
      appBar: AppBar(title: const Text('Shop Reports')),
      body: reports.isEmpty
          ? const Center(child: Text('No shop data available'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final shop = reports[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.withOpacity(0.1),
                      child: Text(shop.shopName[0], style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(shop.shopName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          Icon(LucideIcons.shoppingBag, size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text('${shop.totalOrders} Orders', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹${shop.totalRevenue.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                        const SizedBox(height: 2),
                        const Text('Total Revenue', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                    onTap: () {
                         // Drill down to shop details (optional, reusing shop feature or simplified view)
                         // For now just valid tap
                    },
                  ),
                );
              },
            ),
    );
  }
}
