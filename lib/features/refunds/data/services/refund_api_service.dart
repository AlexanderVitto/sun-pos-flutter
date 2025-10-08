import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/services/secure_storage_service.dart';

class RefundApiService {
  static const String baseUrl = 'https://sfxsys.com/api/v1';
  final SecureStorageService _secureStorage = SecureStorageService();

  /// Get list of refunds with pagination and filters
  Future<Map<String, dynamic>> getRefunds({
    int page = 1,
    int perPage = 15,
    String? search,
    int? storeId,
    int? userId,
    int? customerId,
    String? dateFrom,
    String? dateTo,
    String? status,
    String? refundMethod,
    double? minAmount,
    double? maxAmount,
    String sortBy = 'created_at',
    String sortDirection = 'desc',
  }) async {
    try {
      final token = await _secureStorage.getAccessToken();

      if (token == null || token.isEmpty) {
        throw Exception('Access token not found');
      }

      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
        'sort_by': sortBy,
        'sort_direction': sortDirection,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (storeId != null) {
        queryParams['store_id'] = storeId.toString();
      }
      if (userId != null) {
        queryParams['user_id'] = userId.toString();
      }
      if (customerId != null) {
        queryParams['customer_id'] = customerId.toString();
      }
      if (dateFrom != null) {
        queryParams['date_from'] = dateFrom;
      }
      if (dateTo != null) {
        queryParams['date_to'] = dateTo;
      }
      if (status != null) {
        queryParams['status'] = status;
      }
      if (refundMethod != null) {
        queryParams['refund_method'] = refundMethod;
      }
      if (minAmount != null) {
        queryParams['min_amount'] = minAmount.toString();
      }
      if (maxAmount != null) {
        queryParams['max_amount'] = maxAmount.toString();
      }

      final uri = Uri.parse(
        '$baseUrl/refunds',
      ).replace(queryParameters: queryParams);

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('401: Unauthorized access');
      } else if (response.statusCode == 403) {
        throw Exception('403: Forbidden - You do not have permission');
      } else if (response.statusCode == 404) {
        throw Exception('404: Endpoint not found');
      } else {
        throw Exception(
          'Failed to load refunds: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get refund detail by ID
  Future<Map<String, dynamic>> getRefundById(int id) async {
    try {
      final token = await _secureStorage.getAccessToken();

      if (token == null || token.isEmpty) {
        throw Exception('Access token not found');
      }

      final url = Uri.parse('$baseUrl/refunds/$id');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('401: Unauthorized access');
      } else if (response.statusCode == 404) {
        throw Exception('404: Refund not found');
      } else {
        throw Exception(
          'Failed to load refund: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get refunds by transaction ID
  Future<Map<String, dynamic>> getRefundsByTransactionId(
    int transactionId,
  ) async {
    try {
      final token = await _secureStorage.getAccessToken();

      if (token == null || token.isEmpty) {
        throw Exception('Access token not found');
      }

      final url = Uri.parse(
        '$baseUrl/refunds',
      ).replace(queryParameters: {'transaction_id': transactionId.toString()});

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('401: Unauthorized access');
      } else {
        throw Exception(
          'Failed to load refunds: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
