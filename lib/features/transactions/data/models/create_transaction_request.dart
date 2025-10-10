import 'transaction_detail.dart';
import 'payment_history.dart';

class CreateTransactionRequest {
  final int? storeId;
  final String? customerName;
  final String? customerPhone;
  final List<PaymentHistory>? payments;
  final String? status;
  final String? notes;
  final String? transactionDate;
  final String? outstandingReminderDate;
  final List<TransactionDetail>? details;

  const CreateTransactionRequest({
    this.storeId,
    this.customerName,
    this.customerPhone,
    this.payments,
    this.status,
    this.notes,
    this.transactionDate,
    this.outstandingReminderDate,
    this.details,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    if (storeId != null) json['store_id'] = storeId;
    if (customerName != null) json['customer_name'] = customerName;
    if (customerPhone != null) json['customer_phone'] = customerPhone;
    if (payments != null) {
      json['payments'] = payments!.map((payment) => payment.toJson()).toList();
    }
    if (status != null) json['status'] = status;
    if (notes != null) json['notes'] = notes;
    if (transactionDate != null) json['transaction_date'] = transactionDate;
    if (outstandingReminderDate != null) {
      json['outstanding_reminder_date'] = outstandingReminderDate;
    }
    if (details != null) {
      json['details'] = details!.map((detail) => detail.toJson()).toList();
    }

    return json;
  }

  factory CreateTransactionRequest.fromJson(Map<String, dynamic> json) {
    return CreateTransactionRequest(
      storeId: json['store_id'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      payments:
          (json['payments'] as List<dynamic>? ?? [])
              .map((item) => PaymentHistory.fromJson(item))
              .toList(),
      status: json['status'],
      notes: json['notes'],
      transactionDate: json['transaction_date'],
      outstandingReminderDate: json['outstanding_reminder_date'],
      details:
          (json['details'] as List<dynamic>? ?? [])
              .map((item) => TransactionDetail.fromJson(item))
              .toList(),
    );
  }

  // Calculate total amount from all details
  double get totalAmount {
    return details?.fold(0.0, (sum, detail) => sum ?? 0 + detail.subtotal) ??
        0.0;
  }

  // Calculate total paid amount from all payments
  double get totalPaidAmount {
    return payments?.fold(0.0, (sum, payment) => sum ?? 0 + payment.amount) ??
        0.0;
  }

  // Calculate change amount
  double get changeAmount {
    final change = totalPaidAmount - totalAmount;
    return change > 0 ? change : 0.0;
  }

  // Validate if paid amount is sufficient
  bool get isPaidAmountSufficient => totalPaidAmount >= totalAmount;

  // Get total items count
  int get totalItems {
    return details?.fold(
          0,
          (sum, detail) => sum ?? 0 + (detail.quantity ?? 0),
        ) ??
        0;
  }

  @override
  String toString() {
    return 'CreateTransactionRequest(storeId: $storeId, customerName: $customerName, customerPhone: $customerPhone, payments: $payments, status: $status, notes: $notes, transactionDate: $transactionDate, details: $details)';
  }

  // Create a copy with updated values
  CreateTransactionRequest copyWith({
    int? storeId,
    String? customerName,
    String? customerPhone,
    List<PaymentHistory>? payments,
    String? status,
    String? notes,
    String? transactionDate,
    String? outstandingReminderDate,
    List<TransactionDetail>? details,
  }) {
    return CreateTransactionRequest(
      storeId: storeId ?? this.storeId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      payments: payments ?? this.payments,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      transactionDate: transactionDate ?? this.transactionDate,
      outstandingReminderDate:
          outstandingReminderDate ?? this.outstandingReminderDate,
      details: details ?? this.details,
    );
  }
}
