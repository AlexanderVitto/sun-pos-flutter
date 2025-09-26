import 'transaction_detail.dart';

class CreateTransactionRequest {
  final int? storeId;
  final String? paymentMethod;
  final double? paidAmount;
  final String? notes;
  final String? transactionDate;
  final List<TransactionDetail>? details;
  final String? customerName;
  final String? customerPhone;
  final String? status;
  final double? cashAmount;
  final double transferAmount;
  final String? outstandingReminderDate;

  const CreateTransactionRequest({
    this.storeId,
    this.paymentMethod,
    this.paidAmount,
    this.notes,
    this.transactionDate,
    this.details,
    this.customerName,
    this.customerPhone,
    this.status,
    this.cashAmount,
    this.transferAmount = 0,
    this.outstandingReminderDate,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    if (storeId != null) json['store_id'] = storeId;
    if (paymentMethod != null) json['payment_method'] = paymentMethod;
    if (paidAmount != null) json['paid_amount'] = paidAmount;
    if (notes != null) json['notes'] = notes;
    if (transactionDate != null) json['transaction_date'] = transactionDate;
    if (details != null) {
      json['details'] = details!.map((detail) => detail.toJson()).toList();
    }
    if (customerName != null) json['customer_name'] = customerName;
    if (customerPhone != null) json['customer_phone'] = customerPhone;
    if (status != null) json['status'] = status;
    if (cashAmount != null) json['cash_amount'] = cashAmount;
    // transferAmount has default value 0, so always include it
    json['transfer_amount'] = transferAmount;
    if (outstandingReminderDate != null) {
      json['outstanding_reminder_date'] = outstandingReminderDate;
    }

    return json;
  }

  factory CreateTransactionRequest.fromJson(Map<String, dynamic> json) {
    return CreateTransactionRequest(
      storeId: json['store_id'] ?? 0,
      paymentMethod: json['payment_method'] ?? '',
      paidAmount: (json['paid_amount'] ?? 0).toDouble(),
      notes: json['notes'],
      transactionDate: json['transaction_date'] ?? '',
      details:
          (json['details'] as List<dynamic>? ?? [])
              .map((item) => TransactionDetail.fromJson(item))
              .toList(),
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      status: json['status'],
      cashAmount: json['cash_amount']?.toDouble(),
      transferAmount: json['transfer_amount']?.toDouble() ?? 0,
      outstandingReminderDate: json['outstanding_reminder_date'],
    );
  }

  // Calculate total amount from all details
  double get totalAmount {
    return details?.fold(0.0, (sum, detail) => sum ?? 0 + detail.subtotal) ??
        0.0;
  }

  // Calculate change amount
  double get changeAmount {
    final change = paidAmount ?? 0 - totalAmount;
    return change > 0 ? change : 0.0;
  }

  // Validate if paid amount is sufficient
  bool get isPaidAmountSufficient => (paidAmount ?? 0) >= totalAmount;

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
    return 'CreateTransactionRequest(storeId: $storeId, paymentMethod: $paymentMethod, paidAmount: $paidAmount, notes: $notes, transactionDate: $transactionDate, details: $details, customerName: $customerName, customerPhone: $customerPhone)';
  }

  // Create a copy with updated values
  CreateTransactionRequest copyWith({
    int? storeId,
    String? paymentMethod,
    double? paidAmount,
    String? notes,
    String? transactionDate,
    List<TransactionDetail>? details,
    String? customerName,
    String? customerPhone,
    String? status,
    double? cashAmount,
    double? transferAmount,
    String? outstandingReminderDate,
  }) {
    return CreateTransactionRequest(
      storeId: storeId ?? this.storeId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paidAmount: paidAmount ?? this.paidAmount,
      notes: notes ?? this.notes,
      transactionDate: transactionDate ?? this.transactionDate,
      details: details ?? this.details,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      status: status ?? this.status,
      cashAmount: cashAmount ?? this.cashAmount,
      transferAmount: transferAmount ?? this.transferAmount,
      outstandingReminderDate:
          outstandingReminderDate ?? this.outstandingReminderDate,
    );
  }
}
