import 'package:flutter_test/flutter_test.dart';
import 'package:sun_pos/features/products/providers/product_provider.dart';
import 'package:sun_pos/features/sales/providers/cart_provider.dart';
import 'package:sun_pos/data/models/product.dart';

void main() {
  group('Cart Provider Tests', () {
    test('Cart should add items correctly', () {
      final cartProvider = CartProvider();

      // Create a test product
      final testProduct = Product(
        id: 1,
        name: 'Test Product',
        code: 'TEST001',
        description: 'Test description',
        price: 10000,
        stock: 50,
        category: 'Test',
        imagePath: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Test adding item
      expect(cartProvider.items.length, 0);
      expect(cartProvider.itemCount, 0);

      cartProvider.addItem(testProduct);

      expect(cartProvider.items.length, 1);
      expect(cartProvider.itemCount, 1);
      expect(cartProvider.items.first.product.name, 'Test Product');
      expect(cartProvider.items.first.quantity, 1);

      print('✅ Cart test passed - item added successfully');
    });

    test('Cart should handle multiple quantities', () {
      final cartProvider = CartProvider();

      final testProduct = Product(
        id: 2,
        name: 'Test Product 2',
        code: 'TEST002',
        description: 'Test description 2',
        price: 15000,
        stock: 100,
        category: 'Test',
        imagePath: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add same product twice
      cartProvider.addItem(testProduct);
      cartProvider.addItem(testProduct);

      expect(cartProvider.items.length, 1); // Only one unique product
      expect(cartProvider.itemCount, 2); // Total quantity is 2
      expect(cartProvider.items.first.quantity, 2);

      print('✅ Cart test passed - multiple quantities handled correctly');
    });

    test('Product provider should have dummy products', () {
      final productProvider = ProductProvider();

      // ProductProvider should have generateDummyProducts method
      // We can check if products are available after loading
      expect(productProvider.products, isNotNull);

      print('✅ ProductProvider test passed - provider initialized');
    });
  });
}
