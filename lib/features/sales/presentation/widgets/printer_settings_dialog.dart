import 'package:flutter/material.dart';
import '../services/thermal_printer_service.dart';
import '../services/bluetooth_printer_service.dart';
import '../services/printer_preferences_service.dart';

class PrinterSettingsDialog extends StatefulWidget {
  const PrinterSettingsDialog({super.key});

  @override
  State<PrinterSettingsDialog> createState() => _PrinterSettingsDialogState();
}

class _PrinterSettingsDialogState extends State<PrinterSettingsDialog>
    with TickerProviderStateMixin {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController(
    text: '9100',
  );
  final ThermalPrinterService _printerService = ThermalPrinterService();

  // Network printer state
  bool _isConnecting = false;
  bool _isDiscovering = false;
  List<String> _discoveredPrinters = [];

  // Bluetooth printer state
  bool _isBluetoothConnecting = false;
  bool _isBluetoothDiscovering = false;
  List<BluetoothPrinterDevice> _discoveredBluetoothPrinters = [];

  // Saved printer state
  bool _autoConnect = true;
  bool _hasSavedPrinter = false;
  String _savedPrinterInfo = '';
  bool _isAutoReconnecting = false;

  // Tab controller
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load saved settings and check for saved printer
    _loadSavedSettings();
    _checkSavedPrinter();
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedSettings() async {
    try {
      final autoConnect =
          await PrinterPreferencesService.instance.getAutoConnect();
      setState(() {
        _autoConnect = autoConnect;
      });
    } catch (e) {
      debugPrint('Error loading auto-connect setting: $e');
    }
  }

  Future<void> _checkSavedPrinter() async {
    try {
      final hasSaved = await _printerService.hasSavedPrinter();
      if (hasSaved) {
        final savedPrinter =
            await PrinterPreferencesService.instance.getLastConnectedPrinter();
        setState(() {
          _hasSavedPrinter = hasSaved;
          _savedPrinterInfo = savedPrinter?.displayName ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error checking saved printer: $e');
    }
  }

  Future<void> _attemptAutoReconnect() async {
    setState(() {
      _isAutoReconnecting = true;
    });

    try {
      final success = await _printerService.autoReconnectToLastPrinter();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil terhubung ke printer tersimpan!'),
            backgroundColor: Colors.green,
          ),
        );

        // Close dialog and return printer service
        Navigator.of(context).pop(_printerService);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal terhubung ke printer tersimpan'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error reconnecting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isAutoReconnecting = false;
      });
    }
  }

  Future<void> _discoverPrinters() async {
    setState(() {
      _isDiscovering = true;
      _discoveredPrinters.clear();
    });

    try {
      final printers = await _printerService.discoverPrinters();
      setState(() {
        _discoveredPrinters = printers;
      });

      if (_discoveredPrinters.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak ada printer ditemukan di jaringan'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error mencari printer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isDiscovering = false;
      });
    }
  }

  Future<void> _connectToPrinter() async {
    if (_ipController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan IP address printer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    try {
      final port = int.tryParse(_portController.text) ?? 9100;
      final success = await _printerService.connectToPrinter(
        _ipController.text,
        port: port,
      );

      if (success) {
        // Test print
        final testSuccess = await _printerService.testPrint();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                testSuccess
                    ? 'Printer terhubung dan test print berhasil!'
                    : 'Printer terhubung tapi test print gagal',
              ),
              backgroundColor: testSuccess ? Colors.green : Colors.orange,
            ),
          );
        }

        // TODO: Save settings to shared preferences

        if (mounted) {
          Navigator.of(context).pop(_printerService);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal terhubung ke printer'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  Future<void> _discoverBluetoothPrinters() async {
    setState(() {
      _isBluetoothDiscovering = true;
      _discoveredBluetoothPrinters.clear();
    });

    try {
      final printers =
          await _printerService.bluetoothPrinter.discoverBluetoothPrinters();
      setState(() {
        _discoveredBluetoothPrinters = printers;
      });

      if (_discoveredBluetoothPrinters.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Tidak ada printer Bluetooth ditemukan.\nPastikan printer sudah dipasangkan dan mendukung ESC/POS',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error mencari printer Bluetooth: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isBluetoothDiscovering = false;
      });
    }
  }

  // Method untuk melihat SEMUA perangkat bluetooth
  Future<void> _discoverAllBluetoothDevices() async {
    setState(() {
      _isBluetoothDiscovering = true;
      _discoveredBluetoothPrinters.clear();
    });

    try {
      final printers =
          await _printerService.bluetoothPrinter.discoverAllBluetoothDevices();

      setState(() {
        _discoveredBluetoothPrinters = printers;
      });

      if (_discoveredBluetoothPrinters.isEmpty) {
        if (!mounted) return;

        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Informasi'),
                content: const Text(
                  'Tidak ada perangkat Bluetooth ditemukan.\nPastikan Bluetooth aktif dan perangkat sudah di-pair',
                ),
              ),
        );
      } else {
        if (!mounted) return;

        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text(
                  'Ditemukan ${_discoveredBluetoothPrinters.length} perangkat',
                ),
                content: const Text(
                  'Semua perangkat Bluetooth yang ter-pair ditampilkan di bawah.\n'
                  'Pilih yang sesuai dengan printer PANDA PRJ-58D Anda.',
                ),
              ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Error'),
              content: Text('Error mencari semua perangkat Bluetooth: $e'),
            ),
      );
    } finally {
      setState(() {
        _isBluetoothDiscovering = false;
      });
    }
  }

  Future<void> _connectToBluetoothPrinter(String address) async {
    setState(() {
      _isBluetoothConnecting = true;
    });

    try {
      // Find device name if available
      String? deviceName;
      for (final device in _discoveredBluetoothPrinters) {
        if (device.address == address) {
          deviceName = device.name;
          break;
        }
      }

      final success = await _printerService.connectToBluetoothPrinter(
        address,
        deviceName: deviceName,
      );

      if (success) {
        // Test print
        final testSuccess = await _printerService.testPrint();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                testSuccess
                    ? 'Printer Bluetooth terhubung dan test print berhasil!'
                    : 'Printer Bluetooth terhubung tapi test print gagal',
              ),
              backgroundColor: testSuccess ? Colors.green : Colors.orange,
            ),
          );
        }

        if (mounted) {
          Navigator.of(context).pop(_printerService);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal terhubung ke printer Bluetooth'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isBluetoothConnecting = false;
      });
    }
  }

  Widget _buildSavedPrinterSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: Colors.green[50],
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.bookmark, color: Colors.green[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Printer Tersimpan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _savedPrinterInfo,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Auto-reconnect switch
                  Expanded(
                    child: Row(
                      children: [
                        Switch(
                          value: _autoConnect,
                          onChanged: (value) async {
                            setState(() {
                              _autoConnect = value;
                            });
                            await PrinterPreferencesService.instance
                                .setAutoConnect(value);
                          },
                          activeColor: Colors.green[600],
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Auto-connect saat buka aplikasi',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Connect now button
                  ElevatedButton.icon(
                    onPressed:
                        _isAutoReconnecting ? null : _attemptAutoReconnect,
                    icon:
                        _isAutoReconnecting
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.link, size: 16),
                    label: Text(
                      _isAutoReconnecting ? 'Connecting...' : 'Connect',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Clear saved printer button
                  IconButton(
                    onPressed: () async {
                      await _printerService.clearSavedPrinter();
                      setState(() {
                        _hasSavedPrinter = false;
                        _savedPrinterInfo = '';
                      });

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Printer tersimpan telah dihapus'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Hapus printer tersimpan',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.print, color: Colors.blue[600], size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Pengaturan Printer',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.wifi), text: 'Network'),
                  Tab(icon: Icon(Icons.bluetooth), text: 'Bluetooth'),
                ],
                indicator: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[600],
                indicatorSize: TabBarIndicatorSize.tab,
              ),
            ),
            const SizedBox(height: 16),

            // Saved Printer Section
            if (_hasSavedPrinter) _buildSavedPrinterSection(),

            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildNetworkPrinterTab(),
                  _buildBluetoothPrinterTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkPrinterTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Discovery section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Cari Printer Otomatis',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _isDiscovering ? null : _discoverPrinters,
                        icon:
                            _isDiscovering
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.search, size: 20),
                        label: Text(_isDiscovering ? 'Mencari...' : 'Cari'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  if (_discoveredPrinters.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Printer yang ditemukan:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    for (final ip in _discoveredPrinters)
                      Card(
                        color: Colors.blue[50],
                        child: ListTile(
                          leading: const Icon(Icons.print, color: Colors.blue),
                          title: Text(ip),
                          subtitle: const Text('Thermal Printer'),
                          trailing: TextButton(
                            onPressed: () {
                              _ipController.text = ip;
                            },
                            child: const Text('Pilih'),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Manual connection section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Koneksi Manual',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // IP Address input
                  TextField(
                    controller: _ipController,
                    decoration: const InputDecoration(
                      labelText: 'IP Address Printer',
                      hintText: 'Contoh: 192.168.1.100',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.network_check),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Port input
                  TextField(
                    controller: _portController,
                    decoration: const InputDecoration(
                      labelText: 'Port',
                      hintText: '9100',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.settings_ethernet),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Info card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tips:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[700],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '• Pastikan printer dan device terhubung ke WiFi yang sama\n'
                                '• Cek IP address printer di pengaturan printer\n'
                                '• Port default ESC/POS adalah 9100',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.amber[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isConnecting ? null : _connectToPrinter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                  ),
                  child:
                      _isConnecting
                          ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Menghubungkan...'),
                            ],
                          )
                          : const Text('Hubungkan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBluetoothPrinterTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Discovery section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Cari Printer Bluetooth',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // ElevatedButton.icon(
                      //   onPressed:
                      //       _isBluetoothDiscovering
                      //           ? null
                      //           : _debugBluetoothDevices,
                      //   icon: const Icon(Icons.bug_report, size: 16),
                      //   label: const Text('Debug'),
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.orange[600],
                      //     foregroundColor: Colors.white,
                      //   ),
                      // ),
                      // const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed:
                            _isBluetoothDiscovering
                                ? null
                                : _discoverAllBluetoothDevices,
                        icon: const Icon(Icons.list, size: 16),
                        label: const Text('Semua'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed:
                            _isBluetoothDiscovering
                                ? null
                                : _discoverBluetoothPrinters,
                        icon:
                            _isBluetoothDiscovering
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(
                                  Icons.bluetooth_searching,
                                  size: 20,
                                ),
                        label: Text(
                          _isBluetoothDiscovering ? 'Mencari...' : 'Cari',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  if (_discoveredBluetoothPrinters.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Printer Bluetooth yang ditemukan:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    for (final printer in _discoveredBluetoothPrinters)
                      Card(
                        color: Colors.blue[50],
                        child: ListTile(
                          leading: const Icon(
                            Icons.bluetooth,
                            color: Colors.blue,
                          ),
                          title: Text(printer.name),
                          subtitle: ElevatedButton(
                            onPressed:
                                _isBluetoothConnecting
                                    ? null
                                    : () => _connectToBluetoothPrinter(
                                      printer.address,
                                    ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                            ),
                            child:
                                _isBluetoothConnecting
                                    ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : const Text('Hubungkan'),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Info card untuk Bluetooth
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Tips Bluetooth Printer',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• Pastikan Bluetooth device sudah diaktifkan\n'
                  '• Printer harus sudah dipasangkan (paired) terlebih dahulu\n'
                  '• Pastikan printer mendukung protokol ESC/POS\n'
                  '• Jarak printer maksimal 10 meter dari device\n'
                  '• PANDA PRJ-58D: Gunakan "Debug" jika tidak terdeteksi\n'
                  '• PANDA PRJ-58D: Coba "Semua" untuk melihat semua perangkat',
                  style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Manual pairing instructions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cara Pairing Printer Bluetooth',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '1. Buka Settings → Bluetooth di device Anda\n'
                    '2. Pastikan printer dalam mode pairing\n'
                    '3. Cari dan pilih printer di daftar device\n'
                    '4. Masukkan PIN jika diminta (biasanya: 0000 atau 1234)\n'
                    '5. Kembali ke aplikasi dan cari printer',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      // Show message to open Bluetooth settings manually
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Silakan buka Settings → Bluetooth untuk pairing printer',
                            ),
                            backgroundColor: Colors.blue,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.settings_bluetooth),
                    label: const Text('Panduan Pairing'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
