import 'package:flutter/material.dart';

import '../../../../core/network/auth_http_client.dart';
import '../models/product_response.dart';
import '../models/product_detail_response.dart';

class ProductApiService {
  static const String baseUrl = 'https://sfxsys.com/api/v1';
  final AuthHttpClient _httpClient = AuthHttpClient();

  /// Get products with pagination and filtering
  /// [page] - Page number (default: 1)
  /// [perPage] - Items per page (default: 15)
  /// [search] - Search query for product name or SKU
  /// [categoryId] - Filter by category ID
  /// [unitId] - Filter by unit ID
  /// [activeOnly] - Filter active products only (default: true)
  /// [sortBy] - Sort field (name, created_at, updated_at, etc.)
  /// [sortDirection] - Sort direction (asc or desc)
  Future<ProductResponse> getProducts({
    int page = 1,
    int perPage = 15,
    String? search,
    int? categoryId,
    int? unitId,
    bool activeOnly = true,
    String? sortBy,
    String? sortDirection,
  }) async {
    try {
      // Build query parameters
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
        'active_only': activeOnly.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (categoryId != null) {
        queryParams['category_id'] = categoryId.toString();
      }

      if (unitId != null) {
        queryParams['unit_id'] = unitId.toString();
      }

      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sort_by'] = sortBy;
      }

      if (sortDirection != null && sortDirection.isNotEmpty) {
        queryParams['sort_direction'] = sortDirection;
      }

      // Build URL with query parameters
      final uri = Uri.parse('$baseUrl/products');
      final finalUri = uri.replace(queryParameters: queryParams);

      final response = await _httpClient.get(
        finalUri.toString(),
        requireAuth: true, // Products endpoint requires authentication
      );

      final responseData = _httpClient.parseJsonResponse(response);
      debugPrint('Response data: $responseData', wrapWidth: 2024);
      return ProductResponse.fromJson(responseData);
    } catch (e) {
      throw Exception('Failed to get products: ${e.toString()}');
    }
  }

  /// Get single product by ID
  Future<ProductDetailResponse> getProduct(int productId) async {
    try {
      final url = '$baseUrl/products/$productId';

      final response = await _httpClient.get(url, requireAuth: true);

      final responseData = _httpClient.parseJsonResponse(response);
      return ProductDetailResponse.fromJson(responseData);
    } catch (e) {
      throw Exception('Failed to get product: ${e.toString()}');
    }
  }

  /// Search products by name or SKU
  Future<ProductResponse> searchProducts(
    String query, {
    int page = 1,
    int perPage = 15,
    int? categoryId,
    int? unitId,
    String? sortBy,
    String? sortDirection,
  }) async {
    return await getProducts(
      page: page,
      perPage: perPage,
      search: query,
      categoryId: categoryId,
      unitId: unitId,
      sortBy: sortBy,
      sortDirection: sortDirection,
    );
  }

  /// Get products by category
  Future<ProductResponse> getProductsByCategory(
    int categoryId, {
    int page = 1,
    int perPage = 15,
    String? search,
    int? unitId,
    String? sortBy,
    String? sortDirection,
  }) async {
    return await getProducts(
      page: page,
      perPage: perPage,
      search: search,
      categoryId: categoryId,
      unitId: unitId,
      sortBy: sortBy,
      sortDirection: sortDirection,
    );
  }

  /// Get products by unit
  Future<ProductResponse> getProductsByUnit(
    int unitId, {
    int page = 1,
    int perPage = 15,
    String? search,
    int? categoryId,
    String? sortBy,
    String? sortDirection,
  }) async {
    return await getProducts(
      page: page,
      perPage: perPage,
      search: search,
      categoryId: categoryId,
      unitId: unitId,
      sortBy: sortBy,
      sortDirection: sortDirection,
    );
  }

  /// Get active products only (default behavior)
  Future<ProductResponse> getActiveProducts({
    int page = 1,
    int perPage = 15,
    String? search,
    int? categoryId,
    int? unitId,
    String? sortBy,
    String? sortDirection,
  }) async {
    return await getProducts(
      page: page,
      perPage: perPage,
      search: search,
      categoryId: categoryId,
      unitId: unitId,
      activeOnly: true,
      sortBy: sortBy,
      sortDirection: sortDirection,
    );
  }

  /// Get all products including inactive ones
  Future<ProductResponse> getAllProducts({
    int page = 1,
    int perPage = 15,
    String? search,
    int? categoryId,
    int? unitId,
    String? sortBy,
    String? sortDirection,
  }) async {
    return await getProducts(
      page: page,
      perPage: perPage,
      search: search,
      categoryId: categoryId,
      unitId: unitId,
      activeOnly: false,
      sortBy: sortBy,
      sortDirection: sortDirection,
    );
  }
}
