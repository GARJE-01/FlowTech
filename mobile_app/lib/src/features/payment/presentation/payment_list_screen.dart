import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/payment_service.dart';
import '../domain/payment_model.dart';

class PaymentListScreen extends ConsumerStatefulWidget {
  const PaymentListScreen({super.key});

  @override
  ConsumerState<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends ConsumerState<PaymentListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allPayments = ref.watch(paymentProvider);
    
    // Filter logic
    List<Payment> filteredPayments = _filterPayments(allPayments, _tabController.index);
    filteredPayments = filteredPayments.where((p) => 
       p.shopName.toLowerCase().contains(_searchQuery.toLowerCase()) || 
       p.invoiceId.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) => setState(() {}),
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Partially Paid'),
            Tab(text: 'Paid'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Shop or Invoice #',
                prefixIcon: const Icon(LucideIcons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (val) {
                setState(() {
                   _searchQuery = val;
                });
              },
            ),
          ),
          
          // List
          Expanded(
            child: filteredPayments.isEmpty 
            ? const Center(child: Text('No payments found'))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredPayments.length,
                itemBuilder: (context, index) {
                  final payment = filteredPayments[index];
                  return _buildPaymentCard(context, payment);
                },
              ),
          ),
        ],
      ),
    );
  }

  // --- Filter Helpers ---
  List<Payment> _filterPayments(List<Payment> all, int tabIndex) {
    switch (tabIndex) {
      case 1: return all.where((p) => p.status == PaymentStatus.pending).toList();
      case 2: return all.where((p) => p.status == PaymentStatus.partiallyPaid).toList();
      case 3: return all.where((p) => p.status == PaymentStatus.paid).toList();
      default: return all;
    }
  }

  Widget _buildPaymentCard(BuildContext context, Payment payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          context.push('/payment-details/${payment.paymentId}');
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
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(payment.shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                       Text(payment.invoiceId, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                     ],
                   ),
                   _buildStatusBadge(payment.status),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Bill', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      Text('₹${payment.totalBillAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Balance Due', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      Text(
                        '₹${payment.balanceAmount.toStringAsFixed(0)}', 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: payment.balanceAmount > 0 ? Colors.red : Colors.green
                        )
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(PaymentStatus status) {
    Color color;
    String label;
    switch (status) {
      case PaymentStatus.paid: 
        color = Colors.green; 
        label = 'PAID'; 
        break;
      case PaymentStatus.partiallyPaid: 
        color = Colors.orange; 
        label = 'PARTIAL'; 
        break;
      case PaymentStatus.pending: 
        color = Colors.red; 
        label = 'PENDING'; 
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }
}
