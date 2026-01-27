enum VisitStatus { notVisited, visited, orderPlaced }

class Visit {
  final String id;
  final String shopId;
  final String shopName;
  final String cityId;
  final VisitStatus status;
  final DateTime? lastVisitDateTime;

  Visit({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.cityId,
    this.status = VisitStatus.notVisited,
    this.lastVisitDateTime,
  });

  Visit copyWith({
    String? id,
    String? shopId,
    String? shopName,
    String? cityId,
    VisitStatus? status,
    DateTime? lastVisitDateTime,
  }) {
    return Visit(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      cityId: cityId ?? this.cityId,
      status: status ?? this.status,
      lastVisitDateTime: lastVisitDateTime ?? this.lastVisitDateTime,
    );
  }
}
