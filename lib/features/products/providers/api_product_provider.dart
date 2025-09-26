import 'package:flutter/material.dart';
import '../data/services/product_api_service.dart';
import '../data/models/product.dart' as api_product;
import '../data/models/product_detail_response.dart';
import '../data/models/pagination.dart';
import '../../../data/models/product.dart' as local_product;

class ApiProductProvider extends ChangeNotifier {
  final ProductApiService _apiService = ProductApiService();

  // API Products
  List<api_product.Product> _apiProducts = [];
  PaginationMeta? _paginationMeta;
  bool _isLoading = false;
  String? _errorMessage;

  // Search and filter
  String _searchQuery = '';
  int? _selectedCategoryId;
  int? _selectedUnitId;
  String _sortBy = 'name';
  String _sortDirection = 'asc';
  int _currentPage = 1;

  // Getters for API products
  List<api_product.Product> get apiProducts => _apiProducts;
  PaginationMeta? get paginationMeta => _paginationMeta;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  int? get selectedCategoryId => _selectedCategoryId;
  int? get selectedUnitId => _selectedUnitId;
  String get sortBy => _sortBy;
  String get sortDirection => _sortDirection;
  int get currentPage => _currentPage;

  // Get selected category as string for compatibility
  String get selectedCategory {
    if (_selectedCategoryId == null) return 'All';
    final category =
        _apiProducts
            .map((p) => p.category)
            .where((c) => c.id == _selectedCategoryId)
            .firstOrNull;
    return category?.name ?? 'All';
  }

  // Getters for pagination info
  int get totalProducts => _paginationMeta?.total ?? 0;
  int get totalPages => _paginationMeta?.lastPage ?? 1;
  int get perPage => _paginationMeta?.perPage ?? 15;
  bool get hasNextPage => _currentPage < totalPages;
  bool get hasPreviousPage => _currentPage > 1;

  // Categories from API products
  List<String> get categories {
    final Set<String> categorySet = {'All'};
    for (final product in _apiProducts) {
      categorySet.add(product.category.name);
    }
    return categorySet.toList();
  }

  /// Load products from API
  Future<void> loadProducts({int page = 1, bool append = false}) async {
    try {
      if (!append) {
        _isLoading = true;
        _errorMessage = null;
        notifyListeners();
      }

      final response = await _apiService.getProducts(
        page: page,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        categoryId: _selectedCategoryId,
        unitId: _selectedUnitId,
        activeOnly: true, // Only get active products
        sortBy: _sortBy,
        sortDirection: _sortDirection,
      );

      if (response.isSuccess) {
        if (append) {
          _apiProducts.addAll(response.data.data);
        } else {
          _apiProducts = response.data.data;
        }
        _paginationMeta = response.data.meta;
        _currentPage = page;
        _errorMessage = null;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = 'Failed to load products: ${e.toString()}';
      print('Error loading products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more products (pagination)
  Future<void> loadMoreProducts() async {
    if (_isLoading || !hasNextPage) return;

    await loadProducts(page: _currentPage + 1, append: true);
  }

  /// Refresh products (reload first page)
  Future<void> refreshProducts() async {
    _currentPage = 1;
    await loadProducts(page: 1);
  }

  /// Search products
  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    _currentPage = 1;
    await loadProducts(page: 1);
  }

  /// Filter by category ID
  Future<void> filterByCategory(int? categoryId) async {
    _selectedCategoryId = categoryId;
    _currentPage = 1;
    await loadProducts(page: 1);
  }

  /// Clear search and filters
  Future<void> clearFilters() async {
    _searchQuery = '';
    _selectedCategoryId = null;
    _selectedUnitId = null;
    _currentPage = 1;
    await loadProducts(page: 1);
  }

  /// Filter by unit ID
  Future<void> filterByUnit(int? unitId) async {
    _selectedUnitId = unitId;
    _currentPage = 1;
    await loadProducts(page: 1);
  }

  /// Set sorting
  Future<void> setSorting(String sortBy, String sortDirection) async {
    _sortBy = sortBy;
    _sortDirection = sortDirection;
    _currentPage = 1;
    await loadProducts(page: 1);
  }

  /// Quick sort by name
  Future<void> sortByName({bool ascending = true}) async {
    await setSorting('name', ascending ? 'asc' : 'desc');
  }

  /// Quick sort by created date
  Future<void> sortByCreatedAt({bool ascending = false}) async {
    await setSorting('created_at', ascending ? 'asc' : 'desc');
  }

  /// Quick sort by updated date
  Future<void> sortByUpdatedAt({bool ascending = false}) async {
    await setSorting('updated_at', ascending ? 'asc' : 'desc');
  }

  /// Convert API product to local product for compatibility
  local_product.Product apiProductToLocal(api_product.Product apiProduct) {
    return local_product.Product(
      id: apiProduct.id,
      name: apiProduct.name,
      code: apiProduct.sku,
      description: apiProduct.description,
      price:
          0.0, // API doesn't have price in this response, might need separate call
      stock: apiProduct.minStock, // Using minStock as stock for now
      category: apiProduct.category.name,
      imagePath: apiProduct.image,
      createdAt: apiProduct.createdAt,
      updatedAt: apiProduct.updatedAt,
    );
  }

  /// Get products as local products for compatibility
  List<local_product.Product> get compatibilityProducts {
    return _apiProducts
        .map((apiProduct) => apiProductToLocal(apiProduct))
        .toList();
  }

  /// Get single API product by ID
  Future<api_product.Product?> getProduct(int productId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getProduct(productId);

      if (response.status == 'success') {
        // Convert ProductDetail to api_product.Product for compatibility
        final productDetail = response.data;
        return api_product.Product.fromJson({
          'id': productDetail.id,
          'name': productDetail.name,
          'sku': productDetail.sku,
          'description': productDetail.description,
          'min_stock': productDetail.minStock,
          'image': productDetail.image,
          'is_active': productDetail.isActive,
          'category': {
            'id': productDetail.category.id,
            'name': productDetail.category.name,
            'description': productDetail.category.description,
            'is_active': productDetail.category.isActive,
            'created_at': productDetail.category.createdAt,
            'updated_at': productDetail.category.updatedAt,
          },
          'unit': {
            'id': productDetail.unit.id,
            'name': productDetail.unit.name,
            'symbol': productDetail.unit.symbol,
            'description': productDetail.unit.description,
            'is_active': productDetail.unit.isActive,
            'created_at': productDetail.unit.createdAt,
            'updated_at': productDetail.unit.updatedAt,
          },
          'variants_count': productDetail.variants.length,
          'created_at': productDetail.createdAt,
          'updated_at': productDetail.updatedAt,
        });
      }

      return null;
    } catch (e) {
      _errorMessage = 'Failed to get product: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get product detail with full information including variants
  Future<ProductDetail?> getProductDetail(int productId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getProduct(productId);

      if (response.status == 'success') {
        return response.data;
      }

      _errorMessage = response.message;
      return null;
    } catch (e) {
      _errorMessage = 'Failed to get product detail: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search products by query
  Future<void> performSearch(String query) async {
    if (query.trim().isEmpty) {
      await clearFilters();
      return;
    }

    await searchProducts(query.trim());
  }

  /// Get products by category name
  Future<void> filterByCategoryName(String categoryName) async {
    if (categoryName == 'All') {
      await clearFilters();
      return;
    }

    // Find category ID by name
    final category =
        _apiProducts
            .map((p) => p.category)
            .where((c) => c.name == categoryName)
            .firstOrNull;

    if (category != null) {
      await filterByCategory(category.id);
    }
  }

  /// Initialize provider
  Future<void> initialize() async {
    await loadProducts();
  }
}
