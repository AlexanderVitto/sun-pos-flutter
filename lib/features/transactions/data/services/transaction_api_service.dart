import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/services/secure_storage_service.dart';
import '../models/create_transaction_request.dart';
import '../models/create_transaction_response.dart';
import '../models/transaction_list_response.dart';

class TransactionApiService {
  static const String baseUrl = 'https://sfxsys.com/api/v1';
  final SecureStorageService _secureStorage = SecureStorageService();

  /// Create a new transaction
  Future<CreateTransactionResponse> createTransaction(
    CreateTransactionRequest request,
  ) async {
    try {
      final token = await _secureStorage.getAccessToken();

      if (token == null || token.isEmpty) {
        throw Exception('Access token not found');
      }

      final url = Uri.parse('$baseUrl/transactions');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };
      print('Request JSON: ${jsonEncode(request.toJson())}'); // Debug print

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      // Handle different HTTP status codes
      if (response.statusCode == 201 || response.statusCode == 200) {
        // Success response
        final responseData = jsonDecode(response.body);
        return CreateTransactionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        // Unauthorized
        throw Exception('401: Unauthorized access');
      } else if (response.statusCode == 422) {
        // Validation error
        final responseData = jsonDecode(response.body);
        final errorMessage = _extractValidationErrors(responseData);
        throw Exception('Validation error: $errorMessage');
      } else if (response.statusCode == 400) {
        // Bad request
        final responseData = jsonDecode(response.body);
        final message = responseData['message'] ?? 'Bad request';
        throw Exception('Bad request: $message');
      } else if (response.statusCode >= 500) {
        // Server error
        throw Exception(
          'Server error (${response.statusCode}): Please try again later',
        );
      } else {
        // Other errors
        throw Exception(
          'Failed to create transaction (${response.statusCode})',
        );
      }
    } catch (e) {
      // Re-throw with more context if it's not already an Exception
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

  /// Get transaction by ID - returns full transaction detail
  Future<CreateTransactionResponse> getTransaction(int transactionId) async {
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

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return CreateTransactionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('401: Unauthorized access');
      } else if (response.statusCode == 404) {
        throw Exception('Transaction not found');
      } else {
        throw Exception('Failed to get transaction (${response.statusCode})');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: ${e.toString()}');
      }
    }
  }

  /// Get transactions list with pagination and advanced filters
  Future<TransactionListResponse> getTransactions({
    int page = 1,
    int perPage = 10,
    String? search,
    int? storeId,
    int? userId,
    String? dateFrom,
    String? dateTo,
    double? minAmount,
    double? maxAmount,
    String? sortBy,
    String? sortDirection,
    String? paymentMethod,
    String? status,
  }) async {
    try {
      final token = await _secureStorage.getAccessToken();

      if (token == null || token.isEmpty) {
        throw Exception('Access token not found');
      }

      final queryParameters = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }
      if (storeId != null) {
        queryParameters['store_id'] = storeId.toString();
      }
      if (userId != null) {
        queryParameters['user_id'] = userId.toString();
      }
      if (dateFrom != null && dateFrom.isNotEmpty) {
        queryParameters['date_from'] = dateFrom;
      }
      if (dateTo != null && dateTo.isNotEmpty) {
        queryParameters['date_to'] = dateTo;
      }
      if (minAmount != null) {
        queryParameters['min_amount'] = minAmount.toString();
      }
      if (maxAmount != null) {
        queryParameters['max_amount'] = maxAmount.toString();
      }
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParameters['sort_by'] = sortBy;
      }
      if (sortDirection != null && sortDirection.isNotEmpty) {
        queryParameters['sort_direction'] = sortDirection;
      }
      if (paymentMethod != null && paymentMethod.isNotEmpty) {
        queryParameters['payment_method'] = paymentMethod;
      }
      if (status != null && status.isNotEmpty) {
        queryParameters['status'] = status;
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
        return TransactionListResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('401: Unauthorized access');
      } else {
        throw Exception('Failed to get transactions (${response.statusCode})');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: ${e.toString()}');
      }
    }
  }

  /// Update transaction with full transaction data
  Future<CreateTransactionResponse> updateTransaction(
    int transactionId,
    CreateTransactionRequest request,
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

      print('Request JSON: ${jsonEncode(request.toJson())}'); // Debug print

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      // Handle different HTTP status codes
      if (response.statusCode == 200) {
        // Success response
        final responseData = jsonDecode(response.body);
        return CreateTransactionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        // Unauthorized
        throw Exception('401: Unauthorized access');
      } else if (response.statusCode == 404) {
        // Transaction not found
        throw Exception('Transaction not found');
      } else if (response.statusCode == 422) {
        // Validation error
        final responseData = jsonDecode(response.body);
        final errorMessage = _extractValidationErrors(responseData);
        throw Exception('Validation error: $errorMessage');
      } else if (response.statusCode == 400) {
        // Bad request
        final responseData = jsonDecode(response.body);
        final message = responseData['message'] ?? 'Bad request';
        throw Exception('Bad request: $message');
      } else if (response.statusCode >= 500) {
        // Server error
        throw Exception(
          'Server error (${response.statusCode}): Please try again later',
        );
      } else {
        // Other errors
        throw Exception(
          'Failed to update transaction (${response.statusCode})',
        );
      }
    } catch (e) {
      // Re-throw with more context if it's not already an Exception
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: ${e.toString()}');
      }
    }
  }

  /// Update transaction status only
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

  /// Delete transaction by ID
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

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Success - return response or empty object for 204
        if (response.body.isNotEmpty) {
          return jsonDecode(response.body);
        } else {
          return {
            'success': true,
            'message': 'Transaction deleted successfully',
          };
        }
      } else if (response.statusCode == 401) {
        throw Exception('401: Unauthorized access');
      } else if (response.statusCode == 404) {
        throw Exception('Transaction not found');
      } else if (response.statusCode == 403) {
        throw Exception('403: Forbidden - Cannot delete this transaction');
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

  /// Update transaction with custom data
  Future<Map<String, dynamic>> updateTransactionWithData(
    int transactionId,
    Map<String, dynamic> data,
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

      final body = jsonEncode(data);

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
      } else if (response.statusCode == 400) {
        final responseData = jsonDecode(response.body);
        final message = responseData['message'] ?? 'Bad request';
        throw Exception('Bad request: $message');
      } else if (response.statusCode >= 500) {
        throw Exception(
          'Server error (${response.statusCode}): Please try again later',
        );
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

  /// Update transaction payment (for paying outstanding debt)
  /// Only updates payments array and status
  Future<CreateTransactionResponse> updateTransactionPayment(
    int transactionId,
    Map<String, dynamic> paymentData,
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

      print(
        'Payment Update Request: ${jsonEncode(paymentData)}',
      ); // Debug print

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(paymentData),
      );

      // Handle different HTTP status codes
      if (response.statusCode == 200) {
        // Success response
        final responseData = jsonDecode(response.body);
        return CreateTransactionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        // Unauthorized
        throw Exception('401: Unauthorized access');
      } else if (response.statusCode == 404) {
        // Transaction not found
        throw Exception('Transaction not found');
      } else if (response.statusCode == 422) {
        // Validation error
        final responseData = jsonDecode(response.body);
        final errorMessage = _extractValidationErrors(responseData);
        throw Exception('Validation error: $errorMessage');
      } else if (response.statusCode == 400) {
        // Bad request
        final responseData = jsonDecode(response.body);
        final message = responseData['message'] ?? 'Bad request';
        throw Exception('Bad request: $message');
      } else if (response.statusCode >= 500) {
        // Server error
        throw Exception(
          'Server error (${response.statusCode}): Please try again later',
        );
      } else {
        // Other errors
        throw Exception('Failed to update payment (${response.statusCode})');
      }
    } catch (e) {
      // Re-throw with more context if it's not already an Exception
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: ${e.toString()}');
      }
    }
  }
}
