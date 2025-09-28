import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../viewmodels/product_detail_viewmodel.dart';

class AddToCartSection extends StatelessWidget {
  final ProductDetailViewModel viewModel;
  final VoidCallback onAddToCart;

  const AddToCartSection({
    super.key,
    required this.viewModel,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = viewModel.subtotal;
    final isAvailable = viewModel.isAvailable;
    final isQuantityZero = viewModel.quantity == 0;
    final isInCart = viewModel.isInCart;

    return Container(
      margin: const EdgeInsets.all(20),
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
        children: [
          // Price Summary with Enhanced Dashboard Style
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0x0f6366f1), Color(0x0a8b5cf6)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x1a6366f1)),
            ),
            child: Row(
              children: [
                // Price Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Harga',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6b7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.formatIDR(subtotal),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1f2937),
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        '${viewModel.quantity} item${viewModel.quantity > 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6b7280),
                        ),
                      ),
                    ],
                  ),
                ),
                // Cart Icon
                if (isAvailable)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isQuantityZero && isInCart
                              ? const Color(
                                0x1aef4444,
                              ) // Red background for remove
                              : const Color(
                                0x1a6366f1,
                              ), // Blue background for add
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isQuantityZero && isInCart
                          ? LucideIcons
                              .trash2 // Trash icon for remove
                          : LucideIcons.shoppingCart, // Cart icon for add
                      size: 24,
                      color:
                          isQuantityZero && isInCart
                              ? const Color(0xFFef4444) // Red for remove
                              : const Color(0xFF6366f1), // Blue for add
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Add to Cart Button with Enhanced Dashboard Style
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isAvailable ? onAddToCart : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    !isAvailable
                        ? const Color(0xFFe5e7eb)
                        : isQuantityZero && isInCart
                        ? const Color(0xFFef4444) // Red for remove
                        : const Color(0xFF6366f1), // Blue for add/update
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFe5e7eb),
                disabledForegroundColor: const Color(0xFF9ca3af),
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    !isAvailable
                        ? LucideIcons.packageX
                        : isQuantityZero && isInCart
                        ? LucideIcons
                            .trash2 // Trash icon for remove
                        : LucideIcons.plus, // Plus icon for add/update
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    !isAvailable
                        ? 'Stok Tidak Tersedia'
                        : isQuantityZero && isInCart
                        ? 'Hapus dari Keranjang' // Remove text
                        : 'Tambah ke Keranjang', // Add text
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Additional Info with Dashboard Style
          if (isAvailable)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x0a6b7280)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isQuantityZero && isInCart
                        ? LucideIcons
                            .trash2 // Trash icon for remove info
                        : LucideIcons.check, // Check icon for add info
                    size: 16,
                    color:
                        isQuantityZero && isInCart
                            ? const Color(0xFFef4444) // Red for remove
                            : const Color(0xFF10b981), // Green for add
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isQuantityZero && isInCart
                        ? 'Produk akan dihapus dari keranjang belanja'
                        : 'Produk akan ditambahkan ke keranjang belanja',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isQuantityZero && isInCart
                              ? const Color(0xFFef4444) // Red text for remove
                              : const Color(0xFF6b7280), // Gray text for add
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
