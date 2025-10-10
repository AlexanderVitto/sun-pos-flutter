import 'user.dart';
import 'store.dart';
import 'customer.dart';
import 'transaction_detail_response.dart';
import 'payment_history.dart';

class CreateTransactionResponse {
  final String status;
  final String message;
  final TransactionData? data;

  const CreateTransactionResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory CreateTransactionResponse.fromJson(Map<String, dynamic> json) {
    return CreateTransactionResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data:
          json['data'] != null ? TransactionData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'message': message, 'data': data?.toJson()};
  }

  @override
  String toString() {
    return 'CreateTransactionResponse(status: $status, message: $message, data: $data)';
  }
}

class TransactionData {
  final int id;
  final String transactionNumber;
  final String date;
  final double totalAmount;
  final double totalPaid;
  final double changeAmount;
  final double outstandingAmount;
  final bool? isFullyPaid;
  final String status;
  final String? notes;
  final DateTime transactionDate;
  final DateTime? outstandingReminderDate;
  final User user;
  final Store store;
  final Customer? customer;
  final List<TransactionDetailResponse> details;
  final List<PaymentHistory> paymentHistories;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionData({
    required this.id,
    required this.transactionNumber,
    required this.date,
    required this.totalAmount,
    required this.totalPaid,
    required this.changeAmount,
    required this.outstandingAmount,
    this.isFullyPaid,
    required this.status,
    this.notes,
    required this.transactionDate,
    this.outstandingReminderDate,
    required this.user,
    required this.store,
    this.customer,
    required this.details,
    required this.paymentHistories,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
      id: json['id'] ?? 0,
      transactionNumber: json['transaction_number'] ?? '',
      date: json['date'] ?? '',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      totalPaid: (json['total_paid'] ?? 0).toDouble(),
      changeAmount: (json['change_amount'] ?? 0).toDouble(),
      outstandingAmount: (json['outstanding_amount'] ?? 0).toDouble(),
      isFullyPaid: json['is_fully_paid'],
      status: json['status'] ?? '',
      notes: json['notes'],
      transactionDate: DateTime.parse(
        json['transaction_date'] ?? DateTime.now().toIso8601String(),
      ),
      outstandingReminderDate:
          json['outstanding_reminder_date'] != null
              ? DateTime.parse(json['outstanding_reminder_date'])
              : null,
      user: User.fromJson(json['user'] ?? {}),
      store: Store.fromJson(json['store'] ?? {}),
      customer:
          json['customer'] != null ? Customer.fromJson(json['customer']) : null,
      details:
          (json['details'] as List<dynamic>? ?? [])
              .map((item) => TransactionDetailResponse.fromJson(item))
              .toList(),
      paymentHistories:
          (json['payment_histories'] as List<dynamic>? ?? [])
              .map((item) => PaymentHistory.fromJson(item))
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
      'total_paid': totalPaid,
      'change_amount': changeAmount,
      'outstanding_amount': outstandingAmount,
      'is_fully_paid': isFullyPaid,
      'status': status,
      'notes': notes,
      'transaction_date': transactionDate.toIso8601String(),
      'outstanding_reminder_date': outstandingReminderDate?.toIso8601String(),
      'user': user.toJson(),
      'store': store.toJson(),
      'customer': customer?.toJson(),
      'details': details.map((detail) => detail.toJson()).toList(),
      'payment_histories':
          paymentHistories.map((payment) => payment.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Check if transaction has any items that can be refunded
  bool get hasRefundableItems {
    return details.any((detail) => detail.remainingQty > 0);
  }

  @override
  String toString() {
    return 'TransactionData(id: $id, transactionNumber: $transactionNumber, totalAmount: $totalAmount, totalPaid: $totalPaid, status: $status)';
  }
}
