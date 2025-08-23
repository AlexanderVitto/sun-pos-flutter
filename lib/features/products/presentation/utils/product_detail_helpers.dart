import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../viewmodels/product_detail_viewmodel.dart';

class ProductDetailHelpers {
  static Future<void> handleAddToCart(
    BuildContext context,
    ProductDetailViewModel viewModel,
  ) async {
    try {
      final success = await viewModel.addToCart();

      if (!context.mounted) return;

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(LucideIcons.check, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${viewModel.productDetail?.name ?? "Produk"} berhasil ditambahkan ke keranjang',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10b981),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            action: SnackBarAction(
              label: 'LIHAT KERANJANG',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pop(context); // Go back to POS page
              },
            ),
          ),
        );
      } else {
        // Show error message
        _showErrorSnackbar(
          context,
          'Gagal menambahkan produk ke keranjang. Silakan coba lagi.',
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      // Show error message
      _showErrorSnackbar(context, 'Terjadi kesalahan: ${e.toString()}');
    }
  }

  static void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.alertCircle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFef4444),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
