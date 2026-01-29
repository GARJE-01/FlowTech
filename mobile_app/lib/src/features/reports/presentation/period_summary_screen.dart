import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../reports/data/reports_service.dart';
import 'widgets/simple_chart_widgets.dart';

class PeriodSummaryScreen extends ConsumerStatefulWidget {
  final String periodType; // 'weekly', 'monthly'

  const PeriodSummaryScreen({required this.periodType, super.key});

  @override
  ConsumerState<PeriodSummaryScreen> createState() => _PeriodSummaryScreenState();
}

class _PeriodSummaryScreenState extends ConsumerState<PeriodSummaryScreen> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _calculateDateRange();
  }

  void _calculateDateRange() {
    final now = DateTime.now();
    if (widget.periodType == 'weekly') {
      // Last 7 days
      _endDate = now;
      _startDate = now.subtract(const Duration(days: 6));
    } else {
      // This Month
      _endDate = now;
      _startDate = DateTime(now.year, now.month, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportService = ref.watch(reportsServiceProvider);
    final summary = reportService.getPeriodSummary(_startDate, _endDate);

    final title = widget.periodType == 'weekly' ? 'Weekly Analysis' : 'Monthly Overview';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
               '${DateFormat('dd MMM').format(_startDate)} - ${DateFormat('dd MMM yyyy').format(_endDate)}',
               style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
             ),
             const SizedBox(height: 24),

             // Summary Cards
             Row(
               children: [
                 Expanded(
                   child: _buildBigStatCard('Total Revenue', '₹${summary.totalRevenue.toStringAsFixed(0)}', Colors.green),
                 ),
                 const SizedBox(width: 16),
                 Expanded(
                   child: _buildBigStatCard('Total Orders', '${summary.totalOrders}', Colors.blue),
                 ),
               ],
             ),
             
             const SizedBox(height: 32),

             // Revenue Trend
             const Text('Revenue Trend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
             const SizedBox(height: 16),
             Container(
               padding: const EdgeInsets.all(20),
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: Colors.grey[200]!),
               ),
               child: SimpleTrendChart(
                 data: [
                   // Mock trend data based on summary for visual
                   summary.totalRevenue * 0.2,
                   summary.totalRevenue * 0.5,
                   summary.totalRevenue * 0.3,
                   summary.totalRevenue * 0.8,
                   summary.totalRevenue,
                 ],
                 lineColor: Colors.teal,
                 height: 120,
               ),
             ),

             const SizedBox(height: 32),
             
             // Top Shops List
             const Text('Top Performing Shops', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
             const SizedBox(height: 12),
             if (summary.topShops.isEmpty)
                const Padding(padding: EdgeInsets.all(16), child: Text('No data available')),
             
             ...summary.topShops.map((shop) => Container(
               margin: const EdgeInsets.only(bottom: 8),
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: Colors.grey[100]!),
               ),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(shop.shopName, style: const TextStyle(fontWeight: FontWeight.bold)),
                       Text('${shop.totalOrders} Orders', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                     ],
                   ),
                   Text('₹${shop.totalRevenue.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                 ],
               ),
             )),
          ],
        ),
      ),
    );
  }

  Widget _buildBigStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
           const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
