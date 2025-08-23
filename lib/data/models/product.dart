class Product {
  final String id;
  final String name;
  final String code;
  final String description;
  final double price;
  final int stock;
  final String category;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  Product copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    double? price,
    int? stock,
    String? category,
    String? imagePath,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      description: json['description'],
      price: json['price'].toDouble(),
      stock: json['stock'],
      category: json['category'],
      imagePath: json['imagePath'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, code: $code, price: $price, stock: $stock)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
