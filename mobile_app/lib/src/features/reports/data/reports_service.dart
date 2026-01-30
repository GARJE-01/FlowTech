import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../order/data/order_service.dart';
import '../../order/domain/order_model.dart';
import '../../shop/data/shop_service.dart';
import '../../shop/domain/shop_model.dart';
import '../../route/data/visit_service.dart'; // Assuming visit service exists or reusing logic
import '../../route/domain/visit_model.dart';
import '../../reports/domain/report_models.dart';
import '../../city/data/city_service.dart';

final reportsServiceProvider = Provider<ReportsService>((ref) {
  return ReportsService(ref);
});

class ReportsService {
  final Ref _ref;

  ReportsService(this._ref);

  /// Get summary for a specific day
  DailySummary getDailySummary(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final cityState = _ref.watch(cityProvider); // Assuming cityProvider is imported or available
    final allOrders = _ref.watch(orderListProvider);
    
    // Filter orders by date AND city
    final dailyOrders = allOrders.where((o) => 
      _isSameDay(o.createdAt, date) && 
      (cityState.selectedCity == null || o.cityId == cityState.selectedCity!.id)
    ).toList();

    // Calculate metrics
    // Exclude drafts from "Orders Placed"
    final ordersPlaced = dailyOrders.where((o) => o.status != OrderStatus.draft).length;
    final approvedOrders = dailyOrders.where((o) => o.status == OrderStatus.approved).length;
    final pendingOrders = dailyOrders.where((o) => o.status == OrderStatus.pending).length;
    final totalSales = dailyOrders
        .where((o) => o.status == OrderStatus.approved) // Only approved sales count usually
        .fold(0.0, (sum, o) => sum + o.totalAmount);

    // Visits Logic
    int visitsCount = 0;
    final userIsLookingAtToday = _isSameDay(date, DateTime.now());

    if (userIsLookingAtToday) {
      // For today, we can use the live VisitService state
      final visits = _ref.read(visitProvider);
      // Count visits that are either 'visited' or 'orderPlaced'
      visitsCount = visits.where((v) => 
        v.status == VisitStatus.visited || v.status == VisitStatus.orderPlaced
      ).length;
    } else {
      // For past dates, since we don't have a full Visit History log in this version,
      // we approximate visits by counting unique shops that had orders placed.
      // In a full backend system, we would query the Visit table.
      visitsCount = dailyOrders.map((o) => o.shopId).toSet().length;
    }
    
    return DailySummary(
      date: date,
      shopsVisited: visitsCount,
      ordersPlaced: ordersPlaced,
      approvedOrders: approvedOrders,
      pendingOrders: pendingOrders,
      totalSales: totalSales,
    );
  }

  /// Get summary for a custom period
  PeriodSummary getPeriodSummary(DateTime start, DateTime end) {
    // Normalize range
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);

    final cityState = _ref.watch(cityProvider);
    final allOrders = _ref.watch(orderListProvider);
    final periodOrders = allOrders.where((o) => 
      o.createdAt.isAfter(startDate) && 
      o.createdAt.isBefore(endDate) &&
      (cityState.selectedCity == null || o.cityId == cityState.selectedCity!.id)
    ).toList();

    final approved = periodOrders.where((o) => o.status == OrderStatus.approved).toList();

    // Stats
    final totalOrders = periodOrders.length;
    final approvedCount = approved.length;
    final revenue = approved.fold(0.0, (sum, o) => sum + o.totalAmount);

    // Top Shops Logic
    final shopMap = <String, double>{}; // ID -> Revenue
    final shopOrderCount = <String, int>{};

    for (var o in approved) {
      shopMap[o.shopId] = (shopMap[o.shopId] ?? 0) + o.totalAmount;
      shopOrderCount[o.shopId] = (shopOrderCount[o.shopId] ?? 0) + 1;
    }

    final sortedShops = shopMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // Descending Revenue

    final shopList = _ref.read(shopProvider); // To get names

    final topShopItems = sortedShops.take(5).map((e) {
      final shop = shopList.firstWhere((s) => s.id == e.key, orElse: () => Shop(id: '?', name: 'Unknown', ownerName: '', mobileNumber: '', address: '', cityId: ''));
      return ShopReportItem(
        shopId: e.key,
        shopName: shop.name,
        totalOrders: shopOrderCount[e.key] ?? 0,
        totalRevenue: e.value,
      );
    }).toList();

    // Top Products Logic
    final productMap = <String, ProductReportItem>{}; // ID -> Item

    for (var o in approved) {
      for (var item in o.items) {
        if (!productMap.containsKey(item.productId)) {
          productMap[item.productId] = ProductReportItem(
            productId: item.productId,
            productName: item.productName,
            quantitySold: 0,
            totalRevenue: 0,
            ordersCount: 0,
          );
        }
        final existing = productMap[item.productId]!;
        productMap[item.productId] = ProductReportItem(
          productId: existing.productId,
          productName: existing.productName,
          quantitySold: existing.quantitySold + item.quantity,
          totalRevenue: existing.totalRevenue + item.lineTotal,
          ordersCount: existing.ordersCount + 1, // Rough approx per order line
        );
      }
    }

    final topProducts = productMap.values.toList()
      ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

    return PeriodSummary(
      startDate: startDate,
      endDate: endDate,
      totalOrders: totalOrders,
      approvedOrders: approvedCount,
      totalRevenue: revenue,
      topShops: topShopItems,
      topProducts: topProducts.take(5).toList(),
    );
  }

  /// Get Shop-wise comprehensive report
  List<ShopReportItem> getShopReports() {
    final cityState = _ref.watch(cityProvider);
    final allOrders = _ref.watch(orderListProvider);
    final allShops = _ref.watch(shopProvider);
    
    final filteredShops = cityState.selectedCity == null 
       ? allShops 
       : allShops.where((s) => s.cityId == cityState.selectedCity!.id).toList();

    final List<ShopReportItem> reports = [];

    for (var shop in filteredShops) {
      final shopOrders = allOrders.where((o) => o.shopId == shop.id).toList();
      final approved = shopOrders.where((o) => o.status == OrderStatus.approved);
      
      final revenue = approved.fold(0.0, (sum, o) => sum + o.totalAmount);
      
      // Last order
      DateTime? lastOrder;
      if (shopOrders.isNotEmpty) {
        lastOrder = shopOrders.map((o) => o.createdAt).reduce((a, b) => a.isAfter(b) ? a : b);
      }

      reports.add(ShopReportItem(
        shopId: shop.id,
        shopName: shop.name,
        totalOrders: shopOrders.length,
        totalRevenue: revenue,
        lastOrderDate: lastOrder,
      ));
    }
    
    // Sort by default (Revenue)
    reports.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
    return reports;
  }

  /// Get Product-wise comprehensive report
  List<ProductReportItem> getProductReports() {
    final cityState = _ref.watch(cityProvider);
    final allOrders = _ref.watch(orderListProvider);
    final approvedOrders = allOrders.where((o) => 
        o.status == OrderStatus.approved &&
        (cityState.selectedCity == null || o.cityId == cityState.selectedCity!.id)
    );

    final Map<String, ProductReportItem> map = {};

    for (var o in approvedOrders) {
      for (var item in o.items) {
         if (!map.containsKey(item.productId)) {
          map[item.productId] = ProductReportItem(
            productId: item.productId,
            productName: item.productName,
            quantitySold: 0,
            totalRevenue: 0,
            ordersCount: 0,
          );
        }
        final existing = map[item.productId]!;
        map[item.productId] = ProductReportItem(
          productId: existing.productId,
          productName: existing.productName,
          quantitySold: existing.quantitySold + item.quantity,
          totalRevenue: existing.totalRevenue + item.lineTotal,
          ordersCount: existing.ordersCount + 1, 
        );
      }
    }

    final list = map.values.toList();
    list.sort((a, b) => b.quantitySold.compareTo(a.quantitySold));
    return list;
  }

  /// Get Personal Performance Stats
  PerformanceStats getPerformanceStats() {
    final cityState = _ref.watch(cityProvider);
    final all = _ref.watch(orderListProvider);
    
    final allOrders = all.where((o) => 
       cityState.selectedCity == null || o.cityId == cityState.selectedCity!.id
    ).toList();
    
    final shops = _ref.watch(shopProvider);

    if (allOrders.isEmpty) {
      return PerformanceStats(totalOrdersPlaced: 0, approvalRate: 0, averageOrderValue: 0, shopsServed: 0, repeatOrderPercentage: 0);
    }

    final approved = allOrders.where((o) => o.status == OrderStatus.approved).length;
    final total = allOrders.length;
    final rate = (approved / total) * 100;

    final revenue = allOrders.where((o) => o.status == OrderStatus.approved).fold(0.0, (sum, o) => sum + o.totalAmount);
    final avgVal = approved > 0 ? revenue / approved : 0.0;

    // Shops served (unique shops with at least one order)
    final servedShops = allOrders.map((o) => o.shopId).toSet().length;

    // Repeat percentage (Approx: Shops with >1 order / Total shops served)
    final shopCounts = <String, int>{};
    for(var o in allOrders) {
      shopCounts[o.shopId] = (shopCounts[o.shopId] ?? 0) + 1;
    }
    final repeaters = shopCounts.values.where((c) => c > 1).length;
    final repeatRate = servedShops > 0 ? (repeaters / servedShops) * 100 : 0.0;

    return PerformanceStats(
      totalOrdersPlaced: total,
      approvalRate: rate,
      averageOrderValue: avgVal,
      shopsServed: servedShops,
      repeatOrderPercentage: repeatRate,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
