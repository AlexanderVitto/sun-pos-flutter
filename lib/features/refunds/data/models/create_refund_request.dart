class CreateRefundRequest {
  final int transactionId;
  final int storeId;
  final String refundMethod;
  final double cashRefundAmount;
  final double transferRefundAmount;
  final String status;
  final String? notes;
  final String refundDate;
  final List<RefundDetailRequest> details;

  CreateRefundRequest({
    required this.transactionId,
    required this.storeId,
    required this.refundMethod,
    required this.cashRefundAmount,
    required this.transferRefundAmount,
    required this.status,
    this.notes,
    required this.refundDate,
    required this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'store_id': storeId,
      'refund_method': refundMethod,
      'cash_refund_amount': cashRefundAmount,
      'transfer_refund_amount': transferRefundAmount,
      'status': status,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      'refund_date': refundDate,
      'details': details.map((e) => e.toJson()).toList(),
    };
  }
}

class RefundDetailRequest {
  final int transactionDetailId;
  final int quantityRefunded;

  RefundDetailRequest({
    required this.transactionDetailId,
    required this.quantityRefunded,
  });

  Map<String, dynamic> toJson() {
    return {
      'transaction_detail_id': transactionDetailId,
      'quantity_refunded': quantityRefunded,
    };
  }
}
