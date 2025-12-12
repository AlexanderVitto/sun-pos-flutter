import 'package:flutter_test/flutter_test.dart';
import 'package:sun_pos/features/customers/data/models/payment_receipt_item.dart';
import 'package:sun_pos/features/transactions/data/models/transaction_detail_response.dart';

void main() {
  group('PaymentReceiptItem Tests', () {
    test('Should create PaymentReceiptItem with all required fields', () {
      final receiptItem = PaymentReceiptItem(
        transactionId: 1,
        receiptNumber: 'TRX-001',
        transactionDate: DateTime(2025, 12, 10),
        originalAmount: 100000,
        previousOutstanding: 50000,
        paymentAmount: 30000,
        remainingOutstanding: 20000,
        isFullyPaid: false,
      );

      expect(receiptItem.transactionId, 1);
      expect(receiptItem.receiptNumber, 'TRX-001');
      expect(receiptItem.originalAmount, 100000);
      expect(receiptItem.previousOutstanding, 50000);
      expect(receiptItem.paymentAmount, 30000);
      expect(receiptItem.remainingOutstanding, 20000);
      expect(receiptItem.isFullyPaid, false);
    });

    test('Should mark as fully paid when remaining outstanding is zero', () {
      final receiptItem = PaymentReceiptItem(
        transactionId: 2,
        receiptNumber: 'TRX-002',
        transactionDate: DateTime(2025, 12, 10),
        originalAmount: 100000,
        previousOutstanding: 30000,
        paymentAmount: 30000,
        remainingOutstanding: 0,
        isFullyPaid: true,
      );

      expect(receiptItem.isFullyPaid, true);
      expect(receiptItem.remainingOutstanding, 0);
    });

    test('Should copy receipt item with updated values', () {
      final original = PaymentReceiptItem(
        transactionId: 1,
        receiptNumber: 'TRX-001',
        transactionDate: DateTime(2025, 12, 10),
        originalAmount: 100000,
        previousOutstanding: 50000,
        paymentAmount: 30000,
        remainingOutstanding: 20000,
        isFullyPaid: false,
      );

      final updated = original.copyWith(
        paymentAmount: 50000,
        remainingOutstanding: 0,
        isFullyPaid: true,
      );

      expect(updated.transactionId, 1);
      expect(updated.paymentAmount, 50000);
      expect(updated.remainingOutstanding, 0);
      expect(updated.isFullyPaid, true);
      expect(updated.originalAmount, 100000); // Unchanged
    });

    test('Should handle transaction details in receipt item', () {
      final details = [
        TransactionDetailResponse(
          id: 1,
          productId: 1,
          productName: 'Product A',
          productSku: 'SKU-001',
          unitPrice: 10000,
          quantity: 2,
          totalAmount: 20000,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        TransactionDetailResponse(
          id: 2,
          productId: 2,
          productName: 'Product B',
          productSku: 'SKU-002',
          unitPrice: 15000,
          quantity: 3,
          totalAmount: 45000,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final receiptItem = PaymentReceiptItem(
        transactionId: 1,
        receiptNumber: 'TRX-001',
        transactionDate: DateTime(2025, 12, 10),
        originalAmount: 65000,
        previousOutstanding: 65000,
        paymentAmount: 65000,
        remainingOutstanding: 0,
        isFullyPaid: true,
        transactionDetails: details,
      );

      expect(receiptItem.transactionDetails, isNotNull);
      expect(receiptItem.transactionDetails!.length, 2);
      expect(receiptItem.transactionDetails![0].productName, 'Product A');
      expect(receiptItem.transactionDetails![1].productName, 'Product B');
    });
  });

  group('Payment Calculation Tests', () {
    test(
      'Should calculate correct payment distribution for single transaction',
      () {
        const totalOutstanding = 50000.0;
        const paymentAmount = 30000.0;

        const remaining = totalOutstanding - paymentAmount;

        expect(remaining, 20000);
        expect(remaining > 0, true);
      },
    );

    test('Should calculate correct payment distribution for full payment', () {
      const totalOutstanding = 50000.0;
      const paymentAmount = 50000.0;

      const remaining = totalOutstanding - paymentAmount;

      expect(remaining, 0);
      expect(remaining == 0, true);
    });

    test('Should calculate change amount when overpayment occurs', () {
      const totalOutstanding = 50000.0;
      const paymentAmount = 60000.0;

      const changeAmount = paymentAmount - totalOutstanding;

      expect(changeAmount, 10000);
      expect(changeAmount > 0, true);
    });

    test(
      'Should handle FIFO payment distribution across multiple transactions',
      () {
        // Transaction 1: Outstanding 30000
        // Transaction 2: Outstanding 20000
        // Transaction 3: Outstanding 15000
        // Total Outstanding: 65000
        // Payment: 45000

        const transaction1Outstanding = 30000.0;
        const transaction2Outstanding = 20000.0;
        const transaction3Outstanding = 15000.0;
        var remainingPayment = 45000.0;

        // Pay transaction 1 first (oldest)
        final payment1 = remainingPayment >= transaction1Outstanding
            ? transaction1Outstanding
            : remainingPayment;
        remainingPayment -= payment1;

        expect(payment1, 30000);
        expect(remainingPayment, 15000);

        // Pay transaction 2
        final payment2 = remainingPayment >= transaction2Outstanding
            ? transaction2Outstanding
            : remainingPayment;
        remainingPayment -= payment2;

        expect(payment2, 15000);
        expect(remainingPayment, 0);

        // No payment for transaction 3
        final payment3 = remainingPayment >= transaction3Outstanding
            ? transaction3Outstanding
            : remainingPayment;

        expect(payment3, 0);
        expect(transaction3Outstanding, 15000); // Remains unpaid
      },
    );
  });
}
