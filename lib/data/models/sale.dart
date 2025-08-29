import 'product.dart';

enum PaymentMethod { cash, card, transfer }

class SaleItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final double subtotal;

  SaleItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  }) : subtotal = price * quantity;

  SaleItem copyWith({
    String? productId,
    String? productName,
    double? price,
    int? quantity,
  }) {
    return SaleItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      productId: json['productId'],
      productName: json['productName'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
    );
  }

  factory SaleItem.fromProduct(Product product, int quantity) {
    return SaleItem(
      productId: product.id,
      productName: product.name,
      price: product.price,
      quantity: quantity,
    );
  }
}

class Sale {
  final String id;
  final String? customerId;
  final String? customerName;
  final List<SaleItem> items;
  final double subtotal;
  final double discount;
  final double total;
  final PaymentMethod paymentMethod;
  final DateTime createdAt;

  Sale({
    required this.id,
    this.customerId,
    this.customerName,
    required this.items,
    required this.discount,
    required this.paymentMethod,
    required this.createdAt,
  }) : subtotal = items.fold(0.0, (sum, item) => sum + item.subtotal),
       total = items.fold(0.0, (sum, item) => sum + item.subtotal) - discount;

  Sale copyWith({
    String? id,
    String? customerId,
    String? customerName,
    List<SaleItem>? items,
    double? discount,
    PaymentMethod? paymentMethod,
    DateTime? createdAt,
  }) {
    return Sale(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      discount: discount ?? this.discount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'total': total,
      'paymentMethod': paymentMethod.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      items:
          (json['items'] as List)
              .map((item) => SaleItem.fromJson(item))
              .toList(),
      discount: json['discount'].toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (method) => method.name == json['paymentMethod'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  @override
  String toString() {
    return 'Sale(id: $id, total: $total, items: ${items.length})';
  }
}
