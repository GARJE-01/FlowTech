import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../data/shop_service.dart';
import '../domain/shop_model.dart';
import '../../city/data/city_service.dart';

class AddShopScreen extends ConsumerStatefulWidget {
  const AddShopScreen({super.key});

  @override
  ConsumerState<AddShopScreen> createState() => _AddShopScreenState();
}

class _AddShopScreenState extends ConsumerState<AddShopScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ownerController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _gstController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final cityState = ref.read(cityProvider);
      
      if (cityState.selectedCity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No city selected. Please select a city from the Dashboard first.')),
        );
        return;
      }

      setState(() => _isLoading = true);

      // Simulate a small delay for UX
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;

        final newShop = Shop(
          id: const Uuid().v4(),
          name: _nameController.text.trim(),
          ownerName: _ownerController.text.trim(),
          mobileNumber: _mobileController.text.trim(),
          address: _addressController.text.trim(),
          gstNumber: _gstController.text.trim().isEmpty ? null : _gstController.text.trim(),
          cityId: cityState.selectedCity!.id,
          status: ShopStatus.active,
        );

        ref.read(shopProvider.notifier).addShop(newShop);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Shop "${newShop.name}" added successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        context.pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
     final cityState = ref.watch(cityProvider);
     final cityName = cityState.selectedCity?.name ?? 'No City Selected';
     final isCitySelected = cityState.selectedCity != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Shop')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner if no city selected
              if (!isCitySelected)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(child: Text('You must select a city from the Dashboard before adding a shop.', style: TextStyle(color: Colors.red[900]))),
                    ],
                  ),
                ),

              // Read-only City Field
              TextFormField(
                initialValue: cityName,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'City',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[100],
                  prefixIcon: const Icon(Icons.location_city),
                  enabled: false, // Make it look disabled
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Shop Name', 
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) => v == null || v.trim().isEmpty ? 'Shop name is required' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _ownerController,
                decoration: const InputDecoration(
                   labelText: 'Owner Name', 
                   border: OutlineInputBorder(),
                   prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) => v == null || v.trim().isEmpty ? 'Owner name is required' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number', 
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                  hintText: '10 digit mobile number',
                ),
                keyboardType: TextInputType.phone,
                maxLength: 10,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Mobile number is required';
                  if (v.length != 10 || int.tryParse(v) == null) return 'Enter a valid 10-digit number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _gstController,
                decoration: const InputDecoration(
                  labelText: 'GST Number (Optional)', 
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.receipt),
                  hintText: 'e.g. 27ABCDE1234F1Z5',
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address', 
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.map),
                ),
                maxLines: 3,
                validator: (v) => v == null || v.trim().isEmpty ? 'Address is required' : null,
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: (isCitySelected && !_isLoading) ? _submit : null,
                  child: _isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                    : const Text('Add Shop', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
