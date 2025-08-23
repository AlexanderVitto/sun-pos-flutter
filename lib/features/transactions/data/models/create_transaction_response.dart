import 'user.dart';
import 'store.dart';
import 'customer.dart';

class CreateTransactionResponse {
  final bool success;
  final String message;
  final TransactionData? data;

  const CreateTransactionResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CreateTransactionResponse.fromJson(Map<String, dynamic> json) {
    return CreateTransactionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          json['data'] != null ? TransactionData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data?.toJson()};
  }

  @override
  String toString() {
    return 'CreateTransactionResponse(success: $success, message: $message, data: $data)';
  }
}

class TransactionData {
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
  final User user;
  final Store store;
  final Customer? customer;
  final int detailsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionData({
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
    required this.user,
    required this.store,
    this.customer,
    required this.detailsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
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
    return 'TransactionData(id: $id, transactionNumber: $transactionNumber, totalAmount: $totalAmount, status: $status)';
  }
}
