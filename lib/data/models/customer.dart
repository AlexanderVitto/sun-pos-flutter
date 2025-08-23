class Customer {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  String toString() {
    return 'Customer(id: $id, name: $name, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Customer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
