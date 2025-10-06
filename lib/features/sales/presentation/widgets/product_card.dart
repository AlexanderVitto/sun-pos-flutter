import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/product.dart';
import '../../../sales/providers/cart_provider.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final Function(Product, int) onAddToCart; // Modified to include quantity
  final VoidCallback? onTap; // Add onTap parameter
  final bool hasMultipleVariants; // Indicator for multiple variants

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
    this.onTap, // Add onTap parameter
    this.hasMultipleVariants = false, // Default to false
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int _quantity = 1; // Default quantity

  // Helper methods for quantity management
  void _increaseQuantity() {
    if (_quantity < widget.product.stock) {
      setState(() {
        _quantity++;
      });
    }
  }

  void _decreaseQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final existingItem = cartProvider.getItemByProductId(widget.product.id);
        final isProductInCart = existingItem != null;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _getCategoryColor(
                  widget.product.category,
                ).withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap:
                widget
                    .onTap, // Use onTap for product details instead of onAddToCart
            borderRadius: BorderRadius.circular(16),
            splashColor: _getCategoryColor(
              widget.product.category,
            ).withValues(alpha: 0.1),
            highlightColor: _getCategoryColor(
              widget.product.category,
            ).withValues(alpha: 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Variant indicator badge (top-right)
                if (widget.hasMultipleVariants)
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8b5cf6),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF8b5cf6,
                            ).withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.style,
                            size: 10,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 3),
                          const Text(
                            'Variants',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Product Name with Dashboard Typography
                Text(
                  widget.product.name,
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
                const SizedBox(height: 3),
                Text(
                  widget.product.code,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6b7280),
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 8),
                // Category Badge with Dashboard Style
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(
                      widget.product.category,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.product.category,
                    style: TextStyle(
                      fontSize: 10,
                      color: _getCategoryColor(widget.product.category),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                const Spacer(),

                // Price with Dashboard Typography
                Text(
                  'Rp ${_formatPrice(widget.product.price)}',
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
                  'Stok: ${widget.product.stock}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color:
                        widget.product.stock < 10
                            ? const Color(0xFFef4444)
                            : const Color(0xFF6b7280),
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 8),

                // // Quantity Controls
                // Container(
                //   height: 32,
                //   decoration: BoxDecoration(
                //     border: Border.all(color: Colors.grey[300]!),
                //     borderRadius: BorderRadius.circular(8),
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //     children: [
                //       // Decrease button
                //       Expanded(
                //         child: InkWell(
                //           onTap: _quantity > 1 ? _decreaseQuantity : null,
                //           child: Container(
                //             height: double.infinity,
                //             decoration: BoxDecoration(
                //               color:
                //                   _quantity > 1
                //                       ? Colors.grey[100]
                //                       : Colors.grey[50],
                //               borderRadius: const BorderRadius.only(
                //                 topLeft: Radius.circular(7),
                //                 bottomLeft: Radius.circular(7),
                //               ),
                //             ),
                //             child: Icon(
                //               Icons.remove,
                //               size: 16,
                //               color:
                //                   _quantity > 1
                //                       ? Colors.grey[700]
                //                       : Colors.grey[400],
                //             ),
                //           ),
                //         ),
                //       ),
                //       // Quantity display
                //       Expanded(
                //         child: Container(
                //           height: double.infinity,
                //           color: Colors.white,
                //           child: Center(
                //             child: Text(
                //               '$_quantity',
                //               style: const TextStyle(
                //                 fontSize: 12,
                //                 fontWeight: FontWeight.bold,
                //               ),
                //             ),
                //           ),
                //         ),
                //       ),
                //       // Increase button
                //       Expanded(
                //         child: InkWell(
                //           onTap:
                //               _quantity < widget.product.stock
                //                   ? _increaseQuantity
                //                   : null,
                //           child: Container(
                //             height: double.infinity,
                //             decoration: BoxDecoration(
                //               color:
                //                   _quantity < widget.product.stock
                //                       ? Colors.grey[100]
                //                       : Colors.grey[50],
                //               borderRadius: const BorderRadius.only(
                //                 topRight: Radius.circular(7),
                //                 bottomRight: Radius.circular(7),
                //               ),
                //             ),
                //             child: Icon(
                //               Icons.add,
                //               size: 16,
                //               color:
                //                   _quantity < widget.product.stock
                //                       ? Colors.grey[700]
                //                       : Colors.grey[400],
                //             ),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // const SizedBox(height: 4),

                // Modern Add to Cart Button
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow:
                          widget.product.stock > 0
                              ? [
                                BoxShadow(
                                  color:
                                      isProductInCart
                                          ? Colors.orange.withValues(alpha: 0.2)
                                          : Colors.purple.withValues(
                                            alpha: 0.2,
                                          ),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                              : null,
                    ),
                    child: ElevatedButton(
                      onPressed:
                          widget.product.stock > 0
                              ? () =>
                                  widget.onAddToCart(widget.product, _quantity)
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            widget.product.stock > 0
                                ? (isProductInCart
                                    ? Colors.orange[600] // Orange if in cart
                                    : Colors
                                        .purple[600]) // Purple if not in cart
                                : const Color(0xFFe5e7eb),
                        foregroundColor:
                            widget.product.stock > 0
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
                            widget.product.stock > 0
                                ? (isProductInCart
                                    ? Icons.add_shopping_cart_rounded
                                    : Icons.shopping_cart_outlined)
                                : Icons.remove_shopping_cart_outlined,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.product.stock > 0
                                ? (isProductInCart
                                    ? '+ Tambah (${existingItem.quantity})'
                                    : '+ Keranjang')
                                : 'Stok Habis',
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
      },
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
