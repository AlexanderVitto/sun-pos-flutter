import '../models/product.dart';

class CartItem {
  final int id;
  final Product product;
  int quantity;
  final DateTime addedAt;

  // Discount fields
  final double? discountPercentage; // Percentage discount (0-100)
  final double? discountAmount; // Fixed discount amount
  final String? notes; // Item-specific notes

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.addedAt,
    this.discountPercentage,
    this.discountAmount,
    this.notes,
  });

  // Get unit price (product price)
  double get unitPrice => product.price;

  // Get total discount for this item
  double get totalDiscount {
    if (discountAmount != null && discountAmount! > 0) {
      return discountAmount! * quantity;
    }
    if (discountPercentage != null && discountPercentage! > 0) {
      return (unitPrice * quantity) * (discountPercentage! / 100);
    }
    return 0.0;
  }

  // Get price after discount per unit
  double get discountedUnitPrice {
    if (discountAmount != null && discountAmount! > 0) {
      return unitPrice - discountAmount!;
    }
    if (discountPercentage != null && discountPercentage! > 0) {
      return unitPrice * (1 - discountPercentage! / 100);
    }
    return unitPrice;
  }

  // Get subtotal before discount
  double get subtotalBeforeDiscount => unitPrice * quantity;

  // Get subtotal after discount
  double get subtotal => subtotalBeforeDiscount - totalDiscount;

  // Check if item has discount
  bool get hasDiscount =>
      (discountPercentage != null && discountPercentage! > 0) ||
      (discountAmount != null && discountAmount! > 0);

  // Get product variant ID (for transaction details)
  int get productVariantId => product.productVariantId ?? 0;

  // Get product ID
  int get productId => product.id;

  // Validate stock availability
  bool get hasEnoughStock => quantity <= product.stock;

  // Get remaining stock after this cart item
  int get remainingStock => product.stock - quantity;

  CartItem copyWith({
    int? id,
    Product? product,
    int? quantity,
    DateTime? addedAt,
    double? discountPercentage,
    double? discountAmount,
    String? notes,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountAmount: discountAmount ?? this.discountAmount,
      notes: notes ?? this.notes,
    );
  }

  // Create a copy with updated quantity
  CartItem withQuantity(int newQuantity) {
    return copyWith(quantity: newQuantity);
  }

  // Create a copy with discount
  CartItem withDiscount({double? percentage, double? amount}) {
    return copyWith(discountPercentage: percentage, discountAmount: amount);
  }

  // Create a copy with notes
  CartItem withNotes(String newNotes) {
    return copyWith(notes: newNotes);
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
      'subtotal': subtotal,
      'subtotalBeforeDiscount': subtotalBeforeDiscount,
      'unitPrice': unitPrice,
      'discountedUnitPrice': discountedUnitPrice,
      'totalDiscount': totalDiscount,
    };

    if (discountPercentage != null) {
      json['discountPercentage'] = discountPercentage!;
    }
    if (discountAmount != null) {
      json['discountAmount'] = discountAmount!;
    }
    if (notes != null) {
      json['notes'] = notes!;
    }

    return json;
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      addedAt: DateTime.parse(json['addedAt']),
      discountPercentage: json['discountPercentage']?.toDouble(),
      discountAmount: json['discountAmount']?.toDouble(),
      notes: json['notes'],
    );
  }

  // Convert to TransactionDetail format
  Map<String, dynamic> toTransactionDetail() {
    return {
      'product_id': productId,
      'product_variant_id': productVariantId,
      'quantity': quantity,
      'unit_price': discountedUnitPrice, // Use discounted price
    };
  }

  @override
  String toString() {
    final buffer = StringBuffer('CartItem(');
    buffer.write('product: ${product.name}, ');
    buffer.write('quantity: $quantity, ');
    buffer.write('unitPrice: $unitPrice, ');
    if (hasDiscount) {
      buffer.write('discount: $totalDiscount, ');
    }
    buffer.write('subtotal: $subtotal');
    if (notes != null && notes!.isNotEmpty) {
      buffer.write(', notes: $notes');
    }
    buffer.write(')');
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
