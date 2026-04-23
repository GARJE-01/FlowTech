import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../domain/visit_model.dart';
import '../data/visit_service.dart';
import '../../order/data/order_service.dart';

class VisitActionSheet extends ConsumerWidget {
  final Visit visit;

  const VisitActionSheet({required this.visit, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      // SafeArea for bottom
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24, 
        bottom: MediaQuery.of(context).viewInsets.bottom + 24
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(visit.shopName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Select an action for this shop visit.', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          
          if (visit.status == VisitStatus.notVisited)
            FilledButton.icon(
              onPressed: () {
                ref.read(visitProvider.notifier).markVisited(visit.id);
                context.pop();
              },
              icon: const Icon(LucideIcons.checkCircle),
              label: const Text('Mark as Visited'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: () {
              // Initialize Draft Order
              ref.read(draftOrderProvider.notifier).startNewDraft(
                shopId: visit.shopId,
                shopName: visit.shopName,
                cityId: visit.cityId,
              );
              
              context.pop();
              context.push('/products'); 
            },
            icon: const Icon(LucideIcons.shoppingCart),
            label: const Text('Place Order'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
          
          const SizedBox(height: 12),
          
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
