import 'package:flutter/material.dart';
import '../../core/network/auth_http_client.dart';

class SSLTestPage extends StatefulWidget {
  const SSLTestPage({super.key});

  @override
  State<SSLTestPage> createState() => _SSLTestPageState();
}

class _SSLTestPageState extends State<SSLTestPage> {
  String _testResult = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SSL Certificate Test'),
        backgroundColor: const Color(0xFF6366f1),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SSL Certificate Test',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This test will attempt to connect to the sfxsys.com API to verify that the SSL certificate issue has been resolved.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _testSSLConnection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366f1),
                          foregroundColor: Colors.white,
                        ),
                        child:
                            _isLoading
                                ? const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Testing Connection...'),
                                  ],
                                )
                                : const Text('Test SSL Connection'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Test Results
            if (_testResult.isNotEmpty) ...[
              const Text(
                'Test Results:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: SelectableText(
                      _testResult,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _testSSLConnection() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
    });

    try {
      final httpClient = AuthHttpClient();

      // Test 1: Basic connection to the API base URL
      setState(() {
        _testResult +=
            'Test 1: Testing basic connection to sfxsys.com API...\n';
      });

      try {
        final response = await httpClient.get(
          'https://sfxsys.com/api/v1',
          requireAuth: false,
        );

        setState(() {
          _testResult += '✅ SUCCESS: Basic connection established\n';
          _testResult += '   Status Code: ${response.statusCode}\n';
          _testResult +=
              '   Response Length: ${response.body.length} characters\n\n';
        });
      } catch (e) {
        setState(() {
          _testResult += '❌ FAILED: Basic connection failed\n';
          _testResult += '   Error: $e\n\n';
        });
      }

      // Test 2: Test profile endpoint (this will likely fail due to auth, but should not fail due to SSL)
      setState(() {
        _testResult +=
            'Test 2: Testing profile endpoint (expecting 401, but not SSL errors)...\n';
      });

      try {
        final response = await httpClient.get(
          'https://sfxsys.com/api/v1/auth/profile',
          requireAuth: false, // Don't send auth token
        );

        setState(() {
          _testResult += '✅ SUCCESS: Profile endpoint reachable\n';
          _testResult += '   Status Code: ${response.statusCode}\n';
          if (response.statusCode == 401) {
            _testResult +=
                '   Note: 401 Unauthorized is expected without auth token\n';
          }
          _testResult += '\n';
        });
      } catch (e) {
        final errorString = e.toString();
        if (errorString.contains('CERTIFICATE_VERIFY_FAILED') ||
            errorString.contains('HandshakeException')) {
          setState(() {
            _testResult += '❌ FAILED: SSL Certificate error still present\n';
            _testResult += '   Error: $e\n\n';
          });
        } else {
          setState(() {
            _testResult +=
                '✅ SUCCESS: No SSL errors (other errors are expected)\n';
            _testResult += '   Error: $e\n\n';
          });
        }
      }

      // Test 3: Test with a known good SSL site
      setState(() {
        _testResult += 'Test 3: Testing with httpbin.org (known good SSL)...\n';
      });

      try {
        final response = await httpClient.get(
          'https://httpbin.org/get',
          requireAuth: false,
        );

        setState(() {
          _testResult += '✅ SUCCESS: httpbin.org connection established\n';
          _testResult += '   Status Code: ${response.statusCode}\n\n';
        });
      } catch (e) {
        setState(() {
          _testResult += '❌ FAILED: httpbin.org connection failed\n';
          _testResult += '   Error: $e\n\n';
        });
      }

      setState(() {
        _testResult += '=== TEST SUMMARY ===\n';
        _testResult +=
            'SSL Certificate implementation has been updated with:\n';
        _testResult += '• Custom HTTP client with certificate handling\n';
        _testResult += '• Enhanced error messages for SSL issues\n';
        _testResult +=
            '• Proper certificate validation for sfxsys.com domain\n';
        _testResult += '• Fallback handling for certificate mismatches\n\n';
        _testResult +=
            'If you see SSL certificate errors above, the issue may require server-side configuration changes.\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
