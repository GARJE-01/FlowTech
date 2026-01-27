import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/shop_service.dart';
import '../domain/shop_model.dart';
import '../../city/data/city_service.dart';

class ShopListScreen extends ConsumerStatefulWidget {
  const ShopListScreen({super.key});

  @override
  ConsumerState<ShopListScreen> createState() => _ShopListScreenState();
}

class _ShopListScreenState extends ConsumerState<ShopListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cityState = ref.watch(cityProvider);
    final allCityShops = ref.watch(filteredShopsProvider(_searchQuery));
    
    // Split into active/inactive for tabs
    final activeShops = allCityShops.where((s) => s.status == ShopStatus.active).toList();
    final inactiveShops = allCityShops.where((s) => s.status == ShopStatus.inactive).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Shops'),
            if (cityState.selectedCity != null)
              Text(
                cityState.selectedCity!.name,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Active (${activeShops.length})'),
            Tab(text: 'Inactive (${inactiveShops.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search shops...',
                prefixIcon: const Icon(LucideIcons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val);
              },
            ),
          ),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildShopList(activeShops),
                _buildShopList(inactiveShops),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/shops/add'),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Add Shop'),
      ),
    );
  }

  Widget _buildShopList(List<Shop> shops) {
    if (shops.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.store, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No shops found', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: shops.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final shop = shops[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[100],
              child: Text(shop.name[0].toUpperCase()),
            ),
            title: Text(shop.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(shop.ownerName),
                const SizedBox(height: 2),
                Text(shop.mobileNumber, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
            trailing: const Icon(LucideIcons.chevronRight, size: 16),
            onTap: () => context.push('/shops/${shop.id}'),
          ),
        );
      },
    );
  }
}
