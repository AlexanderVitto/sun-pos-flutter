class Customer {
  final int id;
  final String name;
  final String phone;
  final String? address;
  final int? customerGroupId;
  final bool hasCustomerGroup;
  final String? customerGroupName;
  final String? formattedDiscount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    this.customerGroupId,
    this.hasCustomerGroup = false,
    this.customerGroupName,
    this.formattedDiscount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'],
      customerGroupId: json['customer_group_id'],
      hasCustomerGroup: json['has_customer_group'] ?? false,
      customerGroupName: json['customer_group_name'],
      formattedDiscount: json['formatted_discount'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'customer_group_id': customerGroupId,
      'has_customer_group': hasCustomerGroup,
      'customer_group_name': customerGroupName,
      'formatted_discount': formattedDiscount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Customer(id: $id, name: $name, phone: $phone, group: $customerGroupName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Customer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
