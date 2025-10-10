class PaymentHistory {
  final int? id;
  final int? transactionId;
  final String paymentMethod;
  final double amount;
  final String paymentDate;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PaymentHistory({
    this.id,
    this.transactionId,
    required this.paymentMethod,
    required this.amount,
    required this.paymentDate,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'payment_method': paymentMethod,
      'amount': amount,
      'payment_date': paymentDate,
    };

    if (id != null) json['id'] = id;
    if (transactionId != null) json['transaction_id'] = transactionId;
    if (notes != null) json['notes'] = notes;
    if (createdAt != null) json['created_at'] = createdAt!.toIso8601String();
    if (updatedAt != null) json['updated_at'] = updatedAt!.toIso8601String();

    return json;
  }

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      id: json['id'],
      transactionId: json['transaction_id'],
      paymentMethod: json['payment_method'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paymentDate: json['payment_date'] ?? '',
      notes: json['notes'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  @override
  String toString() {
    return 'PaymentHistory(id: $id, paymentMethod: $paymentMethod, amount: $amount, paymentDate: $paymentDate, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentHistory &&
        other.id == id &&
        other.transactionId == transactionId &&
        other.paymentMethod == paymentMethod &&
        other.amount == amount &&
        other.paymentDate == paymentDate &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        transactionId.hashCode ^
        paymentMethod.hashCode ^
        amount.hashCode ^
        paymentDate.hashCode ^
        notes.hashCode;
  }
}
