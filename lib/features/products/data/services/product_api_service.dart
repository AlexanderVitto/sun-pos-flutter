import '../../../../core/network/auth_http_client.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/services/selected_store_holder.dart';
import '../models/product.dart';
import '../models/low_stock_product.dart';
import '../models/product_response.dart';
import '../models/product_detail_response.dart';
import '../models/category_response.dart';

class ProductApiService {
  String get baseUrl => AppConfig.baseUrl;
  final AuthHttpClient _httpClient = AuthHttpClient();

  /// Get products with pagination and filtering
  /// [page] - Page number (default: 1)
  /// [perPage] - Items per page (default: 15)
  /// [customerId] - Customer ID for customer-specific pricing (REQUIRED)
  /// [search] - Search query for product name or SKU
  /// [categoryId] - Filter by category ID
  /// [unitId] - Filter by unit ID
  /// [activeOnly] - Filter active products only (default: true)
  /// [sortBy] - Sort field (name, created_at, updated_at, etc.)
  /// [sortDirection] - Sort direction (asc or desc)
  Future<ProductResponse> getProducts({
    int page = 1,
    int perPage = 15,
    int? customerId,
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

      // customer_id opsional — hanya untuk harga spesifik customer/grup.
      // Tanpa ini, API mengembalikan harga base sehingga produk tetap bisa
      // dimuat walau belum ada customer terpilih.
      if (customerId != null) {
        queryParams['customer_id'] = customerId.toString();
      }

      // Sisipkan store_id dari toko yang sedang dipilih (bila ada).
      final storeId = SelectedStoreHolder.instance.storeId;
      if (storeId != null) {
        queryParams['store_id'] = storeId.toString();
      }

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
      // debugPrint('Response data: $responseData', wrapWidth: 2024); // Commented out - too verbose
      return ProductResponse.fromJson(responseData);
    } catch (e) {
      throw Exception('Failed to get products: ${e.toString()}');
    }
  }

  /// Ambil daftar produk dengan stok menipis/habis untuk satu toko.
  ///
  /// Endpoint: `GET /products/low-stock?store_id=..&per_page=..`
  Future<LowStockResponse> getLowStockProducts({
    int? storeId,
    int perPage = 15,
  }) async {
    try {
      final queryParams = <String, String>{'per_page': perPage.toString()};

      final resolvedStoreId = storeId ?? SelectedStoreHolder.instance.storeId;
      if (resolvedStoreId != null) {
        queryParams['store_id'] = resolvedStoreId.toString();
      }

      final uri = Uri.parse(
        '$baseUrl/products/low-stock',
      ).replace(queryParameters: queryParams);

      final response = await _httpClient.get(
        uri.toString(),
        requireAuth: true,
      );

      final responseData = _httpClient.parseJsonResponse(response);
      return LowStockResponse.fromJson(responseData);
    } catch (e) {
      throw Exception('Failed to get low stock products: ${e.toString()}');
    }
  }

  /// Ambil SELURUH produk aktif untuk satu toko (tanpa pagination) dengan
  /// HARGA BASE — dipakai untuk membangun snapshot cache offline.
  ///
  /// Endpoint: `GET /products?store_id=..&active_only=true`
  /// Berbeda dengan [getProducts] yang dipaginasi & bisa pakai harga grup.
  Future<List<Product>> getProductsSnapshot({
    int? storeId,
    bool activeOnly = true,
  }) async {
    try {
      final queryParams = <String, String>{
        'active_only': activeOnly.toString(),
      };

      final resolvedStoreId = storeId ?? SelectedStoreHolder.instance.storeId;
      if (resolvedStoreId != null) {
        queryParams['store_id'] = resolvedStoreId.toString();
      }

      final uri = Uri.parse(
        '$baseUrl/products',
      ).replace(queryParameters: queryParams);

      final response = await _httpClient.get(
        uri.toString(),
        requireAuth: true,
      );

      final responseData = _httpClient.parseJsonResponse(response);
      return ProductResponse.fromJson(responseData).data.data;
    } catch (e) {
      throw Exception('Failed to get all products: ${e.toString()}');
    }
  }

  /// Get single product by ID
  /// [productId] - Product ID
  /// [customerId] - Customer ID for customer-specific pricing (opsional;
  /// tanpa ini API mengembalikan harga base)
  Future<ProductDetailResponse> getProduct(
    int productId, {
    int? customerId,
  }) async {
    try {
      final queryParams = <String, String>{};

      // customer_id opsional — hanya untuk harga spesifik customer/grup.
      if (customerId != null) {
        queryParams['customer_id'] = customerId.toString();
      }

      // Sisipkan store_id dari toko yang sedang dipilih (bila ada).
      final storeId = SelectedStoreHolder.instance.storeId;
      if (storeId != null) {
        queryParams['store_id'] = storeId.toString();
      }

      final uri = Uri.parse(
        '$baseUrl/products/$productId',
      ).replace(queryParameters: queryParams);

      final response = await _httpClient.get(
        uri.toString(),
        requireAuth: true,
      );

      final responseData = _httpClient.parseJsonResponse(response);
      return ProductDetailResponse.fromJson(responseData);
    } catch (e) {
      throw Exception('Failed to get product: ${e.toString()}');
    }
  }

  /// Search products by name or SKU
  Future<ProductResponse> searchProducts(
    String query, {
    required int customerId,
    int page = 1,
    int perPage = 15,
    int? categoryId,
    int? unitId,
    String? sortBy,
    String? sortDirection,
  }) async {
    return await getProducts(
      customerId: customerId,
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
    required int customerId,
    int page = 1,
    int perPage = 15,
    String? search,
    int? unitId,
    String? sortBy,
    String? sortDirection,
  }) async {
    return await getProducts(
      customerId: customerId,
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
    required int customerId,
    int page = 1,
    int perPage = 15,
    String? search,
    int? categoryId,
    String? sortBy,
    String? sortDirection,
  }) async {
    return await getProducts(
      customerId: customerId,
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
    required int customerId,
    int page = 1,
    int perPage = 15,
    String? search,
    int? categoryId,
    int? unitId,
    String? sortBy,
    String? sortDirection,
  }) async {
    return await getProducts(
      customerId: customerId,
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
    required int customerId,
    int page = 1,
    int perPage = 15,
    String? search,
    int? categoryId,
    int? unitId,
    String? sortBy,
    String? sortDirection,
  }) async {
    return await getProducts(
      customerId: customerId,
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

  /// Get all categories
  /// Returns list of all categories available in the system
  Future<CategoryResponse> getCategories() async {
    try {
      final url = '$baseUrl/categories';

      final response = await _httpClient.get(url, requireAuth: true);

      final responseData = _httpClient.parseJsonResponse(response);
      return CategoryResponse.fromJson(responseData);
    } catch (e) {
      throw Exception('Failed to get categories: ${e.toString()}');
    }
  }
}
