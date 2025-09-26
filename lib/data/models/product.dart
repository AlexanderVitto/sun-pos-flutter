class Product {
  final int id;
  final String name;
  final String code;
  final String description;
  final double price;
  final int stock;
  final String category;
  final String? imagePath;
  final int? productVariantId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    this.code = '',
    this.description = '',
    this.price = 0.0,
    this.stock = 0,
    this.category = 'General',
    this.imagePath,
    this.productVariantId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Product copyWith({
    int? id,
    String? name,
    String? code,
    String? description,
    double? price,
    int? stock,
    String? category,
    String? imagePath,
    int? productVariantId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      productVariantId: productVariantId ?? this.productVariantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': name,
      'product_id': code,
      'description': description,
      'unit_price': price,
      'quantity': stock,
      'product_variant_id': productVariantId,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['product_name'] ?? '',
      code: json['product_id'] ?? '',
      description: json['description'] ?? '',
      price: (json['unit_price'] ?? 0.0).toDouble(),
      stock: json['quantity'] ?? 0,
      category: json['category'] ?? 'General',
      imagePath: json['imagePath'],
      productVariantId: json['product_variant_id'],
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : null, // Will use default from constructor
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : null, // Will use default from constructor
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, code: $code, price: $price, stock: $stock, productVariantId: $productVariantId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
