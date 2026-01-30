import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../city/data/city_service.dart'; // To filter by selected city
import '../../../core/storage/storage_service.dart';
import '../domain/shop_model.dart';

// Mock Data
final _initialShops = [
  Shop(
    id: '1',
    name: 'Chanderai General Stores',
    ownerName: 'Ramesh Gupta',
    mobileNumber: '9876543210',
    address: 'Main Bazaar',
    cityId: '1', // Chanderai
    gstNumber: '27AAAAA1111A1Z5',
    status: ShopStatus.active,
  ),
  Shop(
    id: '2',
    name: 'Jakadevi Hardware',
    ownerName: 'Suresh Sharma',
    mobileNumber: '9988776655',
    address: 'Near Bus Stand',
    cityId: '2', // Jakadevi
    status: ShopStatus.active,
  ),
  Shop(
    id: '3',
    name: 'Devrukh Electronics',
    ownerName: 'Vijay Laxmi',
    mobileNumber: '9898989898',
    address: 'Shop 12, Market Yard',
    cityId: '3', // Devrukh
    gstNumber: '27BBBBB2222B1Z6',
    status: ShopStatus.inactive,
  ),
   Shop(
    id: '4',
    name: 'Jaigad Traders',
    ownerName: 'Anil Patil',
    mobileNumber: '9000000000',
    address: 'Port Road',
    cityId: '4', // Jaigad
    status: ShopStatus.active,
  ),
];

class ShopService extends StateNotifier<List<Shop>> {
  final StorageService _storage;

  ShopService(this._storage) : super([]) {
    _loadShops();
  }

  void _loadShops() {
    final loaded = _storage.loadShops();
    if (loaded.isNotEmpty) {
      state = loaded;
    } else {
      // First run: Use mock data and save it
      state = _initialShops;
      _storage.saveShops(_initialShops);
    }
  }

  void addShop(Shop shop) {
    state = [...state, shop];
    _storage.saveShops(state);
  }

  void updateShopStatus(String id, ShopStatus status) {
    state = [
      for (final shop in state)
        if (shop.id == id) shop.copyWith(status: status) else shop
    ];
    _storage.saveShops(state);
  }

  // Soft delete / Deactivate
  void deactivateShop(String id) {
    updateShopStatus(id, ShopStatus.inactive);
  }
}

final storageServiceProvider = FutureProvider<StorageService>((ref) async {
  return await StorageService.init();
});

final shopProvider = StateNotifierProvider<ShopService, List<Shop>>((ref) {
  // We need to wait for storage to be ready. 
  // However, StateNotifier provider cannot be async directly for initialization in a simple way
  // without using AsyncValue or initializing in main.
  // For simplicity, we assume main.dart initializes a strictly synchronous provider via override 
  // OR we use Ref to read storage. 
  // Better approach: Let's assume storage is initialized in main and passed down via a simple Provider 
  // that throws if not ready (UnimplementedError) or better, we update main.dart to `overrides` it.
  
  throw UnimplementedError('StorageService must be overridden in main.dart');
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
