class ProductDetailResponse {
  final String status;
  final String message;
  final ProductDetail data;

  ProductDetailResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProductDetailResponse.fromJson(Map<String, dynamic> json) {
    return ProductDetailResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: ProductDetail.fromJson(json['data'] ?? {}),
    );
  }
}

class ProductDetail {
  final int id;
  final String name;
  final String sku;
  final String description;
  final int minStock;
  final String? image;
  final bool isActive;
  final CategoryDetail category;
  final UnitDetail unit;
  final List<ProductVariant> variants;
  final String createdAt;
  final String updatedAt;

  ProductDetail({
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
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      description: json['description'] ?? '',
      minStock: json['min_stock'] ?? 0,
      image: json['image'],
      isActive: json['is_active'] ?? false,
      category: CategoryDetail.fromJson(json['category'] ?? {}),
      unit: UnitDetail.fromJson(json['unit'] ?? {}),
      variants:
          (json['variants'] as List<dynamic>?)
              ?.map((variant) => ProductVariant.fromJson(variant))
              .toList() ??
          [],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class CategoryDetail {
  final int id;
  final String name;
  final String description;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  CategoryDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryDetail.fromJson(Map<String, dynamic> json) {
    return CategoryDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class UnitDetail {
  final int id;
  final String name;
  final String symbol;
  final String description;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  UnitDetail({
    required this.id,
    required this.name,
    required this.symbol,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UnitDetail.fromJson(Map<String, dynamic> json) {
    return UnitDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class ProductVariant {
  final int id;
  final String name;
  final String sku;
  final double price;
  final double costPrice;
  final int stock;
  final Map<String, dynamic> attributes;
  final String? image;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  ProductVariant({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.costPrice,
    required this.stock,
    required this.attributes,
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
      attributes: json['attributes'] ?? {},
      image: json['image'],
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
