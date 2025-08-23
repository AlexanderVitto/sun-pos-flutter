import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import 'customer_input_dialog.dart';
import '../../../customers/data/models/customer.dart';

class CartSidebar extends StatelessWidget {
  final VoidCallback onPaymentPressed;
  final VoidCallback? onClearCart;

  const CartSidebar({
    super.key,
    required this.onPaymentPressed,
    this.onClearCart,
  });

  Future<void> _showCustomerDialog(
    BuildContext context,
    CartProvider cartProvider,
  ) async {
    // Get current customer if any
    final currentCustomer =
        cartProvider.customerName != null
            ? null // We don't have full Customer object, just name and phone
            : null;

    final selectedCustomer = await showDialog<Customer?>(
      context: context,
      builder:
          (context) => CustomerInputDialog(initialCustomer: currentCustomer),
    );

    if (selectedCustomer != null) {
      cartProvider.setCustomerName(selectedCustomer.name);
      cartProvider.setCustomerPhone(selectedCustomer.phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Column(
          children: [
            // Cart Header
            // Container(
            //   width: double.infinity,
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(color: Colors.blue[600]),
            //   child: Row(
            //     children: [
            //       const Icon(Icons.shopping_cart, color: Colors.white),
            //       const SizedBox(width: 8),
            //       Expanded(
            //         child: Text(
            //           'Keranjang (${cartProvider.itemCount})',
            //           style: const TextStyle(
            //             color: Colors.white,
            //             fontSize: 16,
            //             fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //       ),
            //       if (cartProvider.items.isNotEmpty)
            //         IconButton(
            //           icon: const Icon(Icons.delete, color: Colors.white),
            //           onPressed: () {
            //             cartProvider.clearCart();
            //             onClearCart?.call();
            //           },
            //           tooltip: 'Kosongkan Keranjang',
            //         ),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 8),

            // Cart Items
            Expanded(
              child:
                  cartProvider.items.isEmpty
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Keranjang kosong',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: cartProvider.items.length,
                        itemBuilder: (context, index) {
                          final item = cartProvider.items[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp ${_formatPrice(item.product.price)}',
                                    style: TextStyle(
                                      color: Colors.green[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: const Icon(
                                                Icons.remove,
                                                size: 16,
                                              ),
                                              onPressed:
                                                  item.quantity > 1
                                                      ? () {
                                                        cartProvider
                                                            .updateItemQuantity(
                                                              item.id,
                                                              item.quantity - 1,
                                                            );
                                                      }
                                                      : () {
                                                        cartProvider.removeItem(
                                                          item.id,
                                                        );
                                                      },
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            child: Text(
                                              '${item.quantity}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: const Icon(
                                                Icons.add,
                                                size: 16,
                                              ),
                                              onPressed:
                                                  item.quantity <
                                                          item.product.stock
                                                      ? () {
                                                        cartProvider
                                                            .updateItemQuantity(
                                                              item.id,
                                                              item.quantity + 1,
                                                            );
                                                      }
                                                      : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Rp ${_formatPrice(item.product.price * item.quantity)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),

            // Customer Information Section
            if (cartProvider.items.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Info Display or Button
                    if (cartProvider.customerName != null) ...[
                      // Selected Customer Display
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cartProvider.customerName!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (cartProvider.customerPhone != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      cartProvider.customerPhone!,
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed:
                                  () => _showCustomerDialog(
                                    context,
                                    cartProvider,
                                  ),
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.green,
                                size: 18,
                              ),
                              tooltip: 'Ubah Pembeli',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                cartProvider.setCustomerName(null);
                                cartProvider.setCustomerPhone(null);
                              },
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.red,
                                size: 18,
                              ),
                              tooltip: 'Hapus Pembeli',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Customer Input Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed:
                              () => _showCustomerDialog(context, cartProvider),
                          icon: const Icon(Icons.person_add, size: 18),
                          label: const Text(
                            'Masukkan Pembeli',
                            style: TextStyle(fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: BorderSide(color: Colors.blue[300]!),
                            foregroundColor: Colors.blue[700],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Opsional - untuk receipt dan database customer',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Cart Total and Payment
            if (cartProvider.items.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: Column(
                  children: [
                    // Total Items
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total (${cartProvider.itemCount} item)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Total Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Bayar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Rp ${_formatPrice(cartProvider.total)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Payment Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onPaymentPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'BAYAR',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
