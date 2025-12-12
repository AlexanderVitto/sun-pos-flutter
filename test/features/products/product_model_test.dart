import 'package:flutter_test/flutter_test.dart';
import 'package:sun_pos/data/models/product.dart';

void main() {
  group('Product Model Tests', () {
    test('Should create Product with all required fields', () {
      final product = Product(
        id: 1,
        name: 'Kembang Api Mercon',
        code: 'KA-001',
        description: 'Kembang api tipe mercon',
        price: 15000,
        stock: 100,
        category: 'Kembang Api',
        imagePath: '/images/product1.jpg',
        createdAt: DateTime(2025, 12, 1),
        updatedAt: DateTime(2025, 12, 10),
      );

      expect(product.id, 1);
      expect(product.name, 'Kembang Api Mercon');
      expect(product.code, 'KA-001');
      expect(product.price, 15000);
      expect(product.stock, 100);
      expect(product.category, 'Kembang Api');
    });

    test('Should calculate product total correctly', () {
      final product = Product(
        id: 1,
        name: 'Test Product',
        code: 'TEST-001',
        description: 'Test description',
        price: 10000,
        stock: 50,
        category: 'Test',
        imagePath: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final quantity = 5;
      final total = product.price * quantity;

      expect(total, 50000);
    });

    test('Should check stock availability', () {
      final product = Product(
        id: 1,
        name: 'Test Product',
        code: 'TEST-001',
        description: 'Test description',
        price: 10000,
        stock: 10,
        category: 'Test',
        imagePath: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(product.stock >= 5, true); // Can buy 5
      expect(product.stock >= 15, false); // Cannot buy 15
      expect(product.stock > 0, true); // In stock
    });

    test('Should handle zero stock', () {
      final product = Product(
        id: 1,
        name: 'Out of Stock Product',
        code: 'OOS-001',
        description: 'Product out of stock',
        price: 10000,
        stock: 0,
        category: 'Test',
        imagePath: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(product.stock, 0);
      expect(product.stock > 0, false);
    });
  });

  group('Product Price Calculations', () {
    test('Should calculate discount correctly', () {
      const originalPrice = 100000.0;
      const discountPercentage = 10.0;

      final discountAmount = originalPrice * (discountPercentage / 100);
      final finalPrice = originalPrice - discountAmount;

      expect(discountAmount, 10000);
      expect(finalPrice, 90000);
    });

    test('Should calculate per-item discount', () {
      const itemPrice = 50000.0;
      const quantity = 3;
      const perItemDiscount = 5000.0;

      final subtotal = itemPrice * quantity;
      final totalDiscount = perItemDiscount * quantity;
      final finalTotal = subtotal - totalDiscount;

      expect(subtotal, 150000);
      expect(totalDiscount, 15000);
      expect(finalTotal, 135000);
    });

    test('Should handle price formatting', () {
      const price = 1250000.0;

      // Simulate Indonesian rupiah formatting
      final formattedPrice = price.toStringAsFixed(0);
      final withSeparator = formattedPrice.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );

      expect(formattedPrice, '1250000');
      expect(withSeparator, '1.250.000');
    });
  });
}
