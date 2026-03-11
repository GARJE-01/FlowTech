
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../../../core/network/sync_service.dart';

// --- Domain ---
class User {
  final String id;
  final String name;
  final String role;
  final String email;
  final String? phoneNumber;
  final String? area;

  User({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    this.phoneNumber,
    this.area,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'email': email,
    'phoneNumber': phoneNumber,
    'area': area,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    role: json['role'],
    email: json['email'],
    phoneNumber: json['phoneNumber'],
    area: json['area'],
  );
}


// --- State ---
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null;
}

// --- Service / Controller ---
class AuthService extends StateNotifier<AuthState> {
  final ApiClient _apiClient;
  final Ref _ref;

  AuthService(this._apiClient, this._ref) : super(AuthState()) {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString('user_session');
    
    if (storedUser != null) {
      try {
        final user = User.fromJson(jsonDecode(storedUser));
        state = AuthState(user: user);
        // Optional: Trigger sync on resume
        _ref.read(syncServiceProvider).performFullSync();
      } catch (e) {
        state = AuthState(); // Fallback if corrupt
      }
    }
  }

  Future<void> login(String email, String password) async {
    state = AuthState(isLoading: true);
    
    final result = await _apiClient.post("/auth/login", {
      "email": email,
      "password": password,
    });

    if (result['success'] == true) {
      final userData = result['user'];
      final user = User.fromJson(userData);
      
      // Persist
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_session', jsonEncode(user.toJson()));

      state = AuthState(user: user, isLoading: false);
      
      // Trigger Sync
      await _ref.read(syncServiceProvider).performFullSync();
    } else {
      state = AuthState(error: result['error'] ?? 'Invalid credentials', isLoading: false);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_session');
    state = AuthState();
  }
}

// --- Providers ---
final authProvider = StateNotifierProvider<AuthService, AuthState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient, ref);
});
