import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/cart_item.dart';
import '../../../transactions/data/models/store.dart';
import '../../../transactions/data/models/user.dart';
import '../../../transactions/data/models/payment_history.dart';
import '../../../customers/data/models/payment_receipt_item.dart';
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

  /// Pastikan terhubung ke printer yang tersimpan, dengan retry.
  ///
  /// Inti pola "koneksi sesaat" untuk printer BERBAGI: connect tepat sebelum
  /// mencetak bila belum terhubung. Retry menangani kasus printer sedang
  /// dipakai kasir lain (BLE hanya melayani satu koneksi pada satu waktu).
  Future<bool> ensureConnectedToSavedPrinter({int retries = 3}) async {
    if (_isConnected) return true;

    final saved = await PrinterPreferencesService.instance
        .getLastConnectedPrinter();
    if (saved == null) {
      debugPrint('ensureConnected: tidak ada printer tersimpan');
      return false;
    }

    for (var attempt = 1; attempt <= retries; attempt++) {
      bool ok = false;
      if (saved.type == SavedPrinterType.network && saved.ipAddress != null) {
        ok = await connectToPrinter(saved.ipAddress!, port: saved.port ?? 9100);
      } else if (saved.type == SavedPrinterType.bluetooth &&
          saved.bluetoothAddress != null) {
        ok = await connectToBluetoothPrinter(
          saved.bluetoothAddress!,
          deviceName: saved.bluetoothName,
        );
      }
      if (ok) return true;

      // Gagal — printer mungkin sedang dipakai kasir lain. Tunggu lalu ulang.
      if (attempt < retries) {
        debugPrint('ensureConnected: gagal (percobaan $attempt), retry...');
        await Future.delayed(Duration(milliseconds: 700 * attempt));
      }
    }
    return false;
  }

  /// Lepas koneksi Bluetooth setelah mencetak agar kasir lain bisa memakai
  /// printer yang sama. Network printer TIDAK dilepas (mendukung multi-koneksi).
  Future<void> _releaseBluetoothAfterPrint() async {
    if (_connectionType == PrinterConnectionType.bluetooth) {
      // Jeda agar data ter-flush ke printer sebelum link diputus.
      await Future.delayed(const Duration(milliseconds: 1000));
      disconnect();
      debugPrint('Bluetooth printer dilepas setelah cetak (mode berbagi)');
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
    // Pola koneksi sesaat: connect ke printer tersimpan tepat sebelum cetak.
    if (!_isConnected) {
      final ok = await ensureConnectedToSavedPrinter();
      if (!ok) {
        debugPrint('Printer not connected and auto-connect failed');
        return false;
      }
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
    } finally {
      // Lepas printer Bluetooth agar bisa dipakai kasir lain bergantian.
      await _releaseBluetoothAfterPrint();
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

  /// Mencetak struk pembayaran hutang pelanggan.
  Future<bool> printPaymentReceipt({
    required String customerName,
    String? customerPhone,
    required String paymentMethod,
    required List<PaymentReceiptItem> paidTransactions,
    required double totalPaid,
    required double changeAmount,
    required DateTime paymentDate,
    String? notes,
  }) async {
    if (!_isConnected) {
      debugPrint('Printer not connected');
      return false;
    }

    try {
      final bytes = await _buildPaymentReceiptBytes(
        customerName: customerName,
        customerPhone: customerPhone,
        paymentMethod: paymentMethod,
        paidTransactions: paidTransactions,
        totalPaid: totalPaid,
        changeAmount: changeAmount,
        paymentDate: paymentDate,
        notes: notes,
      );

      if (_connectionType == PrinterConnectionType.network &&
          _printer != null) {
        _printer!.rawBytes(bytes);
        debugPrint('Payment receipt printed successfully (network)');
        return true;
      } else if (_connectionType == PrinterConnectionType.bluetooth &&
          _bluetoothPrinter != null) {
        return await _bluetoothPrinter!.printRawData(bytes);
      }

      return false;
    } catch (e) {
      debugPrint('Error printing payment receipt: $e');
      return false;
    }
  }

  /// Membangun byte ESC/POS struk pembayaran hutang. Dipakai bersama oleh
  /// network & bluetooth agar isi struk selalu identik di kedua jalur.
  Future<List<int>> _buildPaymentReceiptBytes({
    required String customerName,
    String? customerPhone,
    required String paymentMethod,
    required List<PaymentReceiptItem> paidTransactions,
    required double totalPaid,
    required double changeAmount,
    required DateTime paymentDate,
    String? notes,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    bytes += generator.text('================================');
    bytes += generator.text(
      'STRUK PEMBAYARAN HUTANG',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text('================================');
    bytes += generator.feed(1);

    // Info pelanggan & pembayaran
    bytes += generator.row([
      PosColumn(
        text: 'Customer',
        width: 5,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: ': $customerName',
        width: 7,
        styles: const PosStyles(align: PosAlign.left),
      ),
    ]);
    if (customerPhone != null && customerPhone.trim().isNotEmpty) {
      bytes += generator.row([
        PosColumn(
          text: 'Telepon',
          width: 5,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: ': $customerPhone',
          width: 7,
          styles: const PosStyles(align: PosAlign.left),
        ),
      ]);
    }
    bytes += generator.row([
      PosColumn(
        text: 'Tanggal',
        width: 5,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: ': ${_formatDateTime(paymentDate)}',
        width: 7,
        styles: const PosStyles(align: PosAlign.left),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Metode',
        width: 5,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: ': ${_formatPaymentMethodLabel(paymentMethod)}',
        width: 7,
        styles: const PosStyles(align: PosAlign.left),
      ),
    ]);
    bytes += generator.feed(1);

    // Daftar transaksi yang dibayar
    bytes += generator.text('--------------------------------');
    bytes += generator.text(
      'TRANSAKSI YANG DIBAYAR',
      styles: const PosStyles(bold: true),
    );
    bytes += generator.text('--------------------------------');

    for (var i = 0; i < paidTransactions.length; i++) {
      final item = paidTransactions[i];
      bytes += generator.text(
        '${i + 1}. ${item.receiptNumber}',
        styles: const PosStyles(bold: true),
      );
      bytes += generator.text(
        _formatDateTime(item.transactionDate),
        styles: const PosStyles(align: PosAlign.left),
      );

      // Detail item bila tersedia
      final details = item.transactionDetails;
      if (details != null && details.isNotEmpty) {
        for (final detail in details) {
          bytes += generator.text(
            detail.productName,
            styles: const PosStyles(align: PosAlign.left),
          );
          bytes += generator.row([
            PosColumn(
              text:
                  '  ${detail.quantity}@ ${_formatPrice(detail.unitPrice)}',
              width: 6,
              styles: const PosStyles(align: PosAlign.left),
            ),
            PosColumn(
              text: 'Rp ${_formatPrice(detail.totalAmount)}',
              width: 6,
              styles: const PosStyles(align: PosAlign.right),
            ),
          ]);
        }
      }

      bytes += generator.row([
        PosColumn(
          text: 'Total Transaksi',
          width: 7,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: 'Rp ${_formatPrice(item.originalAmount)}',
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(
          text: 'Hutang Sebelumnya',
          width: 7,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: 'Rp ${_formatPrice(item.previousOutstanding)}',
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(
          text: 'Dibayar',
          width: 7,
          styles: const PosStyles(align: PosAlign.left, bold: true),
        ),
        PosColumn(
          text: 'Rp ${_formatPrice(item.paymentAmount)}',
          width: 5,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);
      bytes += generator.row([
        PosColumn(
          text: 'Sisa Hutang',
          width: 7,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: 'Rp ${_formatPrice(item.remainingOutstanding)}',
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(
          text: 'Status',
          width: 7,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: item.isFullyPaid ? 'LUNAS' : 'SEBAGIAN',
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      if (i != paidTransactions.length - 1) {
        bytes += generator.text('--------------------------------');
      }
    }

    bytes += generator.text('================================');
    bytes += generator.row([
      PosColumn(
        text: 'TOTAL DIBAYAR',
        width: 6,
        styles: const PosStyles(align: PosAlign.left, bold: true),
      ),
      PosColumn(
        text: 'Rp ${_formatPrice(totalPaid)}',
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);
    if (changeAmount > 0) {
      bytes += generator.row([
        PosColumn(
          text: 'Kembalian',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: 'Rp ${_formatPrice(changeAmount)}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }
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
      'Atas pembayaran Anda',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }

  /// Test print untuk cek koneksi
  Future<bool> testPrint() async {
    // Pola koneksi sesaat: connect ke printer tersimpan bila belum terhubung.
    if (!_isConnected) {
      final ok = await ensureConnectedToSavedPrinter();
      if (!ok) return false;
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
    } finally {
      await _releaseBluetoothAfterPrint();
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
