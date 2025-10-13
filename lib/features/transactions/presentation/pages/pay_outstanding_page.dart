import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../transactions/data/models/create_transaction_response.dart';
import '../../../transactions/data/models/payment_history.dart';
import '../../../transactions/data/services/transaction_api_service.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../../core/constants/payment_constants.dart';
import '../../../sales/presentation/pages/receipt_page.dart';
import '../../../../data/models/cart_item.dart';
import '../../../../data/models/product.dart';

class PayOutstandingPage extends StatefulWidget {
  final TransactionData transaction;

  const PayOutstandingPage({super.key, required this.transaction});

  @override
  State<PayOutstandingPage> createState() => _PayOutstandingPageState();
}

class _PayOutstandingPageState extends State<PayOutstandingPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final TransactionApiService _apiService = TransactionApiService();

  String _selectedPaymentMethod = 'cash';
  bool _isProcessing = false;
  double _outstandingAmount = 0.0;
  double _totalPaid = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateOutstanding();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateOutstanding() {
    // Calculate total paid from payment histories
    _totalPaid = widget.transaction.paymentHistories.fold<double>(
      0,
      (sum, payment) => sum + payment.amount,
    );

    // Calculate outstanding amount
    _outstandingAmount = widget.transaction.totalAmount - _totalPaid;

    // Set max amount to outstanding amount
    setState(() {});
  }

  double get _inputAmount {
    final text = _amountController.text.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(text) ?? 0.0;
  }

  bool get _isPaymentValid {
    return _inputAmount > 0 && _inputAmount <= _outstandingAmount;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nominal pembayaran harus diisi';
    }

    final amount = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (amount == null || amount <= 0) {
      return 'Nominal harus lebih dari 0';
    }

    if (amount > _outstandingAmount) {
      return 'Nominal melebihi sisa utang';
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
      // Create new payment object
      final newPayment = {
        'payment_method': _selectedPaymentMethod,
        'amount': _inputAmount,
        'payment_date': DateTime.now().toIso8601String(),
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        'user_id': userId,
      };

      // Combine existing payments with new payment
      final updatedPayments = [
        ...widget.transaction.paymentHistories.map(
          (p) => {
            'payment_method': p.paymentMethod,
            'amount': p.amount,
            'payment_date': p.paymentDate,
            'notes': p.notes,
          },
        ),
        newPayment,
      ];

      // Calculate new outstanding amount
      final newTotalPaid = _totalPaid + _inputAmount;
      final newOutstanding = widget.transaction.totalAmount - newTotalPaid;

      // Determine new status
      final newStatus = newOutstanding <= 0 ? 'completed' : 'outstanding';

      // Prepare request body
      final requestBody = <String, dynamic>{
        'payments': updatedPayments,
        'status': newStatus,
      };

      // Include outstandingReminderDate if status is still outstanding
      if (newStatus == 'outstanding' &&
          widget.transaction.outstandingReminderDate != null) {
        requestBody['outstanding_reminder_date'] = widget
            .transaction
            .outstandingReminderDate!
            .toIso8601String();
      }

      // Call API to update transaction
      await _apiService.updateTransactionPayment(
        widget.transaction.id,
        requestBody,
      );

      if (!mounted) return;

      // Navigate to receipt page
      _navigateToReceipt(newStatus, newTotalPaid, newOutstanding);
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

    final newTotalPaid = _totalPaid + _inputAmount;
    final newOutstanding = _outstandingAmount - _inputAmount;
    final willBeCompleted = newOutstanding <= 0;

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
                'Apakah Anda yakin ingin memproses pembayaran ini?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
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
                      'Total Dibayar:',
                      currencyFormat.format(newTotalPaid),
                      Colors.blue.shade700,
                    ),
                    const SizedBox(height: 8),
                    _buildConfirmRow(
                      willBeCompleted ? 'Status:' : 'Sisa Utang:',
                      willBeCompleted
                          ? 'LUNAS'
                          : currencyFormat.format(newOutstanding),
                      willBeCompleted
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: willBeCompleted
                      ? Colors.green.shade50
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      willBeCompleted
                          ? LucideIcons.checkCircle
                          : LucideIcons.info,
                      color: willBeCompleted
                          ? Colors.green.shade700
                          : Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        willBeCompleted
                            ? 'Transaksi akan diselesaikan dan ditandai sebagai LUNAS'
                            : 'Pembayaran akan ditambahkan ke riwayat pembayaran',
                        style: TextStyle(
                          fontSize: 13,
                          color: willBeCompleted
                              ? Colors.green.shade700
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
          'Bayar Utang',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction Header
              _buildTransactionHeader(),
              const SizedBox(height: 24),

              // Outstanding Summary
              _buildOutstandingSummary(currencyFormat),
              const SizedBox(height: 24),

              // Payment History (if any)
              if (widget.transaction.paymentHistories.isNotEmpty) ...[
                _buildPaymentHistory(currencyFormat),
                const SizedBox(height: 24),
              ],

              // Payment Input Section
              _buildPaymentInputSection(currencyFormat),
              const SizedBox(height: 100), // Space for bottom button
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildTransactionHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFEA580C), // Orange for outstanding
            const Color(0xFFF97316),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEA580C).withValues(alpha: 0.3),
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
                child: const Icon(
                  LucideIcons.alertTriangle,
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
                      widget.transaction.transactionNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
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
                      child: const Text(
                        'Outstanding',
                        style: TextStyle(
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
          const SizedBox(height: 16),
          Text(
            DateFormat(
              'dd MMMM yyyy, HH:mm',
              'id_ID',
            ).format(widget.transaction.transactionDate),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
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
                  color: const Color(0xFFEA580C).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.wallet,
                  color: Color(0xFFEA580C),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Ringkasan Utang',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSummaryRow(
            'Total Transaksi',
            currencyFormat.format(widget.transaction.totalAmount),
            const Color(0xFF6B7280),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Sudah Dibayar',
            currencyFormat.format(_totalPaid),
            const Color(0xFF10B981),
          ),
          const Divider(height: 24),
          _buildSummaryRow(
            'Sisa Utang',
            currencyFormat.format(_outstandingAmount),
            const Color(0xFFEF4444),
            isLarge: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    Color valueColor, {
    bool isLarge = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isLarge ? 18 : 16,
            fontWeight: isLarge ? FontWeight.bold : FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isLarge ? 24 : 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentHistory(NumberFormat currencyFormat) {
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
                  LucideIcons.history,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Riwayat Pembayaran',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.transaction.paymentHistories.asMap().entries.map((entry) {
            final index = entry.key;
            final payment = entry.value;
            final isLast =
                index == widget.transaction.paymentHistories.length - 1;
            return _buildPaymentHistoryItem(payment, isLast, currencyFormat);
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryItem(
    PaymentHistory payment,
    bool isLast,
    NumberFormat currencyFormat,
  ) {
    final paymentDate = DateTime.tryParse(payment.paymentDate);
    final formattedDate = paymentDate != null
        ? DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(paymentDate)
        : payment.paymentDate;

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
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              LucideIcons.checkCircle,
              color: Color(0xFF10B981),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PaymentConstants.paymentMethods[payment.paymentMethod] ??
                      payment.paymentMethod,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Text(
            currencyFormat.format(payment.amount),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF10B981),
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
                'Pembayaran Baru',
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
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              prefixText: 'Rp ',
              hintText: 'Masukkan nominal',
              helperText:
                  'Maksimal: ${currencyFormat.format(_outstandingAmount)}',
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
            onChanged: (value) {
              setState(() {}); // Update UI for validation
            },
          ),
          const SizedBox(height: 24),

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
                        _inputAmount >= _outstandingAmount
                            ? 'Bayar & Selesaikan'
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

  void _navigateToReceipt(
    String newStatus,
    double newTotalPaid,
    double newOutstanding,
  ) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Convert transaction details to cart items for receipt
    final cartItems = widget.transaction.details.map((detail) {
      final product = Product(
        id: detail.productId ?? 0,
        name: detail.productName,
        price: detail.unitPrice,
        productVariantId: detail.productVariantId,
        description: detail.productVariant?.name ?? '',
        stock: 0,
        category: '',
      );

      return CartItem(
        id: detail.id,
        product: product,
        quantity: detail.quantity,
        addedAt: detail.createdAt,
      );
    }).toList();

    // Prepare notes with payment info
    String receiptNotes =
        'Pembayaran Utang: ${currencyFormat.format(_inputAmount)}';
    if (newStatus == 'outstanding') {
      receiptNotes += '\nSisa Utang: ${currencyFormat.format(newOutstanding)}';
    } else {
      receiptNotes += '\nStatus: LUNAS';
    }
    if (_notesController.text.trim().isNotEmpty) {
      receiptNotes += '\nCatatan: ${_notesController.text.trim()}';
    }

    // Navigate to receipt page
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ReceiptPage(
          receiptId: widget.transaction.transactionNumber,
          transactionDate: widget.transaction.transactionDate,
          items: cartItems,
          store: widget.transaction.store,
          user: widget.transaction.user, // Use transaction user to match type
          subtotal: widget.transaction.totalAmount,
          discount: 0.0,
          total: widget.transaction.totalAmount,
          paymentMethod: _selectedPaymentMethod,
          notes: receiptNotes,
          status: newStatus,
          dueDate: newStatus == 'outstanding'
              ? widget.transaction.outstandingReminderDate
              : null,
        ),
      ),
    );
  }
}
