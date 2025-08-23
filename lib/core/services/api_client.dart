import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _client = http.Client();

  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);

    try {
      final response = await _client
          .get(uri, headers: headers ?? AppConfig.defaultHeaders)
          .timeout(Duration(seconds: AppConfig.timeoutSeconds));

      _logResponse('GET', uri.toString(), response);
      return response;
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('HTTP error occurred');
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);

    try {
      final response = await _client
          .post(
            uri,
            headers: headers ?? AppConfig.defaultHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: AppConfig.timeoutSeconds));

      _logResponse('POST', uri.toString(), response);
      return response;
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('HTTP error occurred');
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }

  Uri _buildUri(String endpoint, Map<String, dynamic>? queryParameters) {
    final baseUri = Uri.parse(AppConfig.baseUrl);
    final uri = baseUri.replace(
      path: '${baseUri.path}/$endpoint'.replaceAll('//', '/'),
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
    return uri;
  }

  void _logResponse(String method, String url, http.Response response) {
    if (AppConfig.enableLogging) {
      print('[$method] $url');
      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }

  void dispose() {
    _client.close();
  }
}
