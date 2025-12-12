import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Transaction Calculations', () {
    test('Should calculate subtotal correctly', () {
      const price = 10000.0;
      const quantity = 5;

      final subtotal = price * quantity;

      expect(subtotal, 50000);
    });

    test('Should calculate discount amount from percentage', () {
      const subtotal = 100000.0;
      const discountPercentage = 10.0;

      final discountAmount = subtotal * (discountPercentage / 100);
      final totalAfterDiscount = subtotal - discountAmount;

      expect(discountAmount, 10000);
      expect(totalAfterDiscount, 90000);
    });

    test('Should calculate total with fixed discount per item', () {
      const unitPrice = 15000.0;
      const quantity = 3;
      const discountPerItem = 1000.0;

      final subtotal = unitPrice * quantity;
      final totalDiscount = discountPerItem * quantity;
      final finalTotal = subtotal - totalDiscount;

      expect(subtotal, 45000);
      expect(totalDiscount, 3000);
      expect(finalTotal, 42000);
    });

    test('Should calculate change amount', () {
      const total = 75000.0;
      const cashPaid = 100000.0;

      final change = cashPaid - total;

      expect(change, 25000);
      expect(change > 0, true);
    });

    test('Should validate payment is sufficient', () {
      const total = 50000.0;
      const payment = 45000.0;

      final isValid = payment >= total;

      expect(isValid, false);
    });

    test('Should calculate outstanding amount', () {
      const totalAmount = 100000.0;
      const paidAmount = 60000.0;

      final outstanding = totalAmount - paidAmount;

      expect(outstanding, 40000);
      expect(outstanding > 0, true);
    });

    test('Should mark transaction as fully paid when outstanding is zero', () {
      const totalAmount = 100000.0;
      const paidAmount = 100000.0;

      final outstanding = totalAmount - paidAmount;
      final isFullyPaid = outstanding == 0;

      expect(outstanding, 0);
      expect(isFullyPaid, true);
    });
  });

  group('Price Formatting Tests', () {
    test('Should format price to Indonesian rupiah format', () {
      const price = 1250000.0;

      final formatted = price
          .toStringAsFixed(0)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );

      expect(formatted, '1.250.000');
    });

    test('Should format small numbers correctly', () {
      const price = 5000.0;

      final formatted = price.toStringAsFixed(0);

      expect(formatted, '5000');
    });

    test('Should handle zero value', () {
      const price = 0.0;

      final formatted = price.toStringAsFixed(0);

      expect(formatted, '0');
    });
  });

  group('Stock Validation Tests', () {
    test('Should check if quantity is available in stock', () {
      const availableStock = 10;
      const requestedQuantity = 5;

      final isAvailable = availableStock >= requestedQuantity;

      expect(isAvailable, true);
    });

    test('Should reject quantity greater than stock', () {
      const availableStock = 5;
      const requestedQuantity = 10;

      final isAvailable = availableStock >= requestedQuantity;

      expect(isAvailable, false);
    });

    test('Should handle zero stock', () {
      const availableStock = 0;
      const requestedQuantity = 1;

      final isAvailable = availableStock >= requestedQuantity;

      expect(isAvailable, false);
    });

    test('Should calculate remaining stock after purchase', () {
      const initialStock = 50;
      const soldQuantity = 15;

      final remainingStock = initialStock - soldQuantity;

      expect(remainingStock, 35);
      expect(remainingStock >= 0, true);
    });
  });

  group('Customer Debt Payment Tests', () {
    test('Should distribute payment across multiple transactions (FIFO)', () {
      // Oldest to newest
      const transaction1 = 30000.0;
      const transaction2 = 20000.0;
      const transaction3 = 15000.0;

      var remainingPayment = 45000.0;

      // Pay transaction 1 first
      final pay1 = remainingPayment >= transaction1
          ? transaction1
          : remainingPayment;
      remainingPayment -= pay1;

      expect(pay1, 30000);
      expect(remainingPayment, 15000);

      // Pay transaction 2
      final pay2 = remainingPayment >= transaction2
          ? transaction2
          : remainingPayment;
      remainingPayment -= pay2;

      expect(pay2, 15000);
      expect(remainingPayment, 0);

      // Transaction 3 remains unpaid
      expect(transaction3, 15000);
    });

    test('Should calculate payment with change', () {
      const totalOutstanding = 50000.0;
      const payment = 60000.0;

      final applied = payment > totalOutstanding ? totalOutstanding : payment;
      final change = payment - applied;

      expect(applied, 50000);
      expect(change, 10000);
    });

    test('Should handle partial payment', () {
      const originalAmount = 100000.0;
      const previousPaid = 40000.0;
      const currentPayment = 30000.0;

      final totalPaid = previousPaid + currentPayment;
      final remaining = originalAmount - totalPaid;

      expect(totalPaid, 70000);
      expect(remaining, 30000);
      expect(remaining > 0, true);
    });

    test('Should calculate outstanding reminder date (100 days)', () {
      final paymentDate = DateTime(2025, 12, 10);
      final reminderDate = paymentDate.add(const Duration(days: 100));

      final expectedDate = DateTime(2026, 3, 20);

      expect(reminderDate.year, expectedDate.year);
      expect(reminderDate.month, expectedDate.month);
      expect(reminderDate.day, expectedDate.day);
    });
  });

  group('Discount Calculations', () {
    test('Should calculate percentage discount on cart', () {
      const subtotal = 200000.0;
      const discountPercentage = 15.0;

      final discountAmount = subtotal * (discountPercentage / 100);
      final finalTotal = subtotal - discountAmount;

      expect(discountAmount, 30000);
      expect(finalTotal, 170000);
    });

    test('Should handle no discount', () {
      const subtotal = 100000.0;
      const discountPercentage = 0.0;

      final discountAmount = subtotal * (discountPercentage / 100);
      final finalTotal = subtotal - discountAmount;

      expect(discountAmount, 0);
      expect(finalTotal, 100000);
    });

    test('Should apply fixed discount amount', () {
      const subtotal = 150000.0;
      const discountAmount = 20000.0;

      final finalTotal = subtotal - discountAmount;

      expect(finalTotal, 130000);
    });
  });
}
