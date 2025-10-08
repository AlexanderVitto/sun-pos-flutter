import 'refund_list_response.dart';

class RefundDetailResponse {
  final String status;
  final String message;
  final RefundDetailData data;

  RefundDetailResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RefundDetailResponse.fromJson(Map<String, dynamic> json) {
    return RefundDetailResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      data: RefundDetailData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'message': message, 'data': data.toJson()};
  }
}

class RefundDetailData {
  final int id;
  final String refundNumber;
  final int transactionId;
  final int customerId;
  final int userId;
  final int storeId;
  final double totalRefundAmount;
  final String refundMethod;
  final double cashRefundAmount;
  final double transferRefundAmount;
  final String status;
  final String? notes;
  final String refundDate;
  final RefundDetailUser? user;
  final RefundStore? store;
  final RefundCustomer? customer;
  final RefundTransaction? transaction;
  final List<RefundDetailItem>? details;
  final String createdAt;
  final String updatedAt;

  RefundDetailData({
    required this.id,
    required this.refundNumber,
    required this.transactionId,
    required this.customerId,
    required this.userId,
    required this.storeId,
    required this.totalRefundAmount,
    required this.refundMethod,
    required this.cashRefundAmount,
    required this.transferRefundAmount,
    required this.status,
    this.notes,
    required this.refundDate,
    this.user,
    this.store,
    this.customer,
    this.transaction,
    this.details,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RefundDetailData.fromJson(Map<String, dynamic> json) {
    return RefundDetailData(
      id: json['id'] as int,
      refundNumber: json['refund_number'] as String,
      transactionId: json['transaction_id'] as int,
      customerId: json['customer_id'] as int,
      userId: json['user_id'] as int,
      storeId: json['store_id'] as int,
      totalRefundAmount: (json['total_refund_amount'] as num).toDouble(),
      refundMethod: json['refund_method'] as String,
      cashRefundAmount: (json['cash_refund_amount'] as num).toDouble(),
      transferRefundAmount: (json['transfer_refund_amount'] as num).toDouble(),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      refundDate: json['refund_date'] as String,
      user:
          json['user'] != null
              ? RefundDetailUser.fromJson(json['user'] as Map<String, dynamic>)
              : null,
      store:
          json['store'] != null
              ? RefundStore.fromJson(json['store'] as Map<String, dynamic>)
              : null,
      customer:
          json['customer'] != null
              ? RefundCustomer.fromJson(
                json['customer'] as Map<String, dynamic>,
              )
              : null,
      transaction:
          json['transaction'] != null
              ? RefundTransaction.fromJson(
                json['transaction'] as Map<String, dynamic>,
              )
              : null,
      details:
          json['details'] != null
              ? (json['details'] as List<dynamic>)
                  .map(
                    (e) => RefundDetailItem.fromJson(e as Map<String, dynamic>),
                  )
                  .toList()
              : null,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'refund_number': refundNumber,
      'transaction_id': transactionId,
      'customer_id': customerId,
      'user_id': userId,
      'store_id': storeId,
      'total_refund_amount': totalRefundAmount,
      'refund_method': refundMethod,
      'cash_refund_amount': cashRefundAmount,
      'transfer_refund_amount': transferRefundAmount,
      'status': status,
      'notes': notes,
      'refund_date': refundDate,
      'user': user?.toJson(),
      'store': store?.toJson(),
      'customer': customer?.toJson(),
      'transaction': transaction?.toJson(),
      'details': details?.map((e) => e.toJson()).toList(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class RefundDetailUser {
  final int id;
  final String name;
  final String email;
  final List<UserRole>? roles;
  final String? createdAt;
  final String? updatedAt;

  RefundDetailUser({
    required this.id,
    required this.name,
    required this.email,
    this.roles,
    this.createdAt,
    this.updatedAt,
  });

  factory RefundDetailUser.fromJson(Map<String, dynamic> json) {
    return RefundDetailUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      roles:
          json['roles'] != null
              ? (json['roles'] as List<dynamic>)
                  .map((e) => UserRole.fromJson(e as Map<String, dynamic>))
                  .toList()
              : null,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'roles': roles?.map((e) => e.toJson()).toList(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class UserRole {
  final int id;
  final String name;
  final String displayName;
  final String guardName;
  final List<String>? permissions;
  final String? createdAt;
  final String? updatedAt;

  UserRole({
    required this.id,
    required this.name,
    required this.displayName,
    required this.guardName,
    this.permissions,
    this.createdAt,
    this.updatedAt,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id'] as int,
      name: json['name'] as String,
      displayName: json['display_name'] as String,
      guardName: json['guard_name'] as String,
      permissions:
          json['permissions'] != null
              ? (json['permissions'] as List<dynamic>)
                  .map((e) => e as String)
                  .toList()
              : null,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'guard_name': guardName,
      'permissions': permissions,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class RefundDetailItem {
  final int id;
  final int transactionDetailId;
  final int? productId;
  final int? productVariantId;
  final String productName;
  final String productSku;
  final double unitPrice;
  final int quantityRefunded;
  final double totalRefundAmount;
  final ProductVariant? productVariant;
  final String? createdAt;
  final String? updatedAt;

  RefundDetailItem({
    required this.id,
    required this.transactionDetailId,
    this.productId,
    this.productVariantId,
    required this.productName,
    required this.productSku,
    required this.unitPrice,
    required this.quantityRefunded,
    required this.totalRefundAmount,
    this.productVariant,
    this.createdAt,
    this.updatedAt,
  });

  factory RefundDetailItem.fromJson(Map<String, dynamic> json) {
    return RefundDetailItem(
      id: json['id'] as int,
      transactionDetailId: json['transaction_detail_id'] as int,
      productId: json['product_id'] as int?,
      productVariantId: json['product_variant_id'] as int?,
      productName: json['product_name'] as String,
      productSku: json['product_sku'] as String,
      unitPrice: (json['unit_price'] as num).toDouble(),
      quantityRefunded: json['quantity_refunded'] as int,
      totalRefundAmount: (json['total_refund_amount'] as num).toDouble(),
      productVariant:
          json['product_variant'] != null
              ? ProductVariant.fromJson(
                json['product_variant'] as Map<String, dynamic>,
              )
              : null,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_detail_id': transactionDetailId,
      'product_id': productId,
      'product_variant_id': productVariantId,
      'product_name': productName,
      'product_sku': productSku,
      'unit_price': unitPrice,
      'quantity_refunded': quantityRefunded,
      'total_refund_amount': totalRefundAmount,
      'product_variant': productVariant?.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class ProductVariant {
  final int id;
  final String name;
  final String sku;
  final double price;
  final double costPrice;
  final int stock;
  final Map<String, dynamic>? attributes;
  final String? image;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  ProductVariant({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.costPrice,
    required this.stock,
    this.attributes,
    this.image,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] as int,
      name: json['name'] as String,
      sku: json['sku'] as String,
      price: (json['price'] as num).toDouble(),
      costPrice: (json['cost_price'] as num).toDouble(),
      stock: json['stock'] as int,
      attributes: json['attributes'] as Map<String, dynamic>?,
      image: json['image'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
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
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
