import 'package:flutter/material.dart';
import '../../../data/models/product.dart';
import '../data/services/product_api_service.dart';
import '../data/models/product.dart' as ApiProduct;

class ProductProvider extends ChangeNotifier {
  final List<Product> _products = [];
  final ProductApiService _apiService = ProductApiService();
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = '';
  int? _customerId; // Customer ID for pricing

  // Getters
  List<Product> get products =>
      _searchQuery.isEmpty && _selectedCategory.isEmpty
      ? _products
      : _filteredProducts;

  List<Product> get _filteredProducts {
    List<Product> filtered = _products;

    // Filter by category
    if (_selectedCategory.isNotEmpty) {
      filtered = filtered
          .where((product) => product.category == _selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (product) =>
                product.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                product.code.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                product.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    return filtered;
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  List<String> get categories {
    final Set<String> categorySet = <String>{};
    for (final product in _products) {
      categorySet.add(product.category);
    }
    return categorySet.toList();
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
        _loadProductsFromApi();
      } else {
        _products.clear();
        notifyListeners();
      }
    }
  }

  // Load products from API
  Future<void> _loadProductsFromApi() async {
    if (_customerId == null) {
      _errorMessage = 'Customer ID is required to load products';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get products from API with customer ID
      final response = await _apiService.getProducts(
        customerId: _customerId!,
        perPage: 100, // Load more products for POS
        activeOnly: true,
      );

      if (response.status == 'success') {
        // Convert API products to local Product model
        _products.clear();
        _products.addAll(
          response.data.data.map(
            (apiProduct) => _convertApiProductToLocalProduct(apiProduct),
          ),
        );
        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat produk: ${e.toString()}';
      _isLoading = false;
      // Fallback to dummy data if API fails
      // _loadDummyProducts();
      notifyListeners();
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

  // Search functionality
  void searchProducts(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _selectedCategory = '';
    notifyListeners();
  }

  // Category filter
  void filterByCategory(String category) {
    // Jika kategori yang dipilih sama dengan yang sudah terpilih, unselect (kosongkan filter)
    if (_selectedCategory == category) {
      _selectedCategory = '';
    } else {
      _selectedCategory = category;
    }
    notifyListeners();
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
    await _loadProductsFromApi();
  }

  // Refresh products
  Future<void> refreshProducts() async {
    await _loadProductsFromApi();
  }
}
