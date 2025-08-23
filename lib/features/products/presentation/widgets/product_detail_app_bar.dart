import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../viewmodels/product_detail_viewmodel.dart';

class ProductDetailAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final ProductDetailViewModel viewModel;

  const ProductDetailAppBar({super.key, required this.viewModel});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        viewModel.productDetail?.name ?? 'Detail Produk',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF1f2937),
        ),
      ),
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1f2937),
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(color: Color(0xFF6366f1)),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: const Color(0x0f6366f1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(LucideIcons.refreshCw, color: Color(0xFF6366f1)),
            onPressed: viewModel.loadProductDetail,
          ),
        ),
      ],
    );
  }
}
