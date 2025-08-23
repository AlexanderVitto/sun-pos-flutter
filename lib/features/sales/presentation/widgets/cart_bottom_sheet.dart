import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../../../data/models/cart_item.dart';
import '../utils/pos_ui_helpers.dart';
import '../view_models/pos_transaction_view_model.dart';

class CartBottomSheet extends StatelessWidget {
  final POSTransactionViewModel viewModel;
  final VoidCallback onPaymentPressed;

  const CartBottomSheet({
    super.key,
    required this.viewModel,
    required this.onPaymentPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _buildHandle(),
              _buildHeader(context),
              _buildCartContent(scrollController),
              _buildFooter(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: 48,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFe2e8f0),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366f1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_cart_rounded,
              color: Color(0xFF6366f1),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                return Text(
                  'Keranjang Belanja (${cartProvider.itemCount})',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1f2937),
                    letterSpacing: -0.5,
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFf3f4f6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: () => Navigator.pop(context),
              color: const Color(0xFF6b7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(ScrollController scrollController) {
    return Expanded(
      child: Consumer<CartProvider>(
        builder: (_, cartProvider, child) {
          if (cartProvider.items.isEmpty) {
            return _buildEmptyCart();
          }

          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: cartProvider.items.length,
            itemBuilder: (context, index) {
              final item = cartProvider.items[index];
              return _buildCartItem(item, cartProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFf8fafc),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: Color(0xFF9ca3af),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Keranjang Belanja Kosong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1f2937),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tambahkan produk untuk memulai transaksi',
              style: TextStyle(fontSize: 14, color: Color(0xFF6b7280)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItem item, CartProvider cartProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFe2e8f0), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1f2937).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1f2937),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rp ${PosUIHelpers.formatPrice(item.product.price)}',
                  style: const TextStyle(
                    color: Color(0xFF10b981),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFf8fafc),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFfef2f2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () => cartProvider.decreaseQuantity(item.id),
                    icon: const Icon(Icons.remove_rounded, size: 18),
                    color: const Color(0xFFef4444),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1f2937),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFf0fdf4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () => cartProvider.addItem(item.product),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    color: const Color(0xFF10b981),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (_, cartProvider, child) {
        if (cartProvider.items.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFf8fafc),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFe2e8f0), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1f2937).withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total (${cartProvider.itemCount} item)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6b7280),
                    ),
                  ),
                  Text(
                    'Rp ${PosUIHelpers.formatPrice(cartProvider.total)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10b981),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10b981).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onPaymentPressed();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10b981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.payment_rounded, size: 22),
                        SizedBox(width: 12),
                        Text(
                          'PROSES PEMBAYARAN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
