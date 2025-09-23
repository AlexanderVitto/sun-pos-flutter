import 'transaction_detail.dart';

class CreateTransactionRequest {
  final int storeId;
  final String paymentMethod;
  final double paidAmount;
  final String? notes;
  final String transactionDate;
  final List<TransactionDetail> details;
  final String? customerName;
  final String? customerPhone;
  final String? status;
  final double? cashAmount;
  final double transferAmount;
  final String? outstandingReminderDate;

  const CreateTransactionRequest({
    required this.storeId,
    required this.paymentMethod,
    required this.paidAmount,
    this.notes,
    required this.transactionDate,
    required this.details,
    this.customerName,
    this.customerPhone,
    this.status,
    this.cashAmount,
    this.transferAmount = 0,
    this.outstandingReminderDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'store_id': storeId,
      'payment_method': paymentMethod,
      'paid_amount': paidAmount,
      'notes': notes,
      'transaction_date': transactionDate,
      'details': details.map((detail) => detail.toJson()).toList(),
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'status': status,
      'cash_amount': cashAmount,
      'transfer_amount': transferAmount,
      'outstanding_reminder_date': outstandingReminderDate,
    };
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
    return details.fold(0.0, (sum, detail) => sum + detail.subtotal);
  }

  // Calculate change amount
  double get changeAmount {
    final change = paidAmount - totalAmount;
    return change > 0 ? change : 0.0;
  }

  // Validate if paid amount is sufficient
  bool get isPaidAmountSufficient => paidAmount >= totalAmount;

  // Get total items count
  int get totalItems {
    return details.fold(0, (sum, detail) => sum + detail.quantity);
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
