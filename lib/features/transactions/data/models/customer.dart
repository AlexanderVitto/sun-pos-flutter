class Customer {
  final int id;
  final String name;
  final String? email;
  final String? phoneNumber;
  final String? address;
  final int? customerGroupId;
  final CustomerGroup? customerGroup;
  final bool hasCustomerGroup;
  final String? customerGroupName;
  final String? formattedDiscount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Customer({
    required this.id,
    required this.name,
    this.email,
    this.phoneNumber,
    this.address,
    this.customerGroupId,
    this.customerGroup,
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
      email: json['email'],
      phoneNumber: json['phone'],
      address: json['address'],
      customerGroupId: json['customer_group_id'],
      customerGroup: json['customer_group'] != null
          ? CustomerGroup.fromJson(json['customer_group'])
          : null,
      hasCustomerGroup: json['has_customer_group'] ?? false,
      customerGroupName: json['customer_group_name'],
      formattedDiscount: json['formatted_discount'],
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
      'email': email,
      'phone': phoneNumber,
      'address': address,
      'customer_group_id': customerGroupId,
      'customer_group': customerGroup?.toJson(),
      'has_customer_group': hasCustomerGroup,
      'customer_group_name': customerGroupName,
      'formatted_discount': formattedDiscount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Customer(id: $id, name: $name, email: $email, customerGroupName: $customerGroupName)';
  }
}

class CustomerGroup {
  final int id;
  final String name;
  final String discountPercentage;
  final bool isActive;

  const CustomerGroup({
    required this.id,
    required this.name,
    required this.discountPercentage,
    required this.isActive,
  });

  factory CustomerGroup.fromJson(Map<String, dynamic> json) {
    return CustomerGroup(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      discountPercentage: json['discount_percentage']?.toString() ?? '0.00',
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'discount_percentage': discountPercentage,
      'is_active': isActive,
    };
  }

  @override
  String toString() {
    return 'CustomerGroup(id: $id, name: $name, discount: $discountPercentage%)';
  }
}
