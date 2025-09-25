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
        final allProducts = productProvider.products;
        final filteredProducts =
            allProducts.where((product) {
              final matchesSearch = product.name.toLowerCase().contains(
                searchQuery.toLowerCase(),
              );
              final matchesCategory =
                  selectedCategory.isEmpty ||
                  product.category == selectedCategory;
              return matchesSearch && matchesCategory;
            }).toList();

        if (filteredProducts.isEmpty) {
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

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
            return ProductCard(
              product: product,
              onTap: onProductTap != null ? () => onProductTap!(product) : null,
              onAddToCart:
                  (product, quantity) => onAddToCart(product, quantity),
            );
          },
        );
      },
    );
  }
}
