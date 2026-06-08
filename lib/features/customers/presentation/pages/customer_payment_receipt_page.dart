import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../shared/utils/receipt_share_helper.dart';
import '../../data/models/customer.dart';
import '../../data/models/payment_receipt_item.dart';
import '../../../sales/presentation/services/thermal_printer_service.dart';
import '../../../sales/presentation/widgets/printer_settings_dialog.dart';

class CustomerPaymentReceiptPage extends StatefulWidget {
  final Customer customer;
  final List<PaymentReceiptItem> paidTransactions;
  final String paymentMethod;
  final double totalPaid;
  final double changeAmount;
  final DateTime paymentDate;
  final String? notes;

  const CustomerPaymentReceiptPage({
    super.key,
    required this.customer,
    required this.paidTransactions,
    required this.paymentMethod,
    required this.totalPaid,
    required this.changeAmount,
    required this.paymentDate,
    this.notes,
  });

  @override
  State<CustomerPaymentReceiptPage> createState() =>
      _CustomerPaymentReceiptPageState();
}

class _CustomerPaymentReceiptPageState
    extends State<CustomerPaymentReceiptPage> {
  ThermalPrinterService? _connectedPrinter;
  final GlobalKey _receiptBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initializePrinter();
  }

  Future<void> _initializePrinter() async {
    try {
      final printer = ThermalPrinterService();
      final hasSaved = await printer.hasSavedPrinter();

      if (hasSaved) {
        final success = await printer.autoReconnectToLastPrinter();
        if (success) {
          _connectedPrinter = printer;
        }
      }
    } catch (e) {
      debugPrint('Error initializing printer: $e');
      _connectedPrinter = null;
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Struk Pembayaran Hutang',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: RepaintBoundary(
          key: _receiptBoundaryKey,
          child: Container(
            color: Colors.grey.shade50,
            child: Column(
              children: [
                // Header Card
                _buildHeaderCard(currencyFormat),
                const SizedBox(height: 16),

                // List of Paid Transactions
                ...widget.paidTransactions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Column(
                    children: [
                      _buildTransactionReceiptCard(
                        item,
                        index + 1,
                        currencyFormat,
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                }),

                // Summary Card
                _buildSummaryCard(currencyFormat),
                const SizedBox(height: 16),

                // Footer
                _buildFooter(),
                const SizedBox(height: 16),

                // Notes if exists
                if (widget.notes != null && widget.notes!.trim().isNotEmpty)
                  _buildNotesCard(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildHeaderCard(NumberFormat currencyFormat) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade600, Colors.green.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Icon(LucideIcons.checkCircle2, color: Colors.white, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Pembayaran Berhasil',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat(
                'EEEE, dd MMMM yyyy HH:mm',
                'id_ID',
              ).format(widget.paymentDate),
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.user,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Customer',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              widget.customer.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (widget.customer.phone.isNotEmpty)
                              Text(
                                widget.customer.phone,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                          ],
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
    );
  }

  Widget _buildTransactionReceiptCard(
    PaymentReceiptItem item,
    int index,
    NumberFormat currencyFormat,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.receipt,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaksi #$index',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        item.receiptNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: item.isFullyPaid
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: item.isFullyPaid
                          ? Colors.green.shade300
                          : Colors.orange.shade300,
                    ),
                  ),
                  child: Text(
                    item.isFullyPaid ? 'LUNAS' : 'SEBAGIAN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: item.isFullyPaid
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Transaction Date
            Row(
              children: [
                const Icon(
                  LucideIcons.calendar,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat(
                    'dd MMM yyyy',
                    'id_ID',
                  ).format(item.transactionDate),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Transaction Items List (if available)
            if (item.transactionDetails != null &&
                item.transactionDetails!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DETAIL PEMBELIAN',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B7280),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...item.transactionDetails!.map((detail) {
                      return _buildItemRow(detail, currencyFormat);
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Payment Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    'Total Transaksi:',
                    currencyFormat.format(item.originalAmount),
                    Colors.grey.shade700,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Hutang Sebelumnya:',
                    currencyFormat.format(item.previousOutstanding),
                    Colors.red.shade700,
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    'Dibayar:',
                    currencyFormat.format(item.paymentAmount),
                    Colors.green.shade700,
                    isBold: true,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Sisa Hutang:',
                    currencyFormat.format(item.remainingOutstanding),
                    item.isFullyPaid
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                    isBold: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    Color valueColor, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow(dynamic detail, NumberFormat currencyFormat) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris pertama: Nama item
          Text(
            detail.productName,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          // Baris kedua: Quantity @ harga dan subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${detail.quantity} × ${currencyFormat.format(detail.unitPrice)}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              Text(
                currencyFormat.format(detail.totalAmount),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(height: 1, thickness: 0.5, color: Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(NumberFormat currencyFormat) {
    final totalPaymentAmount = widget.paidTransactions.fold<double>(
      0,
      (sum, item) => sum + item.paymentAmount,
    );
    final fullyPaidCount = widget.paidTransactions
        .where((t) => t.isFullyPaid)
        .length;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.fileText,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Ringkasan Pembayaran',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    'Metode Pembayaran:',
                    widget.paymentMethod,
                    Colors.grey.shade700,
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    'Jumlah Transaksi:',
                    '${widget.paidTransactions.length} transaksi',
                    Colors.grey.shade700,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Lunas:',
                    '$fullyPaidCount transaksi',
                    Colors.green.shade700,
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    'Total Dibayarkan:',
                    currencyFormat.format(totalPaymentAmount),
                    Colors.green.shade700,
                    isBold: true,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Nominal Bayar:',
                    currencyFormat.format(widget.totalPaid),
                    Colors.blue.shade700,
                    isBold: true,
                  ),
                  if (widget.changeAmount > 0) ...[
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            currencyFormat.format(widget.changeAmount),
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
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.stickyNote,
                    color: Colors.purple.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Catatan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                widget.notes ?? '',
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'TERIMA KASIH',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Atas kunjungan Anda',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            // Peringatan kembang api
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 20,
                        color: Colors.orange[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'PERINGATAN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pengguna kembang api dimainkan mengikuti aturan penggunaan yang tertera di setiap produk. Setiap pembeli mengetahui dan mengerti aturan untuk menjual/memakai produk kembang api ini.',
                    style: TextStyle(fontSize: 12, color: Colors.orange[900]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
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
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showShareSheet(context),
                  icon: const Icon(LucideIcons.share2, size: 18),
                  label: const Text('Bagikan', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _printReceipt(context),
                  icon: const Icon(LucideIcons.printer, size: 18),
                  label: const Text('Print', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.check, size: 18),
                  label: const Text('Selesai', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Bagikan Struk Pembayaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Bagikan sebagai PDF'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _shareAsPdf();
                },
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Colors.blue),
                title: const Text('Bagikan sebagai Gambar'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _shareAsImage();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  String _shareSubject() => 'Struk Pembayaran — ${widget.customer.name}';

  String _shareCaption() {
    final f = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return 'Pembayaran hutang dari ${widget.customer.name}\n'
        'Total dibayar: ${f.format(widget.totalPaid)}';
  }

  String _baseFilename() {
    final ts = DateFormat('yyyyMMdd_HHmm').format(widget.paymentDate);
    final cust = widget.customer.name.replaceAll(RegExp(r'\s+'), '_');
    return 'pembayaran_${cust}_$ts';
  }

  Future<void> _shareAsImage() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ReceiptShareHelper.shareImageFromBoundary(
        _receiptBoundaryKey,
        filename: '${_baseFilename()}.png',
        subject: _shareSubject(),
        text: _shareCaption(),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Gagal membagikan gambar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _shareAsPdf() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final bytes = await _buildReceiptPdf();
      await ReceiptShareHelper.sharePdfBytes(
        bytes,
        filename: '${_baseFilename()}.pdf',
        subject: _shareSubject(),
        text: _shareCaption(),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Gagal membuat PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Uint8List> _buildReceiptPdf() async {
    final doc = pw.Document();
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFmt = DateFormat('dd MMM yyyy HH:mm', 'id_ID');

    pw.Widget kv(String key, String value, {bool bold = false}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 1),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              key,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginLeft: 32,
          marginRight: 32,
          marginTop: 32,
          marginBottom: 32,
        ),
        build: (context) {
          return [
            pw.Center(
              child: pw.Text(
                'STRUK PEMBAYARAN HUTANG',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Center(
              child: pw.Text(
                dateFmt.format(widget.paymentDate),
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
            pw.Divider(thickness: 0.8),
            pw.SizedBox(height: 4),
            kv('Customer', widget.customer.name, bold: true),
            if (widget.customer.phone.isNotEmpty)
              kv('Telepon', widget.customer.phone),
            kv('Metode Pembayaran', widget.paymentMethod),
            pw.SizedBox(height: 8),
            pw.Text(
              'TRANSAKSI YANG DIBAYAR',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            ...widget.paidTransactions.asMap().entries.map((entry) {
              final i = entry.key + 1;
              final item = entry.value;
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 6),
                padding: const pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '$i. ${item.receiptNumber}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      dateFmt.format(item.transactionDate),
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                    pw.SizedBox(height: 4),
                    kv('Total Transaksi', currency.format(item.originalAmount)),
                    kv(
                      'Hutang Sebelumnya',
                      currency.format(item.previousOutstanding),
                    ),
                    kv(
                      'Pembayaran',
                      currency.format(item.paymentAmount),
                      bold: true,
                    ),
                    kv(
                      'Sisa Hutang',
                      currency.format(item.remainingOutstanding),
                    ),
                    kv('Status', item.isFullyPaid ? 'LUNAS' : 'SEBAGIAN'),
                  ],
                ),
              );
            }),
            pw.Divider(thickness: 0.8),
            kv('Total Dibayar', currency.format(widget.totalPaid), bold: true),
            if (widget.changeAmount > 0)
              kv('Kembalian', currency.format(widget.changeAmount)),
            if (widget.notes != null && widget.notes!.trim().isNotEmpty) ...[
              pw.SizedBox(height: 10),
              pw.Text(
                'CATATAN:',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                widget.notes!,
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
            pw.SizedBox(height: 16),
            pw.Center(
              child: pw.Text(
                'Terima kasih atas pembayaran Anda',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
          ];
        },
      ),
    );

    return doc.save();
  }

  Future<void> _printReceipt(BuildContext context) async {
    // Jika belum ada printer atau tidak terkoneksi, coba reconnect dulu
    if (_connectedPrinter == null || !_connectedPrinter!.isConnected) {
      // Show loading dialog
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Menghubungkan printer...'),
            ],
          ),
        ),
      );

      try {
        final printer = ThermalPrinterService();
        final hasSaved = await printer.hasSavedPrinter();

        if (hasSaved) {
          final success = await printer.autoReconnectToLastPrinter();
          if (success) {
            _connectedPrinter = printer;
          }
        }

        if (context.mounted) {
          Navigator.of(context).pop(); // Close loading dialog
        }

        // Jika masih tidak bisa connect, tampilkan dialog setup
        if (_connectedPrinter == null || !_connectedPrinter!.isConnected) {
          if (!context.mounted) return;
          final printer = await showDialog<ThermalPrinterService>(
            context: context,
            builder: (context) => const PrinterSettingsDialog(),
          );

          if (printer != null) {
            setState(() {
              _connectedPrinter = printer;
            });
          } else {
            return; // User cancelled
          }
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context).pop(); // Close loading dialog

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    // Show printing dialog
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Mencetak struk...'),
          ],
        ),
      ),
    );

    try {
      // Print struk pembayaran hutang
      bool success = false;

      if (_connectedPrinter != null) {
        success = await _connectedPrinter!.printPaymentReceipt(
          customerName: widget.customer.name,
          customerPhone: widget.customer.phone,
          paymentMethod: widget.paymentMethod,
          paidTransactions: widget.paidTransactions,
          totalPaid: widget.totalPaid,
          changeAmount: widget.changeAmount,
          paymentDate: widget.paymentDate,
          notes: widget.notes,
        );
      }

      if (context.mounted) {
        Navigator.of(context).pop(); // Close printing dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Struk berhasil dicetak!' : 'Struk dikirim ke printer',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close printing dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mencetak: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Coba Lagi',
              textColor: Colors.white,
              onPressed: () => _printReceipt(context),
            ),
          ),
        );
      }
    }
  }
}
