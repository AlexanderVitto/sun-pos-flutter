import 'product_variant.dart';

class TransactionDetailResponse {
  final int id;
  final int? productId;
  final int? productVariantId;
  final String productName;
  final String productSku;
  final double unitPrice;
  final int quantity;
  final double totalAmount;
  final dynamic product; // Can be null or Product object
  final ProductVariant? productVariant;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionDetailResponse({
    required this.id,
    this.productId,
    this.productVariantId,
    required this.productName,
    required this.productSku,
    required this.unitPrice,
    required this.quantity,
    required this.totalAmount,
    this.product,
    this.productVariant,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionDetailResponse.fromJson(Map<String, dynamic> json) {
    return TransactionDetailResponse(
      id: json['id'] ?? 0,
      productId: json['product_id'],
      productVariantId: json['product_variant_id'],
      productName: json['product_name'] ?? '',
      productSku: json['product_sku'] ?? '',
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      product: json['product'],
      productVariant:
          json['product_variant'] != null
              ? ProductVariant.fromJson(json['product_variant'])
              : null,
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
      'product_id': productId,
      'product_variant_id': productVariantId,
      'product_name': productName,
      'product_sku': productSku,
      'unit_price': unitPrice,
      'quantity': quantity,
      'total_amount': totalAmount,
      'product': product,
      'product_variant': productVariant?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'TransactionDetailResponse(id: $id, productName: $productName, quantity: $quantity, unitPrice: $unitPrice, totalAmount: $totalAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionDetailResponse &&
        other.id == id &&
        other.productId == productId &&
        other.productVariantId == productVariantId &&
        other.quantity == quantity &&
        other.unitPrice == unitPrice &&
        other.totalAmount == totalAmount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        productId.hashCode ^
        productVariantId.hashCode ^
        quantity.hashCode ^
        unitPrice.hashCode ^
        totalAmount.hashCode;
  }
}
