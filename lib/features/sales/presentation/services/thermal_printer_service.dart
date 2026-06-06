import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/cart_item.dart';
import '../../../transactions/data/models/store.dart';
import '../../../transactions/data/models/user.dart';
import '../../../transactions/data/models/payment_history.dart';
import 'bluetooth_printer_service.dart';
import 'printer_preferences_service.dart';

enum PrinterConnectionType { network, bluetooth }

class ThermalPrinterService {
  NetworkPrinter? _printer;
  BluetoothPrinterService? _bluetoothPrinter;
  bool _isConnected = false;
  PrinterConnectionType? _connectionType;
  SavedPrinterInfo? _currentPrinterInfo;

  bool get isConnected => _isConnected;
  PrinterConnectionType? get connectionType => _connectionType;
  SavedPrinterInfo? get currentPrinterInfo => _currentPrinterInfo;

  // Getter untuk Bluetooth printer service
  BluetoothPrinterService get bluetoothPrinter {
    _bluetoothPrinter ??= BluetoothPrinterService();
    return _bluetoothPrinter!;
  }

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

  /// Menghubungkan ke printer berdasarkan IP address (Network)
  Future<bool> connectToPrinter(String ipAddress, {int port = 9100}) async {
    try {
      // Disconnect any existing connections
      disconnect();

      const PaperSize paper = PaperSize.mm58; // 58mm thermal paper
      final profile = await CapabilityProfile.load();

      _printer = NetworkPrinter(paper, profile);
      final PosPrintResult result = await _printer!.connect(
        ipAddress,
        port: port,
      );

      if (result == PosPrintResult.success) {
        _isConnected = true;
        _connectionType = PrinterConnectionType.network;

        // Save printer preferences
        _currentPrinterInfo = SavedPrinterInfo(
          type: SavedPrinterType.network,
          ipAddress: ipAddress,
          port: port,
          lastConnected: DateTime.now(),
        );

        await PrinterPreferencesService.instance.saveLastConnectedPrinter(
          type: SavedPrinterType.network,
          ipAddress: ipAddress,
          port: port,
        );

        debugPrint(
          'Network printer connected successfully and preferences saved',
        );
        return true;
      } else {
        debugPrint('Failed to connect to network printer: $result');
        return false;
      }
    } catch (e) {
      debugPrint('Error connecting to network printer: $e');
      return false;
    }
  }

  /// Menghubungkan ke printer Bluetooth berdasarkan address
  Future<bool> connectToBluetoothPrinter(
    String address, {
    String? deviceName,
  }) async {
    try {
      // Disconnect any existing connections
      disconnect();

      final success = await bluetoothPrinter.connectToPrinter(address);

      if (success) {
        _isConnected = true;
        _connectionType = PrinterConnectionType.bluetooth;

        // Save printer preferences
        _currentPrinterInfo = SavedPrinterInfo(
          type: SavedPrinterType.bluetooth,
          bluetoothAddress: address,
          bluetoothName: deviceName,
          lastConnected: DateTime.now(),
        );

        await PrinterPreferencesService.instance.saveLastConnectedPrinter(
          type: SavedPrinterType.bluetooth,
          bluetoothAddress: address,
          bluetoothName: deviceName,
        );

        debugPrint(
          'Bluetooth printer connected successfully and preferences saved',
        );
        return true;
      } else {
        debugPrint('Failed to connect to Bluetooth printer');
        return false;
      }
    } catch (e) {
      debugPrint('Error connecting to Bluetooth printer: $e');
      return false;
    }
  }

  /// Memutuskan koneksi printer
  void disconnect() {
    if (_printer != null) {
      _printer!.disconnect();
      _printer = null;
    }

    if (_bluetoothPrinter != null) {
      _bluetoothPrinter!.disconnect();
    }

    _isConnected = false;
    _connectionType = null;
    _currentPrinterInfo = null;
  }

  /// Auto-reconnect ke printer terakhir yang tersimpan
  Future<bool> autoReconnectToLastPrinter() async {
    try {
      final autoConnect = await PrinterPreferencesService.instance
          .getAutoConnect();
      if (!autoConnect) {
        debugPrint('Auto-connect disabled');
        return false;
      }

      final savedPrinter = await PrinterPreferencesService.instance
          .getLastConnectedPrinter();
      if (savedPrinter == null) {
        debugPrint('No saved printer found');
        return false;
      }

      debugPrint('Attempting to reconnect to: ${savedPrinter.displayName}');

      if (savedPrinter.type == SavedPrinterType.network) {
        if (savedPrinter.ipAddress != null) {
          return await connectToPrinter(
            savedPrinter.ipAddress!,
            port: savedPrinter.port ?? 9100,
          );
        }
      } else if (savedPrinter.type == SavedPrinterType.bluetooth) {
        if (savedPrinter.bluetoothAddress != null) {
          return await connectToBluetoothPrinter(
            savedPrinter.bluetoothAddress!,
            deviceName: savedPrinter.bluetoothName,
          );
        }
      }

      return false;
    } catch (e) {
      debugPrint('Error auto-reconnecting to printer: $e');
      return false;
    }
  }

  /// Cek apakah sudah ada printer tersimpan
  Future<bool> hasSavedPrinter() async {
    return await PrinterPreferencesService.instance.hasSavedPrinter();
  }

  /// Hapus printer tersimpan
  Future<void> clearSavedPrinter() async {
    await PrinterPreferencesService.instance.clearSavedPrinter();
    _currentPrinterInfo = null;
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
    List<PaymentHistory>? paymentHistories,
    String? notes,
    String? status,
    DateTime? dueDate,
  }) async {
    if (!_isConnected) {
      debugPrint('Printer not connected');
      return false;
    }

    try {
      // Satu sumber kebenaran: bangun byte struk sekali, lalu kirim ke
      // network atau bluetooth. Menghindari struk yang berbeda antar jalur.
      final bytes = await _buildReceiptBytes(
        receiptId: receiptId,
        transactionDate: transactionDate,
        items: items,
        store: store,
        user: user,
        subtotal: subtotal,
        discount: discount,
        total: total,
        paymentMethod: paymentMethod,
        paymentHistories: paymentHistories,
        notes: notes,
        status: status,
        dueDate: dueDate,
      );

      if (_connectionType == PrinterConnectionType.network &&
          _printer != null) {
        _printer!.rawBytes(bytes);
        debugPrint('Receipt printed successfully (network)');
        return true;
      } else if (_connectionType == PrinterConnectionType.bluetooth &&
          _bluetoothPrinter != null) {
        return await _bluetoothPrinter!.printRawData(bytes);
      }

      return false;
    } catch (e) {
      debugPrint('Error printing receipt: $e');
      return false;
    }
  }

  /// Convert API payment method key to display label.
  String _formatPaymentMethodLabel(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Tunai';
      case 'card':
        return 'Kartu';
      case 'transfer':
      case 'bank_transfer':
        return 'Transfer';
      case 'e-wallet':
      case 'ewallet':
      case 'digital_wallet':
        return 'E-Wallet';
      case 'credit':
        return 'Kredit';
      default:
        return method;
    }
  }

  /// Membangun byte ESC/POS struk. Dipakai bersama oleh network & bluetooth
  /// agar isi struk selalu identik di kedua jalur (item, diskon, jatuh tempo).
  Future<List<int>> _buildReceiptBytes({
    required String receiptId,
    required DateTime transactionDate,
    required List<CartItem> items,
    required Store store,
    User? user,
    required double subtotal,
    required double discount,
    required double total,
    String paymentMethod = 'Tunai',
    List<PaymentHistory>? paymentHistories,
    String? notes,
    String? status,
    DateTime? dueDate,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    // Header toko dihapus sesuai requirement
    bytes += generator.text('================================');
    bytes += generator.text(
      'STRUK PEMBAYARAN',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text('================================');
    bytes += generator.feed(1);

    // Info transaksi
    bytes += generator.row([
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
    bytes += generator.row([
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
    bytes += generator.row([
      PosColumn(
        text: 'Kasir',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: ': ${_toInitials(user?.name ?? 'Admin POS')}',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
    ]);

    // Pembayaran — multi-method bila histories > 1, selain itu satu baris
    if (paymentHistories != null && paymentHistories.length > 1) {
      bytes += generator.row([
        PosColumn(
          text: 'Pembayaran',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: ':',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
      ]);
      for (final p in paymentHistories) {
        bytes += generator.row([
          PosColumn(
            text: '  ${_formatPaymentMethodLabel(p.paymentMethod)}',
            width: 6,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: 'Rp ${_formatPrice(p.amount)}',
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }
    } else {
      final label = paymentHistories != null && paymentHistories.isNotEmpty
          ? _formatPaymentMethodLabel(paymentHistories.first.paymentMethod)
          : paymentMethod;
      bytes += generator.row([
        PosColumn(
          text: 'Pembayaran',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: ': $label',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
      ]);
    }

    // Status hutang + jatuh tempo
    if (status != null && status.toLowerCase() == 'outstanding') {
      bytes += generator.row([
        PosColumn(
          text: 'Status Pembayaran',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: ': Hutang',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
      ]);
      if (dueDate != null) {
        bytes += generator.row([
          PosColumn(
            text: 'Jatuh Tempo',
            width: 6,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: ': ${_formatOutstandingDate(dueDate)}',
            width: 6,
            styles: const PosStyles(align: PosAlign.left),
          ),
        ]);
      }
    }

    bytes += generator.feed(1);

    // Detail pembelian
    bytes += generator.text('--------------------------------');
    bytes += generator.text(
      'DETAIL PEMBELIAN',
      styles: const PosStyles(bold: true),
    );
    bytes += generator.text('--------------------------------');
    bytes += generator.row([
      PosColumn(
        text: 'Item',
        width: 6,
        styles: const PosStyles(align: PosAlign.left, bold: true),
      ),
      PosColumn(
        text: 'Subtotal',
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);
    bytes += generator.text('--------------------------------');

    for (final item in items) {
      final itemName = item.product.code.isNotEmpty
          ? '${item.product.code} ${item.product.name}'
          : item.product.name;
      bytes += generator.text(
        itemName,
        styles: const PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      );
      bytes += generator.row([
        PosColumn(
          text: '${item.quantity}@ ${_formatPrice(item.product.price)}',
          width: 6,
          styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          ),
        ),
        PosColumn(
          text: 'Rp ${_formatPrice(item.subtotal)}',
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            bold: true,
          ),
        ),
      ]);
      if (items.last != item) {
        bytes += generator.text('');
      }
    }

    // Subtotal & diskon hanya ditampilkan bila ada diskon
    if (discount > 0) {
      bytes += generator.row([
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
      bytes += generator.row([
        PosColumn(
          text: 'Diskon',
          width: 8,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: '- Rp ${_formatPrice(discount)}',
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.text('================================');
    bytes += generator.row([
      PosColumn(
        text: 'TOTAL',
        width: 4,
        styles: const PosStyles(
          align: PosAlign.left,
          bold: true,
          height: PosTextSize.size1,
        ),
      ),
      PosColumn(
        text: 'Rp ${_formatPrice(total)}',
        width: 8,
        styles: const PosStyles(
          align: PosAlign.right,
          bold: true,
          height: PosTextSize.size1,
        ),
      ),
    ]);
    bytes += generator.text('================================');
    bytes += generator.feed(1);

    if (notes != null && notes.trim().isNotEmpty) {
      bytes += generator.text('CATATAN:', styles: const PosStyles(bold: true));
      bytes += generator.text(notes);
      bytes += generator.feed(1);
    }

    // Footer
    bytes += generator.text(
      'TERIMA KASIH',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
      ),
    );
    bytes += generator.text(
      'Atas kunjungan Anda',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(1);
    bytes += generator.text(
      'Barang yang sudah dibeli tidak dapat',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'ditukar kembali kecuali ada kerusakan',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'dari pihak toko',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(2);

    // Peringatan kembang api
    bytes += generator.text(
      'PERINGATAN',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      'Pengguna kembang api dimainkan mengikuti',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'aturan penggunaan yang tertera di setiap produk.',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'Setiap pembeli mengetahui dan mengerti aturan',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'untuk menjual/memakai produk kembang api ini.',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(2);

    bytes += generator.cut();
    return bytes;
  }

  /// Test print untuk cek koneksi
  Future<bool> testPrint() async {
    if (!_isConnected) {
      return false;
    }

    try {
      if (_connectionType == PrinterConnectionType.network &&
          _printer != null) {
        // Network printer test print
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
          'Network Printer berhasil terhubung!',
          styles: const PosStyles(align: PosAlign.center),
        );
        _printer!.text(
          DateTime.now().toString(),
          styles: const PosStyles(align: PosAlign.center),
        );
        _printer!.feed(2);
        _printer!.cut();
        return true;
      } else if (_connectionType == PrinterConnectionType.bluetooth &&
          _bluetoothPrinter != null) {
        // Bluetooth printer test print
        return await _bluetoothPrinter!.testPrint();
      }

      return false;
    } catch (e) {
      debugPrint('Error test printing: $e');
      return false;
    }
  }

  /// Ubah nama menjadi inisial huruf besar. "Agus Louis" -> "AL".
  String _toInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';
    return trimmed
        .split(RegExp(r'\s+'))
        .map((part) => part.isNotEmpty ? part[0].toUpperCase() : '')
        .join();
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  String _formatOutstandingDate(dynamic date) {
    try {
      DateTime dateTime;

      if (date is String) {
        dateTime = DateTime.parse(date);
      } else if (date is DateTime) {
        dateTime = date;
      } else {
        return 'Tanggal tidak valid';
      }

      final formatter = DateFormat('dd MMMM yyyy', 'id_ID');
      return formatter.format(dateTime);
    } catch (e) {
      return 'Tanggal tidak valid';
    }
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
