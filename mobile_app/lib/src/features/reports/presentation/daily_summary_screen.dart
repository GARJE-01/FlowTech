import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../reports/data/reports_service.dart';
import 'widgets/simple_chart_widgets.dart';

class DailySummaryScreen extends ConsumerStatefulWidget {
  const DailySummaryScreen({super.key});

  @override
  ConsumerState<DailySummaryScreen> createState() => _DailySummaryScreenState();
}

class _DailySummaryScreenState extends ConsumerState<DailySummaryScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final reportService = ref.watch(reportsServiceProvider);
    final summary = reportService.getDailySummary(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Summary'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.calendar),
            onPressed: () => _pickDate(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Date Selector Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                     DateFormat('EEEE, dd MMM yyyy').format(_selectedDate),
                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                   ),
                   const Icon(LucideIcons.chevronDown, size: 16, color: Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Key Metrics
            Row(
              children: [
                Expanded(child: _buildMetricCard('Orders', '${summary.ordersPlaced}', LucideIcons.shoppingBag, Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildMetricCard('Visits', '${summary.shopsVisited}', LucideIcons.mapPin, Colors.green)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildMetricCard('Sales', '₹${summary.totalSales.toStringAsFixed(0)}', LucideIcons.indianRupee, Colors.orange)),
                const SizedBox(width: 16),
                Expanded(child: _buildMetricCard('Approved', '${summary.approvedOrders}', LucideIcons.checkCircle, Colors.purple)),
              ],
            ),

            const SizedBox(height: 32),
            
            // Charts Area
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Activity Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 24),
                  SimpleBarChart(
                    data: [
                      summary.shopsVisited.toDouble(),
                      summary.ordersPlaced.toDouble(),
                      summary.pendingOrders.toDouble(),
                      summary.approvedOrders.toDouble(),
                    ], 
                    labels: const ['Visits', 'Orders', 'Pending', 'Apprvd'],
                    barColor: Theme.of(context).primaryColor,
                    height: 180,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context, 
      initialDate: _selectedDate, 
      firstDate: DateTime(2020), 
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const Spacer(),
              // Icon(LucideIcons.arrowUpRight, size: 14, color: Colors.green),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}
