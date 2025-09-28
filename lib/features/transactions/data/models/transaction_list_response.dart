import 'user.dart';
import 'store.dart';
import 'customer.dart';

class TransactionListResponse {
  final String status;
  final String message;
  final TransactionListData data;

  const TransactionListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TransactionListResponse.fromJson(Map<String, dynamic> json) {
    return TransactionListResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: TransactionListData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'message': message, 'data': data.toJson()};
  }
}

class TransactionListData {
  final List<TransactionListItem> data;
  final TransactionLinks links;
  final TransactionMeta meta;

  const TransactionListData({
    required this.data,
    required this.links,
    required this.meta,
  });

  factory TransactionListData.fromJson(Map<String, dynamic> json) {
    return TransactionListData(
      data:
          (json['data'] as List<dynamic>? ?? [])
              .map((item) => TransactionListItem.fromJson(item))
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

class TransactionListItem {
  final int id;
  final String transactionNumber;
  final String date;
  final double totalAmount;
  final double paidAmount;
  final double changeAmount;
  final String paymentMethod;
  final String status;
  final String? notes;
  final DateTime? outstandingReminderDate;
  final DateTime transactionDate;
  final User user;
  final Store store;
  final Customer? customer;
  final int detailsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionListItem({
    required this.id,
    required this.transactionNumber,
    required this.date,
    required this.totalAmount,
    required this.paidAmount,
    required this.changeAmount,
    required this.paymentMethod,
    required this.status,
    this.notes,
    this.outstandingReminderDate,
    required this.transactionDate,
    required this.user,
    required this.store,
    this.customer,
    required this.detailsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionListItem.fromJson(Map<String, dynamic> json) {
    return TransactionListItem(
      id: json['id'] ?? 0,
      transactionNumber: json['transaction_number'] ?? '',
      date: json['date'] ?? '',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      paidAmount: (json['paid_amount'] ?? 0).toDouble(),
      changeAmount: (json['change_amount'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? '',
      status: json['status'] ?? '',
      notes: json['notes'],
      outstandingReminderDate:
          json['outstanding_reminder_date'] != null
              ? DateTime.parse(json['outstanding_reminder_date'])
              : null,
      transactionDate: DateTime.parse(
        json['transaction_date'] ?? DateTime.now().toIso8601String(),
      ),
      user: User.fromJson(json['user'] ?? {}),
      store: Store.fromJson(json['store'] ?? {}),
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
      'outstanding_reminder_date': outstandingReminderDate?.toIso8601String(),
      'transaction_date': transactionDate.toIso8601String(),
      'user': user.toJson(),
      'store': store.toJson(),
      'customer': customer?.toJson(),
      'details_count': detailsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'TransactionListItem(id: $id, transactionNumber: $transactionNumber, totalAmount: $totalAmount, status: $status, outstandingReminderDate: $outstandingReminderDate)';
  }
}

class TransactionLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  const TransactionLinks({this.first, this.last, this.prev, this.next});

  factory TransactionLinks.fromJson(Map<String, dynamic> json) {
    return TransactionLinks(
      first: json['first'],
      last: json['last'],
      prev: json['prev'],
      next: json['next'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'first': first, 'last': last, 'prev': prev, 'next': next};
  }
}

class TransactionMeta {
  final int currentPage;
  final int? from;
  final int lastPage;
  final List<TransactionMetaLink> links;
  final String path;
  final int perPage;
  final int? to;
  final int total;

  const TransactionMeta({
    required this.currentPage,
    this.from,
    required this.lastPage,
    required this.links,
    required this.path,
    required this.perPage,
    this.to,
    required this.total,
  });

  factory TransactionMeta.fromJson(Map<String, dynamic> json) {
    return TransactionMeta(
      currentPage: json['current_page'] ?? 1,
      from: json['from'],
      lastPage: json['last_page'] ?? 1,
      links:
          (json['links'] as List<dynamic>? ?? [])
              .map((item) => TransactionMetaLink.fromJson(item))
              .toList(),
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 10,
      to: json['to'],
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'from': from,
      'last_page': lastPage,
      'links': links.map((item) => item.toJson()).toList(),
      'path': path,
      'per_page': perPage,
      'to': to,
      'total': total,
    };
  }
}

class TransactionMetaLink {
  final String? url;
  final String label;
  final bool active;

  const TransactionMetaLink({
    this.url,
    required this.label,
    required this.active,
  });

  factory TransactionMetaLink.fromJson(Map<String, dynamic> json) {
    return TransactionMetaLink(
      url: json['url'],
      label: json['label'] ?? '',
      active: json['active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'url': url, 'label': label, 'active': active};
  }
}
