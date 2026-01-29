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

  Shop({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.mobileNumber,
    required this.address,
    required this.cityId,
    this.gstNumber,
    this.status = ShopStatus.active,
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
    );
  }
}
