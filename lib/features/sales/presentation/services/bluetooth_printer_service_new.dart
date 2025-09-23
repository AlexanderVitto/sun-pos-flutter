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
            name.contains('rp-')) {
          // Star RP series
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
              name.contains('rp-')) {
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
      final targetDevice = bondedDevices.firstWhere(
        (device) => device.remoteId.toString() == address,
        orElse: () => throw Exception('Device not found in bonded devices'),
      );

      // Connect to device
      await targetDevice.connect();

      // Discover services
      final services = await targetDevice.discoverServices();

      // Find suitable characteristic for writing (usually Serial Port Profile)
      BluetoothCharacteristic? writeChar;
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.properties.write) {
            writeChar = characteristic;
            break;
          }
        }
        if (writeChar != null) break;
      }

      if (writeChar != null) {
        _connectedDevice = targetDevice;
        _writeCharacteristic = writeChar;
        _isConnected = true;

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

      // Send to printer via characteristic
      await _writeCharacteristic!.write(bytes, withoutResponse: true);

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
      // Split data into chunks if too large (BLE has MTU limits)
      const chunkSize = 185; // Safe chunk size for most BLE implementations
      for (int i = 0; i < data.length; i += chunkSize) {
        final end = (i + chunkSize < data.length) ? i + chunkSize : data.length;
        final chunk = data.sublist(i, end);
        await _writeCharacteristic!.write(chunk, withoutResponse: true);

        // Small delay between chunks
        await Future.delayed(const Duration(milliseconds: 50));
      }

      debugPrint('Bluetooth print data sent successfully');
      return true;
    } catch (e) {
      debugPrint('Error printing to Bluetooth printer: $e');
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    disconnect();
  }
}
