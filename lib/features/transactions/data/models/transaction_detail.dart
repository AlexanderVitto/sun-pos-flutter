class TransactionDetail {
  final int? id; // Add ID for existing transaction details (for updates)
  final int? productId;
  final int? productVariantId;
  final int? quantity;
  final double? unitPrice;

  const TransactionDetail({
    this.id,
    this.productId,
    this.productVariantId,
    this.quantity,
    this.unitPrice,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    if (id != null) json['id'] = id; // Include ID in JSON for updates
    if (productId != null) json['product_id'] = productId;
    if (productVariantId != null) json['product_variant_id'] = productVariantId;
    if (quantity != null) json['quantity'] = quantity;
    if (unitPrice != null) json['unit_price'] = unitPrice;

    return json;
  }

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    return TransactionDetail(
      id: json['id'],
      productId: json['product_id'],
      productVariantId: json['product_variant_id'],
      quantity: json['quantity'],
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
    );
  }

  // Calculate subtotal for this detail
  double get subtotal => (quantity ?? 0) * (unitPrice ?? 0);

  @override
  String toString() {
    return 'TransactionDetail(id: $id, productId: $productId, productVariantId: $productVariantId, quantity: $quantity, unitPrice: $unitPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionDetail &&
        other.id == id &&
        other.productId == productId &&
        other.productVariantId == productVariantId &&
        other.quantity == quantity &&
        other.unitPrice == unitPrice;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        productId.hashCode ^
        productVariantId.hashCode ^
        quantity.hashCode ^
        unitPrice.hashCode;
  }
}
