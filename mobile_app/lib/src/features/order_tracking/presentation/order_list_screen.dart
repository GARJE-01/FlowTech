import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../order/domain/order_model.dart';
import '../../order/data/order_service.dart';
import '../../city/data/city_service.dart';

class OrderListScreen extends ConsumerStatefulWidget {
  const OrderListScreen({super.key});

  @override
  ConsumerState<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cityState = ref.watch(cityProvider);
    final allOrders = ref.watch(orderListProvider);
    
    // Filter by city
    final cityOrders = allOrders.where((o) => o.cityId == cityState.selectedCity?.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Draft'),
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(cityOrders, OrderStatus.draft),
          _buildOrderList(cityOrders, OrderStatus.pending),
          _buildOrderList(cityOrders, OrderStatus.approved),
          _buildOrderList(cityOrders, OrderStatus.rejected),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<Order> allOrders, OrderStatus status) {
    final orders = allOrders.where((o) => o.status == status).toList();
    
    // Sort by Date Descending
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.fileX, size: 64, color: Colors.grey[300]),
             const SizedBox(height: 16),
            Text('No ${status.name} orders found.', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildOrderCard(context, orders[index]);
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    Color statusColor;
    Color statusBgColor;

    switch (order.status) {
      case OrderStatus.approved:
        statusColor = Colors.green;
        statusBgColor = Colors.green.withOpacity(0.1);
        break;
      case OrderStatus.rejected:
        statusColor = Colors.red;
        statusBgColor = Colors.red.withOpacity(0.1);
        break;
      case OrderStatus.pending:
        statusColor = Colors.orange;
        statusBgColor = Colors.orange.withOpacity(0.1);
        break;
      case OrderStatus.draft:
      default:
        statusColor = Colors.grey;
        statusBgColor = Colors.grey.withOpacity(0.1);
        break;
    }

    return Card(
      child: InkWell(
        onTap: () {
          // Navigate to details
          context.push('/orders/${order.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.shopName, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      order.status.name.toUpperCase(), 
                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ID: ...${order.id.substring(order.id.length - 6)}', 
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)
                  ),
                  Text(
                    DateFormat('MMM dd, hh:mm a').format(order.createdAt),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${order.items.length} Items', style: TextStyle(color: Colors.grey[600])),
                  Text(
                    '₹${order.totalAmount.toStringAsFixed(0)}', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).primaryColor)
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
