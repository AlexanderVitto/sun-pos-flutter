class CustomerGroup {
  final int id;
  final String name;
  final String? description;
  final double discountPercentage;
  final bool isActive;
  final int sortOrder;
  final String formattedDiscount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomerGroup({
    required this.id,
    required this.name,
    this.description,
    required this.discountPercentage,
    required this.isActive,
    required this.sortOrder,
    required this.formattedDiscount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerGroup.fromJson(Map<String, dynamic> json) {
    return CustomerGroup(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      discountPercentage: (json['discount_percentage'] ?? 0).toDouble(),
      isActive: json['is_active'] ?? true,
      sortOrder: json['sort_order'] ?? 0,
      formattedDiscount: json['formatted_discount'] ?? '0.00%',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'discount_percentage': discountPercentage,
      'is_active': isActive,
      'sort_order': sortOrder,
      'formatted_discount': formattedDiscount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'CustomerGroup(id: $id, name: $name, discount: $formattedDiscount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomerGroup && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
