import 'package:flutter/material.dart';
import '../../core/utils/device_info_helper.dart';

class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({super.key});

  @override
  State<DeviceInfoPage> createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  Map<String, dynamic>? _deviceInfo;
  String? _deviceIdentifier;
  String? _deviceDisplayName;
  String? _osVersion;
  bool? _isPhysicalDevice;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    setState(() => _isLoading = true);

    try {
      final deviceInfo = await DeviceInfoHelper.getDeviceInfo();
      final deviceIdentifier = await DeviceInfoHelper.getDeviceIdentifier();
      final deviceDisplayName = await DeviceInfoHelper.getDeviceDisplayName();
      final osVersion = await DeviceInfoHelper.getOSVersion();
      final isPhysicalDevice = await DeviceInfoHelper.isPhysicalDevice();

      setState(() {
        _deviceInfo = deviceInfo;
        _deviceIdentifier = deviceIdentifier;
        _deviceDisplayName = deviceDisplayName;
        _osVersion = osVersion;
        _isPhysicalDevice = isPhysicalDevice;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading device info: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Information'),
        backgroundColor: const Color(0xFF6366f1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDeviceInfo,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Device Summary',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              'Device Name',
                              _deviceDisplayName ?? 'Unknown',
                            ),
                            _buildInfoRow(
                              'OS Version',
                              _osVersion ?? 'Unknown',
                            ),
                            _buildInfoRow(
                              'Physical Device',
                              _isPhysicalDevice?.toString() ?? 'Unknown',
                            ),
                            _buildInfoRow(
                              'Device ID',
                              _deviceIdentifier ?? 'Unknown',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Detailed Information
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Detailed Information',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_deviceInfo != null)
                              ..._deviceInfo!.entries.map((entry) {
                                return _buildInfoRow(
                                  _formatKey(entry.key),
                                  _formatValue(entry.value),
                                );
                              }).toList()
                            else
                              const Text('No device information available'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    return key
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatValue(dynamic value) {
    if (value is Map) {
      return value.entries
          .map((e) => '${_formatKey(e.key)}: ${_formatValue(e.value)}')
          .join('\n');
    } else if (value is List) {
      return value.join(', ');
    } else {
      return value.toString();
    }
  }
}
