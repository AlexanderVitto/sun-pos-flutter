import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../services/secure_storage_service.dart';
import '../services/ssl_certificate_service.dart';
import '../utils/app_info_helper.dart';
import 'ssl_http_client.dart';

/// HTTP Client yang otomatis menambahkan token authorization
class AuthHttpClient {
  static final AuthHttpClient _instance = AuthHttpClient._internal();

  factory AuthHttpClient() {
    return _instance;
  }

  AuthHttpClient._internal();

  final SecureStorageService _secureStorage = SecureStorageService();
  final http.Client _client = SSLHttpClient();

  /// GET request dengan authorization header otomatis
  Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
    bool requireAuth = true,
  }) async {
    try {
      final finalHeaders = await _prepareHeaders(headers, requireAuth);
      return await _client.get(Uri.parse(url), headers: finalHeaders);
    } on HandshakeException catch (e) {
      final errorMessage = SSLCertificateService.getSSLErrorMessage(e);
      throw Exception(errorMessage);
    } on SocketException catch (e) {
      throw Exception('Network connection error: ${e.message}');
    } catch (e) {
      if (e.toString().contains('CERTIFICATE_VERIFY_FAILED') ||
          e.toString().contains('HandshakeException')) {
        final errorMessage = SSLCertificateService.getSSLErrorMessage(e);
        throw Exception(errorMessage);
      }
      rethrow;
    }
  }

  /// POST request dengan authorization header otomatis
  Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool requireAuth = true,
  }) async {
    try {
      final finalHeaders = await _prepareHeaders(headers, requireAuth);
      return await _client.post(
        Uri.parse(url),
        headers: finalHeaders,
        body: body,
        encoding: encoding,
      );
    } on HandshakeException catch (e) {
      final errorMessage = SSLCertificateService.getSSLErrorMessage(e);
      throw Exception(errorMessage);
    } on SocketException catch (e) {
      throw Exception('Network connection error: ${e.message}');
    } catch (e) {
      if (e.toString().contains('CERTIFICATE_VERIFY_FAILED') ||
          e.toString().contains('HandshakeException')) {
        final errorMessage = SSLCertificateService.getSSLErrorMessage(e);
        throw Exception(errorMessage);
      }
      rethrow;
    }
  }

  /// PUT request dengan authorization header otomatis
  Future<http.Response> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool requireAuth = true,
  }) async {
    try {
      final finalHeaders = await _prepareHeaders(headers, requireAuth);
      return await _client.put(
        Uri.parse(url),
        headers: finalHeaders,
        body: body,
        encoding: encoding,
      );
    } on HandshakeException catch (e) {
      final errorMessage = SSLCertificateService.getSSLErrorMessage(e);
      throw Exception(errorMessage);
    } on SocketException catch (e) {
      throw Exception('Network connection error: ${e.message}');
    } catch (e) {
      if (e.toString().contains('CERTIFICATE_VERIFY_FAILED') ||
          e.toString().contains('HandshakeException')) {
        final errorMessage = SSLCertificateService.getSSLErrorMessage(e);
        throw Exception(errorMessage);
      }
      rethrow;
    }
  }

  /// DELETE request dengan authorization header otomatis
  Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool requireAuth = true,
  }) async {
    try {
      final finalHeaders = await _prepareHeaders(headers, requireAuth);
      return await _client.delete(
        Uri.parse(url),
        headers: finalHeaders,
        body: body,
        encoding: encoding,
      );
    } on HandshakeException catch (e) {
      final errorMessage = SSLCertificateService.getSSLErrorMessage(e);
      throw Exception(errorMessage);
    } on SocketException catch (e) {
      throw Exception('Network connection error: ${e.message}');
    } catch (e) {
      if (e.toString().contains('CERTIFICATE_VERIFY_FAILED') ||
          e.toString().contains('HandshakeException')) {
        final errorMessage = SSLCertificateService.getSSLErrorMessage(e);
        throw Exception(errorMessage);
      }
      rethrow;
    }
  }

  /// PATCH request dengan authorization header otomatis
  Future<http.Response> patch(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool requireAuth = true,
  }) async {
    try {
      final finalHeaders = await _prepareHeaders(headers, requireAuth);
      return await _client.patch(
        Uri.parse(url),
        headers: finalHeaders,
        body: body,
        encoding: encoding,
      );
    } on HandshakeException catch (e) {
      final errorMessage = SSLCertificateService.getSSLErrorMessage(e);
      throw Exception(errorMessage);
    } on SocketException catch (e) {
      throw Exception('Network connection error: ${e.message}');
    } catch (e) {
      if (e.toString().contains('CERTIFICATE_VERIFY_FAILED') ||
          e.toString().contains('HandshakeException')) {
        final errorMessage = SSLCertificateService.getSSLErrorMessage(e);
        throw Exception(errorMessage);
      }
      rethrow;
    }
  }

  /// Menyiapkan headers dengan token authorization dan device information
  Future<Map<String, String>> _prepareHeaders(
    Map<String, String>? headers,
    bool requireAuth,
  ) async {
    // Pastikan app info sudah diinisialisasi
    if (!AppInfoHelper.isInitialized) {
      await AppInfoHelper.initialize();
    }

    final finalHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // Custom headers yang diminta
      'User-Agent': AppInfoHelper.userAgent,
      'X-Device-Id': AppInfoHelper.deviceId,
      'X-Platform': AppInfoHelper.platform,
      'X-App-Version': AppInfoHelper.fullVersion,
    };

    // Tambahkan headers yang diberikan
    if (headers != null) {
      finalHeaders.addAll(headers);
    }

    // Tambahkan authorization header jika diperlukan
    if (requireAuth) {
      try {
        final token = await _secureStorage.getAccessToken();
        if (token != null) {
          finalHeaders['Authorization'] = 'Bearer $token';
        }

        // Tambahkan device ID jika ada dari secure storage (untuk backward compatibility)
        final deviceId = await _secureStorage.getDeviceId();
        if (deviceId != null) {
          finalHeaders['X-Device-ID'] = deviceId;
        }
      } catch (e) {
        // Log error tapi jangan throw, biar request tetap bisa dilanjutkan
        print('Error getting auth token: $e');
      }
    }

    return finalHeaders;
  }

  /// Cek apakah response menunjukkan token expired
  bool isTokenExpired(http.Response response) {
    return response.statusCode == 401 ||
        (response.statusCode == 403 &&
            response.body.contains('token') &&
            response.body.contains('expired'));
  }

  /// Handle response dengan auto-refresh token
  Future<http.Response> handleResponse(
    http.Response response,
    Future<http.Response> Function() retryRequest,
  ) async {
    if (isTokenExpired(response)) {
      // Coba refresh token
      try {
        final refreshToken = await _secureStorage.getRefreshToken();
        if (refreshToken != null) {
          // Implementasi refresh token sesuai API Anda
          // final newToken = await refreshTokenFromServer(refreshToken);
          // if (newToken != null) {
          //   await _secureStorage.saveAccessToken(newToken);
          //   return await retryRequest();
          // }
        }
      } catch (e) {
        print('Error refreshing token: $e');
      }

      // Jika refresh gagal, hapus session dan throw exception
      await _secureStorage.clearLoginSession();
      throw Exception('Token expired and refresh failed. Please login again.');
    }

    return response;
  }

  /// Helper untuk JSON POST request
  Future<http.Response> postJson(
    String url,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
    bool requireAuth = true,
  }) async {
    return await post(
      url,
      headers: headers,
      body: json.encode(data),
      requireAuth: requireAuth,
    );
  }

  /// Helper untuk JSON PUT request
  Future<http.Response> putJson(
    String url,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
    bool requireAuth = true,
  }) async {
    return await put(
      url,
      headers: headers,
      body: json.encode(data),
      requireAuth: requireAuth,
    );
  }

  /// Helper untuk JSON PATCH request
  Future<http.Response> patchJson(
    String url,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
    bool requireAuth = true,
  }) async {
    return await patch(
      url,
      headers: headers,
      body: json.encode(data),
      requireAuth: requireAuth,
    );
  }

  /// Parse JSON response dengan error handling
  Map<String, dynamic> parseJsonResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw Exception('Invalid JSON response: ${response.body}');
      }
    } else {
      try {
        final errorData = json.decode(response.body) as Map<String, dynamic>;
        throw Exception(errorData['message'] ?? 'HTTP ${response.statusCode}');
      } catch (e) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    }
  }

  /// Close client connection
  void close() {
    _client.close();
  }
}
