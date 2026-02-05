import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../products/providers/product_provider.dart';
import 'product_card.dart';
import '../../../../data/models/product.dart';

class ProductGrid extends StatelessWidget {
  final int crossAxisCount;
  final String searchQuery;
  final String selectedCategory;
  final Function(Product, int) onAddToCart; // Updated to include quantity
  final Function(Product)? onProductTap; // Add onTap functionality

  const ProductGrid({
    super.key,
    required this.crossAxisCount,
    required this.searchQuery,
    required this.selectedCategory,
    required this.onAddToCart,
    this.onProductTap, // Add onTap functionality
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        // Products are already filtered by backend
        // No need for client-side filtering
        final products = productProvider.products;

        if (productProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (products.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Tidak ada produk ditemukan',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Calculate dynamic aspect ratio based on screen width
        final screenWidth = MediaQuery.of(context).size.width;
        // For Pixel 8 (~412dp) and larger: use 1.0
        // For smaller screens: use 0.75 for more height
        final aspectRatio = screenWidth >= 400 ? 1.0 : 0.85;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              onTap: onProductTap != null ? () => onProductTap!(product) : null,
              onAddToCart: (product, quantity) =>
                  onAddToCart(product, quantity),
            );
          },
        );
      },
    );
  }
}
