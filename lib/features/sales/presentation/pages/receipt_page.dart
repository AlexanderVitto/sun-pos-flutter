import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/models/cart_item.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../transactions/data/models/store.dart';
import '../../../transactions/data/models/user.dart';
import '../services/thermal_printer_service.dart';
import '../widgets/printer_settings_dialog.dart';

class ReceiptPage extends StatefulWidget {
  final String receiptId;
  final DateTime transactionDate;
  final List<CartItem> items;
  final Store store;
  final User? user; // Add user parameter (optional for backward compatibility)
  final double subtotal;
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
    required this.discount,
    required this.total,
    this.paymentMethod = 'Tunai',
    this.notes,
  });

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  ThermalPrinterService? _connectedPrinter;
  bool _isInitializingPrinter = true;

  @override
  void initState() {
    super.initState();
    _initializePrinter();
  }

  Future<void> _initializePrinter() async {
    try {
      // Coba buat instance printer dan cek apakah ada printer tersimpan
      final printer = ThermalPrinterService();

      // Cek apakah sudah ada printer yang tersimpan
      final hasSaved = await printer.hasSavedPrinter();

      if (hasSaved) {
        // Coba auto-reconnect ke printer terakhir yang tersimpan
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
      setState(() {
        _isInitializingPrinter = false;
      });
    }
  }

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
            tooltip: 'Bagikan Struk',
          ),
          PopupMenuButton<String>(
            icon:
                _isInitializingPrinter
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : Icon(
                      _connectedPrinter?.isConnected == true
                          ? Icons.print
                          : Icons.print_disabled,
                      color:
                          _connectedPrinter?.isConnected == true
                              ? Colors.white
                              : Colors.white70,
                    ),
            tooltip:
                _isInitializingPrinter
                    ? 'Menginisialisasi printer...'
                    : 'Opsi Printer',
            onSelected: (value) async {
              switch (value) {
                case 'print':
                  _printReceipt(context);
                  break;
                case 'setup':
                  _setupPrinter(context);
                  break;
                case 'test':
                  _testPrinter(context);
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem<String>(
                    value: 'print',
                    child: Row(
                      children: [
                        Icon(
                          Icons.print,
                          color:
                              _connectedPrinter?.isConnected == true
                                  ? Colors.green
                                  : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _connectedPrinter?.isConnected == true
                              ? 'Cetak Struk'
                              : 'Cetak Struk (Setup Required)',
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'setup',
                    child: Row(
                      children: [
                        Icon(Icons.settings, color: Colors.blue),
                        SizedBox(width: 12),
                        Text('Pengaturan Printer'),
                      ],
                    ),
                  ),
                  if (_connectedPrinter?.isConnected == true)
                    const PopupMenuItem<String>(
                      value: 'test',
                      child: Row(
                        children: [
                          Icon(Icons.receipt_long, color: Colors.orange),
                          SizedBox(width: 12),
                          Text('Test Print'),
                        ],
                      ),
                    ),
                ],
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
                  if (widget.notes != null &&
                      widget.notes!.trim().isNotEmpty) ...[
                    _buildNotesSection(),
                    const SizedBox(height: 16),
                  ],

                  // Footer
                  _buildFooter(),

                  // Status printer info
                  if (!_isInitializingPrinter) _buildPrinterStatus(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tombol Cetak Struk (jika printer tersedia)
            if (_connectedPrinter?.isConnected == true &&
                !_isInitializingPrinter) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _printReceipt(context),
                  icon: const Icon(Icons.print, size: 20),
                  label: const Text(
                    'Cetak Struk',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            // Tombol navigasi lainnya
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _newTransaction(context),
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Transaksi Baru'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
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
                color: Colors.blue.withValues(alpha: 0.3),
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
          widget.store.name,
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
          '${widget.store.address}\nTelp: ${widget.store.phoneNumber}',
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
              widget.receiptId,
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
              _formatDateTime(widget.transactionDate),
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
              widget.paymentMethod,
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
        ...widget.items.map((item) => _buildItemRow(item)),
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
        _buildTotalRow('Subtotal', widget.subtotal, false),
        if (widget.discount > 0)
          _buildTotalRow('Diskon', -widget.discount, false),
        const Divider(),
        _buildTotalRow('TOTAL BAYAR', widget.total, true),
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

        // Container(
        //   padding: const EdgeInsets.all(12),
        //   decoration: BoxDecoration(
        //     color: Colors.blue[50],
        //     borderRadius: BorderRadius.circular(8),
        //     border: Border.all(color: Colors.blue[200]!),
        //   ),
        //   child: Column(
        //     children: [
        //       Row(
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         children: [
        //           Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
        //           const SizedBox(width: 8),
        //           Text(
        //             'Informasi',
        //             style: TextStyle(
        //               fontWeight: FontWeight.bold,
        //               color: Colors.blue[700],
        //             ),
        //           ),
        //         ],
        //       ),
        //       const SizedBox(height: 8),
        //       Text(
        //         'Barang yang sudah dibeli tidak dapat ditukar kembali kecuali ada kerusakan dari pihak toko',
        //         style: TextStyle(fontSize: 12, color: Colors.blue[600]),
        //         textAlign: TextAlign.center,
        //       ),
        //     ],
        //   ),
        // ),

        // const SizedBox(height: 16),

        // Text(
        //   'Powered by POS System Flutter',
        //   style: TextStyle(fontSize: 10, color: Colors.grey[500]),
        // ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Catatan:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(widget.notes!, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildPrinterStatus() {
    if (_connectedPrinter?.isConnected == true) {
      return Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.print, color: Colors.green[600], size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Printer siap. Tekan tombol "Cetak Struk" untuk mencetak.',
                style: TextStyle(fontSize: 12, color: Colors.green[700]),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.print_disabled, color: Colors.orange[600], size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Printer belum terhubung. Gunakan menu printer untuk setup.',
                style: TextStyle(fontSize: 12, color: Colors.orange[700]),
              ),
            ),
          ],
        ),
      );
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

  void _printReceipt(BuildContext context) async {
    // Jika belum ada printer atau tidak terkoneksi, coba reconnect dulu
    if (_connectedPrinter == null || !_connectedPrinter!.isConnected) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Menghubungkan printer...'),
                ],
              ),
            ),
      );

      try {
        // Coba reconnect ke printer tersimpan
        final printer = ThermalPrinterService();
        final hasSaved = await printer.hasSavedPrinter();

        if (hasSaved) {
          final success = await printer.autoReconnectToLastPrinter();
          if (success) {
            _connectedPrinter = printer;
          }
        }

        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
        }

        // Jika masih tidak bisa connect, tampilkan dialog setup
        if (_connectedPrinter == null || !_connectedPrinter!.isConnected) {
          final printer = await showDialog<ThermalPrinterService>(
            context: context,
            builder: (context) => const PrinterSettingsDialog(),
          );

          if (printer != null) {
            setState(() {
              _connectedPrinter = printer;
            });
          } else {
            // User cancelled printer setup
            return;
          }
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error menghubungkan printer: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    // Show printing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Mencetak struk...'),
              ],
            ),
          ),
    );

    try {
      // Print receipt using thermal printer
      final success = await _connectedPrinter!.printReceipt(
        receiptId: widget.receiptId,
        transactionDate: widget.transactionDate,
        items: widget.items,
        store: widget.store,
        user: widget.user,
        subtotal: widget.subtotal,
        discount: widget.discount,
        total: widget.total,
        paymentMethod: widget.paymentMethod,
        notes: widget.notes,
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close printing dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  success
                      ? 'Struk berhasil dicetak!'
                      : 'Gagal mencetak struk. Silakan coba lagi.',
                ),
              ],
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            action:
                success
                    ? null
                    : SnackBarAction(
                      label: 'Retry',
                      onPressed: () => _printReceipt(context),
                    ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close printing dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _printReceipt(context),
            ),
          ),
        );
      }
    }
  }

  Future<void> _setupPrinter(BuildContext context) async {
    final printer = await showDialog<ThermalPrinterService>(
      context: context,
      builder: (context) => const PrinterSettingsDialog(),
    );

    if (printer != null) {
      setState(() {
        _connectedPrinter = printer;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Printer berhasil dikonfigurasi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _testPrinter(BuildContext context) async {
    if (_connectedPrinter == null || !_connectedPrinter!.isConnected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Printer belum terhubung'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Show loading
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Mencetak test page...'),
                ],
              ),
            ),
      );
    }

    try {
      final success = await _connectedPrinter!.testPrint();

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Test print berhasil!'
                  : 'Test print gagal. Periksa koneksi printer.',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
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
    buffer.writeln('     ${widget.store.name.toUpperCase()}');
    buffer.writeln('  ${widget.store.address}');
    buffer.writeln('       Telp: ${widget.store.phoneNumber}');
    buffer.writeln('=================================');
    buffer.writeln();
    buffer.writeln('STRUK PEMBAYARAN');
    buffer.writeln();
    buffer.writeln('No. Transaksi: ${widget.receiptId}');
    buffer.writeln('Tanggal: ${_formatDateTime(widget.transactionDate)}');
    buffer.writeln('Kasir: ${widget.user?.name ?? 'Admin POS'}');
    buffer.writeln('Pembayaran: ${widget.paymentMethod}');
    buffer.writeln();
    buffer.writeln('---------------------------------');
    buffer.writeln('DETAIL PEMBELIAN');
    buffer.writeln('---------------------------------');

    for (final item in widget.items) {
      buffer.writeln(item.product.name);
      buffer.writeln(
        '  ${item.quantity} x Rp ${_formatPrice(item.product.price)} = Rp ${_formatPrice(item.subtotal)}',
      );
    }

    buffer.writeln('---------------------------------');
    buffer.writeln('Subtotal: Rp ${_formatPrice(widget.subtotal)}');
    if (widget.discount > 0) {
      buffer.writeln('Diskon: Rp ${_formatPrice(widget.discount)}');
    }
    buffer.writeln('=================================');
    buffer.writeln('TOTAL BAYAR: Rp ${_formatPrice(widget.total)}');
    buffer.writeln('=================================');
    buffer.writeln();

    // Add notes if exists
    if (widget.notes != null && widget.notes!.trim().isNotEmpty) {
      buffer.writeln('CATATAN:');
      buffer.writeln(widget.notes!);
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
