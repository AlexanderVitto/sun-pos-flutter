import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sun_pos/data/models/product.dart';
import 'package:sun_pos/features/products/providers/product_provider.dart';
import '../../providers/pending_transaction_provider.dart';
import '../../data/models/pending_transaction_api_models.dart';
import 'customer_selection_page.dart';
import '../../providers/cart_provider.dart';
import 'pos_transaction_page.dart';

class PendingTransactionListPage extends StatefulWidget {
  const PendingTransactionListPage({super.key});

  @override
  State<PendingTransactionListPage> createState() =>
      _PendingTransactionListPageState();
}

class _PendingTransactionListPageState
    extends State<PendingTransactionListPage> {
  @override
  void initState() {
    super.initState();
    // Load pending transactions on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pendingProvider = Provider.of<PendingTransactionProvider>(
        context,
        listen: false,
      );
      pendingProvider.loadPendingTransactions();
    });
  }

  Future<void> _refreshTransactions() async {
    final pendingProvider = Provider.of<PendingTransactionProvider>(
      context,
      listen: false,
    );
    await pendingProvider.loadPendingTransactions();
  }

  void _resumeTransaction(dynamic transaction) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final pendingProvider = Provider.of<PendingTransactionProvider>(
      context,
      listen: false,
    );
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    try {
      // Clear current cart
      cartProvider.clearCart();

      if (transaction is PendingTransactionItem) {
        // Handle API transaction - need to get detail first
        final detail = await pendingProvider.getPendingTransactionDetail(
          transaction.id,
        );

        // Set draft transaction ID for future updates
        cartProvider.setDraftTransactionId(transaction.id);
        debugPrint('🔄 Setting draft transaction ID: ${transaction.id}');

        // Convert API detail items to cart items
        for (final item in detail.details) {
          if (item.product != null) {
            // find product in productProvider, return null if not found
            Product? product =
                productProvider.products
                        .where((p) => p.id == item.product!.id)
                        .isNotEmpty
                    ? productProvider.products.firstWhere(
                      (p) => p.id == item.product!.id,
                    )
                    : null;

            if (product != null) {
              cartProvider.addItem(product, quantity: item.quantity);
            } else {
              debugPrint(
                '⚠️ Product with ID ${item.product!.id} not found in productProvider',
              );
            }
          }
        }

        // Set customer from API customer format
        if (detail.customer != null) {
          cartProvider.setCustomerFromApi(detail.customer!);
        }

        // Show confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Melanjutkan transaksi untuk ${detail.customerName}'),
            backgroundColor: Colors.blue,
          ),
        );
      } else if (transaction is PendingTransaction) {
        // Handle local transaction (backward compatibility)
        // Note: Local transactions don't have API transaction ID
        debugPrint(
          '🔄 Resuming local pending transaction (no API transaction ID)',
        );

        // Load cart items
        for (final item in transaction.cartItems) {
          cartProvider.addItem(item.product, quantity: item.quantity);
        }

        // Set customer from API customer format
        final apiCustomer = transaction.customer;
        cartProvider.setCustomerFromApi(apiCustomer);

        // Show confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Melanjutkan transaksi untuk ${transaction.customerName}',
            ),
            backgroundColor: Colors.blue,
          ),
        );
      }

      // Delay untuk memastikan provider state ter-update
      await Future.delayed(const Duration(milliseconds: 100));

      // Debug: Verify cart state before navigation
      debugPrint(
        '🛒 Cart items before navigation: ${cartProvider.items.length}',
      );
      debugPrint(
        '🛒 Selected customer: ${cartProvider.selectedCustomer?.name}',
      );

      // Navigate to POS page dengan context yang sama untuk mempertahankan provider state
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const POSTransactionPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal melanjutkan transaksi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('❌ Error resuming transaction: $e');
    }
  }

  Future<void> _deleteTransaction(dynamic transaction) async {
    String customerName;
    if (transaction is PendingTransactionItem) {
      customerName = transaction.customerName;
    } else if (transaction is PendingTransaction) {
      customerName = transaction.customerName;
    } else {
      customerName = 'Unknown Customer';
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Transaksi Pending'),
            content: Text(
              'Apakah Anda yakin ingin menghapus transaksi pending untuk $customerName?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        final pendingProvider = Provider.of<PendingTransactionProvider>(
          context,
          listen: false,
        );

        if (transaction is PendingTransactionItem) {
          // Delete API transaction by ID
          await pendingProvider.deletePendingTransactionById(transaction.id);
        } else if (transaction is PendingTransaction) {
          // Delete local transaction by customer ID
          await pendingProvider.deletePendingTransaction(
            transaction.customerId,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Transaksi untuk $customerName berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus transaksi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _createNewTransaction() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CustomerSelectionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshTransactions,
          color: const Color(0xFF3B82F6),
          child: Consumer<PendingTransactionProvider>(
            builder: (context, pendingProvider, child) {
              final transactions = pendingProvider.allPendingTransactionsList;

              if (pendingProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
                );
              }

              if (transactions.isEmpty) {
                return _buildEmptyState();
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with title and refresh button
                    _buildHeader(),
                    const SizedBox(height: 24),

                    // Error message if any
                    if (pendingProvider.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.alertTriangle,
                              color: Colors.orange,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                pendingProvider.errorMessage!,
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Header stats
                    _buildHeaderStats(transactions),
                    const SizedBox(height: 24),

                    // Transactions list
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return _buildTransactionCard(transaction);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewTransaction,
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(LucideIcons.plus, size: 20),
        label: const Text(
          'Transaksi Baru',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Transaksi Pending',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        IconButton(
          icon: const Icon(LucideIcons.refreshCw, color: Color(0xFF6B7280)),
          onPressed: _refreshTransactions,
        ),
      ],
    );
  }

  Widget _buildHeaderStats(List<dynamic> transactions) {
    final totalTransactions = transactions.length;
    double totalAmount = 0;
    int totalItems = 0;

    for (final transaction in transactions) {
      if (transaction is PendingTransactionItem) {
        totalAmount += transaction.totalAmount;
        totalItems += transaction.totalItems;
      } else if (transaction is PendingTransaction) {
        totalAmount += transaction.totalAmount;
        totalItems += transaction.totalItems;
      }
    }

    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  LucideIcons.clock,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Transaksi Pending',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total $totalTransactions transaksi',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Nilai',
                  formatCurrency.format(totalAmount),
                  LucideIcons.dollarSign,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Total Item',
                  totalItems.toString(),
                  LucideIcons.package,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 16),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 40),

          // Empty state content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6B7280).withValues(alpha: 0.1),
                        const Color(0xFF9CA3AF).withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Icon(
                    LucideIcons.receipt,
                    size: 64,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Belum ada transaksi pending',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF374151),
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mulai transaksi baru untuk melayani pelanggan',
                  style: TextStyle(
                    color: const Color(0xFF6B7280),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF3B82F6),
                        const Color(0xFF1D4ED8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _createNewTransaction,
                    icon: const Icon(LucideIcons.plus, size: 20),
                    label: const Text(
                      'Buat Transaksi Baru',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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

  Widget _buildTransactionCard(PendingTransactionItem transaction) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final formatDate = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    String customerName = transaction.customerName;
    String? customerPhone = transaction.customerPhone;
    double totalAmount = transaction.totalAmount;
    int totalItems = transaction.totalItems;
    DateTime createdAt = transaction.createdAt;
    DateTime updatedAt = transaction.updatedAt;
    String? notes = transaction.notes;

    // Extract common properties based on transaction type
    // String customerName;
    // String? customerPhone;
    // double totalAmount;
    // int totalItems;
    // DateTime createdAt;
    // DateTime updatedAt;
    // String? notes;

    // if (transaction is PendingTransactionItem) {

    // } else if (transaction is PendingTransaction) {
    //   customerName = transaction.customerName;
    //   customerPhone = transaction.customerPhone;
    //   totalAmount = transaction.totalAmount;
    //   totalItems = transaction.totalItems;
    //   createdAt = transaction.createdAt;
    //   updatedAt = transaction.updatedAt;
    //   notes = transaction.notes;
    // } else {
    //   // Fallback values
    //   customerName = 'Unknown Customer';
    //   customerPhone = null;
    //   totalAmount = 0.0;
    //   totalItems = 0;
    //   createdAt = DateTime.now();
    //   updatedAt = DateTime.now();
    //   notes = null;
    // }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with customer info
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF3B82F6),
                        const Color(0xFF1D4ED8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      customerName.isNotEmpty
                          ? customerName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (customerPhone != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.phone,
                              size: 14,
                              color: const Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              customerPhone,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Container(
                //   padding: const EdgeInsets.all(8),
                //   decoration: BoxDecoration(
                //     color: const Color(0xFFF3F4F6),
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                //   child: PopupMenuButton<String>(
                //     onSelected: (value) {
                //       if (value == 'delete') {
                //         _deleteTransaction(transaction);
                //       }
                //     },
                //     icon: const Icon(
                //       LucideIcons.moreVertical,
                //       size: 16,
                //       color: Color(0xFF6B7280),
                //     ),
                //     itemBuilder:
                //         (context) => [
                //           PopupMenuItem(
                //             value: 'delete',
                //             child: Row(
                //               children: [
                //                 const Icon(
                //                   LucideIcons.trash2,
                //                   color: Color(0xFFEF4444),
                //                   size: 16,
                //                 ),
                //                 const SizedBox(width: 8),
                //                 const Text(
                //                   'Hapus',
                //                   style: TextStyle(
                //                     color: Color(0xFFEF4444),
                //                     fontWeight: FontWeight.w600,
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ],
                //   ),
                // ),
              ],
            ),

            const SizedBox(height: 20),

            // Transaction summary with modern cards
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF10B981).withValues(alpha: 0.1),
                          const Color(0xFF059669).withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.package,
                              size: 16,
                              color: const Color(0xFF059669),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Items',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF059669),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$totalItems',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF065F46),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF3B82F6).withValues(alpha: 0.1),
                          const Color(0xFF1D4ED8).withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.dollarSign,
                              size: 16,
                              color: const Color(0xFF1D4ED8),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1D4ED8),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatCurrency.format(totalAmount),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E3A8A),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Date info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.clock,
                        size: 14,
                        color: const Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Dibuat: ${formatDate.format(createdAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (updatedAt != createdAt) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B7280),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Update: ${formatDate.format(updatedAt)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Notes if available
            if (notes != null && notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      LucideIcons.stickyNote,
                      size: 14,
                      color: const Color(0xFF1D4ED8),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        notes,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1E3A8A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Action button with modern design
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _resumeTransaction(transaction),
                  icon: const Icon(LucideIcons.play, size: 18),
                  label: const Text(
                    'Lanjutkan Transaksi',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
