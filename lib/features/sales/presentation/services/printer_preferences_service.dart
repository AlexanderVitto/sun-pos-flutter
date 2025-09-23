import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

enum SavedPrinterType { network, bluetooth }

class SavedPrinterInfo {
  final SavedPrinterType type;
  final String? ipAddress;
  final int? port;
  final String? bluetoothAddress;
  final String? bluetoothName;
  final DateTime lastConnected;

  SavedPrinterInfo({
    required this.type,
    this.ipAddress,
    this.port,
    this.bluetoothAddress,
    this.bluetoothName,
    required this.lastConnected,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'ipAddress': ipAddress,
      'port': port,
      'bluetoothAddress': bluetoothAddress,
      'bluetoothName': bluetoothName,
      'lastConnected': lastConnected.millisecondsSinceEpoch,
    };
  }

  factory SavedPrinterInfo.fromJson(Map<String, dynamic> json) {
    return SavedPrinterInfo(
      type: SavedPrinterType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      ipAddress: json['ipAddress'],
      port: json['port'],
      bluetoothAddress: json['bluetoothAddress'],
      bluetoothName: json['bluetoothName'],
      lastConnected: DateTime.fromMillisecondsSinceEpoch(json['lastConnected']),
    );
  }

  String get displayName {
    if (type == SavedPrinterType.network) {
      return 'Network: $ipAddress:$port';
    } else {
      return 'Bluetooth: ${bluetoothName ?? bluetoothAddress}';
    }
  }
}

class PrinterPreferencesService {
  static const String _keyLastPrinter = 'last_printer';
  static const String _keyAutoConnect = 'auto_connect_printer';

  static PrinterPreferencesService? _instance;
  static PrinterPreferencesService get instance {
    _instance ??= PrinterPreferencesService._();
    return _instance!;
  }

  PrinterPreferencesService._();

  /// Simpan informasi printer yang berhasil terkoneksi
  Future<void> saveLastConnectedPrinter({
    required SavedPrinterType type,
    String? ipAddress,
    int? port,
    String? bluetoothAddress,
    String? bluetoothName,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final printerInfo = SavedPrinterInfo(
        type: type,
        ipAddress: ipAddress,
        port: port,
        bluetoothAddress: bluetoothAddress,
        bluetoothName: bluetoothName,
        lastConnected: DateTime.now(),
      );

      final jsonString = printerInfo.toJson().toString();
      await prefs.setString(_keyLastPrinter, jsonString);

      debugPrint('Printer preferences saved: ${printerInfo.displayName}');
    } catch (e) {
      debugPrint('Error saving printer preferences: $e');
    }
  }

  /// Ambil informasi printer terakhir yang tersimpan
  Future<SavedPrinterInfo?> getLastConnectedPrinter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyLastPrinter);

      if (jsonString != null && jsonString.isNotEmpty) {
        // Parse JSON string manually since we saved it as toString()
        final Map<String, dynamic> jsonMap = _parseJsonString(jsonString);
        return SavedPrinterInfo.fromJson(jsonMap);
      }
    } catch (e) {
      debugPrint('Error loading printer preferences: $e');
    }
    return null;
  }

  /// Simpan pengaturan auto-connect
  Future<void> setAutoConnect(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyAutoConnect, enabled);
      debugPrint('Auto-connect setting saved: $enabled');
    } catch (e) {
      debugPrint('Error saving auto-connect setting: $e');
    }
  }

  /// Ambil pengaturan auto-connect
  Future<bool> getAutoConnect() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyAutoConnect) ?? true; // Default: enabled
    } catch (e) {
      debugPrint('Error loading auto-connect setting: $e');
      return true; // Default: enabled
    }
  }

  /// Hapus semua preferensi printer tersimpan
  Future<void> clearSavedPrinter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyLastPrinter);
      debugPrint('Printer preferences cleared');
    } catch (e) {
      debugPrint('Error clearing printer preferences: $e');
    }
  }

  /// Check apakah ada printer tersimpan
  Future<bool> hasSavedPrinter() async {
    final savedPrinter = await getLastConnectedPrinter();
    return savedPrinter != null;
  }

  /// Parse JSON string manually (simple implementation)
  Map<String, dynamic> _parseJsonString(String jsonString) {
    // Remove curly braces
    String content = jsonString.substring(1, jsonString.length - 1);

    Map<String, dynamic> result = {};

    // Split by commas
    List<String> pairs = content.split(', ');

    for (String pair in pairs) {
      List<String> keyValue = pair.split(': ');
      if (keyValue.length == 2) {
        String key = keyValue[0].trim();
        String value = keyValue[1].trim();

        // Remove quotes from key
        if (key.startsWith("'") && key.endsWith("'")) {
          key = key.substring(1, key.length - 1);
        }

        // Parse value based on type
        if (value == 'null') {
          result[key] = null;
        } else if (value.startsWith("'") && value.endsWith("'")) {
          // String value
          result[key] = value.substring(1, value.length - 1);
        } else {
          // Try to parse as number
          if (RegExp(r'^\d+$').hasMatch(value)) {
            result[key] = int.parse(value);
          } else {
            result[key] = value;
          }
        }
      }
    }

    return result;
  }
}
