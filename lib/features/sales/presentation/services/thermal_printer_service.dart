import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import '../../../../data/models/cart_item.dart';
import '../../../transactions/data/models/store.dart';
import '../../../transactions/data/models/user.dart';

class ThermalPrinterService {
  NetworkPrinter? _printer;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  /// Mencari printer di jaringan lokal (simplified version)
  Future<List<String>> discoverPrinters() async {
    final List<String> devices = [];

    try {
      // For now, return common IP ranges for manual discovery
      // In a real implementation, you would use network scanning
      final baseIps = ['192.168.1.', '192.168.0.', '10.0.0.'];

      // This is a simplified discovery - in production you'd want proper network scanning
      for (final baseIp in baseIps) {
        for (int i = 100; i <= 200; i++) {
          final ip = '$baseIp$i';
          // Test connection briefly (simplified)
          try {
            const PaperSize paper = PaperSize.mm58;
            final profile = await CapabilityProfile.load();
            final testPrinter = NetworkPrinter(paper, profile);

            final result = await testPrinter.connect(ip, port: 9100);
            if (result == PosPrintResult.success) {
              devices.add(ip);
              testPrinter.disconnect();
              if (devices.length >= 5) break; // Limit discovery results
            }
          } catch (e) {
            // Continue scanning
          }
        }
        if (devices.length >= 5) break;
      }

      debugPrint('Found ${devices.length} potential printers');
    } catch (e) {
      debugPrint('Error discovering printers: $e');
    }

    return devices;
  }

  /// Menghubungkan ke printer berdasarkan IP address
  Future<bool> connectToPrinter(String ipAddress, {int port = 9100}) async {
    try {
      const PaperSize paper = PaperSize.mm58; // 58mm thermal paper
      final profile = await CapabilityProfile.load();

      _printer = NetworkPrinter(paper, profile);
      final PosPrintResult result = await _printer!.connect(
        ipAddress,
        port: port,
      );

      if (result == PosPrintResult.success) {
        _isConnected = true;
        debugPrint('Printer connected successfully');
        return true;
      } else {
        debugPrint('Failed to connect to printer: $result');
        return false;
      }
    } catch (e) {
      debugPrint('Error connecting to printer: $e');
      return false;
    }
  }

  /// Memutuskan koneksi printer
  void disconnect() {
    if (_printer != null) {
      _printer!.disconnect();
      _isConnected = false;
      _printer = null;
    }
  }

  /// Mencetak struk transaksi
  Future<bool> printReceipt({
    required String receiptId,
    required DateTime transactionDate,
    required List<CartItem> items,
    required Store store,
    User? user,
    required double subtotal,
    required double discount,
    required double total,
    String paymentMethod = 'Tunai',
    String? notes,
  }) async {
    if (_printer == null || !_isConnected) {
      debugPrint('Printer not connected');
      return false;
    }

    try {
      // Header dengan nama toko
      _printer!.text(
        store.name,
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          bold: true,
        ),
      );
      _printer!.feed(1);

      // Alamat toko
      _printer!.text(
        store.address,
        styles: const PosStyles(align: PosAlign.center),
      );
      _printer!.text(
        'Telp: ${store.phoneNumber}',
        styles: const PosStyles(align: PosAlign.center),
      );
      _printer!.feed(1);

      // Garis pemisah
      _printer!.text('================================');
      _printer!.text(
        'STRUK PEMBAYARAN',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
      _printer!.text('================================');
      _printer!.feed(1);

      // Informasi transaksi
      _printer!.row([
        PosColumn(
          text: 'No. Transaksi',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: ': $receiptId',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
      ]);

      _printer!.row([
        PosColumn(
          text: 'Tanggal',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: ': ${_formatDateTime(transactionDate)}',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
      ]);

      _printer!.row([
        PosColumn(
          text: 'Kasir',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: ': ${user?.name ?? 'Admin POS'}',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
      ]);

      _printer!.row([
        PosColumn(
          text: 'Pembayaran',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: ': $paymentMethod',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
      ]);
      _printer!.feed(1);

      // Detail pembelian
      _printer!.text('--------------------------------');
      _printer!.text('DETAIL PEMBELIAN', styles: const PosStyles(bold: true));
      _printer!.text('--------------------------------');

      // Header tabel
      _printer!.row([
        PosColumn(text: 'Item', width: 7, styles: const PosStyles(bold: true)),
        PosColumn(
          text: 'Qty',
          width: 2,
          styles: const PosStyles(align: PosAlign.center, bold: true),
        ),
        PosColumn(
          text: 'Total',
          width: 3,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);
      _printer!.text('--------------------------------');

      // Item-item
      for (final item in items) {
        _printer!.text(item.product.name, styles: const PosStyles(bold: true));
        _printer!.row([
          PosColumn(
            text: 'Rp ${_formatPrice(item.product.price)}',
            width: 7,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: '${item.quantity}',
            width: 2,
            styles: const PosStyles(align: PosAlign.center),
          ),
          PosColumn(
            text: 'Rp ${_formatPrice(item.subtotal)}',
            width: 3,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }

      _printer!.text('--------------------------------');

      // Total
      _printer!.row([
        PosColumn(
          text: 'Subtotal',
          width: 8,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: 'Rp ${_formatPrice(subtotal)}',
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      if (discount > 0) {
        _printer!.row([
          PosColumn(
            text: 'Diskon',
            width: 8,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: 'Rp ${_formatPrice(discount)}',
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }

      _printer!.text('================================');
      _printer!.row([
        PosColumn(
          text: 'TOTAL BAYAR',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
            bold: true,
            height: PosTextSize.size2,
          ),
        ),
        PosColumn(
          text: 'Rp ${_formatPrice(total)}',
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
            bold: true,
            height: PosTextSize.size2,
          ),
        ),
      ]);
      _printer!.text('================================');
      _printer!.feed(1);

      // Catatan jika ada
      if (notes != null && notes.trim().isNotEmpty) {
        _printer!.text('CATATAN:', styles: const PosStyles(bold: true));
        _printer!.text(notes);
        _printer!.feed(1);
      }

      // Footer
      _printer!.text(
        'TERIMA KASIH',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
        ),
      );
      _printer!.text(
        'Atas kunjungan Anda',
        styles: const PosStyles(align: PosAlign.center),
      );
      _printer!.feed(1);

      _printer!.text(
        'Barang yang sudah dibeli tidak dapat',
        styles: const PosStyles(align: PosAlign.center),
      );
      _printer!.text(
        'ditukar kembali kecuali ada kerusakan',
        styles: const PosStyles(align: PosAlign.center),
      );
      _printer!.text(
        'dari pihak toko',
        styles: const PosStyles(align: PosAlign.center),
      );
      _printer!.feed(2);

      // QR Code untuk verifikasi (optional)
      // _printer!.qrcode(receiptId);
      // _printer!.feed(1);

      _printer!.cut();

      debugPrint('Receipt printed successfully');
      return true;
    } catch (e) {
      debugPrint('Error printing receipt: $e');
      return false;
    }
  }

  /// Test print untuk cek koneksi
  Future<bool> testPrint() async {
    if (_printer == null || !_isConnected) {
      return false;
    }

    try {
      _printer!.text(
        'TEST PRINT',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
        ),
      );
      _printer!.feed(1);
      _printer!.text(
        'Printer berhasil terhubung!',
        styles: const PosStyles(align: PosAlign.center),
      );
      _printer!.text(
        DateTime.now().toString(),
        styles: const PosStyles(align: PosAlign.center),
      );
      _printer!.feed(2);
      _printer!.cut();
      return true;
    } catch (e) {
      debugPrint('Error test printing: $e');
      return false;
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
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }
}
