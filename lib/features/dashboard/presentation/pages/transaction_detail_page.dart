import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../transactions/data/models/transaction_list_response.dart';
import '../../../transactions/data/services/transaction_api_service.dart';
import '../../../sales/presentation/pages/payment_confirmation_page.dart';
import '../../../customers/data/models/customer.dart';
import '../../../../data/models/cart_item.dart';
import '../../../../data/models/product.dart';
import '../../../sales/presentation/pages/payment_success_page.dart';
import '../../../sales/presentation/pages/receipt_page.dart';
import '../../../../shared/widgets/payment_method_widgets.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../sales/providers/transaction_provider.dart';

class TransactionItemDetail {
  final int id;
  final int productId;
  final int? productVariantId;
  final String productName;
  final String variant;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final double totalAmount;
  final Map<String, dynamic>? product;
  final Map<String, dynamic>? productVariant;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionItemDetail({
    required this.id,
    required this.productId,
    this.productVariantId,
    required this.productName,
    required this.variant,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.totalAmount,
    this.product,
    this.productVariant,
    required this.createdAt,
    required this.updatedAt,
  });
}

class TransactionDetailPage extends StatefulWidget {
  final TransactionListItem transaction;

  const TransactionDetailPage({super.key, required this.transaction});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  final TransactionApiService _apiService = TransactionApiService();
  List<TransactionItemDetail>? _transactionItems;
  TransactionListItem? _detailedTransaction;
  List<CartItem>? _cartItems;
  bool _isLoadingItems = true;
  String? _errorMessage;

  // Get storeId from user profile
  int _getStoreIdFromUser(BuildContext context) {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user != null && user.stores.isNotEmpty) {
        return user.stores.first.id;
      }
    } catch (e) {
      debugPrint('Error getting storeId from user profile: $e');
    }

    // Default fallback storeId
    return 1;
  }

  @override
  void initState() {
    super.initState();
    _loadTransactionDetails();
  }

  Future<void> _loadTransactionDetails() async {
    try {
      setState(() {
        _isLoadingItems = true;
        _errorMessage = null;
      });

      // Load transaction details from API
      final response = await _apiService.getTransaction(widget.transaction.id);

      // Parse transaction items from API response
      List<TransactionItemDetail> items = [];

      // Check if response has transaction items/details
      if (response['data'] != null) {
        final transactionData = response['data'];

        _detailedTransaction = TransactionListItem.fromJson(transactionData);

        // Parse items from different possible API structures
        List<dynamic>? itemsData;

        // Try different possible field names for items
        if (transactionData['items'] != null) {
          itemsData = transactionData['items'] as List<dynamic>;
        } else if (transactionData['transaction_items'] != null) {
          itemsData = transactionData['transaction_items'] as List<dynamic>;
        } else if (transactionData['details'] != null) {
          itemsData = transactionData['details'] as List<dynamic>;
        } else if (transactionData['products'] != null) {
          itemsData = transactionData['products'] as List<dynamic>;
        }

        if (itemsData != null && itemsData.isNotEmpty) {
          items =
              itemsData.map((item) {
                final unitPrice =
                    (item['unit_price']?.toDouble() ??
                            item['price']?.toDouble() ??
                            item['price_per_unit']?.toDouble() ??
                            0)
                        .toDouble();
                final quantity =
                    item['quantity']?.toInt() ?? item['qty']?.toInt() ?? 1;
                final subtotal =
                    (item['subtotal']?.toDouble() ??
                            item['total']?.toDouble() ??
                            item['total_price']?.toDouble() ??
                            (unitPrice * quantity))
                        .toDouble();

                return TransactionItemDetail(
                  id:
                      item['id']?.toInt() ??
                      DateTime.now().millisecondsSinceEpoch,
                  productId: item['product_id']?.toInt() ?? 0,
                  productVariantId: item['product_variant_id']?.toInt(),
                  productName:
                      item['product_name']?.toString() ??
                      item['name']?.toString() ??
                      item['product']?.toString() ??
                      'Unknown Product',
                  variant:
                      item['variant']?.toString() ??
                      item['variation']?.toString() ??
                      item['size']?.toString() ??
                      '',
                  quantity: quantity,
                  unitPrice: unitPrice,
                  subtotal: subtotal,
                  totalAmount:
                      subtotal, // totalAmount same as subtotal for individual items
                  product: item['product'] as Map<String, dynamic>?,
                  productVariant:
                      item['product_variant'] as Map<String, dynamic>?,
                  createdAt:
                      DateTime.tryParse(item['created_at']?.toString() ?? '') ??
                      DateTime.now(),
                  updatedAt:
                      DateTime.tryParse(item['updated_at']?.toString() ?? '') ??
                      DateTime.now(),
                );
              }).toList();
        }

        _cartItems =
            items.map((item) {
              // Create a mock product based on transaction item
              final product = Product(
                id: item.product?['id'] ?? item.id,
                name: item.product?['name'] ?? item.productName,
                price: item.unitPrice,
                productVariantId: item.productVariantId ?? 0,

                // Add other required fields with mock or default values
                description: '',
                stock: 0,
                category: '',
              );
              return CartItem(
                id: item.id,
                product: product,
                quantity: item.quantity,
                addedAt: item.createdAt,
              );
            }).toList();
      }

      setState(() {
        _transactionItems = items;
        _isLoadingItems = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingItems = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  TransactionListItem get transaction => widget.transaction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTransactionHeader(),
            const SizedBox(height: 24),
            _buildTransactionInfo(),
            const SizedBox(height: 24),
            _buildTransactionItems(),
            const SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            LucideIcons.arrowLeft,
            color: Color(0xFF1F2937),
            size: 20,
          ),
        ),
      ),
      title: const Text(
        'Detail Transaksi',
        style: TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildTransactionHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366f1), // Indigo
            const Color(0xFF8b5cf6), // Purple
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366f1).withValues(alpha: 0.3),
            blurRadius: 24,
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
                child: Icon(
                  _getStatusIcon(transaction.status),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.transactionNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(transaction.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(transaction.totalAmount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Total Items',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    '${transaction.detailsCount} barang',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Transaksi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailRow('Nomor Transaksi', transaction.transactionNumber),
          _buildDetailRow(
            'Tanggal & Waktu',
            DateFormat('dd MMMM yyyy, HH:mm').format(transaction.createdAt),
          ),
          _buildDetailRow('Status', _getStatusText(transaction.status)),
          _buildDetailRow(
            'Total Amount',
            NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(transaction.totalAmount),
          ),
          _buildDetailRow('Jumlah Item', '${transaction.detailsCount} barang'),
          _buildPaymentMethodRow(
            'Metode Pembayaran',
            transaction.paymentMethod,
          ),
          if (transaction.notes != null && transaction.notes!.trim().isNotEmpty)
            _buildDetailRow('Catatan', transaction.notes!),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(color: Color(0xFF6B7280))),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodRow(String label, String paymentMethod) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(color: Color(0xFF6B7280))),
          Expanded(
            child: PaymentMethodDisplay(
              paymentMethod: paymentMethod,
              fontSize: 14,
              iconSize: 16,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItems() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366f1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.shoppingBag,
                  color: Color(0xFF6366f1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Detail Item',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (_isLoadingItems)
            _buildLoadingItems()
          else if (_errorMessage != null)
            _buildErrorItems()
          else if (_transactionItems != null &&
              _transactionItems!.isNotEmpty) ...[
            ..._transactionItems!.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildItemRow(
                item,
                index == _transactionItems!.length - 1,
              );
            }),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE5E7EB)),
            const SizedBox(height: 16),
            _buildTotalRow(),
          ] else
            _buildEmptyItems(),
        ],
      ),
    );
  }

  Widget _buildLoadingItems() {
    return Column(
      children: [
        for (int i = 0; i < 3; i++) ...[
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      width: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 16,
                width: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          if (i < 2) const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildErrorItems() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(
            LucideIcons.alertCircle,
            color: Color(0xFFEF4444),
            size: 32,
          ),
          const SizedBox(height: 8),
          const Text(
            'Gagal memuat detail item',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _errorMessage ?? 'Terjadi kesalahan tidak diketahui',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _loadTransactionDetails,
            icon: const Icon(LucideIcons.refreshCw, size: 16),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366f1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyItems() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Column(
        children: [
          Icon(LucideIcons.package, color: Color(0xFF9CA3AF), size: 32),
          SizedBox(height: 8),
          Text(
            'Detail item tidak tersedia',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Detail item belum tersedia dari API untuk transaksi ini',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Pembayaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          Text(
            NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(transaction.totalAmount),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF059669),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(TransactionItemDetail item, bool isLast) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border:
            isLast
                ? null
                : Border(
                  bottom: BorderSide(
                    color: const Color(0xFFE5E7EB).withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image Placeholder
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Icon(
              LucideIcons.package,
              color: Color(0xFF9CA3AF),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity}x @ ${currencyFormat.format(item.unitPrice)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                if (item.variant.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.variant,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Subtotal
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.end,
          //   children: [
          //     Text(
          //       currencyFormat.format(item.subtotal),
          //       style: const TextStyle(
          //         fontWeight: FontWeight.w600,
          //         fontSize: 16,
          //         color: Color(0xFF059669),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final status = transaction.status.toLowerCase();

    // Show "Lihat Struk" button for completed transactions
    if (status == 'completed') {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _navigateToReceipt(),
              icon: const Icon(LucideIcons.receipt, size: 20),
              label: const Text(
                'Lihat Struk',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      );
    }

    // Show action buttons for pending and outstanding transactions
    if (status != 'pending' && status != 'outstanding') {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showCompleteTransactionDialog(context),
                icon: Icon(
                  status == 'outstanding'
                      ? LucideIcons.dollarSign
                      : LucideIcons.check,
                  size: 18,
                ),
                label: Text(
                  status == 'outstanding'
                      ? 'Bayar Utang'
                      : 'Selesaikan Transaksi',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      status == 'outstanding'
                          ? const Color(0xFFEA580C)
                          : const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row(
        //   children: [
        //     Expanded(
        //       child: OutlinedButton.icon(
        //         onPressed: () => _showCancelTransactionDialog(context),
        //         icon: const Icon(LucideIcons.x, size: 18),
        //         label: const Text('Batalkan Transaksi'),
        //         style: OutlinedButton.styleFrom(
        //           foregroundColor: const Color(0xFFEF4444),
        //           side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        //           padding: const EdgeInsets.symmetric(vertical: 16),
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(12),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }

  void _showCompleteTransactionDialog(BuildContext context) {
    // Convert transaction items to cart items for payment dialog
    // final cartItems =
    //     _transactionItems?.map((item) {
    //       // Create a mock product based on transaction item
    //       final product = Product(
    //         id: item.productName.hashCode.abs(),
    //         name: item.productName,
    //         code: 'MOCK_${item.productName.toUpperCase().replaceAll(' ', '_')}',
    //         description:
    //             item.variant.isNotEmpty
    //                 ? 'Variant: ${item.variant}'
    //                 : 'Product from transaction',
    //         price: item.unitPrice,
    //         stock: 999, // Mock stock
    //         category: 'Transaction Item',
    //         imagePath: null,
    //         createdAt: DateTime.now(),
    //         updatedAt: DateTime.now(),
    //       );

    //       return CartItem(
    //         id:
    //             'cart_${item.productName.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}',
    //         product: product,
    //         quantity: item.quantity,
    //         addedAt: DateTime.now(),
    //       );
    //     }).toList() ??
    //     [];

    // Create a mock customer if needed
    Customer? selectedCustomer;
    // You can extract customer info from transaction if available

    final notesController = TextEditingController(
      text: transaction.notes ?? '',
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => PaymentConfirmationPage(
              cartItems: _cartItems ?? [],
              totalAmount: transaction.totalAmount,
              itemCount: _cartItems?.length ?? 0,
              notesController: notesController,
              selectedCustomer: selectedCustomer,
              onConfirm: (
                customerName,
                customerPhone,
                paymentMethod,
                cashAmount,
                transferAmount,
                paymentStatus,
                outstandingReminderDate,
                updatedCartItems,
                updatedTotalAmount,
              ) {
                Navigator.pop(context); // Close page
                _completeTransaction(
                  context,
                  paymentMethod: paymentMethod,
                  cashAmount: cashAmount,
                  transferAmount: transferAmount,
                  notes: notesController.text.trim(),
                  paymentStatus: paymentStatus,
                  outstandingReminderDate: outstandingReminderDate,
                  updatedCartItems: updatedCartItems,
                  updatedTotalAmount: updatedTotalAmount,
                );
              },
            ),
      ),
    );
  }

  void _completeTransaction(
    BuildContext context, {
    String? paymentMethod,
    double? cashAmount,
    double? transferAmount,
    String? notes,
    String? paymentStatus,
    String? outstandingReminderDate,
    List<CartItem>? updatedCartItems,
    double? updatedTotalAmount,
  }) async {
    // Cache navigator reference before async operations
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Menyelesaikan transaksi...'),
            ],
          ),
        );
      },
    );

    try {
      // Get transaction provider
      final transactionProvider = Provider.of<TransactionProvider>(
        context,
        listen: false,
      );

      // Use updatedCartItems if provided and not null, otherwise create from transaction items
      List<CartItem> cartItemsToUpdate;

      if (updatedCartItems != null && updatedCartItems.isNotEmpty) {
        // Use the provided updated cart items
        cartItemsToUpdate = updatedCartItems;
      } else {
        // Default to empty list if no cart items or transaction items available
        cartItemsToUpdate = [];
      }

      // Use TransactionProvider.updateTransaction method like in _confirmOrder
      final response = await transactionProvider.updateTransaction(
        transactionId: transaction.id,
        cartItems: cartItemsToUpdate,
        totalAmount: updatedTotalAmount ?? transaction.totalAmount,
        notes: notes ?? transaction.notes ?? '',
        paymentMethod: paymentMethod ?? transaction.paymentMethod,
        storeId: _getStoreIdFromUser(context),
        customerName:
            transaction.customer?.name ?? 'Customer', // Default customer name
        customerPhone: null,
        status: paymentStatus == 'utang' ? 'outstanding' : 'completed',
        cashAmount: cashAmount ?? 0,
        transferAmount: transferAmount ?? 0.0,
        outstandingReminderDate: outstandingReminderDate,
      );

      debugPrint('Update Response: $response', wrapWidth: 2024);

      // Close loading dialog using cached navigator
      if (mounted && navigator.canPop()) {
        navigator.pop();
      }

      // Check if update was successful (TransactionProvider returns non-null response on success)
      if (response != null) {
        // Show success message
        if (mounted) {
          // Convert transaction items to cart items for payment success page
          // final cartItems =
          //     _transactionItems?.map((item) {
          //       final product = Product(
          //         id: item.productName.hashCode.abs(),
          //         name: item.productName,
          //         code:
          //             'CODE_${item.productName.toUpperCase().replaceAll(' ', '_')}',
          //         description:
          //             item.variant.isNotEmpty
          //                 ? 'Variant: ${item.variant}'
          //                 : 'Product item',
          //         price: item.unitPrice,
          //         stock: 999,
          //         category: 'Transaction Item',
          //         imagePath: null,
          //         createdAt: DateTime.now(),
          //         updatedAt: DateTime.now(),
          //       );

          //       return CartItem(
          //         id:
          //             'item_${item.productName.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}',
          //         product: product,
          //         quantity: item.quantity,
          //         addedAt: DateTime.now(),
          //       );
          //     }).toList() ??
          //     [];

          // Navigate to PaymentSuccessPage instead of just going back
          navigator.pushReplacement(
            MaterialPageRoute(
              builder:
                  (context) => PaymentSuccessPage(
                    paymentMethod: paymentMethod ?? transaction.paymentMethod,
                    amountPaid: transaction.totalAmount,
                    totalAmount: updatedTotalAmount ?? transaction.totalAmount,
                    transactionNumber: transaction.transactionNumber,
                    store: transaction.store,
                    cartItems: cartItemsToUpdate,
                    notes: notes ?? transaction.notes,
                    user:
                        Provider.of<AuthProvider>(context, listen: false).user,
                  ),
            ),
          );
        }
      } else {
        // Handle failure from TransactionProvider
        if (mounted) {
          _showErrorMessage(
            scaffoldMessenger,
            transactionProvider.errorMessage ??
                'Gagal menyelesaikan transaksi. Silakan coba lagi.',
          );
        }
      }
    } catch (e) {
      // Close loading dialog if still open using cached navigator
      if (mounted && navigator.canPop()) {
        navigator.pop();
      }

      // Show error message
      if (mounted) {
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        _showErrorMessage(
          scaffoldMessenger,
          'Terjadi kesalahan: $errorMessage',
        );
      }
    }
  }

  void _showErrorMessage(
    ScaffoldMessengerState scaffoldMessenger,
    String message,
  ) {
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.alertCircle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return LucideIcons.checkCircle;
      case 'pending':
        return LucideIcons.clock;
      case 'outstanding':
        return LucideIcons.alertTriangle;
      case 'cancelled':
        return LucideIcons.xCircle;
      default:
        return LucideIcons.fileText;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Selesai';
      case 'pending':
        return 'Pending';
      case 'outstanding':
        return 'Utang';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  void _navigateToReceipt() {
    // Konversi data transaksi ke format CartItem untuk ReceiptPage
    List<CartItem> receiptItems = [];

    // Gunakan _cartItems jika tersedia, jika tidak buat dari _transactionItems
    if (_cartItems != null && _cartItems!.isNotEmpty) {
      receiptItems = _cartItems!;
    } else if (_transactionItems != null && _transactionItems!.isNotEmpty) {
      receiptItems =
          _transactionItems!.map((item) {
            final product = Product(
              id: item.productId,
              name: item.productName,
              code: item.productId.toString(),
              description:
                  item.variant.isNotEmpty
                      ? 'Variant: ${item.variant}'
                      : 'Item transaksi',
              price: item.unitPrice,
              stock: 1,
              category: 'General',
            );

            return CartItem(
              id: item.id,
              product: product,
              quantity: item.quantity,
              addedAt: item.createdAt,
            );
          }).toList();
    } else {
      // Fallback: buat placeholder items berdasarkan total dan jumlah item
      if (transaction.detailsCount > 0) {
        double averagePrice =
            transaction.totalAmount / transaction.detailsCount;
        for (int i = 0; i < transaction.detailsCount; i++) {
          receiptItems.add(
            CartItem(
              id: i + 1,
              product: Product(
                id: i + 1,
                name: 'Item ${i + 1}',
                code: 'ITEM${i + 1}',
                description: 'Item transaksi',
                price: averagePrice,
                stock: 1,
                category: 'General',
              ),
              quantity: 1,
              addedAt: transaction.transactionDate,
            ),
          );
        }
      }
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ReceiptPage(
              receiptId: transaction.transactionNumber,
              transactionDate: transaction.transactionDate,
              items: receiptItems,
              store: transaction.store,
              user: transaction.user,
              subtotal: transaction.totalAmount,
              discount: 0.0,
              total: transaction.totalAmount,
              paymentMethod: _getPaymentMethodText(transaction.paymentMethod),
              notes: transaction.notes,
            ),
      ),
    );
  }

  String _getPaymentMethodText(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return 'Tunai';
      case 'card':
        return 'Kartu';
      case 'transfer':
        return 'Transfer';
      case 'e-wallet':
        return 'E-Wallet';
      default:
        return paymentMethod;
    }
  }
}
