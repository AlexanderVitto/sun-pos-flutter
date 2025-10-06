import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../viewmodels/product_detail_viewmodel.dart';
import '../../data/models/product_detail_response.dart';

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
    final totalPrice = viewModel.totalPrice;
    final totalItems = viewModel.totalSelectedItems;
    final hasSelection = viewModel.hasSelectedVariants;
    final selectedVariants = viewModel.selectedVariants;

    // Check for items with quantity = 0 (marked for removal)
    final itemsToRemove =
        viewModel.variantQuantities.entries
            .where((entry) => entry.value == 0)
            .length;
    final hasChanges = hasSelection || itemsToRemove > 0;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                LucideIcons.shoppingBag,
                size: 24,
                color: Color(0xFF6366f1),
              ),
              const SizedBox(width: 12),
              const Text(
                'Ringkasan Pesanan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1f2937),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),

          // Selected Variants Summary
          if (hasSelection) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x1a6b7280)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Item yang Dipilih:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6b7280),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...selectedVariants.map((item) {
                    final variant = item['variant'] as ProductVariant;
                    final quantity = item['quantity'] as int;
                    final itemSubtotal = variant.price * quantity;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366f1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$quantity×',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  variant.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1f2937),
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.formatIDR(variant.price),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6b7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatIDR(itemSubtotal),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10b981),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

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
                        CurrencyFormatter.formatIDR(totalPrice),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1f2937),
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        hasSelection
                            ? '$totalItems item${totalItems > 1 ? 's' : ''} dari ${selectedVariants.length} varian'
                            : 'Pilih varian terlebih dahulu',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6b7280),
                        ),
                      ),
                    ],
                  ),
                ),
                // Cart Icon
                if (hasSelection)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0x1a6366f1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.shoppingCart,
                      size: 24,
                      color: Color(0xFF6366f1),
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
              onPressed: hasChanges ? onAddToCart : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    hasChanges
                        ? const Color(0xFF6366f1)
                        : const Color(0xFFe5e7eb),
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
                    hasSelection
                        ? LucideIcons.plus
                        : (itemsToRemove > 0
                            ? LucideIcons.trash2
                            : LucideIcons.packageX),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hasSelection
                        ? 'Simpan Perubahan'
                        : (itemsToRemove > 0
                            ? 'Hapus dari Keranjang'
                            : 'Pilih Varian'),
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
          if (hasSelection)
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
                  const Icon(
                    LucideIcons.check,
                    size: 16,
                    color: Color(0xFF10b981),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${selectedVariants.length} varian akan ditambahkan/diupdate',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6b7280),
                    ),
                  ),
                ],
              ),
            ),

          // Info untuk item yang akan dihapus
          if (itemsToRemove > 0 && !hasSelection)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFEF4444).withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.alertCircle,
                    size: 16,
                    color: Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$itemsToRemove item akan dihapus dari keranjang',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.w500,
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
