import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/pos_transaction_view_model.dart';

class POSAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isTablet;
  final VoidCallback onCartPressed;

  const POSAppBar({
    super.key,
    required this.isTablet,
    required this.onCartPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        isTablet ? 'Transaksi POS - Tablet' : 'Transaksi POS',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 20,
          letterSpacing: -0.5,
        ),
      ),
      backgroundColor: const Color(0xFF6366f1),
      elevation: 0,
      foregroundColor: Colors.white,
      actions: [if (!isTablet) _buildCartButton()],
    );
  }

  Widget _buildCartButton() {
    return Consumer<POSTransactionViewModel>(
      builder: (_, viewModel, child) {
        final cartProvider = viewModel.cartProvider;
        final itemCount = cartProvider?.itemCount ?? 0;

        print('🛒 POSAppBar: Building cart button with itemCount: $itemCount');

        return Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.shopping_cart_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: onCartPressed,
              ),
            ),
            if (itemCount > 0)
              Positioned(
                right: 8,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFef4444),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFef4444).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  child: Text(
                    '$itemCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
