class City {
  final String id;
  final String name;

  City({
    required this.id,
    required this.name,
  });

  // Serialization helpers
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory City.fromJson(Map<String, dynamic> map) {
    return City(
      id: map['id'],
      name: map['name'],
    );
  }
}
