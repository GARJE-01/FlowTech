class DailySummary {
  final DateTime date;
  final int shopsVisited;
  final int ordersPlaced;
  final int approvedOrders;
  final int pendingOrders;
  final double totalSales;

  DailySummary({
    required this.date,
    required this.shopsVisited,
    required this.ordersPlaced,
    required this.approvedOrders,
    required this.pendingOrders,
    required this.totalSales,
  });
}

class PeriodSummary {
  final DateTime startDate;
  final DateTime endDate;
  final int totalOrders;
  final int approvedOrders;
  final double totalRevenue;
  final List<ShopReportItem> topShops;
  final List<ProductReportItem> topProducts;

  PeriodSummary({
    required this.startDate,
    required this.endDate,
    required this.totalOrders,
    required this.approvedOrders,
    required this.totalRevenue,
    required this.topShops,
    required this.topProducts,
  });
}

class ShopReportItem {
  final String shopId;
  final String shopName;
  final int totalOrders;
  final double totalRevenue;
  final DateTime? lastOrderDate;

  ShopReportItem({
    required this.shopId,
    required this.shopName,
    required this.totalOrders,
    required this.totalRevenue,
    this.lastOrderDate,
  });
}

class ProductReportItem {
  final String productId;
  final String productName;
  final int quantitySold;
  final double totalRevenue;
  final int ordersCount;

  ProductReportItem({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.totalRevenue,
    required this.ordersCount,
  });
}

class PerformanceStats {
  final int totalOrdersPlaced;
  final double approvalRate;
  final double averageOrderValue;
  final int shopsServed;
  final double repeatOrderPercentage;

  PerformanceStats({
    required this.totalOrdersPlaced,
    required this.approvalRate,
    required this.averageOrderValue,
    required this.shopsServed,
    required this.repeatOrderPercentage,
  });
}
