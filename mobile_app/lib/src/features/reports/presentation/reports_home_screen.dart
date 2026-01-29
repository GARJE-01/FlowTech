import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../city/data/city_service.dart';

class ReportsHomeScreen extends ConsumerWidget {
  const ReportsHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCity = ref.watch(cityProvider).selectedCity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          // City Badge (Read-only context)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.mapPin, size: 14, color: Theme.of(context).primaryColor),
                const SizedBox(width: 4),
                Text(
                  selectedCity?.name ?? 'All Cities',
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.bold, 
                    color: Theme.of(context).primaryColor
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Performance Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildReportCard(
              context, 
              title: 'Personal Performance', 
              subtitle: 'Approval rates, avg order value',
              icon: LucideIcons.userCheck, 
              color: Colors.purple,
              onTap: () => context.push('/reports/performance'),
            ),
            
            const SizedBox(height: 24),
            const Text('Time-Period Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildGridCard(context, 'Daily\nSummary', LucideIcons.calendar, Colors.blue, () => context.push('/reports/daily')),
                _buildGridCard(context, 'Weekly\nAnalysis', LucideIcons.barChart2, Colors.orange, () => context.push('/reports/period/weekly')),
                _buildGridCard(context, 'Monthly\nOverview', LucideIcons.pieChart, Colors.teal, () => context.push('/reports/period/monthly')),
              ],
            ),

            const SizedBox(height: 24),
            const Text('Operational Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
             _buildReportCard(
              context, 
              title: 'Shop-wise Report', 
              subtitle: 'Revenue & order counts by shop',
              icon: LucideIcons.store, 
              color: Colors.indigo,
              onTap: () => context.push('/reports/shops'),
            ),
            const SizedBox(height: 12),
             _buildReportCard(
              context, 
              title: 'Product-wise Report', 
              subtitle: 'Top selling products & stock',
              icon: LucideIcons.package, 
              color: Colors.pink,
              onTap: () => context.push('/reports/products'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                 child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}
