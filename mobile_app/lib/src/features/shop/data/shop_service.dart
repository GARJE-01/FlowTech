import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../city/data/city_service.dart'; // To filter by selected city
import '../domain/shop_model.dart';

// Mock Data
final _initialShops = [
  Shop(
    id: '1',
    name: 'Gupta General Store',
    ownerName: 'Ramesh Gupta',
    mobileNumber: '9876543210',
    address: '123 Market Road',
    cityId: '1', // Mumbai
    gstNumber: '27AAAAA1111A1Z5',
    status: ShopStatus.active,
  ),
  Shop(
    id: '2',
    name: 'Sharma Hardware',
    ownerName: 'Suresh Sharma',
    mobileNumber: '9988776655',
    address: '45 Station Area',
    cityId: '1', // Mumbai
    status: ShopStatus.active,
  ),
  Shop(
    id: '3',
    name: 'Laxmi Electronics',
    ownerName: 'Vijay Laxmi',
    mobileNumber: '9898989898',
    address: 'Shop 12, City Mall',
    cityId: '1', // Mumbai
    gstNumber: '27BBBBB2222B1Z6',
    status: ShopStatus.inactive,
  ),
   Shop(
    id: '4',
    name: 'Pune Traders',
    ownerName: 'Anil Patil',
    mobileNumber: '9000000000',
    address: 'JM Road',
    cityId: '2', // Pune
    status: ShopStatus.active,
  ),
];

class ShopService extends StateNotifier<List<Shop>> {
  ShopService() : super(_initialShops);

  void addShop(Shop shop) {
    state = [...state, shop];
  }

  void updateShopStatus(String id, ShopStatus status) {
    state = [
      for (final shop in state)
        if (shop.id == id) shop.copyWith(status: status) else shop
    ];
  }

  // Soft delete / Deactivate
  void deactivateShop(String id) {
    updateShopStatus(id, ShopStatus.inactive);
  }
}

final shopProvider = StateNotifierProvider<ShopService, List<Shop>>((ref) {
  return ShopService();
});

// Derived provider: Shops for the currently selected city
final cityShopsProvider = Provider<List<Shop>>((ref) {
  final allShops = ref.watch(shopProvider);
  final cityState = ref.watch(cityProvider);
  
  if (cityState.selectedCity == null) return [];

  return allShops.where((shop) => shop.cityId == cityState.selectedCity!.id).toList();
});

// Derived provider: Filtered shops (e.g. by status or search query)
final filteredShopsProvider = Provider.family<List<Shop>, String>((ref, query) {
  final shops = ref.watch(cityShopsProvider);
  if (query.isEmpty) return shops;
  return shops.where((s) => s.name.toLowerCase().contains(query.toLowerCase())).toList();
});
