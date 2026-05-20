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
      data: ProductDetail.fromJson(json['data']['data'] ?? {}),
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
  // Pricing dari payload `pricing_info`. Berisi customer-specific price
  // sesuai grup customer. Null jika backend tidak mengirim pricing_info.
  final double? customerFinalPrice;
  final bool hasCustomerPricing;
  final String? customerGroupName;

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
    this.customerFinalPrice,
    this.hasCustomerPricing = false,
    this.customerGroupName,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    // Backend (Laravel) men-serialize empty associative array sebagai `[]`
    // alih-alih `{}`. Toleransi keduanya supaya parsing tidak crash.
    final rawAttrs = json['attributes'];
    final attributes = rawAttrs is Map
        ? Map<String, dynamic>.from(rawAttrs)
        : <String, dynamic>{};

    final pricingInfo = json['pricing_info'] is Map
        ? Map<String, dynamic>.from(json['pricing_info'])
        : null;

    return ProductVariant(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      costPrice: (json['cost_price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      attributes: attributes,
      image: json['image'],
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      customerFinalPrice: pricingInfo != null
          ? (pricingInfo['final_price'] ?? 0).toDouble()
          : null,
      hasCustomerPricing: pricingInfo?['has_customer_pricing'] ?? false,
      customerGroupName: pricingInfo?['customer_group_name'],
    );
  }

  /// Harga akhir untuk display: customer-specific price kalau ada,
  /// fallback ke base `price`.
  double get finalPrice => customerFinalPrice ?? price;
}
