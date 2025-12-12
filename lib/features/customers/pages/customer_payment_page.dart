import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../data/models/customer.dart';
import '../data/models/payment_receipt_item.dart';
import '../../transactions/data/services/transaction_api_service.dart';
import '../../transactions/data/models/transaction_list_response.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/constants/payment_constants.dart';
import 'customer_payment_receipt_page.dart';

class CustomerPaymentPage extends StatefulWidget {
  final Customer customer;

  const CustomerPaymentPage({super.key, required this.customer});

  @override
  State<CustomerPaymentPage> createState() => _CustomerPaymentPageState();
}

class _CustomerPaymentPageState extends State<CustomerPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final TransactionApiService _apiService = TransactionApiService();

  String _selectedPaymentMethod = 'cash';
  bool _isProcessing = false;
  bool _isLoadingTransactions = false;

  List<TransactionListItem> _transactions = [];
  double _totalOutstanding = 0.0;
  List<PaymentReceiptItem> _paymentReceiptItems = [];

  @override
  void initState() {
    super.initState();
    _loadOutstandingTransactions();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadOutstandingTransactions() async {
    setState(() {
      _isLoadingTransactions = true;
    });

    try {
      final response = await _apiService.getTransactions(
        customerId: widget.customer.id,
        status: 'outstanding',
        sortBy: 'transaction_date',
        sortDirection: 'asc',
        perPage: 100,
      );

      final outstandingTransactions = response.data.data
          .where((t) => t.outstandingAmount > 0)
          .toList();

      final total = outstandingTransactions.fold<double>(
        0,
        (sum, t) => sum + t.outstandingAmount,
      );

      setState(() {
        _transactions = outstandingTransactions;
        _totalOutstanding = total;
        _isLoadingTransactions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTransactions = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat transaksi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  double _parseAmount(String text) {
    final cleanText = text.replaceAll('.', '');
    return double.tryParse(cleanText) ?? 0.0;
  }

  double get _inputAmount {
    return _parseAmount(_amountController.text);
  }

  bool get _isPaymentValid {
    return _inputAmount > 0;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nominal pembayaran harus diisi';
    }

    final amount = _parseAmount(value);
    if (amount <= 0) {
      return 'Nominal harus lebih dari 0';
    }

    return null;
  }

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isProcessing) return;

    // Cache BuildContext-dependent values before async
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id ?? 0;

    // Show confirmation dialog
    final confirm = await _showConfirmationDialog();
    if (!confirm) return;
    if (!mounted) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      double remainingPayment = _inputAmount;
      int completedCount = 0;
      int updatedCount = 0;
      final List<PaymentReceiptItem> receiptItems = [];

      // Process each transaction oldest first
      for (final transaction in _transactions) {
        if (remainingPayment <= 0) break;

        final outstandingAmount = transaction.outstandingAmount;
        final paymentForThisTransaction = remainingPayment >= outstandingAmount
            ? outstandingAmount
            : remainingPayment;

        // Create new payment object
        final newPayment = {
          'payment_method': _selectedPaymentMethod,
          'amount': paymentForThisTransaction,
          'payment_date': DateTime.now().toIso8601String(),
          'notes': _notesController.text.trim().isEmpty
              ? 'Pembayaran utang customer'
              : _notesController.text.trim(),
          'user_id': userId,
        };

        // For TransactionListItem, we only send the new payment
        // The API will handle merging with existing payments
        final updatedPayments = [newPayment];

        // Calculate new outstanding
        final newTotalPaid = transaction.totalPaid + paymentForThisTransaction;
        final newOutstanding = transaction.totalAmount - newTotalPaid;

        // Determine new status
        final newStatus = newOutstanding <= 0 ? 'completed' : 'outstanding';

        // Calculate outstanding reminder date (100 days from now) for outstanding transactions
        final outstandingReminderDate = newStatus == 'outstanding'
            ? DateTime.now().add(const Duration(days: 100))
            : null;

        // Prepare request body
        final requestBody = <String, dynamic>{
          'payments': updatedPayments,
          'status': newStatus,
          if (outstandingReminderDate != null)
            'outstanding_reminder_date': outstandingReminderDate
                .toIso8601String(),
        };

        // Call API to update transaction
        await _apiService.updateTransactionPayment(transaction.id, requestBody);

        // Store receipt item for this transaction
        receiptItems.add(
          PaymentReceiptItem(
            transactionId: transaction.id,
            receiptNumber: transaction.transactionNumber,
            transactionDate: transaction.transactionDate,
            originalAmount: transaction.totalAmount,
            previousOutstanding: outstandingAmount,
            paymentAmount: paymentForThisTransaction,
            remainingOutstanding: newOutstanding,
            isFullyPaid: newStatus == 'completed',
          ),
        );

        // Update counters
        updatedCount++;
        if (newStatus == 'completed') {
          completedCount++;
        }

        // Reduce remaining payment
        remainingPayment -= paymentForThisTransaction;
      }

      // Fetch transaction details for each receipt item
      for (int i = 0; i < receiptItems.length; i++) {
        try {
          final transactionResponse = await _apiService.getTransaction(
            receiptItems[i].transactionId,
          );
          if (transactionResponse.data != null) {
            receiptItems[i] = receiptItems[i].copyWith(
              transactionDetails: transactionResponse.data!.details,
            );
          }
        } catch (e) {
          // If fetch fails, continue without transaction details
          debugPrint(
            'Failed to fetch transaction details for ${receiptItems[i].transactionId}: $e',
          );
        }
      }

      if (!mounted) return;

      // Store receipt items for success dialog
      _paymentReceiptItems = receiptItems;

      // Calculate change amount
      final changeAmount = _inputAmount > _totalOutstanding
          ? _inputAmount - _totalOutstanding
          : 0.0;

      // Show success dialog and get result
      final shouldViewReceipt = await _showSuccessDialog(
        updatedCount,
        completedCount,
      );

      if (!mounted) return;

      if (shouldViewReceipt) {
        // Navigate to receipt page
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CustomerPaymentReceiptPage(
              customer: widget.customer,
              paidTransactions: _paymentReceiptItems,
              paymentMethod:
                  PaymentConstants.paymentMethods[_selectedPaymentMethod] ?? '',
              totalPaid: _inputAmount,
              changeAmount: changeAmount,
              paymentDate: DateTime.now(),
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
            ),
          ),
        );
        if (!mounted) return;
      }

      // Navigate back and refresh
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(LucideIcons.alertCircle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Gagal memproses pembayaran: ${e.toString().replaceAll('Exception: ', '')}',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<bool> _showConfirmationDialog() async {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Calculate how many transactions will be fully paid
    double remainingAmount = _inputAmount;
    int willBeCompleted = 0;
    int willBeUpdated = 0;

    for (final transaction in _transactions) {
      if (remainingAmount <= 0) break;

      final outstandingAmount = transaction.outstandingAmount;
      final paymentForThis = remainingAmount >= outstandingAmount
          ? outstandingAmount
          : remainingAmount;

      willBeUpdated++;
      if (paymentForThis >= outstandingAmount) {
        willBeCompleted++;
      }

      remainingAmount -= paymentForThis;
    }

    // Calculate change if payment exceeds total outstanding
    final changeAmount = _inputAmount > _totalOutstanding
        ? _inputAmount - _totalOutstanding
        : 0.0;
    final hasChange = changeAmount > 0;

    final result = await showDialog<bool>(
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
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  LucideIcons.helpCircle,
                  color: Colors.green.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Konfirmasi Pembayaran',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pembayaran akan didistribusikan ke transaksi dari yang terlama:',
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    _buildConfirmRow(
                      'Nominal Bayar:',
                      currencyFormat.format(_inputAmount),
                      Colors.green.shade700,
                    ),
                    const SizedBox(height: 8),
                    _buildConfirmRow(
                      'Metode:',
                      PaymentConstants.paymentMethods[_selectedPaymentMethod] ??
                          '',
                      Colors.grey.shade700,
                    ),
                    const Divider(height: 20),
                    _buildConfirmRow(
                      'Transaksi Diupdate:',
                      '$willBeUpdated transaksi',
                      Colors.blue.shade700,
                    ),
                    const SizedBox(height: 8),
                    _buildConfirmRow(
                      'Akan Lunas:',
                      '$willBeCompleted transaksi',
                      Colors.green.shade700,
                    ),
                    if (hasChange) ...[
                      const Divider(height: 20),
                      _buildConfirmRow(
                        'Kembalian:',
                        currencyFormat.format(changeAmount),
                        Colors.orange.shade700,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (hasChange)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.alertCircle,
                        color: Colors.orange.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pembayaran melebihi total utang. Kembalian: ${currencyFormat.format(changeAmount)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.info,
                        color: Colors.amber.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pembayaran akan otomatis dibagi ke transaksi tertua terlebih dahulu',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.amber.shade900,
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
              onPressed: () => Navigator.of(context).pop(false),
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
              onPressed: () => Navigator.of(context).pop(true),
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

    return result ?? false;
  }

  Future<bool> _showSuccessDialog(int updatedCount, int completedCount) async {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Calculate change amount
    final changeAmount = _inputAmount > _totalOutstanding
        ? _inputAmount - _totalOutstanding
        : 0.0;
    final hasChange = changeAmount > 0;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.checkCircle,
                  color: Colors.green.shade600,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Pembayaran Berhasil!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Transaksi Diupdate:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          '$updatedCount',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Transaksi Lunas:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          '$completedCount',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    if (hasChange) ...[
                      const Divider(height: 20, thickness: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kembalian:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            currencyFormat.format(changeAmount),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (hasChange) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.banknote,
                        color: Colors.orange.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Jangan lupa kembalikan uang kepada customer',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(LucideIcons.receipt, size: 18),
              label: const Text('Lihat Struk'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                side: BorderSide(color: Colors.blue.shade400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Widget _buildConfirmRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
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
          'Bayar Utang Customer',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoadingTransactions
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCustomerHeader(),
                    const SizedBox(height: 24),

                    _buildOutstandingSummary(currencyFormat),
                    const SizedBox(height: 24),

                    if (_transactions.isNotEmpty) ...[
                      _buildTransactionsList(),
                      const SizedBox(height: 24),
                    ],

                    _buildPaymentInputSection(currencyFormat),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _isLoadingTransactions ? null : _buildBottomBar(),
    );
  }

  Widget _buildCustomerHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF6366f1), const Color(0xFF8b5cf6)],
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
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    widget.customer.name.isNotEmpty
                        ? widget.customer.name[0].toUpperCase()
                        : 'C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
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
                      widget.customer.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.phone,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.customer.phone,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutstandingSummary(NumberFormat currencyFormat) {
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
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.alertCircle,
                  color: Color(0xFFEF4444),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Total Utang',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_transactions.length} Transaksi',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
              Text(
                currencyFormat.format(_totalOutstanding),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
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
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.receipt,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Daftar Transaksi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._transactions.asMap().entries.map((entry) {
            final index = entry.key;
            final transaction = entry.value;
            final isLast = index == _transactions.length - 1;
            return _buildTransactionItem(transaction, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(TransactionListItem transaction, bool isLast) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: const Color(0xFFE5E7EB).withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              LucideIcons.fileText,
              color: Color(0xFFEF4444),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.transactionNumber,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat(
                    'dd MMM yyyy',
                    'id_ID',
                  ).format(transaction.transactionDate),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Text(
            currencyFormat.format(transaction.outstandingAmount),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInputSection(NumberFormat currencyFormat) {
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
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.banknote,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Form Pembayaran',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Payment Method Selection
          const Text(
            'Metode Pembayaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PaymentConstants.paymentMethods.entries.map((entry) {
              final isSelected = _selectedPaymentMethod == entry.key;
              return ChoiceChip(
                label: Text(entry.value),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedPaymentMethod = entry.key;
                  });
                },
                selectedColor: const Color(0xFF10B981),
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF10B981)
                      : const Color(0xFFE5E7EB),
                  width: 1,
                ),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Amount Input
          const Text(
            'Nominal Pembayaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              String cleanText = value.replaceAll(RegExp(r'[^\d]'), '');

              if (cleanText.isEmpty) {
                return;
              }

              double? parsedValue = double.tryParse(cleanText);
              if (parsedValue != null) {
                String formattedText = _formatPrice(parsedValue);

                int cursorPosition = _amountController.selection.baseOffset;
                int originalDotsBeforeCursor =
                    value.substring(0, cursorPosition).split('.').length - 1;

                int tempCursorPos = (cursorPosition - originalDotsBeforeCursor)
                    .clamp(0, formattedText.length);
                int newDotsBeforeCursor =
                    formattedText
                        .substring(0, tempCursorPos)
                        .split('.')
                        .length -
                    1;
                int newCursorPosition =
                    cursorPosition -
                    originalDotsBeforeCursor +
                    newDotsBeforeCursor;

                _amountController.value = TextEditingValue(
                  text: formattedText,
                  selection: TextSelection.collapsed(
                    offset: newCursorPosition.clamp(0, formattedText.length),
                  ),
                );
              }
              setState(() {});
            },
            decoration: InputDecoration(
              prefixText: 'Rp ',
              hintText: 'Masukkan nominal',
              helperText:
                  'Total utang: ${currencyFormat.format(_totalOutstanding)}. Bisa input lebih untuk kembalian.',
              helperStyle: const TextStyle(color: Color(0xFF6B7280)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF10B981),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEF4444)),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: _validateAmount,
          ),
          const SizedBox(height: 24),

          // Payment Summary with Change Display
          Builder(
            builder: (context) {
              final totalRequired = _totalOutstanding;
              final amountPaid = _inputAmount;
              final change = amountPaid > totalRequired
                  ? amountPaid - totalRequired
                  : 0.0;

              // Only show summary when user has input amount
              if (amountPaid > 0) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Utang:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                currencyFormat.format(totalRequired),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Nominal Bayar:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                currencyFormat.format(amountPaid),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                          // Show change if payment exceeds total
                          if (change > 0) ...[
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.orange.shade300,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.payments_outlined,
                                        color: Colors.orange.shade700,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Kembalian:',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    currencyFormat.format(change),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Notes Input
          const Text(
            'Catatan (Opsional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Tambahkan catatan pembayaran...',
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF10B981),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _isProcessing || !_isPaymentValid
                ? null
                : _submitPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade500,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.checkCircle, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _inputAmount >= _totalOutstanding
                            ? 'Bayar & Selesaikan Semua'
                            : 'Proses Pembayaran',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
