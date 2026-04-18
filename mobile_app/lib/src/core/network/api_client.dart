
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/storage_service.dart';

class ApiClient {
  // ─── Production URL (Vercel) ───────────────────────────────────────────────
  // Update this URL after deploying to Vercel.
  static const String _productionUrl = "https://YOUR-APP.vercel.app/api/mobile";

  // ─── Local Dev URLs (uncomment when testing locally) ──────────────────────
  // Android Emulator:  "http://10.0.2.2:3000/api/mobile"
  // Physical Android:  "http://172.26.60.252:3000/api/mobile"
  // iOS / Web:         "http://localhost:3000/api/mobile"

  String get baseUrl => _productionUrl;


  final StorageService _storageService;

  ApiClient(this._storageService);

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse("$baseUrl$path");
      debugPrint("POST -> $url");
      
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      debugPrint("ApiClient POST Error: $e");
      return {"success": false, "error": "Network error: $e"};
    }
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse("$baseUrl$path").replace(queryParameters: queryParams);
      debugPrint("GET -> $uri");
      
      final response = await http.get(uri);
      return _handleResponse(response);
    } catch (e) {
       debugPrint("ApiClient GET Error: $e");
      return {"success": false, "error": "Network error: $e"};
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    debugPrint("Response [${response.statusCode}] -> ${response.body}");
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      try {
        final errorData = jsonDecode(response.body);
        return {"success": false, "error": errorData['error'] ?? "Server error: ${response.statusCode}"};
      } catch (_) {
        return {"success": false, "error": "System error: ${response.statusCode}"};
      }
    }
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ApiClient(storage);
});
