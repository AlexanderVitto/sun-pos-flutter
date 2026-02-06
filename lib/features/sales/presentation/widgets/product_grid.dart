import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../products/providers/product_provider.dart';
import 'product_card.dart';
import '../../../../data/models/product.dart';

class ProductGrid extends StatefulWidget {
  final int crossAxisCount;
  final String searchQuery;
  final String selectedCategory;
  final Function(Product, int) onAddToCart;
  final Function(Product)? onProductTap;

  const ProductGrid({
    super.key,
    required this.crossAxisCount,
    required this.searchQuery,
    required this.selectedCategory,
    required this.onAddToCart,
    this.onProductTap,
  });

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Trigger load more when 200px from bottom
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      productProvider.loadMoreProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        // Products are already filtered by backend
        // No need for client-side filtering
        final products = productProvider.products;

        // Only show full-screen loading on initial load (when products list is empty)
        if (productProvider.isLoading && products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (products.isEmpty && !productProvider.isLoading) {
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

        return Column(
          children: [
            // Show subtle loading indicator on top when refreshing (not initial load)
            if (productProvider.isLoading && products.isNotEmpty)
              Container(
                height: 3,
                child: const LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8b5cf6)),
                ),
              ),
            Expanded(
              child: GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.crossAxisCount,
                  childAspectRatio: aspectRatio,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(
                    product: product,
                    onTap: widget.onProductTap != null
                        ? () => widget.onProductTap!(product)
                        : null,
                    onAddToCart: (product, quantity) =>
                        widget.onAddToCart(product, quantity),
                  );
                },
              ),
            ),
            if (productProvider.isLoadingMore)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }
}
