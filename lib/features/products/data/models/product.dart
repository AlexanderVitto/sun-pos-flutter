import 'category.dart';
import 'unit.dart';

class Product {
  final int id;
  final String name;
  final String sku;
  final String description;
  final int minStock;
  final String? image;
  final bool isActive;
  final Category category;
  final Unit unit;
  final int variantsCount;
  final String createdAt;
  final String updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.description,
    required this.minStock,
    this.image,
    required this.isActive,
    required this.category,
    required this.unit,
    required this.variantsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      description: json['description'] ?? '',
      minStock: json['min_stock'] ?? 0,
      image: json['image'],
      isActive: json['is_active'] ?? false,
      category: Category.fromJson(json['category'] ?? {}),
      unit: Unit.fromJson(json['unit'] ?? {}),
      variantsCount: json['variants_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'description': description,
      'min_stock': minStock,
      'image': image,
      'is_active': isActive,
      'category': category.toJson(),
      'unit': unit.toJson(),
      'variants_count': variantsCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, sku: $sku, category: ${category.name}, unit: ${unit.name})';
  }
}
