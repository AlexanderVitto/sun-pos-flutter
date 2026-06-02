import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sun_pos/data/models/cart_item.dart';
import 'package:sun_pos/data/models/product.dart';
import 'package:sun_pos/features/sales/presentation/services/receipt_pdf_builder.dart';

CartItem _fixtureItem() => CartItem(
  id: 1,
  product: Product(
    id: 101,
    name: 'Kopi Susu Gula Aren',
    price: 25000,
    stock: 100,
  ),
  quantity: 2,
  addedAt: DateTime(2026, 5, 22, 10, 30),
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('ReceiptPdfBuilder.buildPreview', () {
    test('produces a valid PDF without requiring store data', () async {
      final bytes = await ReceiptPdfBuilder.buildPreview(
        previewDate: DateTime(2026, 5, 22, 10, 30),
        items: [_fixtureItem()],
        customerName: 'Budi Santoso',
        customerPhone: '081234567890',
        subtotal: 50000,
        discount: 0,
        total: 50000,
      );

      expect(bytes, isNotEmpty);
      expect(
        String.fromCharCodes(bytes.take(5)),
        '%PDF-',
        reason: 'Output should be a valid PDF file (magic header)',
      );
    });
  });

  group('ReceiptPdfBuilder.build', () {
    test('produces a valid paid-receipt PDF without requiring store data',
        () async {
      final bytes = await ReceiptPdfBuilder.build(
        receiptId: 'TRX-TEST-001',
        transactionDate: DateTime(2026, 5, 22, 10, 30),
        items: [_fixtureItem()],
        subtotal: 50000,
        discount: 0,
        total: 50000,
      );

      expect(bytes, isNotEmpty);
      expect(
        String.fromCharCodes(bytes.take(5)),
        '%PDF-',
        reason: 'Output should be a valid PDF file (magic header)',
      );
    });
  });
}
