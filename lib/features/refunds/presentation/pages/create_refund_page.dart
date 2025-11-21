import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/decimal_text_input_formatter.dart';
import '../../data/models/create_refund_request.dart';
import '../../../transactions/data/models/create_transaction_response.dart';
import '../../providers/refund_list_provider.dart';
import '../../../sales/providers/transaction_provider.dart';
import '../../../../data/models/cart_item.dart';
import '../../../../data/models/product.dart';

class CreateRefundPage extends StatefulWidget {
  final TransactionData transaction;

  const CreateRefundPage({Key? key, required this.transaction})
    : super(key: key);

  @override
  State<CreateRefundPage> createState() => _CreateRefundPageState();
}

class _CreateRefundPageState extends State<CreateRefundPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<int, TextEditingController> _quantityControllers = {};
  final Map<int, bool> _selectedItems = {};

  String _refundMethod = 'cash';
  final TextEditingController _cashAmountController = TextEditingController();
  final TextEditingController _transferAmountController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _refundDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers only for items with remaining_qty > 0
    for (var detail in widget.transaction.details) {
      if (detail.remainingQty > 0) {
        _quantityControllers[detail.id] = TextEditingController(text: '0');
        _selectedItems[detail.id] = false;
      }
    }
  }

  @override
  void dispose() {
    _quantityControllers.forEach((key, controller) => controller.dispose());
    _cashAmountController.dispose();
    _transferAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double _calculateTotalRefund() {
    double total = 0;
    for (var detail in widget.transaction.details) {
      if (_selectedItems[detail.id] == true) {
        int quantity =
            int.tryParse(_quantityControllers[detail.id]?.text ?? '0') ?? 0;
        total += (detail.unitPrice) * quantity;
      }
    }
    return total;
  }

  bool get _hasSelectedItems {
    return _selectedItems.values.any((selected) => selected == true);
  }

  bool get _canSubmit {
    if (!_hasSelectedItems) return false;
    if (_calculateTotalRefund() <= 0) return false;
    return true;
  }

  // Helper getters for outstanding transaction logic
  bool get _isOutstandingTransaction =>
      widget.transaction.status.toLowerCase() == 'outstanding';

  double get _remainingDebt {
    if (!_isOutstandingTransaction) return 0;
    return widget.transaction.outstandingAmount;
  }

  String get _predictedStatus {
    if (!_isOutstandingTransaction) return widget.transaction.status;

    final remainingDebt = _remainingDebt;
    final refundAmount = _calculateTotalRefund();

    if (refundAmount >= remainingDebt) {
      return 'completed';
    }
    return 'outstanding';
  }

  double get _newRemainingDebt {
    if (!_isOutstandingTransaction) return 0;

    final remainingDebt = _remainingDebt;
    final refundAmount = _calculateTotalRefund();

    final newDebt = remainingDebt - refundAmount;
    return newDebt > 0 ? newDebt : 0;
  }

  /// Calculate new reminder date by adding 10 days
  String _calculateNewReminderDate() {
    DateTime newReminderDate;

    if (widget.transaction.outstandingReminderDate != null) {
      // Jika sudah ada reminder date, tambahkan 10 hari dari tanggal tersebut
      newReminderDate = widget.transaction.outstandingReminderDate!.add(
        const Duration(days: 10),
      );
    } else {
      // Jika belum ada, gunakan 10 hari dari sekarang
      newReminderDate = DateTime.now().add(const Duration(days: 10));
    }

    return newReminderDate.toIso8601String();
  }

  Widget _buildDebtInfoRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _onRefundMethodChanged(String? value) {
    setState(() {
      _refundMethod = value ?? 'cash';
      if (_refundMethod == 'cash') {
        _cashAmountController.text = _calculateTotalRefund().toStringAsFixed(0);
        _transferAmountController.clear();
      } else if (_refundMethod == 'transfer') {
        _transferAmountController.text = _calculateTotalRefund()
            .toStringAsFixed(0);
        _cashAmountController.clear();
      } else {
        _cashAmountController.clear();
        _transferAmountController.clear();
      }
    });
  }

  void _showConfirmationDialog() {
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final totalRefund = _calculateTotalRefund();
    final cashAmount =
        DecimalTextInputFormatter.parseDecimal(_cashAmountController.text) ?? 0;
    final transferAmount =
        DecimalTextInputFormatter.parseDecimal(
          _transferAmountController.text,
        ) ??
        0;

    String refundMethodText = '';
    switch (_refundMethod) {
      case 'cash':
        refundMethodText = 'Cash';
        break;
      case 'transfer':
        refundMethodText = 'Transfer';
        break;
      case 'cash_and_transfer':
        refundMethodText = 'Cash & Transfer';
        break;
    }

    // Count selected items
    int selectedItemCount = 0;
    for (var detail in widget.transaction.details) {
      if (_selectedItems[detail.id] == true) {
        selectedItemCount++;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isOutstandingTransaction
                      ? Colors.orange.shade100
                      : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _isOutstandingTransaction ? Icons.edit : Icons.help_outline,
                  color: _isOutstandingTransaction
                      ? Colors.orange.shade600
                      : Colors.green.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isOutstandingTransaction
                      ? 'Konfirmasi Edit Transaksi'
                      : 'Konfirmasi Refund',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isOutstandingTransaction
                    ? 'Transaksi ini belum dibayar. Item yang dipilih akan dihapus dari transaksi.'
                    : 'Apakah Anda yakin ingin memproses refund ini?',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Transaksi:',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          '#${widget.transaction.transactionNumber}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Item di-refund:',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          '$selectedItemCount item',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    // Untuk Outstanding Transaction: tampilkan info debt reduction
                    if (_isOutstandingTransaction) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Sisa Hutang Saat Ini:',
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            currencyFormat.format(_remainingDebt),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Refund:',
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            currencyFormat.format(totalRefund),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Sisa Hutang Setelah Refund:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            currencyFormat.format(_newRemainingDebt),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _predictedStatus == 'completed'
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Status Setelah Refund:',
                            style: TextStyle(fontSize: 14),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _predictedStatus == 'completed'
                                  ? Colors.green.shade100
                                  : Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _predictedStatus == 'completed'
                                    ? Colors.green.shade300
                                    : Colors.orange.shade300,
                              ),
                            ),
                            child: Text(
                              _predictedStatus == 'completed'
                                  ? 'Lunas'
                                  : 'Masih Hutang',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _predictedStatus == 'completed'
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Untuk Completed Transaction: tampilkan info metode refund
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Metode Refund:',
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            refundMethodText,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (_refundMethod == 'cash' ||
                          _refundMethod == 'cash_and_transfer') ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Cash:', style: TextStyle(fontSize: 14)),
                            Text(
                              currencyFormat.format(cashAmount),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (_refundMethod == 'transfer' ||
                          _refundMethod == 'cash_and_transfer') ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Transfer:',
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              currencyFormat.format(transferAmount),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Refund:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            currencyFormat.format(totalRefund),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isOutstandingTransaction
                      ? Colors.orange.shade50
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: _isOutstandingTransaction
                          ? Colors.orange.shade700
                          : Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isOutstandingTransaction
                            ? 'Item akan dihapus dari transaksi dan tidak dapat dikembalikan'
                            : 'Refund akan diproses dan tidak dapat dibatalkan',
                        style: TextStyle(
                          fontSize: 13,
                          color: _isOutstandingTransaction
                              ? Colors.orange.shade700
                              : Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _submitRefund(); // Proceed with refund
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Ya, Proses',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitRefund() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if at least one item is selected
    bool hasSelectedItem = _selectedItems.values.any((selected) => selected);
    if (!hasSelectedItem) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal 1 item untuk di-refund'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isOutstandingTransaction) {
        // OUTSTANDING TRANSACTION: Edit transaksi langsung
        await _updateOutstandingTransaction();
      } else {
        // COMPLETED TRANSACTION: Create refund record
        await _createRefundForCompletedTransaction();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isOutstandingTransaction
                  ? 'Transaksi berhasil diperbarui'
                  : 'Refund berhasil dibuat',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isOutstandingTransaction
                  ? 'Gagal memperbarui transaksi: $e'
                  : 'Gagal membuat refund: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Update outstanding transaction (edit transaksi, bukan create refund)
  Future<void> _updateOutstandingTransaction() async {
    // Build CartItems from remaining items (items yang TIDAK di-refund)
    final List<CartItem> updatedCartItems = [];

    for (var detail in widget.transaction.details) {
      final refundQty = _selectedItems[detail.id] == true
          ? (int.tryParse(_quantityControllers[detail.id]?.text ?? '0') ?? 0)
          : 0;

      // Calculate remaining quantity after refund
      final remainingQty = detail.quantity - detail.returnedQty - refundQty;

      // Hanya tambahkan item yang masih ada qty-nya
      if (remainingQty > 0) {
        // Get data from product variant if available, otherwise from transaction detail
        final productId = detail.productVariantId ?? detail.productId ?? 0;
        final productName = detail.productName;
        final productCode = detail.productSku;
        final productPrice = detail.unitPrice;

        // Get variant data if available
        final variantName = detail.productVariant?.name;
        final variantStock = detail.productVariant?.stock ?? 0;
        final variantImage = detail.productVariant?.image;
        final variantCreatedAt =
            detail.productVariant?.createdAt ?? detail.createdAt;
        final variantUpdatedAt =
            detail.productVariant?.updatedAt ?? detail.updatedAt;

        // Create Product from real transaction detail data
        final product = Product(
          id: productId,
          name: productName,
          code: productCode,
          description: variantName ?? productName,
          price: productPrice,
          stock: variantStock,
          category:
              'Transaction Item', // Category tidak ada di transaction detail
          imagePath: variantImage,
          createdAt: variantCreatedAt,
          updatedAt: variantUpdatedAt,
          productVariantId: detail.productVariantId,
        );

        updatedCartItems.add(
          CartItem(
            id: detail.id,
            product: product,
            quantity: remainingQty,
            addedAt: detail.createdAt,
          ),
        );
      }
    }

    // Calculate new total amount
    final newTotalAmount = updatedCartItems.fold<double>(
      0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );

    // Calculate actual remaining debt manually
    // Formula: newOutstandingAmount = newTotalAmount - totalPaid
    final totalPaid = widget.transaction.totalPaid;
    final newOutstandingAmount = newTotalAmount - totalPaid;

    // Determine new status: completed if debt becomes 0 or negative
    final newStatus = newOutstandingAmount <= 0 ? 'completed' : 'outstanding';

    // Get TransactionProvider
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

    // Call updateTransaction API
    final response = await transactionProvider.updateTransaction(
      transactionId: widget.transaction.id,
      cartItems: updatedCartItems,
      totalAmount: newTotalAmount,
      notes: _notesController.text.trim().isEmpty
          ? widget.transaction.notes
          : '${widget.transaction.notes ?? ''}\n[Refund: ${_notesController.text.trim()}]',
      paymentMethod: 'cash', // Default, not important for outstanding
      storeId: widget.transaction.store.id,
      customerName: widget.transaction.customer?.name,
      customerPhone: widget.transaction.customer?.phoneNumber,
      status: newStatus,
      cashAmount: 0,
      transferAmount: 0,
      outstandingReminderDate: newStatus == 'outstanding'
          ? _calculateNewReminderDate()
          : null,
    );

    if (response == null) {
      throw Exception('Failed to update transaction');
    }
  }

  /// Create refund for completed transaction
  Future<void> _createRefundForCompletedTransaction() async {
    // Validate refund amounts
    double totalRefund = _calculateTotalRefund();
    double cashAmount = 0;
    double transferAmount = 0;

    cashAmount =
        DecimalTextInputFormatter.parseDecimal(_cashAmountController.text) ?? 0;
    transferAmount =
        DecimalTextInputFormatter.parseDecimal(
          _transferAmountController.text,
        ) ??
        0;

    if (_refundMethod == 'cash' && cashAmount != totalRefund) {
      throw Exception(
        'Jumlah cash harus ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(totalRefund)}',
      );
    }

    if (_refundMethod == 'transfer' && transferAmount != totalRefund) {
      throw Exception(
        'Jumlah transfer harus ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(totalRefund)}',
      );
    }

    if (_refundMethod == 'cash_and_transfer' &&
        (cashAmount + transferAmount) != totalRefund) {
      throw Exception(
        'Total cash + transfer harus ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(totalRefund)}',
      );
    }

    // Build refund details
    List<RefundDetailRequest> details = [];
    for (var detail in widget.transaction.details) {
      if (_selectedItems[detail.id] == true) {
        int quantity =
            int.tryParse(_quantityControllers[detail.id]?.text ?? '0') ?? 0;
        if (quantity > 0) {
          details.add(
            RefundDetailRequest(
              transactionDetailId: detail.id,
              quantityRefunded: quantity,
            ),
          );
        }
      }
    }

    // Create refund request
    final request = CreateRefundRequest(
      transactionId: widget.transaction.id,
      storeId: widget.transaction.store.id,
      refundMethod: _refundMethod,
      cashRefundAmount: cashAmount,
      transferRefundAmount: transferAmount,
      status: 'completed',
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      refundDate: DateFormat('yyyy-MM-dd').format(_refundDate),
      details: details,
    );

    // Call RefundListProvider
    final provider = Provider.of<RefundListProvider>(context, listen: false);
    await provider.createRefund(request);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Refund Item'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Transaction Info Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade600,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.receipt_long,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Transaksi #${widget.transaction.transactionNumber}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('dd MMM yyyy HH:mm').format(
                                          widget.transaction.transactionDate,
                                        ),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Transaksi',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                Text(
                                  currencyFormat.format(
                                    widget.transaction.totalAmount,
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Items to Refund Section
                    const Text(
                      'Pilih Item untuk di-Refund',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Item List - only show items with remaining_qty > 0
                    ...widget.transaction.details.where((detail) => detail.remainingQty > 0).map((
                      detail,
                    ) {
                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: _selectedItems[detail.id] == true
                                ? Colors.green.shade300
                                : Colors.grey.shade200,
                            width: _selectedItems[detail.id] == true ? 2 : 1,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              _selectedItems[detail.id] =
                                  !(_selectedItems[detail.id] ?? false);
                              if (_selectedItems[detail.id] == true) {
                                _quantityControllers[detail.id]?.text = '1';
                              } else {
                                _quantityControllers[detail.id]?.text = '0';
                              }
                              _onRefundMethodChanged(_refundMethod);
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Checkbox
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: _selectedItems[detail.id] == true
                                        ? Colors.green.shade600
                                        : Colors.white,
                                    border: Border.all(
                                      color: _selectedItems[detail.id] == true
                                          ? Colors.green.shade600
                                          : Colors.grey.shade400,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: _selectedItems[detail.id] == true
                                      ? const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),

                                // Product Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        detail.productName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: Colors.blue.shade200,
                                              ),
                                            ),
                                            child: Text(
                                              'Sisa: ${detail.remainingQty}x',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.blue.shade700,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            currencyFormat.format(
                                              detail.unitPrice,
                                            ),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Quantity Input (shown when selected)
                                      if (_selectedItems[detail.id] ==
                                          true) ...[
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.green.shade200,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Jumlah Refund:',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.green.shade800,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              SizedBox(
                                                width: 100,
                                                child: TextFormField(
                                                  controller:
                                                      _quantityControllers[detail
                                                          .id],
                                                  keyboardType:
                                                      TextInputType.number,
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .digitsOnly,
                                                  ],
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    contentPadding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 10,
                                                        ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color: Colors
                                                            .green
                                                            .shade300,
                                                      ),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          borderSide:
                                                              BorderSide(
                                                                color: Colors
                                                                    .green
                                                                    .shade300,
                                                              ),
                                                        ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          borderSide:
                                                              BorderSide(
                                                                color: Colors
                                                                    .green
                                                                    .shade600,
                                                                width: 2,
                                                              ),
                                                        ),
                                                    errorBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color: Colors.red,
                                                            width: 2,
                                                          ),
                                                    ),
                                                    hintText: '0',
                                                  ),
                                                  validator: (value) {
                                                    int qty =
                                                        int.tryParse(
                                                          value ?? '0',
                                                        ) ??
                                                        0;
                                                    if (qty <= 0) {
                                                      return 'Min 1';
                                                    }
                                                    if (qty >
                                                        detail.remainingQty) {
                                                      return 'Max ${detail.remainingQty}';
                                                    }
                                                    return null;
                                                  },
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _onRefundMethodChanged(
                                                        _refundMethod,
                                                      );
                                                    });
                                                  },
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                'Max: ${detail.remainingQty}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 20),

                    // Outstanding Debt Info Card (untuk transaksi outstanding)
                    if (_isOutstandingTransaction) ...[
                      Card(
                        elevation: 2,
                        color: Colors.orange.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.orange.shade200,
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade600,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.account_balance_wallet,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Informasi Hutang',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.orange.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildDebtInfoRow(
                                'Sisa Hutang Saat Ini',
                                currencyFormat.format(_remainingDebt),
                                Colors.orange.shade800,
                              ),
                              const Divider(height: 20),
                              _buildDebtInfoRow(
                                'Total Refund',
                                currencyFormat.format(_calculateTotalRefund()),
                                Colors.green.shade700,
                              ),
                              const Divider(height: 20),
                              _buildDebtInfoRow(
                                'Sisa Hutang Setelah Refund',
                                currencyFormat.format(_newRemainingDebt),
                                _predictedStatus == 'completed'
                                    ? Colors.green.shade800
                                    : Colors.orange.shade800,
                              ),
                              if (_predictedStatus == 'completed') ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.green.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green.shade700,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Hutang akan lunas! Status transaksi akan berubah menjadi Completed.',
                                          style: TextStyle(
                                            color: Colors.green.shade900,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.orange.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info,
                                        color: Colors.orange.shade700,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Hutang akan berkurang. Status transaksi tetap Outstanding.',
                                          style: TextStyle(
                                            color: Colors.orange.shade900,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Total Refund Card (hanya untuk completed transaction)
                    if (!_isOutstandingTransaction) ...[
                      Card(
                        elevation: 2,
                        color: Colors.green.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.green.shade200,
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade600,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.calculate,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Total Refund',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.green.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                currencyFormat.format(_calculateTotalRefund()),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Refund Method Section (hanya untuk completed transaction)
                    if (!_isOutstandingTransaction) ...[
                      const Text(
                        'Metode Refund',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _refundMethod,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.green.shade600,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.payment,
                            color: Colors.green.shade600,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'cash',
                            child: Text('Cash', style: TextStyle(fontSize: 16)),
                          ),
                          DropdownMenuItem(
                            value: 'transfer',
                            child: Text(
                              'Transfer',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'cash_and_transfer',
                            child: Text(
                              'Cash & Transfer',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                        onChanged: _onRefundMethodChanged,
                      ),
                      const SizedBox(height: 20),

                      // Amount Fields
                      if (_refundMethod == 'cash' ||
                          _refundMethod == 'cash_and_transfer') ...[
                        TextFormField(
                          controller: _cashAmountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [DecimalTextInputFormatter()],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Jumlah Cash',
                            labelStyle: TextStyle(color: Colors.grey.shade700),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.green.shade600,
                                width: 2,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.attach_money,
                              color: Colors.green.shade600,
                            ),
                            prefixText: 'Rp ',
                            prefixStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          validator: (value) {
                            if (_refundMethod == 'cash' ||
                                _refundMethod == 'cash_and_transfer') {
                              if (value == null || value.isEmpty) {
                                return 'Jumlah cash harus diisi';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (_refundMethod == 'transfer' ||
                          _refundMethod == 'cash_and_transfer') ...[
                        TextFormField(
                          controller: _transferAmountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [DecimalTextInputFormatter()],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Jumlah Transfer',
                            labelStyle: TextStyle(color: Colors.grey.shade700),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.green.shade600,
                                width: 2,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.account_balance,
                              color: Colors.green.shade600,
                            ),
                            prefixText: 'Rp ',
                            prefixStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          validator: (value) {
                            if (_refundMethod == 'transfer' ||
                                _refundMethod == 'cash_and_transfer') {
                              if (value == null || value.isEmpty) {
                                return 'Jumlah transfer harus diisi';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ], // End of if (!_isOutstandingTransaction)
                    // Refund Date (untuk semua jenis transaksi)
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _refundDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _refundDate = date);
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Tanggal Refund',
                          labelStyle: TextStyle(color: Colors.grey.shade700),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.green.shade600,
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.calendar_today,
                            color: Colors.green.shade600,
                          ),
                          suffixIcon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        child: Text(
                          DateFormat('dd MMM yyyy').format(_refundDate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'Catatan (Opsional)',
                        labelStyle: TextStyle(color: Colors.grey.shade700),
                        hintText: 'Tambahkan catatan untuk refund ini...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.white,
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.green.shade600,
                            width: 2,
                          ),
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(bottom: 50),
                          child: Icon(
                            Icons.note_add,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Submit Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_isLoading || !_canSubmit)
                      ? null
                      : _showConfirmationDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.check_circle_outline, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Konfirmasi Refund',
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
      ),
    );
  }
}
