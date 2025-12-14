import '../../../../core/network/auth_http_client.dart';
import '../../../../core/config/app_config.dart';
import '../models/create_customer_request.dart';
import '../models/create_customer_response.dart';
import '../models/update_customer_request.dart';
import '../models/update_customer_response.dart';
import '../models/customer.dart';
import '../models/customer_list_response.dart';
import '../models/customer_group_list_response.dart';

class CustomerApiService {
  String get baseUrl => AppConfig.baseUrl;
  final AuthHttpClient _httpClient = AuthHttpClient();

  /// Create a new customer
  /// POST {{base_url}}/api/v1/customers
  Future<CreateCustomerResponse> createCustomer(
    CreateCustomerRequest request,
  ) async {
    try {
      final url = '$baseUrl/customers';

      final response = await _httpClient.postJson(
        url,
        request.toJson(),
        requireAuth: true,
      );

      final responseData = _httpClient.parseJsonResponse(response);
      return CreateCustomerResponse.fromJson(responseData);
    } catch (e) {
      throw Exception('Failed to create customer: ${e.toString()}');
    }
  }

  /// Get customers list with pagination
  /// GET {{base_url}}/api/v1/customers
  Future<CustomerListResponse> getCustomersWithPagination({
    int page = 1,
    int perPage = 15,
    String? search,
  }) async {
    try {
      // Build query parameters
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      // Build URL with query parameters
      final uri = Uri.parse('$baseUrl/customers');
      final finalUri = uri.replace(queryParameters: queryParams);

      final response = await _httpClient.get(
        finalUri.toString(),
        requireAuth: true,
      );

      final responseData = _httpClient.parseJsonResponse(response);
      return CustomerListResponse.fromJson(responseData);
    } catch (e) {
      throw Exception('Failed to get customers: ${e.toString()}');
    }
  }

  /// Get customers list with pagination (Legacy method - returns raw Map)
  /// GET {{base_url}}/api/v1/customers
  Future<Map<String, dynamic>> getCustomers({
    int page = 1,
    int perPage = 15,
    String? search,
  }) async {
    try {
      // Build query parameters
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      // Build URL with query parameters
      final uri = Uri.parse('$baseUrl/customers');
      final finalUri = uri.replace(queryParameters: queryParams);

      final response = await _httpClient.get(
        finalUri.toString(),
        requireAuth: true,
      );

      return _httpClient.parseJsonResponse(response);
    } catch (e) {
      throw Exception('Failed to get customers: ${e.toString()}');
    }
  }

  /// Get single customer by ID
  /// GET {{base_url}}/api/v1/customers/{id}
  Future<Customer?> getCustomer(int customerId) async {
    try {
      final url = '$baseUrl/customers/$customerId';

      final response = await _httpClient.get(url, requireAuth: true);

      final responseData = _httpClient.parseJsonResponse(response);

      if (responseData['data'] != null) {
        return Customer.fromJson(responseData['data']);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get customer: ${e.toString()}');
    }
  }

  /// Update customer by ID
  /// PUT {{base_url}}/api/v1/customers/{id}
  Future<UpdateCustomerResponse> updateCustomer(
    int customerId,
    UpdateCustomerRequest request,
  ) async {
    try {
      final url = '$baseUrl/customers/$customerId';

      final response = await _httpClient.putJson(
        url,
        request.toJson(),
        requireAuth: true,
      );

      final responseData = _httpClient.parseJsonResponse(response);
      return UpdateCustomerResponse.fromJson(responseData);
    } catch (e) {
      throw Exception('Failed to update customer: ${e.toString()}');
    }
  }

  /// Delete customer by ID
  /// DELETE {{base_url}}/api/v1/customers/{id}
  Future<Map<String, dynamic>> deleteCustomer(int customerId) async {
    try {
      final url = '$baseUrl/customers/$customerId';

      final response = await _httpClient.delete(url, requireAuth: true);

      return _httpClient.parseJsonResponse(response);
    } catch (e) {
      throw Exception('Failed to delete customer: ${e.toString()}');
    }
  }

  /// Search customers by name or phone
  Future<List<Customer>> searchCustomers(String query) async {
    try {
      final response = await getCustomers(search: query, perPage: 50);

      final List<dynamic>? customersData = response['data']?['data'];
      if (customersData == null) return [];

      return customersData
          .map((customerJson) => Customer.fromJson(customerJson))
          .toList();
    } catch (e) {
      throw Exception('Failed to search customers: ${e.toString()}');
    }
  }

  /// Get customer groups list
  /// GET {{base_url}}/api/v1/customer-groups
  Future<CustomerGroupListResponse> getCustomerGroups() async {
    try {
      final url = '$baseUrl/customer-groups';

      final response = await _httpClient.get(url, requireAuth: true);

      final responseData = _httpClient.parseJsonResponse(response);
      return CustomerGroupListResponse.fromJson(responseData);
    } catch (e) {
      throw Exception('Failed to get customer groups: ${e.toString()}');
    }
  }

  /// Get customers with outstanding debts
  /// GET {{base_url}}/api/v1/customers?outstanding_only=true
  Future<CustomerListResponse> getCustomersWithOutstanding({
    int page = 1,
    int perPage = 15,
    String sortDirection = 'asc',
    String? search,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
        'sort_direction': sortDirection,
        'outstanding_only': 'true',
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse('$baseUrl/customers');
      final finalUri = uri.replace(queryParameters: queryParams);

      final response = await _httpClient.get(
        finalUri.toString(),
        requireAuth: true,
      );

      final responseData = _httpClient.parseJsonResponse(response);
      return CustomerListResponse.fromJson(responseData);
    } catch (e) {
      throw Exception(
        'Failed to get customers with outstanding: ${e.toString()}',
      );
    }
  }
}
