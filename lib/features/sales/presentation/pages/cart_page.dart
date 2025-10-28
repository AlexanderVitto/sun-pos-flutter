import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../../products/providers/product_provider.dart';
import '../../../../data/models/cart_item.dart';
import '../utils/pos_ui_helpers.dart';
import '../view_models/pos_transaction_view_model.dart';

class CartPage extends StatefulWidget {
  final POSTransactionViewModel viewModel;
  final VoidCallback onPaymentPressed;

  const CartPage({
    super.key,
    required this.viewModel,
    required this.onPaymentPressed,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    // Refresh products when cart page opens to get latest stock data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      productProvider.refreshProducts();

      // ✅ Capture initial quantities in CartProvider if not already captured
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      if (cartProvider.initialQuantities.isEmpty &&
          cartProvider.items.isNotEmpty) {
        cartProvider.captureInitialQuantities();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF1f2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366f1).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.shoppingCart,
                    color: Color(0xFF6366f1),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Keranjang (${cartProvider.itemCount})',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1f2937),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              if (cartProvider.items.isEmpty) {
                return const SizedBox.shrink();
              }
              return TextButton.icon(
                onPressed: () => _showClearCartDialog(context),
                icon: const Icon(
                  LucideIcons.trash2,
                  size: 18,
                  color: Color(0xFFef4444),
                ),
                label: const Text(
                  'Kosongkan',
                  style: TextStyle(
                    color: Color(0xFFef4444),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.items.isEmpty) {
            return _buildEmptyCart();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.items[index];
                    // Use unique key for each item to prevent Flutter from reusing wrong widget
                    return Container(
                      key: ValueKey(item.id),
                      child: _buildCartItem(context, item, cartProvider),
                    );
                  },
                ),
              ),
              _buildFooter(context, cartProvider),
            ],
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
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1f2937).withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                LucideIcons.shoppingCart,
                size: 80,
                color: Color(0xFF9ca3af),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Keranjang Belanja Kosong',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1f2937),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tambahkan produk untuk memulai transaksi',
              style: TextStyle(fontSize: 16, color: Color(0xFF6b7280)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(LucideIcons.arrowLeft, size: 20),
              label: const Text(
                'Kembali Belanja',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366f1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartItem item,
    CartProvider cartProvider,
  ) {
    // Use Consumer to get real-time stock updates from ProductProvider
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        // Get current stock from ProductProvider
        final currentProduct = productProvider.products.firstWhere((p) {
          // Check if it's a variant or main product
          if (item.product.productVariantId != null) {
            // For variants, we need to check the parent product
            return p.id == item.product.id;
          }
          return p.id == item.product.id;
        }, orElse: () => item.product);

        // Calculate available stock
        int totalStockInSystem;
        if (item.product.productVariantId != null) {
          // For variant products, get stock from variant
          totalStockInSystem = item.product.stock;
        } else {
          // For regular products
          totalStockInSystem = currentProduct.stock;
        }

        // Calculate quantity already in cart for this product
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        final quantityInCart = cartProvider.items
            .where((cartItem) => cartItem.product.id == item.product.id)
            .fold<int>(0, (sum, cartItem) => sum + cartItem.quantity);

        // ✅ Get initial quantity from CartProvider
        final initialQuantity =
            cartProvider.initialQuantities[item.product.id] ?? 0;

        // Calculate delta (change in quantity)
        final deltaQuantity = quantityInCart - initialQuantity;

        // ✅ Available stock calculation using CartProvider flag
        // - Before any action: show total stock from system
        // - After action: show total stock minus delta (change in quantity)
        final availableStock = cartProvider.hasUserAction
            ? totalStockInSystem - deltaQuantity
            : totalStockInSystem;

        final isLowStock = availableStock > 0 && availableStock <= 10;
        final isOutOfStock = availableStock <= 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFe2e8f0), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1f2937).withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Color(0xFF1f2937),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rp ${PosUIHelpers.formatPrice(item.product.price)}',
                          style: const TextStyle(
                            color: Color(0xFF10b981),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Stock badge - shows remaining stock after cart quantity
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isOutOfStock
                                ? const Color(0x1aef4444)
                                : isLowStock
                                ? const Color(0x1af59e0b)
                                : const Color(0x1a10b981),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isOutOfStock
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
                                    : LucideIcons.package,
                                size: 14,
                                color: isOutOfStock
                                    ? const Color(0xFFef4444)
                                    : isLowStock
                                    ? const Color(0xFFf59e0b)
                                    : const Color(0xFF10b981),
                              ),
                              const SizedBox(width: 4),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Stok Tersisa: $availableStock',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isOutOfStock
                                          ? const Color(0xFFef4444)
                                          : isLowStock
                                          ? const Color(0xFFf59e0b)
                                          : const Color(0xFF10b981),
                                    ),
                                  ),
                                  Text(
                                    'Total: $totalStockInSystem',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isOutOfStock
                                          ? const Color(
                                              0xFFef4444,
                                            ).withValues(alpha: 0.7)
                                          : isLowStock
                                          ? const Color(
                                              0xFFf59e0b,
                                            ).withValues(alpha: 0.7)
                                          : const Color(
                                              0xFF10b981,
                                            ).withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        _confirmRemoveItem(context, item, cartProvider),
                    icon: const Icon(LucideIcons.trash2),
                    color: const Color(0xFFef4444),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0x1aef4444),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFe2e8f0)),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Jumlah:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6b7280),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFe2e8f0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFfef2f2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            onPressed: () {
                              debugPrint(
                                '🔽 Decreasing quantity for item ID: ${item.id}, Product: ${item.product.name}',
                              );
                              // ✅ Mark user action in CartProvider
                              cartProvider.markUserAction();
                              cartProvider.decreaseQuantity(
                                item.id,
                                context: context,
                              );
                              // Note: _refreshProducts() called automatically by CartProvider
                            },
                            icon: const Icon(LucideIcons.minus, size: 18),
                            color: const Color(0xFFef4444),
                            constraints: const BoxConstraints(
                              minWidth: 44,
                              minHeight: 44,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showQuantityInputDialog(
                            context,
                            item,
                            cartProvider,
                            availableStock,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF1f2937),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color:
                                isOutOfStock || item.quantity >= availableStock
                                ? const Color(0xFFf3f4f6)
                                : const Color(0xFFf0fdf4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            onPressed:
                                isOutOfStock || item.quantity >= availableStock
                                ? null
                                : () {
                                    debugPrint(
                                      '🔼 Increasing quantity for item ID: ${item.id}, Product: ${item.product.name}',
                                    );
                                    // ✅ Mark user action in CartProvider
                                    cartProvider.markUserAction();
                                    cartProvider.addItem(
                                      item.product,
                                      context: context,
                                    );
                                    // Note: _refreshProducts() called automatically by CartProvider
                                  },
                            icon: const Icon(LucideIcons.plus, size: 18),
                            color:
                                isOutOfStock || item.quantity >= availableStock
                                ? const Color(0xFF9ca3af)
                                : const Color(0xFF10b981),
                            constraints: const BoxConstraints(
                              minWidth: 44,
                              minHeight: 44,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0x0a6366f1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Subtotal:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6b7280),
                      ),
                    ),
                    Text(
                      'Rp ${PosUIHelpers.formatPrice(item.product.price * item.quantity)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6366f1),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }, // End of Consumer<ProductProvider> builder
    ); // End of Consumer<ProductProvider>
  }

  void _showQuantityInputDialog(
    BuildContext context,
    CartItem item,
    CartProvider cartProvider,
    int availableStock,
  ) {
    final controller = TextEditingController(text: '${item.quantity}');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(LucideIcons.hash, size: 24, color: Color(0xFF6366f1)),
            const SizedBox(width: 12),
            const Text(
              'Input Jumlah',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1f2937),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.product.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6b7280),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Stok tersedia: $availableStock',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF10b981),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah',
                hintText: 'Masukkan jumlah',
                prefixIcon: const Icon(
                  LucideIcons.package,
                  color: Color(0xFF6366f1),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (value) {
                _updateQuantity(
                  context,
                  item,
                  cartProvider,
                  controller.text,
                  availableStock,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF6b7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _updateQuantity(
                context,
                item,
                cartProvider,
                controller.text,
                availableStock,
              );
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366f1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _updateQuantity(
    BuildContext context,
    CartItem item,
    CartProvider cartProvider,
    String value,
    int availableStock,
  ) {
    final quantity = int.tryParse(value);
    if (quantity == null || quantity <= 0) {
      PosUIHelpers.showErrorSnackbar(context, 'Jumlah tidak valid');
      return;
    }

    if (quantity > availableStock) {
      PosUIHelpers.showErrorSnackbar(
        context,
        'Stok tidak mencukupi! Maksimal: $availableStock',
      );
      return;
    }

    // ✅ Mark user action in CartProvider
    cartProvider.markUserAction();
    cartProvider.updateItemQuantity(item.id, quantity, context: context);
    // Note: _refreshProducts() and draft transaction update called automatically by CartProvider
    PosUIHelpers.showSuccessSnackbar(context, 'Jumlah berhasil diperbarui');
  }

  void _confirmRemoveItem(
    BuildContext context,
    CartItem item,
    CartProvider cartProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(LucideIcons.alertTriangle, size: 24, color: Color(0xFFf59e0b)),
            SizedBox(width: 12),
            Text(
              'Hapus Item',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1f2937),
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${item.product.name}" dari keranjang?',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF6b7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              cartProvider.removeItem(item.id, context: context);
              // Note: _refreshProducts() called automatically by CartProvider
              Navigator.of(context).pop();
              PosUIHelpers.showSuccessSnackbar(
                context,
                'Item berhasil dihapus',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFef4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(LucideIcons.alertTriangle, size: 24, color: Color(0xFFef4444)),
            SizedBox(width: 12),
            Text(
              'Kosongkan Keranjang',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1f2937),
              ),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus semua item dari keranjang?',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF6b7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final cartProvider = Provider.of<CartProvider>(
                context,
                listen: false,
              );
              cartProvider.clearCart();
              // Note: Products will be refreshed automatically
              Navigator.of(context).pop();
              PosUIHelpers.showSuccessSnackbar(
                context,
                'Keranjang berhasil dikosongkan',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFef4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Kosongkan'),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1f2937).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFe2e8f0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total (${cartProvider.itemCount} item)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6b7280),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${PosUIHelpers.formatPrice(cartProvider.total)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10b981),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10b981).withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onPaymentPressed();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10b981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.creditCard, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'PROSES PEMBAYARAN',
                        style: TextStyle(
                          fontSize: 17,
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
      ),
    );
  }
}
