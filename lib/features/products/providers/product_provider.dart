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
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = '';
  int? _selectedCategoryId; // Category ID for backend filtering
  int? _customerId; // Customer ID for pricing

  // Getters
  // Products are already filtered by backend, no need for client-side filtering
  List<Product> get products => _products;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

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
  Future<void> _loadProductsFromApi({int? categoryId}) async {
    if (_customerId == null) {
      _errorMessage = 'Customer ID is required to load products';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get products from API with customer ID and optional category filter
      final response = await _apiService.getProducts(
        customerId: _customerId!,
        perPage: 100, // Load more products for POS
        activeOnly: true,
        categoryId:
            categoryId ??
            _selectedCategoryId, // Use parameter or current selection
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

  // Search functionality
  void searchProducts(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _selectedCategory = '';
    _selectedCategoryId = null;
    // Reload all products without filters
    _loadProductsFromApi();
  }

  // Category filter - Server-side filtering
  Future<void> filterByCategory(String categoryName) async {
    // Toggle behavior: Jika kategori yang sama diklik lagi, unselect (kosongkan filter)
    if (_selectedCategory == categoryName) {
      // Clear filter - load all products
      _selectedCategory = '';
      _selectedCategoryId = null;
      await _loadProductsFromApi(categoryId: null);
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
        await _loadProductsFromApi(categoryId: category.id);
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
    await _loadProductsFromApi();
  }

  // Refresh products
  Future<void> refreshProducts() async {
    await _loadProductsFromApi();
  }
}
