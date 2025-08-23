class Store {
  final int id;
  final String name;
  final String address;
  final String phoneNumber;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Store({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      isActive: json['is_active'] ?? false,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone_number': phoneNumber,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Store(id: $id, name: $name, address: $address, isActive: $isActive)';
  }
}
