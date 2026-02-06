import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/models/product.dart';
import '../data/services/product_api_service.dart';
import '../data/models/product.dart' as ApiProduct;
import '../data/models/category.dart';

class ProductProvider extends ChangeNotifier {
  final List<Product> _products = [];
  final List<Category> _categories = [];
  final ProductApiService _apiService = ProductApiService();
  bool _isLoading = false;
  bool _isLoadingMore = false; // For pagination loading
  bool _isSearching = false; // Specific loading state for search
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = '';
  int? _selectedCategoryId; // Category ID for backend filtering
  int? _customerId; // Customer ID for pricing
  Timer? _searchDebounceTimer; // Timer for search debouncing
  int _searchSequence = 0; // Sequence number to prevent race conditions

  // Pagination state
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;

  // Search configuration
  static const int minSearchLength = 2; // Minimum characters before search
  static const int searchDebounceMs = 500; // Debounce duration in milliseconds

  // Getters
  // Products are already filtered by backend, no need for client-side filtering
  List<Product> get products => _products;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  List<String> get categories {
    // Return category names from API-loaded categories
    // Filter only active categories
    return _categories
        .where((category) => category.isActive)
        .map((category) => category.name)
        .toList();
  }

  int get totalProducts => _products.length;
  int get lowStockCount => _products.where((p) => p.stock <= 5).length;
  int? get customerId => _customerId;

  ProductProvider() {
    // Don't auto-load on initialization
    // Products will be loaded after customer is selected
  }

  /// Set customer ID for product pricing
  void setCustomerId(int? customerId) {
    if (_customerId != customerId) {
      _customerId = customerId;
      if (customerId != null) {
        // Load both categories and products when customer is set
        _loadCategoriesFromApi();
        _loadProductsFromApi();
      } else {
        _products.clear();
        _categories.clear();
        _selectedCategoryId = null;
        _selectedCategory = '';
        notifyListeners();
      }
    }
  }

  // Load products from API
  Future<void> _loadProductsFromApi({
    int? categoryId,
    String? search,
    int page = 1,
    bool append = false,
  }) async {
    if (_customerId == null) {
      _errorMessage = 'Customer ID is required to load products';
      notifyListeners();
      return;
    }

    // Set loading state
    if (append) {
      _isLoadingMore = true;
    } else {
      _isLoading = true;
      _errorMessage = null;
    }
    notifyListeners();

    try {
      // Get products from API with customer ID and optional filters
      final response = await _apiService.getProducts(
        customerId: _customerId!,
        page: page,
        perPage: 20, // Load 20 items per page for pagination
        activeOnly: true,
        categoryId:
            categoryId ??
            _selectedCategoryId, // Use parameter or current selection
        search: search ?? _searchQuery, // Add search parameter
      );

      if (response.status == 'success') {
        // Update pagination meta
        _currentPage = response.data.meta.currentPage;
        _totalPages = response.data.meta.lastPage;
        _hasMore = _currentPage < _totalPages;

        // Convert API products to local Product model
        final newProducts = response.data.data
            .map((apiProduct) => _convertApiProductToLocalProduct(apiProduct))
            .toList();

        if (append) {
          // Append to existing products
          _products.addAll(newProducts);
          _isLoadingMore = false;
        } else {
          // Replace products
          _products.clear();
          _products.addAll(newProducts);
          _isLoading = false;
        }
        notifyListeners();
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat produk: ${e.toString()}';
      if (append) {
        _isLoadingMore = false;
      } else {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  // Load categories from API
  Future<void> _loadCategoriesFromApi() async {
    try {
      // Get categories from API
      final response = await _apiService.getCategories();

      if (response.status == 'success') {
        _categories.clear();
        _categories.addAll(response.data);
        notifyListeners();
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      // Silently fail for categories - not critical
      debugPrint('⚠️ Failed to load categories: ${e.toString()}');
    }
  }

  // Convert API Product model to local Product model
  Product _convertApiProductToLocalProduct(ApiProduct.Product apiProduct) {
    return Product(
      id: apiProduct.id,
      productVariantId: apiProduct.variants.first.id,
      name: '${apiProduct.name} ${apiProduct.variants.first.name}',
      code: apiProduct.sku,
      description: apiProduct.description,
      price: apiProduct.variants.first.price,
      stock: apiProduct.variants.first.stock,
      category: apiProduct.category.name,
      imagePath: apiProduct.image,
      createdAt: apiProduct.createdAt,
      updatedAt: apiProduct.updatedAt,
    );
  }

  // Search functionality - Server-side search with debounce
  Future<void> searchProducts(String query) async {
    final trimmedQuery = query.trim();
    _searchQuery = query; // Keep original query for TextField

    // Cancel previous timer
    _searchDebounceTimer?.cancel();

    // If query is empty, clear search immediately
    if (trimmedQuery.isEmpty) {
      _isSearching = false;
      _currentPage = 1;
      notifyListeners();
      await _loadProductsFromApi(search: '', page: 1);
      return;
    }

    // If query is too short, don't search yet (just update UI)
    if (trimmedQuery.length < minSearchLength) {
      _isSearching = false;
      notifyListeners();
      return;
    }

    // Set searching state (only notify when changing state)
    if (!_isSearching) {
      _isSearching = true;
      notifyListeners();
    }

    // Set debounce timer
    _searchDebounceTimer = Timer(
      const Duration(milliseconds: searchDebounceMs),
      () async {
        // Increment sequence to track this search
        _searchSequence++;
        final currentSequence = _searchSequence;

        _currentPage = 1;
        await _performSearch(trimmedQuery, currentSequence);
      },
    );
  }

  // Perform actual search with race condition prevention
  Future<void> _performSearch(String query, int sequence) async {
    try {
      await _loadProductsFromApi(search: query, page: 1);

      // Only update state if this is still the latest search
      if (sequence == _searchSequence) {
        _isSearching = false;
        notifyListeners();
      }
    } catch (e) {
      // Only update error if this is still the latest search
      if (sequence == _searchSequence) {
        _isSearching = false;
        notifyListeners();
      }
      rethrow;
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _selectedCategory = '';
    _selectedCategoryId = null;
    _currentPage = 1; // Reset pagination
    _isSearching = false;
    _searchDebounceTimer?.cancel(); // Cancel pending search
    _searchSequence++; // Invalidate any in-flight searches

    notifyListeners();
    // Reload all products without filters
    _loadProductsFromApi(search: '', page: 1);
  }

  // Category filter - Server-side filtering
  Future<void> filterByCategory(String categoryName) async {
    // Toggle behavior: Jika kategori yang sama diklik lagi, unselect (kosongkan filter)
    if (_selectedCategory == categoryName) {
      // Clear filter - load all products
      _selectedCategory = '';
      _selectedCategoryId = null;
      _currentPage = 1; // Reset pagination
      await _loadProductsFromApi(
        categoryId: null,
        search: _searchQuery, // Maintain search query
        page: 1,
      );
    } else {
      // Set filter - find category ID and reload with filter
      _selectedCategory = categoryName;

      // Find category ID by name from loaded categories
      final category = _categories.firstWhere(
        (cat) => cat.name == categoryName,
        orElse: () => Category(
          id: 0,
          name: '',
          description: '',
          isActive: false,
          createdAt: '',
          updatedAt: '',
        ),
      );

      if (category.id != 0) {
        _selectedCategoryId = category.id;
        _currentPage = 1; // Reset pagination
        await _loadProductsFromApi(
          categoryId: category.id,
          search: _searchQuery, // Maintain search query
          page: 1,
        );
      }
    }
  }

  // Add new product
  Future<bool> addProduct(Product product) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Check if product code already exists
      if (_products.any((p) => p.code == product.code)) {
        _errorMessage = 'Product code already exists';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _products.add(product);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add product: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update product
  Future<bool> updateProduct(Product updatedProduct) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final index = _products.indexWhere((p) => p.id == updatedProduct.id);
      if (index == -1) {
        _errorMessage = 'Product not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check if product code already exists (excluding current product)
      if (_products.any(
        (p) => p.code == updatedProduct.code && p.id != updatedProduct.id,
      )) {
        _errorMessage = 'Product code already exists';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _products[index] = updatedProduct;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update product: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete product
  Future<bool> deleteProduct(String productId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final index = _products.indexWhere((p) => p.id == productId);
      if (index == -1) {
        _errorMessage = 'Product not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _products.removeAt(index);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete product: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update stock
  Future<bool> updateStock(String productId, int newStock) async {
    try {
      final product = _products.firstWhere((p) => p.id == productId);
      final updatedProduct = product.copyWith(
        stock: newStock,
        updatedAt: DateTime.now(),
      );
      return await updateProduct(updatedProduct);
    } catch (e) {
      _errorMessage = 'Product not found';
      notifyListeners();
      return false;
    }
  }

  // Get product by ID
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get products by category
  List<Product> getProductsByCategory(String category) {
    if (category == 'Semua') return _products;
    return _products.where((product) => product.category == category).toList();
  }

  // Get low stock products
  List<Product> getLowStockProducts() {
    return _products.where((product) => product.stock <= 5).toList();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Retry loading products from API
  Future<void> retryLoadProducts() async {
    _currentPage = 1; // Reset pagination
    await _loadProductsFromApi(page: 1);
  }

  // Refresh products
  Future<void> refreshProducts() async {
    _currentPage = 1; // Reset pagination
    await _loadProductsFromApi(page: 1);
  }

  // Load more products for infinite scroll
  Future<void> loadMoreProducts() async {
    if (_isLoadingMore || !_hasMore) {
      return; // Don't load if already loading or no more data
    }

    final nextPage = _currentPage + 1;
    await _loadProductsFromApi(
      categoryId: _selectedCategoryId,
      search: _searchQuery, // Maintain search query
      page: nextPage,
      append: true,
    );
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    super.dispose();
  }
}
