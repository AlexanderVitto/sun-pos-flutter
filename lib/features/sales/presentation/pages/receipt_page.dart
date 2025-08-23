import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/models/cart_item.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../transactions/data/models/store.dart';
import '../../../transactions/data/models/user.dart';

class ReceiptPage extends StatelessWidget {
  final String receiptId;
  final DateTime transactionDate;
  final List<CartItem> items;
  final Store store;
  final User? user; // Add user parameter (optional for backward compatibility)
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final String paymentMethod;
  final String? notes; // Add notes parameter

  const ReceiptPage({
    super.key,
    required this.receiptId,
    required this.transactionDate,
    required this.items,
    required this.store,
    this.user, // Add user parameter
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    this.paymentMethod = 'Tunai',
    this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Struk Pembayaran'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareReceipt(context),
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printReceipt(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Store Header
                  _buildStoreHeader(),

                  const Divider(height: 32, thickness: 2),

                  // Transaction Info
                  _buildTransactionInfo(),

                  const SizedBox(height: 24),

                  // Items List
                  _buildItemsList(),

                  const Divider(height: 32, thickness: 1),

                  // Totals
                  _buildTotals(),

                  const Divider(height: 32, thickness: 2),

                  // Notes section (if exists)
                  if (notes != null && notes!.trim().isNotEmpty) ...[
                    _buildNotesSection(),
                    const SizedBox(height: 16),
                  ],

                  // Footer
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _newTransaction(context),
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Transaksi Baru'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const DashboardPage(),
                    ),
                    (route) => false, // Remove all previous routes
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text('Ke Dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreHeader() {
    return Column(
      children: [
        // Store Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blue[600],
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.store, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 16),

        // Store Name
        Text(
          store.name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Store Address
        Text(
          '${store.address}\nTelp: ${store.phoneNumber}',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTransactionInfo() {
    return Column(
      children: [
        const Text(
          'STRUK PEMBAYARAN',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('No. Transaksi:', style: TextStyle(color: Colors.grey[600])),
            Text(
              receiptId,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tanggal:', style: TextStyle(color: Colors.grey[600])),
            Text(
              _formatDateTime(transactionDate),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Kasir:', style: TextStyle(color: Colors.grey[600])),
            const Text(
              'Admin POS',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pembayaran:', style: TextStyle(color: Colors.grey[600])),
            Text(
              paymentMethod,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DETAIL PEMBELIAN',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),

        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Item',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Qty',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Harga',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Items
        ...items.map((item) => _buildItemRow(item)),
      ],
    );
  }

  Widget _buildItemRow(CartItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item.product.name,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${item.quantity}',
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Rp ${_formatPrice(item.product.price)}',
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Rp ${_formatPrice(item.subtotal)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotals() {
    return Column(
      children: [
        _buildTotalRow('Subtotal', subtotal, false),
        if (discount > 0) _buildTotalRow('Diskon', -discount, false),
        if (tax > 0) _buildTotalRow('Pajak (10%)', tax, false),
        const Divider(),
        _buildTotalRow('TOTAL BAYAR', total, true),
      ],
    );
  }

  Widget _buildTotalRow(String label, double amount, bool isTotal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey[700],
            ),
          ),
          Text(
            'Rp ${_formatPrice(amount.abs())}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.bold,
              color:
                  isTotal
                      ? Colors.green[600]
                      : (amount < 0 ? Colors.red : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
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
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Informasi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Barang yang sudah dibeli tidak dapat ditukar kembali kecuali ada kerusakan dari pihak toko',
                style: TextStyle(fontSize: 12, color: Colors.blue[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'Powered by POS System Flutter',
          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note_outlined, size: 16, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Text(
                'Catatan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            notes!,
            style: TextStyle(fontSize: 14, color: Colors.orange[800]),
          ),
        ],
      ),
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

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = months[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day $month $year, $hour:$minute WIB';
  }

  void _shareReceipt(BuildContext context) {
    final receiptText = _generateReceiptText();

    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: receiptText));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Struk disalin ke clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _printReceipt(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur print akan segera tersedia'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _newTransaction(BuildContext context) {
    // Navigate to dashboard and show POS tab (index 1)
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder:
            (context) => const DashboardPage(
              initialIndex: 1, // POS tab
            ),
      ),
      (route) => false, // Remove all previous routes
    );
  }

  String _generateReceiptText() {
    final buffer = StringBuffer();

    buffer.writeln('=================================');
    buffer.writeln('     ${store.name.toUpperCase()}');
    buffer.writeln('  ${store.address}');
    buffer.writeln('       Telp: ${store.phoneNumber}');
    buffer.writeln('=================================');
    buffer.writeln();
    buffer.writeln('STRUK PEMBAYARAN');
    buffer.writeln();
    buffer.writeln('No. Transaksi: $receiptId');
    buffer.writeln('Tanggal: ${_formatDateTime(transactionDate)}');
    buffer.writeln('Kasir: ${user?.name ?? 'Admin POS'}');
    buffer.writeln('Pembayaran: $paymentMethod');
    buffer.writeln();
    buffer.writeln('---------------------------------');
    buffer.writeln('DETAIL PEMBELIAN');
    buffer.writeln('---------------------------------');

    for (final item in items) {
      buffer.writeln('${item.product.name}');
      buffer.writeln(
        '  ${item.quantity} x Rp ${_formatPrice(item.product.price)} = Rp ${_formatPrice(item.subtotal)}',
      );
    }

    buffer.writeln('---------------------------------');
    buffer.writeln('Subtotal: Rp ${_formatPrice(subtotal)}');
    if (discount > 0) {
      buffer.writeln('Diskon: Rp ${_formatPrice(discount)}');
    }
    if (tax > 0) {
      buffer.writeln('Pajak (10%): Rp ${_formatPrice(tax)}');
    }
    buffer.writeln('=================================');
    buffer.writeln('TOTAL BAYAR: Rp ${_formatPrice(total)}');
    buffer.writeln('=================================');
    buffer.writeln();

    // Add notes if exists
    if (notes != null && notes!.trim().isNotEmpty) {
      buffer.writeln('CATATAN:');
      buffer.writeln(notes!);
      buffer.writeln();
    }

    buffer.writeln('        TERIMA KASIH');
    buffer.writeln('      Atas kunjungan Anda');
    buffer.writeln();
    buffer.writeln('Barang yang sudah dibeli tidak dapat');
    buffer.writeln('ditukar kembali kecuali ada kerusakan');
    buffer.writeln('dari pihak toko');
    buffer.writeln();

    return buffer.toString();
  }
}
