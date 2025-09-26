import 'category.dart';
import 'unit.dart';
import 'product_variant.dart';

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
  final List<ProductVariant> variants;
  final int variantsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

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
    required this.variants,
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
      variants:
          (json['variants'] as List<dynamic>?)
              ?.map((variant) => ProductVariant.fromJson(variant))
              .toList() ??
          [],
      variantsCount: json['variants_count'] ?? 0,
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
      'description': description,
      'min_stock': minStock,
      'image': image,
      'is_active': isActive,
      'category': category.toJson(),
      'unit': unit.toJson(),
      'variants': variants.map((variant) => variant.toJson()).toList(),
      'variants_count': variantsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, sku: $sku, category: ${category.name}, unit: ${unit.name}, variantsCount: $variantsCount)';
  }

  // Helper method to get the first variant (for backward compatibility)
  ProductVariant? get firstVariant {
    return variants.isNotEmpty ? variants.first : null;
  }

  // Helper method to get price from first variant (for backward compatibility)
  double get price {
    return firstVariant?.price ?? 0.0;
  }

  // Helper method to get stock from first variant (for backward compatibility)
  int get stock {
    return firstVariant?.stock ?? 0;
  }
}
