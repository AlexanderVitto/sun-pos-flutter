import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/services/secure_storage_service.dart';
import '../models/pending_transaction_api_models.dart';

class PendingTransactionApiService {
  static const String baseUrl = 'https://sfpos.app/api/v1';
  final SecureStorageService _secureStorage = SecureStorageService();

  /// Get pending transactions from API
  Future<PendingTransactionListResponse> getPendingTransactions({
    int page = 1,
    int perPage = 50,
    int? storeId,
  }) async {
    try {
      final token = await _secureStorage.getAccessToken();

      if (token == null || token.isEmpty) {
        throw Exception('Access token not found');
      }

      final queryParameters = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
        'status': 'draft', // Filter for draft transactions only
        'sort_by': 'created_at',
        'sort_direction': 'desc',
      };

      if (storeId != null) {
        queryParameters['store_id'] = storeId.toString();
      }

      final url = Uri.parse(
        '$baseUrl/transactions',
      ).replace(queryParameters: queryParameters);

      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return PendingTransactionListResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('401: Unauthorized access');
      } else {
        throw Exception(
          'Failed to get pending transactions (${response.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: ${e.toString()}');
      }
    }
  }

  /// Get specific pending transaction details
  Future<PendingTransactionDetail> getPendingTransactionDetail(
    int transactionId,
  ) async {
    try {
      final token = await _secureStorage.getAccessToken();

      if (token == null || token.isEmpty) {
        throw Exception('Access token not found');
      }

      final url = Uri.parse('$baseUrl/transactions/$transactionId');

      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint(
          'Pending transaction detail: ${responseData['data']}',
          wrapWidth: 1000,
        );
        return PendingTransactionDetail.fromJson(responseData['data'] ?? {});
      } else if (response.statusCode == 401) {
        throw Exception('401: Unauthorized access');
      } else if (response.statusCode == 404) {
        throw Exception('Transaction not found');
      } else {
        throw Exception(
          'Failed to get transaction detail (${response.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: ${e.toString()}');
      }
    }
  }

  /// Update transaction status (e.g., from pending to completed)
  Future<Map<String, dynamic>> updateTransactionStatus(
    int transactionId,
    String status,
  ) async {
    try {
      final token = await _secureStorage.getAccessToken();

      if (token == null || token.isEmpty) {
        throw Exception('Access token not found');
      }

      final url = Uri.parse('$baseUrl/transactions/$transactionId');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      final body = jsonEncode({'status': status});

      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('401: Unauthorized access');
      } else if (response.statusCode == 404) {
        throw Exception('Transaction not found');
      } else if (response.statusCode == 422) {
        final responseData = jsonDecode(response.body);
        final errorMessage = _extractValidationErrors(responseData);
        throw Exception('Validation error: $errorMessage');
      } else {
        throw Exception(
          'Failed to update transaction (${response.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: ${e.toString()}');
      }
    }
  }

  /// Delete transaction (only if pending)
  Future<Map<String, dynamic>> deleteTransaction(int transactionId) async {
    try {
      final token = await _secureStorage.getAccessToken();

      if (token == null || token.isEmpty) {
        throw Exception('Access token not found');
      }

      final url = Uri.parse('$baseUrl/transactions/$transactionId');

      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('401: Unauthorized access');
      } else if (response.statusCode == 404) {
        throw Exception('Transaction not found');
      } else {
        throw Exception(
          'Failed to delete transaction (${response.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: ${e.toString()}');
      }
    }
  }

  /// Extract validation error messages from API response
  String _extractValidationErrors(Map<String, dynamic> responseData) {
    if (responseData.containsKey('errors')) {
      final errors = responseData['errors'] as Map<String, dynamic>;
      final errorMessages = <String>[];

      errors.forEach((field, messages) {
        if (messages is List) {
          for (final message in messages) {
            errorMessages.add('$field: $message');
          }
        }
      });

      return errorMessages.join(', ');
    } else if (responseData.containsKey('message')) {
      return responseData['message'];
    } else {
      return 'Unknown validation error';
    }
  }
}
