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

  // Getters
  List<Product> get products =>
      _searchQuery.isEmpty && _selectedCategory.isEmpty
          ? _products
          : _filteredProducts;

  List<Product> get _filteredProducts {
    List<Product> filtered = _products;

    // Filter by category
    if (_selectedCategory.isNotEmpty) {
      filtered =
          filtered
              .where((product) => product.category == _selectedCategory)
              .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered
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

  ProductProvider() {
    _loadProductsFromApi();
  }

  // Load products from API
  Future<void> _loadProductsFromApi() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get products from API
      final response = await _apiService.getProducts(
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
      _loadDummyProducts();
      notifyListeners();
    }
  }

  // Convert API Product model to local Product model
  Product _convertApiProductToLocalProduct(ApiProduct.Product apiProduct) {
    return Product(
      id: apiProduct.id,
      name: apiProduct.name,
      code: apiProduct.sku,
      description: apiProduct.description,
      price: _getEstimatedPrice(
        apiProduct,
      ), // Since API doesn't have price, we estimate
      stock: _getEstimatedStock(
        apiProduct,
      ), // Since API doesn't have stock, we estimate
      category: apiProduct.category.name,
      imagePath: apiProduct.image,
      createdAt: DateTime.tryParse(apiProduct.createdAt) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(apiProduct.updatedAt) ?? DateTime.now(),
    );
  }

  // Estimate price based on category (since API doesn't provide price)
  double _getEstimatedPrice(ApiProduct.Product apiProduct) {
    final category = apiProduct.category.name.toLowerCase();
    if (category.contains('minuman') || category.contains('drink')) {
      return 15000.0 + (apiProduct.id % 10) * 5000.0; // 15k-60k
    } else if (category.contains('makanan') || category.contains('food')) {
      return 25000.0 + (apiProduct.id % 15) * 3000.0; // 25k-70k
    } else if (category.contains('snack')) {
      return 8000.0 + (apiProduct.id % 8) * 2000.0; // 8k-24k
    } else {
      return 20000.0 + (apiProduct.id % 12) * 4000.0; // 20k-68k
    }
  }

  // Estimate stock (since API doesn't provide current stock)
  int _getEstimatedStock(ApiProduct.Product apiProduct) {
    // Use min_stock as base and add some random variation
    final baseStock = apiProduct.minStock > 0 ? apiProduct.minStock : 10;
    return baseStock + (apiProduct.id % 20) + 5; // Add 5-24 to min stock
  }

  // Load dummy products as fallback
  void _loadDummyProducts() {
    _isLoading = true;
    notifyListeners();

    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _products.addAll(_generateDummyProducts());
      _isLoading = false;
      notifyListeners();
    });
  }

  List<Product> _generateDummyProducts() {
    final now = DateTime.now();
    return [
      Product(
        id: 1,
        name: 'Kopi Arabica Premium',
        code: 'KAP001',
        description: 'Kopi arabica berkualitas premium dari pegunungan Jawa',
        price: 45000,
        stock: 25,
        category: 'Minuman',
        imagePath: 'assets/images/kopi_arabica.jpg',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
      ),
      Product(
        id: 2,
        name: 'Teh Hijau Organik',
        code: 'THO002',
        description: 'Teh hijau organik tanpa pestisida',
        price: 35000,
        stock: 15,
        category: 'Minuman',
        imagePath: 'assets/images/teh_hijau.jpg',
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now,
      ),
      Product(
        id: 3,
        name: 'Croissant Butter',
        code: 'CB003',
        description: 'Croissant segar dengan butter berkualitas tinggi',
        price: 25000,
        stock: 8,
        category: 'Pastry',
        imagePath: 'assets/images/croissant.jpg',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now,
      ),
      Product(
        id: 4,
        name: 'Donut Glazed',
        code: 'DG004',
        description: 'Donut lembut dengan glazed manis',
        price: 18000,
        stock: 12,
        category: 'Pastry',
        imagePath: 'assets/images/donut.jpg',
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now,
      ),
      Product(
        id: 5,
        name: 'Sandwich Club',
        code: 'SC005',
        description: 'Sandwich dengan isian lengkap dan segar',
        price: 42000,
        stock: 6,
        category: 'Makanan',
        imagePath: 'assets/images/sandwich.jpg',
        createdAt: now.subtract(const Duration(days: 12)),
        updatedAt: now,
      ),
      Product(
        id: 6,
        name: 'Salad Caesar',
        code: 'SAL006',
        description: 'Salad segar dengan dressing caesar',
        price: 38000,
        stock: 10,
        category: 'Makanan',
        imagePath: 'assets/images/salad.jpg',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now,
      ),
      Product(
        id: 7,
        name: 'Jus Jeruk Segar',
        code: 'JJS007',
        description: 'Jus jeruk segar tanpa pengawet',
        price: 22000,
        stock: 20,
        category: 'Minuman',
        imagePath: 'assets/images/jus_jeruk.jpg',
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now,
      ),
      Product(
        id: 8,
        name: 'Muffin Blueberry',
        code: 'MB008',
        description: 'Muffin lembut dengan blueberry segar',
        price: 28000,
        stock: 5,
        category: 'Pastry',
        imagePath: 'assets/images/muffin.jpg',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now,
      ),
      Product(
        id: 9,
        name: 'Pasta Carbonara',
        code: 'PC009',
        description: 'Pasta carbonara dengan cream sauce',
        price: 55000,
        stock: 7,
        category: 'Makanan',
        imagePath: 'assets/images/pasta.jpg',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now,
      ),
      Product(
        id: 10,
        name: 'Cappuccino',
        code: 'CAP010',
        description: 'Cappuccino dengan foam art',
        price: 32000,
        stock: 18,
        category: 'Minuman',
        imagePath: 'assets/images/cappuccino.jpg',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
      ),
    ];
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
