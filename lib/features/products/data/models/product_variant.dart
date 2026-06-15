import 'customer_pricing.dart';
import 'formatted_prices.dart';

class ProductVariant {
  final int id;
  final String name;
  final String sku;
  final double price;
  final double costPrice;
  final int stock;
  final int minStock;
  final Map<String, dynamic> attributes;
  final String? image;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CustomerPricing? customerPricing;
  final FormattedPrices? formattedPrices;

  ProductVariant({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.costPrice,
    required this.stock,
    this.minStock = 0,
    required this.attributes,
    this.image,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.customerPricing,
    this.formattedPrices,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    // Backend (PHP/Laravel) men-serialize empty associative array sebagai
    // `[]` alih-alih `{}`. Toleransi keduanya supaya parsing tidak crash.
    final rawAttrs = json['attributes'];
    final attributes = rawAttrs is Map
        ? Map<String, dynamic>.from(rawAttrs)
        : <String, dynamic>{};

    return ProductVariant(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      costPrice: (json['cost_price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      minStock: json['min_stock'] ?? 0,
      attributes: attributes,
      image: json['image'],
      isActive: json['is_active'] ?? false,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      // API key actually `pricing_info`. Tetap toleransi `customer_pricing`
      // untuk endpoint lain yang mungkin masih pakai nama lama.
      customerPricing:
          json['pricing_info'] != null
              ? CustomerPricing.fromJson(json['pricing_info'])
              : (json['customer_pricing'] != null
                  ? CustomerPricing.fromJson(json['customer_pricing'])
                  : null),
      formattedPrices: json['formatted_prices'] != null
          ? FormattedPrices.fromJson(json['formatted_prices'])
          : null,
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
      'min_stock': minStock,
      'attributes': attributes,
      'image': image,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (customerPricing != null) 'pricing_info': customerPricing!.toJson(),
      if (formattedPrices != null)
        'formatted_prices': formattedPrices!.toJson(),
    };
  }

  @override
  String toString() {
    return 'ProductVariant(id: $id, name: $name, sku: $sku, price: $price, stock: $stock, customerPricing: $customerPricing)';
  }

  /// Get the final price for display (customer price if available, otherwise base price)
  double get finalPrice {
    return customerPricing?.finalPrice ?? price;
  }

  /// Check if this variant has customer-specific pricing
  bool get hasCustomerPricing {
    return customerPricing?.hasCustomerPricing ?? false;
  }

  /// Get the formatted final price for display
  String get formattedFinalPrice {
    return formattedPrices?.finalPrice ?? '';
  }
}
