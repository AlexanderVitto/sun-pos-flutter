class RefundListResponse {
  final String status;
  final String message;
  final RefundData data;

  RefundListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RefundListResponse.fromJson(Map<String, dynamic> json) {
    return RefundListResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      data: RefundData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'message': message, 'data': data.toJson()};
  }
}

class RefundData {
  final List<RefundItem> data;
  final RefundLinks links;
  final RefundMeta meta;

  RefundData({required this.data, required this.links, required this.meta});

  factory RefundData.fromJson(Map<String, dynamic> json) {
    return RefundData(
      data:
          (json['data'] as List<dynamic>)
              .map((e) => RefundItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      links: RefundLinks.fromJson(json['links'] as Map<String, dynamic>),
      meta: RefundMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => e.toJson()).toList(),
      'links': links.toJson(),
      'meta': meta.toJson(),
    };
  }
}

class RefundItem {
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
  final RefundUser? user;
  final RefundStore? store;
  final RefundCustomer? customer;
  final RefundTransaction? transaction;
  final List<RefundDetail>? details;
  final String createdAt;
  final String updatedAt;

  RefundItem({
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

  factory RefundItem.fromJson(Map<String, dynamic> json) {
    return RefundItem(
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
              ? RefundUser.fromJson(json['user'] as Map<String, dynamic>)
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
                  .map((e) => RefundDetail.fromJson(e as Map<String, dynamic>))
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

class RefundUser {
  final int id;
  final String name;
  final String email;

  RefundUser({required this.id, required this.name, required this.email});

  factory RefundUser.fromJson(Map<String, dynamic> json) {
    return RefundUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}

class RefundStore {
  final int id;
  final String name;
  final String address;
  final String phoneNumber;
  final bool isActive;

  RefundStore({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.isActive,
  });

  factory RefundStore.fromJson(Map<String, dynamic> json) {
    return RefundStore(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      phoneNumber: json['phone_number'] as String,
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone_number': phoneNumber,
      'is_active': isActive,
    };
  }
}

class RefundCustomer {
  final int id;
  final String name;
  final String? phone;

  RefundCustomer({required this.id, required this.name, this.phone});

  factory RefundCustomer.fromJson(Map<String, dynamic> json) {
    return RefundCustomer(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'phone': phone};
  }
}

class RefundTransaction {
  final int id;
  final String transactionNumber;
  final String date;
  final double totalAmount;
  final double totalPaid;
  final double changeAmount;
  final double outstandingAmount;
  final String status;
  final String? notes;
  final String transactionDate;
  final String? outstandingReminderDate;

  RefundTransaction({
    required this.id,
    required this.transactionNumber,
    required this.date,
    required this.totalAmount,
    required this.totalPaid,
    required this.changeAmount,
    required this.outstandingAmount,
    required this.status,
    this.notes,
    required this.transactionDate,
    this.outstandingReminderDate,
  });

  factory RefundTransaction.fromJson(Map<String, dynamic> json) {
    return RefundTransaction(
      id: json['id'] as int,
      transactionNumber: json['transaction_number'] as String,
      date: json['date'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      totalPaid: (json['total_paid'] as num).toDouble(),
      changeAmount: (json['change_amount'] as num).toDouble(),
      outstandingAmount: (json['outstanding_amount'] as num).toDouble(),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      transactionDate: json['transaction_date'] as String,
      outstandingReminderDate: json['outstanding_reminder_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_number': transactionNumber,
      'date': date,
      'total_amount': totalAmount,
      'total_paid': totalPaid,
      'change_amount': changeAmount,
      'outstanding_amount': outstandingAmount,
      'status': status,
      'notes': notes,
      'transaction_date': transactionDate,
      'outstanding_reminder_date': outstandingReminderDate,
    };
  }
}

class RefundDetail {
  final int id;
  final int transactionDetailId;
  final int? productId;
  final int? productVariantId;
  final String productName;
  final String productSku;
  final double unitPrice;
  final int quantityRefunded;
  final double totalRefundAmount;

  RefundDetail({
    required this.id,
    required this.transactionDetailId,
    this.productId,
    this.productVariantId,
    required this.productName,
    required this.productSku,
    required this.unitPrice,
    required this.quantityRefunded,
    required this.totalRefundAmount,
  });

  factory RefundDetail.fromJson(Map<String, dynamic> json) {
    return RefundDetail(
      id: json['id'] as int,
      transactionDetailId: json['transaction_detail_id'] as int,
      productId: json['product_id'] as int?,
      productVariantId: json['product_variant_id'] as int?,
      productName: json['product_name'] as String,
      productSku: json['product_sku'] as String,
      unitPrice: (json['unit_price'] as num).toDouble(),
      quantityRefunded: json['quantity_refunded'] as int,
      totalRefundAmount: (json['total_refund_amount'] as num).toDouble(),
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
    };
  }
}

class RefundLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  RefundLinks({this.first, this.last, this.prev, this.next});

  factory RefundLinks.fromJson(Map<String, dynamic> json) {
    return RefundLinks(
      first: json['first'] as String?,
      last: json['last'] as String?,
      prev: json['prev'] as String?,
      next: json['next'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'first': first, 'last': last, 'prev': prev, 'next': next};
  }
}

class RefundMeta {
  final int currentPage;
  final int? from;
  final int lastPage;
  final String path;
  final int perPage;
  final int? to;
  final int total;

  RefundMeta({
    required this.currentPage,
    this.from,
    required this.lastPage,
    required this.path,
    required this.perPage,
    this.to,
    required this.total,
  });

  factory RefundMeta.fromJson(Map<String, dynamic> json) {
    return RefundMeta(
      currentPage: json['current_page'] as int,
      from: json['from'] as int?,
      lastPage: json['last_page'] as int,
      path: json['path'] as String,
      perPage: json['per_page'] as int,
      to: json['to'] as int?,
      total: json['total'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'from': from,
      'last_page': lastPage,
      'path': path,
      'per_page': perPage,
      'to': to,
      'total': total,
    };
  }
}
