import '../../../transactions/data/models/transaction_detail_response.dart';

/// Model untuk menyimpan info pembayaran per transaksi
/// Digunakan untuk generate struk pembayaran hutang
class PaymentReceiptItem {
  final int transactionId;
  final String receiptNumber;
  final DateTime transactionDate;
  final double originalAmount;
  final double previousOutstanding;
  final double paymentAmount;
  final double remainingOutstanding;
  final bool isFullyPaid;
  final List<TransactionDetailResponse>? transactionDetails;

  const PaymentReceiptItem({
    required this.transactionId,
    required this.receiptNumber,
    required this.transactionDate,
    required this.originalAmount,
    required this.previousOutstanding,
    required this.paymentAmount,
    required this.remainingOutstanding,
    required this.isFullyPaid,
    this.transactionDetails,
  });

  PaymentReceiptItem copyWith({
    int? transactionId,
    String? receiptNumber,
    DateTime? transactionDate,
    double? originalAmount,
    double? previousOutstanding,
    double? paymentAmount,
    double? remainingOutstanding,
    bool? isFullyPaid,
    List<TransactionDetailResponse>? transactionDetails,
  }) {
    return PaymentReceiptItem(
      transactionId: transactionId ?? this.transactionId,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      transactionDate: transactionDate ?? this.transactionDate,
      originalAmount: originalAmount ?? this.originalAmount,
      previousOutstanding: previousOutstanding ?? this.previousOutstanding,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      remainingOutstanding: remainingOutstanding ?? this.remainingOutstanding,
      isFullyPaid: isFullyPaid ?? this.isFullyPaid,
      transactionDetails: transactionDetails ?? this.transactionDetails,
    );
  }
}
