import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../viewmodels/product_detail_viewmodel.dart';

class ProductDetailHelpers {
  static Future<void> handleAddToCart(
    BuildContext context,
    ProductDetailViewModel viewModel,
  ) async {
    try {
      // Tentukan aksi penghapusan murni berdasarkan state multi-varian,
      // selaras dengan tombol di AddToCartSection: tidak ada varian terpilih
      // (quantity > 0) tetapi ada varian yang di-set 0 (ditandai untuk dihapus).
      // Sebelumnya memakai `viewModel.quantity` (jalur satu-quantity lama) yang
      // umumnya bernilai 1, sehingga penghapusan salah terdeteksi sebagai
      // penambahan.
      final hasSelection = viewModel.hasSelectedVariants;
      final itemsToRemove = viewModel.variantQuantities.values
          .where((q) => q == 0)
          .length;
      final isRemoveAction = !hasSelection && itemsToRemove > 0;

      // updateCartQuantity menangani penambahan/perubahan sekaligus penghapusan
      // varian ber-quantity 0, jadi dipakai untuk kedua kasus.
      final success = await viewModel.updateCartQuantity(context: context);
      final successMessage = isRemoveAction
          ? '${viewModel.productDetail?.name ?? "Produk"} berhasil dihapus dari keranjang'
          : '${viewModel.productDetail?.name ?? "Produk"} berhasil ditambahkan ke keranjang';

      if (!context.mounted) return;

      // Tutup snackbar yang sedang tampil agar tidak menumpuk di antrian
      // (penyebab snackbar terlihat "tidak tertutup").
      final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();

      if (success) {
        // Show success message
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  isRemoveAction ? LucideIcons.trash2 : LucideIcons.check,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    successMessage,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: isRemoveAction
                ? const Color(0xFFef4444) // Red for remove
                : const Color(0xFF10b981), // Green for add
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            action: isRemoveAction
                ? null
                : SnackBarAction(
                    label: 'LIHAT KERANJANG',
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.pop(context); // Go back to POS page
                    },
                  ),
          ),
        );

        // Log successful cart operation
        debugPrint(
          '✅ ProductDetailHelpers: Cart operation completed successfully - ${isRemoveAction ? 'Removed' : 'Added/Updated'} ${viewModel.productDetail?.name}',
        );
      } else {
        // Show error message
        _showErrorSnackbar(
          context,
          'Gagal ${isRemoveAction ? 'menghapus produk dari' : 'menambahkan produk ke'} keranjang. Silakan coba lagi.',
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      // Show error message
      _showErrorSnackbar(context, 'Terjadi kesalahan: ${e.toString()}');
    }
  }

  static void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                LucideIcons.alertCircle,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
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
