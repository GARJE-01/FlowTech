import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../shop/data/shop_service.dart';
import '../../city/data/city_service.dart';
import '../../shop/domain/shop_model.dart';
import '../domain/visit_model.dart';

class VisitService extends StateNotifier<List<Visit>> {
  final Ref ref;
  
  VisitService(this.ref) : super([]);

  // Initialize today's visits based on active shops in selected city
  void generateDailyRoute() {
    final cityState = ref.read(cityProvider);
    final allShops = ref.read(shopProvider);
    
    if (cityState.selectedCity == null) {
      state = [];
      return;
    }

    // Filter active shops for current city
    final activeShops = allShops.where((s) => 
      s.cityId == cityState.selectedCity!.id && 
      s.status == ShopStatus.active
    ).toList();

    // Map to visits
    // In a real app, we might check if a visit already exists for today to preserve status.
    // For now, we'll simple generate new ones if empty or keep existing.
    
    if (state.isEmpty) {
       state = activeShops.map((shop) => Visit(
        id: const Uuid().v4(),
        shopId: shop.id,
        shopName: shop.name,
        cityId: shop.cityId,
        status: VisitStatus.notVisited,
      )).toList();
    } else {
      // If we switch cities, we need to regenerate
      final currentCityId = cityState.selectedCity!.id;
      final visitsForCity = state.where((v) => v.cityId == currentCityId).toList();
      
      if (visitsForCity.isEmpty && activeShops.isNotEmpty) {
         final newVisits = activeShops.map((shop) => Visit(
          id: const Uuid().v4(),
          shopId: shop.id,
          shopName: shop.name,
          cityId: shop.cityId,
          status: VisitStatus.notVisited,
        )).toList();
        
        // Append to state (keeping other cities' visits in memory if we wanted, 
        // but easier to just replace or append. Let's replace for simplicity of "Daily Route" context)
        state = newVisits;
      }
    }
  }
  
  Future<void> markVisited(String visitId) async {
    state = [
      for (final visit in state)
        if (visit.id == visitId)
          visit.copyWith(
            status: VisitStatus.visited,
            lastVisitDateTime: DateTime.now(),
          )
        else
          visit
    ];
    // Mock Persistence
    // await _saveToPrefs(); 
  }

  Future<void> markOrderPlaced(String shopId) async {
    // Find visit by shopId
    state = [
      for (final visit in state)
        if (visit.shopId == shopId)
          visit.copyWith(
            status: VisitStatus.orderPlaced,
            lastVisitDateTime: DateTime.now(),
          )
        else
          visit
    ];
  }
}

final visitProvider = StateNotifierProvider<VisitService, List<Visit>>((ref) {
  return VisitService(ref);
});

// Derived provider for "Today's Route" (filtered by current city)
final todayVisitsProvider = Provider<List<Visit>>((ref) {
  final allVisits = ref.watch(visitProvider);
  final cityState = ref.watch(cityProvider);
  
  if (cityState.selectedCity == null) return [];
  
  return allVisits.where((v) => v.cityId == cityState.selectedCity!.id).toList();
});
