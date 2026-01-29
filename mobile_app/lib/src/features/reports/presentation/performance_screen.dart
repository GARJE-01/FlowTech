import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../reports/data/reports_service.dart';

class PerformanceScreen extends ConsumerWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportService = ref.watch(reportsServiceProvider);
    final stats = reportService.getPerformanceStats();

    return Scaffold(
      appBar: AppBar(title: const Text('My Performance')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildStatTile(context, 'Total Order Volume', '${stats.totalOrdersPlaced} Orders', LucideIcons.layers, Colors.blue),
            const SizedBox(height: 16),
            _buildStatTile(context, 'Approval Rate', '${stats.approvalRate.toStringAsFixed(1)}%', LucideIcons.checkSquare, Colors.green),
            const SizedBox(height: 16),
            _buildStatTile(context, 'Average Order Value', '₹${stats.averageOrderValue.toStringAsFixed(0)}', LucideIcons.trendingUp, Colors.purple),
            const SizedBox(height: 16),
            _buildStatTile(context, 'Market Coverage', '${stats.shopsServed} Shops', LucideIcons.map, Colors.orange),
            const SizedBox(height: 16),
            _buildStatTile(context, 'Customer Retention', '${stats.repeatOrderPercentage.toStringAsFixed(1)}% Repeat', LucideIcons.repeat, Colors.teal),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0,4))],
      ),
      child: Row(
        children: [
           Container(
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
             child: Icon(icon, color: color, size: 28),
           ),
           const SizedBox(width: 20),
           Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
               const SizedBox(height: 4),
               Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
             ],
           )
        ],
      ),
    );
  }
}
