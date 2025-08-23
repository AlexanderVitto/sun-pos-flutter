import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/product.dart';
import '../../../sales/providers/cart_provider.dart';
import '../../../../core/utils/format_helper.dart';
import '../../../../core/constants/app_icons.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final isInCart = cartProvider.isProductInCart(product.id);
        final cartQuantity = cartProvider.getProductQuantity(product.id);

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image placeholder
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),

                        // Stock badge
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStockBadgeColor(),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${product.stock}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // Cart badge
                        if (isInCart)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    AppIcons.cart,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$cartQuantity',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Product details
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product name
                        Text(
                          product.name,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Product code
                        Text(
                          product.code,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),

                        // Price and add button
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                FormatHelper.formatCurrency(product.price),
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),

                            // Add to cart button
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: IconButton(
                                onPressed:
                                    product.stock > 0 ? onAddToCart : null,
                                icon: Icon(
                                  AppIcons.add,
                                  size: 16,
                                  color:
                                      product.stock > 0
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      product.stock > 0
                                          ? Theme.of(
                                            context,
                                          ).primaryColor.withOpacity(0.1)
                                          : Colors.grey[200],
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Color _getStockBadgeColor() {
    if (product.stock <= 0) {
      return Colors.red;
    } else if (product.stock <= 5) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
