import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../data/models/product_detail_response.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../viewmodels/product_detail_viewmodel.dart';
import '../../../sales/providers/cart_provider.dart';

class VariantsSection extends StatelessWidget {
  final ProductDetailViewModel viewModel;

  const VariantsSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final productDetail = viewModel.productDetail!;
    if (productDetail.variants.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x1a6366f1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1a6366f1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header with Dashboard Style
          Row(
            children: [
              const Icon(
                LucideIcons.layers,
                size: 24,
                color: Color(0xFF6366f1),
              ),
              const SizedBox(width: 12),
              const Text(
                'Varian Produk',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1f2937),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x1a6366f1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${productDetail.variants.length}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6366f1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Variant List
          ...productDetail.variants.map((variant) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _VariantCard(variant: variant, viewModel: viewModel),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _VariantCard extends StatelessWidget {
  final ProductVariant variant;
  final ProductDetailViewModel viewModel;

  const _VariantCard({required this.variant, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        // Get quantity for this variant
        final quantity = viewModel.getVariantQuantity(variant.id);

        // Get quantity already in cart for this variant
        final cartItem = cartProvider.items.firstWhere(
          (item) => item.product.productVariantId == variant.id,
          orElse: () => cartProvider.items.first,
        );
        final quantityInCart =
            cartItem.product.productVariantId == variant.id
                ? cartItem.quantity
                : 0;

        // Calculate remaining stock
        final remainingStock = variant.stock - quantityInCart;
        final isOutOfStock = remainingStock <= 0;
        final isLowStock = remainingStock > 0 && remainingStock <= 10;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  quantity > 0
                      ? const Color(0xFF6366f1)
                      : const Color(0x1a6b7280),
              width: quantity > 0 ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Variant Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          variant.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1f2937),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.formatIDR(variant.price),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10b981),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Stock Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isOutOfStock
                              ? const Color(0x1aef4444)
                              : isLowStock
                              ? const Color(0x1af59e0b)
                              : const Color(0x1a10b981),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isOutOfStock
                                ? const Color(0x3aef4444)
                                : isLowStock
                                ? const Color(0x3af59e0b)
                                : const Color(0x3a10b981),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isOutOfStock
                              ? LucideIcons.xCircle
                              : isLowStock
                              ? LucideIcons.alertTriangle
                              : LucideIcons.check,
                          size: 14,
                          color:
                              isOutOfStock
                                  ? const Color(0xFFef4444)
                                  : isLowStock
                                  ? const Color(0xFFf59e0b)
                                  : const Color(0xFF10b981),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Stok: $remainingStock',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                isOutOfStock
                                    ? const Color(0xFFef4444)
                                    : isLowStock
                                    ? const Color(0xFFf59e0b)
                                    : const Color(0xFF10b981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // SKU and Attributes
              const SizedBox(height: 12),
              Text(
                'SKU: ${variant.sku}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6b7280)),
              ),

              if (variant.attributes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      variant.attributes.entries.map((entry) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0x1a6b7280)),
                          ),
                          child: Text(
                            '${entry.key}: ${entry.value}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6b7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ],

              // Cart Info
              if (quantityInCart > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0x0a6366f1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0x1a6366f1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.shoppingCart,
                        size: 14,
                        color: Color(0xFF6366f1),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Di keranjang: $quantityInCart item',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6366f1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Quantity Controls
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Jumlah:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1f2937),
                    ),
                  ),
                  const Spacer(),
                  // Quantity Controls
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF6366f1)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        // Decrease Button
                        _buildQuantityButton(
                          icon: LucideIcons.minus,
                          onPressed:
                              quantity > 0 && !isOutOfStock
                                  ? () => viewModel.decreaseVariantQuantity(
                                    variant.id,
                                  )
                                  : null,
                        ),
                        // Quantity Display
                        Container(
                          width: 60,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: const BoxDecoration(color: Colors.white),
                          child: Text(
                            '$quantity',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1f2937),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // Increase Button
                        _buildQuantityButton(
                          icon: LucideIcons.plus,
                          onPressed:
                              !isOutOfStock && quantity < remainingStock
                                  ? () => viewModel.increaseVariantQuantity(
                                    variant.id,
                                  )
                                  : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color:
            onPressed != null
                ? const Color(0xFF6366f1)
                : const Color(0xFFe5e7eb),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 18,
          color: onPressed != null ? Colors.white : const Color(0xFF9ca3af),
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
