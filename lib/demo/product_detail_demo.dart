import 'package:flutter/material.dart';
import '../features/products/presentation/pages/product_detail_page.dart';

class ProductDetailDemoPage extends StatelessWidget {
  const ProductDetailDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail Demo'),
        backgroundColor: const Color(0xFF6366f1),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Refactored ProductDetailPage',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              '✅ Separation of Concerns',
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
            const Text(
              '✅ MVVM Architecture',
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
            const Text(
              '✅ ProxyProvider for CartProvider',
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
            const Text(
              '✅ Clean Presentation Layer',
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductDetailPage(productId: 1),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366f1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Test Product Detail Page'),
            ),
          ],
        ),
      ),
    );
  }
}
