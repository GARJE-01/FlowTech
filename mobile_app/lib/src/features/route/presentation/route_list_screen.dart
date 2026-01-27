import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/visit_service.dart';
import '../domain/visit_model.dart';
import 'visit_action_sheet.dart';

class RouteListScreen extends ConsumerStatefulWidget {
  const RouteListScreen({super.key});

  @override
  ConsumerState<RouteListScreen> createState() => _RouteListScreenState();
}

class _RouteListScreenState extends ConsumerState<RouteListScreen> {
  @override
  void initState() {
    super.initState();
    // Defer the provider reading to next frame to avoid build state issues if triggered immediately?
    // Actually safe to call read in initState for events usually.
    // However, since it depends on other providers, let's use postFrameCallback or just call it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(visitProvider.notifier).generateDailyRoute();
    });
  }

  void _showActionSheet(Visit visit) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => VisitActionSheet(visit: visit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visits = ref.watch(todayVisitsProvider);
    final visitedCount = visits.where((v) => v.status != VisitStatus.notVisited).length;
    final totalCount = visits.length;
    final progress = totalCount > 0 ? visitedCount / totalCount : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Route"),
      ),
      body: Column(
        children: [
          // 1. Progress Bar
          if (totalCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: Colors.white,
              child: Column(
                children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text('Progress', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                       Text('$visitedCount / $totalCount Visited', style: const TextStyle(fontWeight: FontWeight.bold)),
                     ],
                   ),
                   const SizedBox(height: 8),
                   LinearProgressIndicator(
                     value: progress,
                     backgroundColor: Colors.grey[200],
                     minHeight: 8,
                     borderRadius: BorderRadius.circular(4),
                   ),
                ],
              ),
            ),
          const SizedBox(height: 8),

          // 2. Visit List
          Expanded(
            child: visits.isEmpty
              ? const Center(child: Text('No route scheduled for today.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: visits.length,
                  itemBuilder: (context, index) {
                    final visit = visits[index];
                    return _buildVisitCard(context, visit);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitCard(BuildContext context, Visit visit) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (visit.status) {
      case VisitStatus.visited:
        statusColor = Colors.blue;
        statusText = 'Visited';
        statusIcon = LucideIcons.checkCircle;
        break;
      case VisitStatus.orderPlaced:
        statusColor = Colors.green;
        statusText = 'Order Placed';
        statusIcon = LucideIcons.shoppingBag;
        break;
      case VisitStatus.notVisited:
      default:
        statusColor = Colors.grey;
        statusText = 'Not Visited';
        statusIcon = LucideIcons.circle;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showActionSheet(visit),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
               // Status Indicator
               CircleAvatar(
                 backgroundColor: statusColor.withOpacity(0.1),
                 foregroundColor: statusColor,
                 child: Icon(statusIcon, size: 20),
               ),
               const SizedBox(width: 16),
               
               // Details
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(visit.shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                     const SizedBox(height: 4),
                     Row(
                       children: [
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                           decoration: BoxDecoration(
                             color: statusColor.withOpacity(0.1),
                             borderRadius: BorderRadius.circular(4),
                           ),
                           child: Text(
                             statusText, 
                             style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)
                           ),
                         ),
                         if (visit.lastVisitDateTime != null) ...[
                           const SizedBox(width: 8),
                           Text(
                             '•  ${DateFormat('hh:mm a').format(visit.lastVisitDateTime!)}',
                             style: TextStyle(color: Colors.grey[500], fontSize: 12),
                           ),
                         ]
                       ],
                     ),
                   ],
                 ),
               ),
               
               const Icon(LucideIcons.moreVertical, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
