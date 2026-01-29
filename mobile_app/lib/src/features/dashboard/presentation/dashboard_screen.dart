import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../city/data/city_service.dart';
import '../../auth/data/auth_service.dart';
import '../../payment/data/payment_service.dart';
import '../../payment/domain/payment_model.dart';
import '../../notification/data/notification_service.dart';
// import '../../notification/domain/notification_model.dart'; // Already imported via service ideally or explicitly if needed

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCity = ref.watch(cityProvider).selectedCity;

    final user = ref.watch(authProvider).user;
    final payments = ref.watch(paymentProvider);
    final notifications = ref.watch(notificationProvider);
    final recentNotifications = notifications.take(3).toList();
    final pendingPaymentsCount = payments.where((p) => p.status == PaymentStatus.pending).length;
    final outstandingAmount = payments.fold(0.0, (sum, p) => sum + p.balanceAmount);

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background for contrast
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => context.push('/city-selection'),
                            child: Row(
                              children: [
                                Icon(LucideIcons.mapPin, size: 16, color: Theme.of(context).primaryColor),
                                const SizedBox(width: 4),
                                Text(
                                  selectedCity?.name ?? 'Select City',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(LucideIcons.chevronDown, size: 16, color: Colors.grey[400]),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hello, ${user?.name.split(' ')[0] ?? "Salesman"}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => context.go('/profile'),
                      borderRadius: BorderRadius.circular(50),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Text(
                          user?.name.substring(0, 1) ?? "U",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Summary Cards Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = (constraints.maxWidth - 16) / 2;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildSummaryCard(context, 'Total Shops', '25', LucideIcons.store, width),
                        _buildSummaryCard(context, 'Active Shops', '18', LucideIcons.checkCircle, width, color: Colors.green),
                        _buildSummaryCard(context, 'Orders Today', '4', LucideIcons.shoppingBag, width, color: Colors.blue),
                        _buildSummaryCard(context, 'Pending Payments', '$pendingPaymentsCount', LucideIcons.indianRupee, width, color: Colors.orange),
                      ],
                    );
                  }
                ),
              ),

              const SizedBox(height: 24),

              // 3. Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildActionButton(context, "Today's Route", LucideIcons.mapPin, () => context.push('/route'), isPrimary: true),
                    _buildActionButton(context, 'Shop List', LucideIcons.list, () => context.push('/shops')),
                    _buildActionButton(context, 'Add Shop', LucideIcons.plus, () => context.push('/shops/add')),
                    _buildActionButton(context, 'New Order', LucideIcons.shoppingCart, () => context.push('/order/select-shop')),
                    _buildActionButton(context, 'Orders', LucideIcons.fileText, () => context.push('/orders')),
                    _buildActionButton(context, 'Payments', LucideIcons.indianRupee, () => context.push('/payments')),
                    _buildActionButton(context, 'Bills', LucideIcons.receipt, () => context.push('/bills')),
                    _buildActionButton(context, 'Reports', LucideIcons.barChart, () => context.push('/reports'), isPrimary: true),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 4. Recent Notifications Preview
               Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notifications',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                         color: Colors.grey[800],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/notifications'),
                      child: Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (recentNotifications.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text("No new notifications", style: TextStyle(color: Colors.grey[400], fontStyle: FontStyle.italic)),
                )
              else
                ...recentNotifications.map((n) => _buildNotificationTile(context, n.id, n.title, n.message, _formatTime(n.timestamp))),


              const SizedBox(height: 24),

              // 5. Recent Shops / Activity
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Recent Shops',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                     color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) => _buildShopTile(context, index),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, IconData icon, double width, {Color? color}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
         boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 20, color: color ?? Colors.grey[600]),
              // Trend indicator mock
              if(title.contains("Orders"))
                 Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                   child: const Text('+2', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                 ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, VoidCallback onTap, {bool isPrimary = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isPrimary ? Theme.of(context).primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: isPrimary ? null : Border.all(color: Colors.grey[300]!),
                 boxShadow: isPrimary ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ] : null,
              ),
              child: Icon(
                icon,
                color: isPrimary ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, String id, String title, String subtitle, String time) {
    return InkWell(
      onTap: () => context.push('/notifications/$id'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8, 
              height: 8, 
              margin: const EdgeInsets.only(top: 6),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              )
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Text(time, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildShopTile(BuildContext context, int index) {
      final names = ['Gupta General Store', 'Sharma Hardware', 'Laxmi Electronics', 'Patil Traders', 'City Supermarket'];
      final owners = ['Ramesh Gupta', 'Suresh Sharma', 'Vijay Laxmi', 'Anil Patil', 'Rahul City'];
      
    return InkWell(
      onTap: () => context.push('/shops/$index'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
           border: Border.all(color: Colors.grey[100]!),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(names[index][0], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(names[index], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(owners[index], style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('Active', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${time.day}/${time.month}';
  }
}
