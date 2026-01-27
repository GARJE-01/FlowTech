import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/city.dart';

// --- State ---
class CityState {
  final City? selectedCity;
  final List<City> availableCities;
  final bool isLoading;

  CityState({
    this.selectedCity,
    this.availableCities = const [],
    this.isLoading = false,
  });

  bool get hasCitySelected => selectedCity != null;
}

// --- Service ---
class CityService extends StateNotifier<CityState> {
  CityService() : super(CityState()) {
    _loadCitiesAndSelection();
  }

  // Mock Data
  final List<City> _mockCities = [
    City(id: '1', name: 'Mumbai'),
    City(id: '2', name: 'Pune'),
    City(id: '3', name: 'Nashik'),
    City(id: '4', name: 'Nagpur'),
    City(id: '5', name: 'Delhi'),
    City(id: '6', name: 'Bangalore'),
  ];

  Future<void> _loadCitiesAndSelection() async {
    state = CityState(isLoading: true, availableCities: _mockCities);
    
    final prefs = await SharedPreferences.getInstance();
    final storedCity = prefs.getString('selected_city');

    if (storedCity != null) {
      try {
        final Map<String, dynamic> cityMap = jsonDecode(storedCity);
        final city = City.fromJson(cityMap);
        // Ensure city still exists in available list (safety)
        if (_mockCities.any((c) => c.id == city.id)) {
          state = CityState(
            selectedCity: city,
            availableCities: _mockCities,
            isLoading: false,
          );
          return;
        }
      } catch (_) {}
    }

    state = CityState(availableCities: _mockCities, isLoading: false);
  }

  Future<void> setCity(City city) async {
    state = CityState(
      selectedCity: city,
      availableCities: state.availableCities,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_city', jsonEncode(city.toJson()));
  }

  Future<void> clearCity() async {
     state = CityState(availableCities: state.availableCities);
     final prefs = await SharedPreferences.getInstance();
     await prefs.remove('selected_city');
  }
}

// --- Provider ---
final cityProvider = StateNotifierProvider<CityService, CityState>((ref) {
  return CityService();
});
