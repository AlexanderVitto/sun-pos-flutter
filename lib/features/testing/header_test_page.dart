import 'package:flutter/material.dart';
import '../../core/network/auth_http_client.dart';
import '../../core/utils/app_info_helper.dart';
import 'dart:convert';

class HeaderTestPage extends StatefulWidget {
  const HeaderTestPage({super.key});

  @override
  State<HeaderTestPage> createState() => _HeaderTestPageState();
}

class _HeaderTestPageState extends State<HeaderTestPage> {
  String _testResult = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HTTP Headers Test'),
        backgroundColor: const Color(0xFF6366f1),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'App Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('App Name', AppInfoHelper.appName),
                    _buildInfoRow('App Version', AppInfoHelper.appVersion),
                    _buildInfoRow('Build Number', AppInfoHelper.buildNumber),
                    _buildInfoRow('Package Name', AppInfoHelper.packageName),
                    _buildInfoRow('Device ID', AppInfoHelper.deviceId),
                    _buildInfoRow('Platform', AppInfoHelper.platform),
                    _buildInfoRow('OS Info', AppInfoHelper.osInfo),
                    _buildInfoRow('Device Name', AppInfoHelper.deviceName),
                    const Divider(),
                    const Text(
                      'Generated Headers:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('User-Agent', AppInfoHelper.userAgent),
                    _buildInfoRow('X-Device-Id', AppInfoHelper.deviceId),
                    _buildInfoRow('X-Platform', AppInfoHelper.platform),
                    _buildInfoRow('X-App-Version', AppInfoHelper.fullVersion),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _testHeaders,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366f1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Testing Headers...'),
                          ],
                        )
                        : const Text('Test HTTP Headers'),
              ),
            ),

            const SizedBox(height: 16),

            // Test Result
            if (_testResult.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Test Result',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SelectableText(
                        _testResult,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

  Future<void> _testHeaders() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
    });

    try {
      final httpClient = AuthHttpClient();

      // Test dengan httpbin.org untuk melihat headers yang dikirim
      final response = await httpClient.get(
        'https://httpbin.org/headers',
        requireAuth: false,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _testResult = const JsonEncoder.withIndent('  ').convert(data);
        });
      } else {
        setState(() {
          _testResult = 'Error: ${response.statusCode}\n${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _testResult = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
