import 'package:flutter/material.dart';
import '../../../../data/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback? onTap; // Add onTap parameter

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
    this.onTap, // Add onTap parameter
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getCategoryColor(product.category).withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap, // Use onTap for product details instead of onAddToCart
        borderRadius: BorderRadius.circular(16),
        splashColor: _getCategoryColor(product.category).withValues(alpha: 0.1),
        highlightColor: _getCategoryColor(
          product.category,
        ).withValues(alpha: 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Name with Dashboard Typography
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1f2937),
                letterSpacing: -0.2,
                height: 1.1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Category Badge with Dashboard Style
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getCategoryColor(
                  product.category,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                product.category,
                style: TextStyle(
                  fontSize: 10,
                  color: _getCategoryColor(product.category),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ),
            const Spacer(),

            // Price with Dashboard Typography
            Text(
              'Rp ${_formatPrice(product.price)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF10b981),
                letterSpacing: -0.3,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 2),

            // Stock Info
            Text(
              'Stok: ${product.stock}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color:
                    product.stock < 10
                        ? const Color(0xFFef4444)
                        : const Color(0xFF6b7280),
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(height: 8),

            // Modern Add to Cart Button
            SizedBox(
              width: double.infinity,
              height: 36,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow:
                      product.stock > 0
                          ? [
                            BoxShadow(
                              color: _getCategoryColor(
                                product.category,
                              ).withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child: ElevatedButton(
                  onPressed: product.stock > 0 ? onAddToCart : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        product.stock > 0
                            ? _getCategoryColor(product.category)
                            : const Color(0xFFe5e7eb),
                    foregroundColor:
                        product.stock > 0
                            ? Colors.white
                            : const Color(0xFF9ca3af),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        product.stock > 0
                            ? Icons.add_shopping_cart_rounded
                            : Icons.remove_shopping_cart_outlined,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        product.stock > 0 ? '+ Keranjang' : 'Stok Habis',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'single rows':
        return const Color(0xFF6366f1); // Indigo like dashboard
      case 'display cake':
        return const Color(0xFF8b5cf6); // Purple like dashboard
      case 'snacks':
        return const Color(0xFFf59e0b); // Amber like dashboard
      case 'beverages':
        return const Color(0xFF06b6d4); // Cyan like dashboard
      case 'food':
        return const Color(0xFF10b981); // Green like dashboard
      default:
        return const Color(0xFF6b7280); // Gray like dashboard
    }
  }
}
