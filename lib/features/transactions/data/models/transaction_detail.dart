class TransactionDetail {
  final int productId;
  final int productVariantId;
  final int quantity;
  final double unitPrice;

  const TransactionDetail({
    required this.productId,
    required this.productVariantId,
    required this.quantity,
    required this.unitPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_variant_id': productVariantId,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    return TransactionDetail(
      productId: json['product_id'] ?? 0,
      productVariantId: json['product_variant_id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
    );
  }

  // Calculate subtotal for this detail
  double get subtotal => quantity * unitPrice;

  @override
  String toString() {
    return 'TransactionDetail(productId: $productId, productVariantId: $productVariantId, quantity: $quantity, unitPrice: $unitPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionDetail &&
        other.productId == productId &&
        other.productVariantId == productVariantId &&
        other.quantity == quantity &&
        other.unitPrice == unitPrice;
  }

  @override
  int get hashCode {
    return productId.hashCode ^
        productVariantId.hashCode ^
        quantity.hashCode ^
        unitPrice.hashCode;
  }
}
