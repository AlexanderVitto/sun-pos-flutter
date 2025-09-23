import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// Custom HTTP client that handles SSL certificate issues
class SSLHttpClient extends http.BaseClient {
  static SSLHttpClient? _instance;
  late final http.Client _client;

  SSLHttpClient._internal() {
    _client = _createClient();
  }

  factory SSLHttpClient() {
    _instance ??= SSLHttpClient._internal();
    return _instance!;
  }

  http.Client _createClient() {
    final httpClient = HttpClient();

    // Configure SSL context to handle certificate issues
    httpClient.badCertificateCallback = (
      X509Certificate cert,
      String host,
      int port,
    ) {
      // For development/testing purposes, you might want to accept all certificates
      // In production, implement proper certificate validation

      // Log the certificate details for debugging
      print('SSL Certificate for $host:$port');
      print('Subject: ${cert.subject}');
      print('Issuer: ${cert.issuer}');
      print('Valid from: ${cert.startValidity}');
      print('Valid to: ${cert.endValidity}');

      // For now, accept certificates for sfxsys.com domain
      // You should implement proper certificate validation in production
      if (host == 'sfxsys.com' || host.endsWith('.sfxsys.com')) {
        print('Accepting certificate for sfxsys.com domain');
        return true;
      }

      // For other domains, use default validation
      return false;
    };

    // Set connection timeout
    httpClient.connectionTimeout = const Duration(seconds: 30);

    // Configure additional SSL settings if needed
    httpClient.userAgent = 'Sun POS Flutter App/1.0.0';

    return IOClient(httpClient);
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request);
  }

  @override
  void close() {
    _client.close();
    _instance = null;
  }
}
