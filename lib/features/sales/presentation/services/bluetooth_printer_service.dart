import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

class BluetoothPrinterDevice {
  final String name;
  final String address;
  final bool isConnected;

  BluetoothPrinterDevice({
    required this.name,
    required this.address,
    required this.isConnected,
  });

  @override
  String toString() => '$name ($address)';
}

class BluetoothPrinterService {
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  bool _isConnected = false;

  /// Apakah karakteristik tulis terpilih mendukung write-without-response.
  /// Jika false, kita harus memakai write-with-response; memaksa
  /// `withoutResponse: true` pada karakteristik yang tidak mendukungnya
  /// akan dilempar exception oleh flutter_blue_plus.
  bool _writeWithoutResponse = true;

  /// MTU hasil negosiasi. Default BLE = 23 (≈20 byte usable). Tanpa
  /// menaikkan MTU, mengirim chunk besar bisa gagal/terpotong.
  int _mtu = 23;

  bool get isConnected => _isConnected;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  /// Cek dan minta permission Bluetooth
  Future<bool> checkBluetoothPermission() async {
    try {
      // Cek apakah Bluetooth tersedia
      final isSupported = await FlutterBluePlus.isSupported;
      if (!isSupported) {
        debugPrint('Bluetooth not supported on this device');
        return false;
      }

      // Request permissions
      final permissions = [
        Permission.bluetooth,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.location,
      ];

      Map<Permission, PermissionStatus> statuses = await permissions.request();

      bool allGranted = statuses.values.every(
        (status) =>
            status == PermissionStatus.granted ||
            status == PermissionStatus.limited,
      );

      if (!allGranted) {
        debugPrint('Bluetooth permissions not granted');
        return false;
      }

      // Cek apakah Bluetooth enabled
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        // Request untuk enable Bluetooth
        await FlutterBluePlus.turnOn();
      }

      return true;
    } catch (e) {
      debugPrint('Error checking Bluetooth permission: $e');
      return false;
    }
  }

  /// Mencari perangkat Bluetooth yang tersedia (bonded devices)
  Future<List<BluetoothPrinterDevice>> discoverBluetoothPrinters() async {
    final List<BluetoothPrinterDevice> devices = [];

    try {
      final hasPermission = await checkBluetoothPermission();
      if (!hasPermission) {
        throw Exception('Bluetooth permission not granted');
      }

      // Get connected/bonded devices
      final List<BluetoothDevice> bondedDevices =
          await FlutterBluePlus.bondedDevices;

      for (BluetoothDevice device in bondedDevices) {
        // Filter hanya printer (biasanya mengandung kata "printer", "POS", "thermal", dll)
        final name = device.platformName.toLowerCase();
        if (name.contains('printer') ||
            name.contains('pos') ||
            name.contains('thermal') ||
            name.contains('receipt') ||
            name.contains('tm-') || // Epson TM series
            name.contains('rp-') || // Star RP series
            name.contains('panda') || // PANDA printer series
            name.contains('prj') || // PANDA PRJ series
            name.contains('rpp') || // PANDA RPP series
            name.contains('58d')) {
          // PANDA PRJ-58D
          devices.add(
            BluetoothPrinterDevice(
              name:
                  device.platformName.isNotEmpty
                      ? device.platformName
                      : 'Unknown Device',
              address: device.remoteId.toString(),
              isConnected: false,
            ),
          );
        }
      }

      debugPrint('Found ${devices.length} potential Bluetooth printers');
    } catch (e) {
      debugPrint('Error discovering Bluetooth printers: $e');
      rethrow;
    }

    return devices;
  }

  /// Mencari SEMUA perangkat Bluetooth yang tersedia (tanpa filter)
  /// Gunakan method ini jika printer tidak terdeteksi dengan method utama
  Future<List<BluetoothPrinterDevice>> discoverAllBluetoothDevices() async {
    final List<BluetoothPrinterDevice> devices = [];

    try {
      final hasPermission = await checkBluetoothPermission();
      if (!hasPermission) {
        throw Exception('Bluetooth permission not granted');
      }

      // Get connected/bonded devices (SEMUA device, tanpa filter)
      final List<BluetoothDevice> bondedDevices =
          await FlutterBluePlus.bondedDevices;

      for (BluetoothDevice device in bondedDevices) {
        devices.add(
          BluetoothPrinterDevice(
            name:
                device.platformName.isNotEmpty
                    ? device.platformName
                    : 'Unknown Device (${device.remoteId})',
            address: device.remoteId.toString(),
            isConnected: false,
          ),
        );
      }

      debugPrint('Found ${devices.length} total Bluetooth devices');
      for (var device in devices) {
        debugPrint('Device: ${device.name} - ${device.address}');
      }
    } catch (e) {
      debugPrint('Error discovering all Bluetooth devices: $e');
      rethrow;
    }

    return devices;
  }

  /// Mulai discovery untuk mencari perangkat Bluetooth baru
  Stream<List<BluetoothPrinterDevice>> startDiscovery() async* {
    final List<BluetoothPrinterDevice> devices = [];

    try {
      final hasPermission = await checkBluetoothPermission();
      if (!hasPermission) {
        throw Exception('Bluetooth permission not granted');
      }

      // Start scanning
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

      // Listen to scan results
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          final name = result.device.platformName.toLowerCase();
          if (name.contains('printer') ||
              name.contains('pos') ||
              name.contains('thermal') ||
              name.contains('receipt') ||
              name.contains('tm-') ||
              name.contains('rp-') ||
              name.contains('panda') ||
              name.contains('prj') ||
              name.contains('rpp') ||
              name.contains('58d')) {
            final device = BluetoothPrinterDevice(
              name:
                  result.device.platformName.isNotEmpty
                      ? result.device.platformName
                      : 'Unknown Device',
              address: result.device.remoteId.toString(),
              isConnected: false,
            );

            // Avoid duplicates
            if (!devices.any((d) => d.address == device.address)) {
              devices.add(device);
            }
          }
        }
      });

      // Yield results periodically
      await Future.delayed(const Duration(seconds: 1));
      yield List.from(devices);

      await Future.delayed(const Duration(seconds: 3));
      yield List.from(devices);

      await Future.delayed(const Duration(seconds: 5));
      yield List.from(devices);
    } catch (e) {
      debugPrint('Error during Bluetooth discovery: $e');
      rethrow;
    }
  }

  /// Menghubungkan ke printer Bluetooth
  Future<bool> connectToPrinter(String address) async {
    try {
      // Disconnect existing connection
      await disconnect();

      final hasPermission = await checkBluetoothPermission();
      if (!hasPermission) {
        throw Exception('Bluetooth permission not granted');
      }

      debugPrint('Attempting to connect to Bluetooth printer: $address');

      // Find device by remote ID
      final bondedDevices = await FlutterBluePlus.bondedDevices;
      debugPrint('Available bonded devices:');
      for (var device in bondedDevices) {
        debugPrint('  ${device.platformName} - ${device.remoteId}');
      }

      final targetDevice = bondedDevices.firstWhere(
        (device) => device.remoteId.toString() == address,
        orElse: () => throw Exception('Device not found in bonded devices'),
      );

      debugPrint('Target device found: ${targetDevice.platformName}');

      // Connect to device
      debugPrint('Connecting to device...');
      await targetDevice.connect();
      debugPrint('Device connected successfully');

      // Naikkan MTU agar bisa mengirim chunk besar (Android). iOS mengatur
      // MTU otomatis & requestMtu tidak didukung — abaikan errornya.
      try {
        final negotiated = await targetDevice.requestMtu(247);
        _mtu = negotiated > 0 ? negotiated : targetDevice.mtuNow;
        debugPrint('Negotiated MTU: $_mtu');
      } catch (e) {
        _mtu = targetDevice.mtuNow;
        debugPrint('requestMtu unsupported/failed, using mtuNow=$_mtu ($e)');
      }

      // Discover services
      debugPrint('Discovering services...');
      final services = await targetDevice.discoverServices();
      debugPrint('Found ${services.length} services');

      // Find suitable characteristic for writing (usually Serial Port Profile)
      BluetoothCharacteristic? writeChar;
      for (BluetoothService service in services) {
        debugPrint('Service UUID: ${service.uuid}');
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          debugPrint('  Characteristic UUID: ${characteristic.uuid}');
          debugPrint(
            '  Properties: write=${characteristic.properties.write}, writeWithoutResponse=${characteristic.properties.writeWithoutResponse}',
          );

          if (characteristic.properties.write ||
              characteristic.properties.writeWithoutResponse) {
            // Prefer write-without-response (lebih cepat), tapi terima
            // write-with-response bila itu satu-satunya yang tersedia.
            if (writeChar == null ||
                characteristic.properties.writeWithoutResponse) {
              writeChar = characteristic;
              debugPrint('  -> Selected for writing');
            }
            if (characteristic.properties.writeWithoutResponse) break;
          }
        }
        if (writeChar != null &&
            writeChar.properties.writeWithoutResponse) {
          break;
        }
      }

      if (writeChar != null) {
        _connectedDevice = targetDevice;
        _writeCharacteristic = writeChar;
        // Pakai mode tulis sesuai kemampuan karakteristik terpilih.
        _writeWithoutResponse = writeChar.properties.writeWithoutResponse;
        _isConnected = true;
        debugPrint('Write mode: withoutResponse=$_writeWithoutResponse');

        debugPrint('Successfully connected to Bluetooth printer');
        return true;
      } else {
        await targetDevice.disconnect();
        debugPrint('No writable characteristic found');
        return false;
      }
    } catch (e) {
      debugPrint('Error connecting to Bluetooth printer: $e');
      _isConnected = false;
      _connectedDevice = null;
      _writeCharacteristic = null;
      return false;
    }
  }

  /// Memutuskan koneksi Bluetooth
  Future<void> disconnect() async {
    try {
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
        _connectedDevice = null;
      }
      _writeCharacteristic = null;
      _isConnected = false;
      debugPrint('Bluetooth printer disconnected');
    } catch (e) {
      debugPrint('Error disconnecting Bluetooth printer: $e');
    }
  }

  /// Test print untuk Bluetooth printer
  Future<bool> testPrint() async {
    if (!_isConnected || _writeCharacteristic == null) {
      debugPrint('Bluetooth printer not connected');
      return false;
    }

    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);

      List<int> bytes = [];

      // Header
      bytes += generator.text(
        'TEST PRINT',
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          bold: true,
        ),
      );
      bytes += generator.text(
        'Bluetooth Connection Test',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        '${DateTime.now()}',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );

      bytes += generator.hr();
      bytes += generator.text(
        'Printer: ${_connectedDevice?.platformName ?? 'Unknown'}',
      );
      bytes += generator.text(
        'Address: ${_connectedDevice?.remoteId.toString() ?? 'Unknown'}',
      );
      bytes += generator.hr();

      bytes += generator.text(
        'Test berhasil!',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );

      bytes += generator.feed(2);
      bytes += generator.cut();

      // Send to printer via characteristic (chunked, mode sesuai kemampuan)
      await printRawData(bytes);

      debugPrint('Bluetooth test print sent successfully');
      return true;
    } catch (e) {
      debugPrint('Error during Bluetooth test print: $e');
      return false;
    }
  }

  /// Mencetak data raw ke Bluetooth printer
  Future<bool> printRawData(List<int> data) async {
    if (!_isConnected || _writeCharacteristic == null) {
      debugPrint('Bluetooth printer not connected');
      return false;
    }

    try {
      // Ukuran chunk dari MTU hasil negosiasi (3 byte untuk ATT header).
      // Clamp ke minimal 20 byte (worst-case default BLE).
      final chunkSize = (_mtu - 3).clamp(20, 512);
      for (int i = 0; i < data.length; i += chunkSize) {
        final end = (i + chunkSize < data.length) ? i + chunkSize : data.length;
        final chunk = data.sublist(i, end);
        await _writeCharacteristic!.write(
          chunk,
          withoutResponse: _writeWithoutResponse,
        );

        // Jeda kecil hanya perlu pada write-without-response (tanpa ack)
        // agar buffer printer tidak overflow.
        if (_writeWithoutResponse) {
          await Future.delayed(const Duration(milliseconds: 20));
        }
      }

      debugPrint('Bluetooth print data sent successfully');
      return true;
    } catch (e) {
      debugPrint('Error printing to Bluetooth printer: $e');
      return false;
    }
  }

  /// Debug method untuk troubleshooting - tampilkan semua device bluetooth
  Future<void> debugBluetoothDevices() async {
    try {
      final hasPermission = await checkBluetoothPermission();
      if (!hasPermission) {
        debugPrint('❌ Bluetooth permission not granted');
        return;
      }

      debugPrint('🔍 === BLUETOOTH DEVICE DEBUG INFO ===');

      // Adapter state
      final adapterState = await FlutterBluePlus.adapterState.first;
      debugPrint('📶 Bluetooth Adapter State: $adapterState');

      // Bonded/Paired devices
      final bondedDevices = await FlutterBluePlus.bondedDevices;
      debugPrint('🔗 Found ${bondedDevices.length} bonded/paired devices:');

      for (int i = 0; i < bondedDevices.length; i++) {
        final device = bondedDevices[i];
        debugPrint('  ${i + 1}. Name: "${device.platformName}"');
        debugPrint('     Address: ${device.remoteId}');

        // Check if it matches PANDA patterns
        final name = device.platformName.toLowerCase();
        final isPandaLike =
            name.contains('panda') ||
            name.contains('prj') ||
            name.contains('rpp') ||
            name.contains('58d');
        if (isPandaLike) {
          debugPrint('     ✅ MATCHES PANDA PATTERN!');
        }
        debugPrint('');
      }

      debugPrint('📋 Tip: Jika printer PANDA PRJ-58D Anda tidak muncul:');
      debugPrint(
        '   1. Pastikan printer sudah di-pair di pengaturan Bluetooth Android',
      );
      debugPrint('   2. Pastikan printer dalam mode pairing');
      debugPrint('   3. Coba gunakan method discoverAllBluetoothDevices()');
      debugPrint('═══════════════════════════════════════');
    } catch (e) {
      debugPrint('❌ Error during debug: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    disconnect();
  }
}
