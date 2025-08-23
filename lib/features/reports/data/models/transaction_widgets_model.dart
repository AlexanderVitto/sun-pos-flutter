class TransactionWidgetsModel {
  final int totalTransactions;
  final int totalSales;
  final int itemsSold;
  final double averageTransactionAmount;

  TransactionWidgetsModel({
    required this.totalTransactions,
    required this.totalSales,
    required this.itemsSold,
    required this.averageTransactionAmount,
  });

  factory TransactionWidgetsModel.fromJson(Map<String, dynamic> json) {
    return TransactionWidgetsModel(
      totalTransactions: json['total_transactions'] ?? 0,
      totalSales: json['total_sales'] ?? 0,
      itemsSold: json['items_sold'] ?? 0,
      averageTransactionAmount:
          (json['average_transaction_amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_transactions': totalTransactions,
      'total_sales': totalSales,
      'items_sold': itemsSold,
      'average_transaction_amount': averageTransactionAmount,
    };
  }
}
