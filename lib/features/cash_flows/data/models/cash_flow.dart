class CashFlow {
  final int id;
  final int storeId;
  final String title;
  final String description;
  final double amount;
  final String type; // 'in' or 'out'
  final String category; // 'sales', 'expense', 'transfer', etc.
  final DateTime transactionDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  CashFlow({
    required this.id,
    required this.storeId,
    required this.title,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
    required this.transactionDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CashFlow.fromJson(Map<String, dynamic> json) {
    return CashFlow(
      id: json['id'] ?? 0,
      storeId: json['store_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      type: json['type'] ?? 'in',
      category: json['category'] ?? 'sales',
      transactionDate:
          DateTime.tryParse(json['transaction_date'] ?? '') ?? DateTime.now(),
      notes: json['notes'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'title': title,
      'description': description,
      'amount': amount.toString(),
      'type': type,
      'category': category,
      'transaction_date': transactionDate.toIso8601String().split('T')[0],
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper method for formatted amount
  String get formattedAmount {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  // Helper method for type icon
  String get typeIcon {
    return type == 'in' ? '↗️' : '↘️';
  }

  // Helper method for type color (returns color name as string)
  String get typeColor {
    return type == 'in' ? 'green' : 'red';
  }
}
