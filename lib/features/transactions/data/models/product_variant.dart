class ProductVariant {
  final int id;
  final String name;
  final String sku;
  final double price;
  final double costPrice;
  final int stock;
  final Map<String, dynamic>? attributes;
  final String? image;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductVariant({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.costPrice,
    required this.stock,
    this.attributes,
    this.image,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      costPrice: (json['cost_price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      attributes: json['attributes'] as Map<String, dynamic>?,
      image: json['image'],
      isActive: json['is_active'] ?? true,
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
      'sku': sku,
      'price': price,
      'cost_price': costPrice,
      'stock': stock,
      'attributes': attributes,
      'image': image,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ProductVariant(id: $id, name: $name, sku: $sku, price: $price, stock: $stock)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductVariant &&
        other.id == id &&
        other.name == name &&
        other.sku == sku &&
        other.price == price &&
        other.costPrice == costPrice &&
        other.stock == stock;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        sku.hashCode ^
        price.hashCode ^
        costPrice.hashCode ^
        stock.hashCode;
  }
}
