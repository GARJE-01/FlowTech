import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../order/data/order_service.dart';
import '../../order/domain/order_model.dart';
import '../data/payment_service.dart';
import '../domain/payment_model.dart';
import 'package:go_router/go_router.dart';

class RecordPaymentScreen extends ConsumerStatefulWidget {
  final String orderId;

  const RecordPaymentScreen({required this.orderId, super.key});

  @override
  ConsumerState<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends ConsumerState<RecordPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  PaymentMode _selectedMode = PaymentMode.cash;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(orderListProvider).where((o) => o.id == widget.orderId).firstOrNull;

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Record Payment')),
        body: const Center(child: Text('Order not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Payment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary Card
              Card(
                elevation: 0,
                color: Colors.blue[50],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildSummaryRow('Shop', order.shopName),
                      const SizedBox(height: 8),
                      _buildSummaryRow('Order Total', '₹${order.totalAmount.toStringAsFixed(2)}'),
                      _buildSummaryRow('Already Paid', '₹${order.paidAmount.toStringAsFixed(2)}', color: Colors.green),
                      const Divider(height: 24),
                      _buildSummaryRow('Remaining Balance', '₹${order.balanceAmount.toStringAsFixed(2)}', 
                        isBold: true, color: Colors.red),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text('Payment Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Enter amount (e.g. 500.00)',
                  prefixIcon: const Icon(LucideIcons.indianRupee),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calculate_outlined),
                    tooltip: 'Full Amount',
                    onPressed: () {
                      _amountController.text = order.balanceAmount.toStringAsFixed(2);
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter amount';
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) return 'Enter a valid amount';
                  if (amount > order.balanceAmount + 0.01) return 'Amount exceeds balance';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              const Text('Payment Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                children: PaymentMode.values.map((mode) {
                  final isSelected = _selectedMode == mode;
                  return ChoiceChip(
                    label: Text(mode.name.toUpperCase()),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedMode = mode);
                    },
                    selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).primaryColor,
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _submitPayment(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('SUBMIT PAYMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
        Text(value, style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: isBold ? 16 : 14,
          color: color,
        )),
      ],
    );
  }

  Future<void> _submitPayment(Order order) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final amount = double.parse(_amountController.text);
    
    try {
      final success = await ref.read(paymentProvider.notifier).addPayment(
        orderId: order.id,
        shopId: order.shopId,
        amount: amount,
        mode: _selectedMode,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment recorded successfully!'), backgroundColor: Colors.green),
          );
          context.pop(); // Return to Bills
        }
      } else {
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to record payment. Please try again.'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
