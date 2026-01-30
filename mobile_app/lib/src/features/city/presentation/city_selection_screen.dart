import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../city/data/city_service.dart';
import '../../city/domain/city.dart';

class CitySelectionScreen extends ConsumerStatefulWidget {
  const CitySelectionScreen({super.key});

  @override
  ConsumerState<CitySelectionScreen> createState() => _CitySelectionScreenState();
}

class _CitySelectionScreenState extends ConsumerState<CitySelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  City? _localSelectedCity;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Initialize with current selection if available
    _localSelectedCity = ref.read(cityProvider).selectedCity;
  }

  @override
  Widget build(BuildContext context) {
    final cityState = ref.watch(cityProvider);
    final filteredCities = cityState.availableCities.where((city) {
      return city.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select City'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                hintText: 'Search cities...',
                prefixIcon: Icon(LucideIcons.search),
              ),
            ),
          ),

          // City List
          Expanded(
            child: cityState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredCities.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final city = filteredCities[index];
                      final isSelected = _localSelectedCity?.id == city.id;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _localSelectedCity = city;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // Reduced padding
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(8), // Slightly smaller radius
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[300]!,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.mapPin,
                                size: 18, // Smaller icon
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  city.name,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith( // Smaller text style
                                        fontWeight:
                                            isSelected ? FontWeight.bold : FontWeight.w500,
                                      ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  LucideIcons.checkCircle,
                                  size: 18, // Smaller check icon
                                  color: Theme.of(context).primaryColor,
                                )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Continue Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _localSelectedCity == null
                    ? null
                    : () async {
                        // Save choice to global state
                        await ref.read(cityProvider.notifier).setCity(_localSelectedCity!);
                        
                        if (mounted) {
                           // Navigate to Dashboard (Placeholder)
                           context.go('/dashboard');
                        }
                      },
                child: const Text('Continue'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
