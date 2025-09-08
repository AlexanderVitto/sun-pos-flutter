import '../../../transactions/data/models/transaction_list_response.dart';
import '../../../customers/data/models/customer.dart';
import '../../../../data/models/product.dart';

/// Transaction User model
class TransactionUser {
  final int id;
  final String name;
  final String email;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const TransactionUser({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory TransactionUser.fromJson(Map<String, dynamic> json) {
    return TransactionUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      emailVerifiedAt:
          json['email_verified_at'] != null
              ? DateTime.parse(json['email_verified_at'])
              : null,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      deletedAt:
          json['deleted_at'] != null
              ? DateTime.parse(json['deleted_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}

/// Transaction Store model
class TransactionStore {
  final int id;
  final String name;
  final String address;
  final String phoneNumber;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionStore({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionStore.fromJson(Map<String, dynamic> json) {
    return TransactionStore(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      isActive: json['is_active'] ?? false,
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
      'address': address,
      'phone_number': phoneNumber,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Response for pending transactions list from API
class PendingTransactionListResponse {
  final String status;
  final String message;
  final PendingTransactionListData data;

  const PendingTransactionListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory PendingTransactionListResponse.fromJson(Map<String, dynamic> json) {
    return PendingTransactionListResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: PendingTransactionListData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'message': message, 'data': data.toJson()};
  }
}

class PendingTransactionListData {
  final List<PendingTransactionItem> data;
  final TransactionLinks links;
  final TransactionMeta meta;

  const PendingTransactionListData({
    required this.data,
    required this.links,
    required this.meta,
  });

  factory PendingTransactionListData.fromJson(Map<String, dynamic> json) {
    return PendingTransactionListData(
      data:
          (json['data'] as List<dynamic>? ?? [])
              .map((item) => PendingTransactionItem.fromJson(item))
              .toList(),
      links: TransactionLinks.fromJson(json['links'] ?? {}),
      meta: TransactionMeta.fromJson(json['meta'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
      'links': links.toJson(),
      'meta': meta.toJson(),
    };
  }
}

/// Pending transaction item from API
class PendingTransactionItem {
  final int id;
  final String transactionNumber;
  final String date;
  final double totalAmount;
  final double paidAmount;
  final double changeAmount;
  final String paymentMethod;
  final String status;
  final String? notes;
  final DateTime transactionDate;
  final Customer? customer;
  final int detailsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PendingTransactionItem({
    required this.id,
    required this.transactionNumber,
    required this.date,
    required this.totalAmount,
    required this.paidAmount,
    required this.changeAmount,
    required this.paymentMethod,
    required this.status,
    this.notes,
    required this.transactionDate,
    this.customer,
    required this.detailsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Getter for customer name with fallback
  String get customerName => customer?.name ?? 'Walk-in Customer';

  /// Getter for customer phone with null safety
  String? get customerPhone => customer?.phone;

  /// Getter for customer ID as string for compatibility
  String get customerId => customer?.id.toString() ?? '0';

  /// Total items count (using details count from API)
  int get totalItems => detailsCount;

  factory PendingTransactionItem.fromJson(Map<String, dynamic> json) {
    return PendingTransactionItem(
      id: json['id'] ?? 0,
      transactionNumber: json['transaction_number'] ?? '',
      date: json['date'] ?? '',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      paidAmount: (json['paid_amount'] ?? 0).toDouble(),
      changeAmount: (json['change_amount'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? '',
      status: json['status'] ?? '',
      notes: json['notes'],
      transactionDate: DateTime.parse(
        json['transaction_date'] ?? DateTime.now().toIso8601String(),
      ),
      customer:
          json['customer'] != null ? Customer.fromJson(json['customer']) : null,
      detailsCount: json['details_count'] ?? 0,
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
      'transaction_number': transactionNumber,
      'date': date,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'change_amount': changeAmount,
      'payment_method': paymentMethod,
      'status': status,
      'notes': notes,
      'transaction_date': transactionDate.toIso8601String(),
      'customer': customer?.toJson(),
      'details_count': detailsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'PendingTransactionItem(id: $id, transactionNumber: $transactionNumber, customerName: $customerName, totalAmount: $totalAmount)';
  }
}

/// Detailed pending transaction with items
class PendingTransactionDetail {
  final int id;
  final String transactionNumber;
  final String date;
  final double totalAmount;
  final double cashAmount;
  final double transferAmount;
  final double changeAmount;
  final String paymentMethod;
  final String status;
  final String? notes;
  final DateTime transactionDate;
  final TransactionUser? user;
  final TransactionStore? store;
  final Customer? customer;
  final List<PendingTransactionDetailItem> details;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PendingTransactionDetail({
    required this.id,
    required this.transactionNumber,
    required this.date,
    required this.totalAmount,
    required this.cashAmount,
    required this.transferAmount,
    required this.changeAmount,
    required this.paymentMethod,
    required this.status,
    this.notes,
    required this.transactionDate,
    this.user,
    this.store,
    this.customer,
    required this.details,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Getter for customer name with fallback
  String get customerName => customer?.name ?? 'Walk-in Customer';

  /// Getter for customer phone with null safety
  String? get customerPhone => customer?.phone;

  /// Getter for customer ID as string for compatibility
  String get customerId => customer?.id.toString() ?? '0';

  /// Total items count
  int get totalItems => details.fold(0, (sum, item) => sum + item.quantity);

  /// Backward compatibility - total paid amount
  double get paidAmount => cashAmount + transferAmount;

  factory PendingTransactionDetail.fromJson(Map<String, dynamic> json) {
    return PendingTransactionDetail(
      id: json['id'] ?? 0,
      transactionNumber: json['transaction_number'] ?? '',
      date: json['date'] ?? '',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      cashAmount: (json['cash_amount'] ?? 0).toDouble(),
      transferAmount: (json['transfer_amount'] ?? 0).toDouble(),
      changeAmount: (json['change_amount'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? '',
      status: json['status'] ?? '',
      notes: json['notes'],
      transactionDate: DateTime.parse(
        json['transaction_date'] ?? DateTime.now().toIso8601String(),
      ),
      user:
          json['user'] != null ? TransactionUser.fromJson(json['user']) : null,
      store:
          json['store'] != null
              ? TransactionStore.fromJson(json['store'])
              : null,
      customer:
          json['customer'] != null ? Customer.fromJson(json['customer']) : null,
      details:
          (json['details'] as List<dynamic>? ?? [])
              .map((item) => PendingTransactionDetailItem.fromJson(item))
              .toList(),
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
      'transaction_number': transactionNumber,
      'date': date,
      'total_amount': totalAmount,
      'cash_amount': cashAmount,
      'transfer_amount': transferAmount,
      'change_amount': changeAmount,
      'payment_method': paymentMethod,
      'status': status,
      'notes': notes,
      'transaction_date': transactionDate.toIso8601String(),
      'user': user?.toJson(),
      'store': store?.toJson(),
      'customer': customer?.toJson(),
      'details': details.map((item) => item.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Product Variant model for transaction details
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
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductVariant({
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
      'price': price,
      'cost_price': costPrice,
      'stock': stock,
      'attributes': attributes,
      'image': image,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Transaction detail item from API
class PendingTransactionDetailItem {
  final int id;
  final int productId;
  final int productVariantId;
  final String productName;
  final String productSku;
  final double unitPrice;
  final int quantity;
  final double totalAmount;
  final Product? product;
  final ProductVariant? productVariant;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PendingTransactionDetailItem({
    required this.id,
    required this.productId,
    required this.productVariantId,
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

  factory PendingTransactionDetailItem.fromJson(Map<String, dynamic> json) {
    return PendingTransactionDetailItem(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productVariantId: json['product_variant_id'] ?? 0,
      productName: json['product_name'] ?? '',
      productSku: json['product_sku'] ?? '',
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      product:
          json['product'] != null ? Product.fromJson(json['product']) : null,
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
      'product': product?.toJson(),
      'product_variant': productVariant?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
