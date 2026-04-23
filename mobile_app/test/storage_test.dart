
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flowtech_salesman/src/core/storage/storage_service.dart';
import 'package:flowtech_salesman/src/features/shop/domain/shop_model.dart';
import 'package:flowtech_salesman/src/features/shop/data/shop_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('StorageService persists and loads shops', () async {
    // 1. Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs);

    // 2. Save Data
    final shop = Shop(
      id: '1',
      name: 'Test Shop',
      ownerName: 'Owner',
      mobileNumber: '123',
      address: 'Address',
      cityId: '1',
      status: ShopStatus.active,
    );
    await storage.saveShops([shop]);

    // 3. Load Data
    final loaded = storage.loadShops();
    expect(loaded.length, 1);
    expect(loaded.first.name, 'Test Shop');
  });

  test('ShopService initializes with data from storage', () async {
    SharedPreferences.setMockInitialValues({}); 
    
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs);
    
    // Pre-populate storage
    final shop = Shop(
      id: '99',
      name: 'Stored Shop',
      ownerName: 'Stored Owner',
      mobileNumber: '000',
      address: 'Stored Addr',
      cityId: '1',
      status: ShopStatus.active,
    );
    await storage.saveShops([shop]);

    // Override the provider with our pre-configured storage
    final container = ProviderContainer(
      overrides: [
        storageServiceProvider.overrideWith((ref) => storage),
        shopProvider.overrideWith((ref) => ShopService(storage, ref)),
      ],
    );
    addTearDown(container.dispose);

    // Read the provider
    final loadedShops = container.read(shopProvider);
    
    // Check state
    expect(loadedShops.length, 1);
    expect(loadedShops.first.name, 'Stored Shop');
  });
}
