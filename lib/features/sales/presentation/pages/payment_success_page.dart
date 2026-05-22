import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/payment_constants.dart';
import '../../../transactions/data/models/store.dart';
import '../../../transactions/data/models/payment_history.dart';
import '../../providers/cart_provider.dart';
import 'receipt_page.dart';
import '../../../../data/models/cart_item.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../transactions/data/models/user.dart' as transactions_user;
import '../../../auth/data/models/user.dart' as auth_user;

class PaymentSuccessPage extends StatelessWidget {
  final String paymentMethod;
  final double amountPaid;
  final double totalAmount;
  final String? transactionNumber;
  final Store store; // Add store parameter
  final List<CartItem>? cartItems; // Store cart items before clearing
  final String? notes; // Add notes parameter
  final auth_user.User? user; // Add user parameter
  final String? status; // Add status parameter
  final DateTime? dueDate; // Add dueDate parameter
  final List<PaymentHistory>? paymentHistories;

  const PaymentSuccessPage({
    super.key,
    required this.paymentMethod,
    required this.amountPaid,
    required this.totalAmount,
    this.transactionNumber,
    required this.store,
    this.cartItems,
    this.notes,
    this.user,
    this.status,
    this.dueDate,
    this.paymentHistories,
  });

  // Helper function to convert auth_user.User to transactions_user.User
  transactions_user.User? _convertAuthUserToTransactionsUser(
    auth_user.User? authUser,
  ) {
    if (authUser == null) return null;

    return transactions_user.User(
      id: authUser.id,
      name: authUser.name,
      email: authUser.email,
      roles:
          authUser.roles
              .map(
                (authRole) => transactions_user.Role(
                  id: authRole.id,
                  name: authRole.name,
                  displayName: authRole.displayName,
                  guardName: authRole.guardName,
                  permissions: authRole.permissionNames,
                  createdAt:
                      DateTime.tryParse(authRole.createdAt) ?? DateTime.now(),
                  updatedAt:
                      DateTime.tryParse(authRole.updatedAt) ?? DateTime.now(),
                ),
              )
              .toList(),
      createdAt: DateTime.tryParse(authUser.createdAt) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(authUser.updatedAt) ?? DateTime.now(),
    );
  }

  /// Render bagian "Metode Bayar". Saat ada lebih dari satu pembayaran
  /// (split: cash + transfer), tampilkan rincian per metode dengan
  /// nominalnya. Selain itu fallback ke single label seperti sebelumnya.
  Widget _buildPaymentMethodSection() {
    final histories = paymentHistories;

    if (histories == null || histories.length <= 1) {
      final label = histories != null && histories.isNotEmpty
          ? (PaymentConstants.paymentMethods[histories.first.paymentMethod] ??
              histories.first.paymentMethod)
          : (PaymentConstants.paymentMethods[paymentMethod] ?? '');
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Metode Bayar:',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metode Bayar:',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 6),
        ...histories.map(
          (p) => Padding(
            padding: const EdgeInsets.only(left: 12, top: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  PaymentConstants.paymentMethods[p.paymentMethod] ??
                      p.paymentMethod,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Rp ${_formatAmount(p.amount)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        // Generate receipt data using passed parameters instead of cleared cart
        final receiptId =
            transactionNumber ?? 'TRX${DateTime.now().millisecondsSinceEpoch}';
        final transactionDate = DateTime.now();
        final items =
            cartItems ?? cartProvider.items; // Use passed items or fallback
        final subtotal = totalAmount;
        final discount = 0.0; // No discount for now
        final total = totalAmount; // Use the passed total amount
        final change = amountPaid - total;

        return Scaffold(
          backgroundColor: Colors.green[50],
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40), // Add some top spacing
                  // Success Animation
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.green[600],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Success Message
                  const Text(
                    'Pembayaran Berhasil!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Transaksi telah berhasil diproses',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Transaction Summary Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'No. Transaksi:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                receiptId,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Belanja:',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                'Rp ${_formatPrice(total)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[600],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Bayar:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Rp ${_formatPrice(amountPaid)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          if (change > 0) ...[
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Kembalian:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  'Rp ${_formatPrice(change)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[600],
                                  ),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 12),

                          _buildPaymentMethodSection(),

                          // Add notes section if notes exist
                          if (notes != null && notes!.trim().isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Catatan:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    notes!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // Add user section if user exists
                          if (user != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Kasir:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  user!.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Action Buttons
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            cartProvider.clearCart();

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => ReceiptPage(
                                      receiptId: receiptId,
                                      transactionDate: transactionDate,
                                      items: items,
                                      store: store,
                                      user: _convertAuthUserToTransactionsUser(
                                        user,
                                      ), // Convert and pass the user object
                                      subtotal: subtotal,
                                      discount: discount,
                                      total: total,
                                      paymentMethod:
                                          PaymentConstants
                                              .paymentMethods[paymentMethod] ??
                                          '',
                                      paymentHistories: paymentHistories,
                                      notes: notes,
                                      status: status,
                                      dueDate: dueDate,
                                    ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.receipt_long),
                          label: const Text('Lihat Struk'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Clear cart and navigate back to dashboard with Transaction tab
                            cartProvider.clearCart();

                            // Navigate to dashboard and show Transaction tab (index 1)
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder:
                                    (context) => const DashboardPage(
                                      initialIndex: 1, // Transaction tab
                                    ),
                              ),
                              (route) => false, // Remove all previous routes
                            );
                          },
                          icon: const Icon(Icons.list_alt),
                          label: const Text('Lihat Transaksi'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextButton.icon(
                        onPressed: () {
                          cartProvider.clearCart();

                          // Navigate back to dashboard (index 0)
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const DashboardPage(),
                            ),
                            (route) => false, // Remove all previous routes
                          );
                        },
                        icon: const Icon(Icons.home),
                        label: const Text('Kembali ke Dashboard'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40), // Add bottom spacing
                ],
              ),
            ),
          ),
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
