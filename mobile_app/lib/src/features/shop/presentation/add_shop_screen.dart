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

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final cityState = ref.read(cityProvider);
      
      if (cityState.selectedCity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No city selected')),
        );
        return;
      }

      final newShop = Shop(
        id: Uuid().v4(),
        name: _nameController.text.trim(),
        ownerName: _ownerController.text.trim(),
        mobileNumber: _mobileController.text.trim(),
        address: _addressController.text.trim(),
        cityId: cityState.selectedCity!.id,
      );

      ref.read(shopProvider.notifier).addShop(newShop);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Shop "${newShop.name}" added successfully!')),
      );

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
     final cityState = ref.watch(cityProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Shop')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Read-only City Field
              TextFormField(
                initialValue: cityState.selectedCity?.name ?? 'Unknown',
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Shop Name', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _ownerController,
                decoration: const InputDecoration(labelText: 'Owner Name', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v.length < 10) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              
              FilledButton(
                onPressed: _submit,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Add Shop'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
