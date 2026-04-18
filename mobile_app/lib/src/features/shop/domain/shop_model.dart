enum ShopStatus { active, inactive }

class Shop {
  final String id;
  final String name;
  final String ownerName;
  final String mobileNumber;
  final String address;
  final String cityId;
  final String? gstNumber;
  final ShopStatus status;
  final double outstandingBalance;

  Shop({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.mobileNumber,
    required this.address,
    required this.cityId,
    this.gstNumber,
    this.status = ShopStatus.active,
    this.outstandingBalance = 0.0,
  });

  Shop copyWith({
    String? id,
    String? name,
    String? ownerName,
    String? mobileNumber,
    String? address,
    String? cityId,
    String? gstNumber,
    ShopStatus? status,
    double? outstandingBalance,
  }) {
    return Shop(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerName: ownerName ?? this.ownerName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      address: address ?? this.address,
      cityId: cityId ?? this.cityId,
      gstNumber: gstNumber ?? this.gstNumber,
      status: status ?? this.status,
      outstandingBalance: outstandingBalance ?? this.outstandingBalance,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ownerName': ownerName,
      'mobileNumber': mobileNumber,
      'address': address,
      'cityId': cityId,
      'gstNumber': gstNumber,
      'status': status.index,
      'outstandingBalance': outstandingBalance,
    };
  }

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'],
      name: json['name'],
      ownerName: json['ownerName'],
      mobileNumber: json['mobileNumber'],
      address: json['address'],
      cityId: json['cityId'],
      gstNumber: json['gstNumber'],
      status: ShopStatus.values[json['status'] ?? 0],
      outstandingBalance: (json['outstandingBalance'] ?? 0).toDouble(),
    );
  }
}
