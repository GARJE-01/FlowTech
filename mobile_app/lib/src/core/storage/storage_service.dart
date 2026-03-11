
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/shop/domain/shop_model.dart';
import '../../features/order/domain/order_model.dart';
import '../../features/payment/domain/payment_model.dart';
import '../../features/product/domain/product_model.dart';


class StorageService {
  static const String _shopsKey = 'shops';
  static const String _ordersKey = 'orders';
  static const String _paymentsKey = 'payments';
  static const String _productsKey = 'products';


  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- Shops ---
  Future<void> saveShops(List<Shop> shops) async {
    final List<String> jsonList = shops.map((shop) => jsonEncode(shop.toJson())).toList();
    await _prefs.setStringList(_shopsKey, jsonList);
  }

  List<Shop> loadShops() {
    final List<String>? jsonList = _prefs.getStringList(_shopsKey);
    if (jsonList == null) return [];
    return jsonList.map((json) => Shop.fromJson(jsonDecode(json))).toList();
  }

  // --- Orders ---
  Future<void> saveOrders(List<Order> orders) async {
    final List<String> jsonList = orders.map((order) => jsonEncode(order.toJson())).toList();
    await _prefs.setStringList(_ordersKey, jsonList);
  }

  List<Order> loadOrders() {
    final List<String>? jsonList = _prefs.getStringList(_ordersKey);
    if (jsonList == null) return [];
    return jsonList.map((json) => Order.fromJson(jsonDecode(json))).toList();
  }

  // --- Payments ---
  Future<void> savePayments(List<Payment> payments) async {
    final List<String> jsonList = payments.map((payment) => jsonEncode(payment.toJson())).toList();
    await _prefs.setStringList(_paymentsKey, jsonList);
  }

  List<Payment> loadPayments() {
    final List<String>? jsonList = _prefs.getStringList(_paymentsKey);
    if (jsonList == null) return [];
    return jsonList.map((json) => Payment.fromJson(jsonDecode(json))).toList();
  }

  // --- Products ---
  Future<void> saveProducts(List<Product> products) async {
    final List<String> jsonList = products.map((p) => jsonEncode(p.toJson())).toList();
    await _prefs.setStringList(_productsKey, jsonList);
  }

  List<Product> loadProducts() {
    final List<String>? jsonList = _prefs.getStringList(_productsKey);
    if (jsonList == null) return [];
    return jsonList.map((json) => Product.fromJson(jsonDecode(json))).toList();
  }
}

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('StorageService must be overridden in main.dart');
});


