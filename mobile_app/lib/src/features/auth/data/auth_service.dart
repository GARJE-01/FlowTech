import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// --- Domain ---
class User {
  final String id;
  final String name;
  final String role;
  final String employeeId;
  final String contact;

  User({
    required this.id,
    required this.name,
    required this.role,
    required this.employeeId,
    required this.contact,
  });
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
// --- Service / Controller ---

class AuthService extends StateNotifier<AuthState> {
  AuthService() : super(AuthState()) {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString('user_session');
    
    if (storedUser != null) {
      try {
        final Map<String, dynamic> userData = jsonDecode(storedUser);
         final user = User(
          id: userData['id'],
          name: userData['name'],
          role: userData['role'],
          employeeId: userData['employeeId'],
          contact: userData['contact'],
        );
        state = AuthState(user: user);
      } catch (e) {
        state = AuthState(); // Fallback if corrupt
      }
    }
  }

  Future<void> login(String username, String password) async {
    state = AuthState(isLoading: true);
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    if (username.isNotEmpty && password.isNotEmpty) {
      // Mock Success
      final dummyUser = User(
        id: 'user_001',
        name: 'Aditya Salesman',
        role: 'Salesman',
        employeeId: 'EMP-1234',
        contact: '+91 98765 43210',
      );
      
      // Persist
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode({
        'id': dummyUser.id,
        'name': dummyUser.name,
        'role': dummyUser.role,
        'employeeId': dummyUser.employeeId,
        'contact': dummyUser.contact,
      });
      await prefs.setString('user_session', userJson);

      state = AuthState(user: dummyUser, isLoading: false);
    } else {
      state = AuthState(error: 'Invalid credentials', isLoading: false);
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
  return AuthService();
});
