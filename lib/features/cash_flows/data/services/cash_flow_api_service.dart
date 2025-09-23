import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/services/secure_storage_service.dart';
import '../models/create_cash_flow_request.dart';
import '../models/cash_flow_response.dart';

class CashFlowApiService {
  static const String baseUrl = 'https://sfxsys.com/api/v1';
  final SecureStorageService _secureStorage = SecureStorageService();

  /// Create a new cash flow entry
  Future<CreateCashFlowResponse> createCashFlow(
    CreateCashFlowRequest request,
  ) async {
    try {
      final token = await _secureStorage.getAccessToken();

      if (token == null || token.isEmpty) {
        throw Exception('Access token not found');
      }

      final url = Uri.parse('$baseUrl/cash-flows');

      // Create multipart request as specified in the API
      final multipartRequest = http.MultipartRequest('POST', url);

      // Add headers
      multipartRequest.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add form fields
      final formData = request.toFormData();
      formData.forEach((key, value) {
        multipartRequest.fields[key] = value.toString();
      });

      // Send request
      final streamedResponse = await multipartRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Handle response
      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return CreateCashFlowResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('401: Unauthorized access');
      } else if (response.statusCode == 422) {
        final responseData = jsonDecode(response.body);
        final errorMessage = _extractValidationErrors(responseData);
        throw Exception('Validation error: $errorMessage');
      } else if (response.statusCode == 400) {
        final responseData = jsonDecode(response.body);
        throw Exception(
          'Bad request: ${responseData['message'] ?? 'Unknown error'}',
        );
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: Failed to create cash flow',
        );
      }
    } catch (e) {
      if (e.toString().contains('401')) {
        rethrow;
      }
      throw Exception('Failed to create cash flow: ${e.toString()}');
    }
  }

  /// Get cash flows with optional filters
  Future<CashFlowListResponse> getCashFlows({
    int storeId = 1,
    String? type, // 'in' or 'out'
    String? category,
    String? dateFrom, // YYYY-MM-DD
    String? dateTo, // YYYY-MM-DD
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final token = await _secureStorage.getAccessToken();

      if (token == null || token.isEmpty) {
        throw Exception('Access token not found');
      }

      // Build query parameters
      final queryParams = <String, String>{
        'store_id': storeId.toString(),
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (dateFrom != null && dateFrom.isNotEmpty) {
        queryParams['date_from'] = dateFrom;
      }
      if (dateTo != null && dateTo.isNotEmpty) {
        queryParams['date_to'] = dateTo;
      }

      final url = Uri.parse(
        '$baseUrl/cash-flows',
      ).replace(queryParameters: queryParams);

      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final response = await http.get(url, headers: headers);

      // Handle response
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return CashFlowListResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('401: Unauthorized access');
      } else if (response.statusCode == 400) {
        final responseData = jsonDecode(response.body);
        throw Exception(
          'Bad request: ${responseData['message'] ?? 'Unknown error'}',
        );
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: Failed to fetch cash flows',
        );
      }
    } catch (e) {
      if (e.toString().contains('401')) {
        rethrow;
      }
      throw Exception('Failed to fetch cash flows: ${e.toString()}');
    }
  }

  /// Extract validation errors from API response
  String _extractValidationErrors(Map<String, dynamic> responseData) {
    if (responseData['errors'] != null) {
      final errors = responseData['errors'] as Map<String, dynamic>;
      final List<String> errorMessages = [];

      errors.forEach((field, messages) {
        if (messages is List) {
          errorMessages.addAll(messages.map((msg) => '$field: $msg'));
        } else {
          errorMessages.add('$field: $messages');
        }
      });

      return errorMessages.join(', ');
    }

    return responseData['message'] ?? 'Validation failed';
  }
}
