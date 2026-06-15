import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/models/product.dart';
import '../data/services/product_api_service.dart';
import '../data/models/product.dart' as api_product;
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
  int _loadSequence =
      0; // Token untuk drop respons stale di _loadProductsFromApi

  // Pagination state
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;

  // Search configuration
  static const int minSearchLength = 2; // Minimum characters before search
  static const int searchDebounceMs = 500; // Debounce duration in milliseconds

  // Jumlah item per halaman untuk pagination produk. Dipakai konsisten di
  // load awal, loadMore, dan silent refresh.
  static const int _pageSize = 20;
  int _totalLoadedPageSize = 0;

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
  int get lowStockCount => _products.where((p) => p.stock <= p.minStock).length;
  int? get customerId => _customerId;

  ProductProvider() {
    // Don't auto-load on initialization
    // Products will be loaded after customer is selected
  }

  /// Set customer ID for product pricing.
  /// customerId boleh null — produk tetap dimuat (harga base).
  void setCustomerId(int? customerId) {
    if (_customerId != customerId) {
      _customerId = customerId;
      // Muat kategori & produk untuk customerId apa pun (termasuk null).
      _loadCategoriesFromApi();
      _loadProductsFromApi();
    }
  }

  /// Muat produk dengan customerId saat ini (boleh null → tanpa pricing
  /// khusus). Dipakai untuk memastikan grid terisi walau belum ada customer.
  Future<void> loadProducts() async {
    _currentPage = 1;
    _totalLoadedPageSize = 0;
    if (_categories.isEmpty) {
      _loadCategoriesFromApi();
    }
    await _loadProductsFromApi(page: 1);
  }

  // Load products from API
  Future<void> _loadProductsFromApi({
    int? categoryId,
    String? search,
    int page = 1,
    int perPage = 20,
    bool append = false,
  }) async {
    // customerId opsional: produk tetap dimuat tanpa customer (harga base).

    // Increment sequence untuk full-replace load. Append ikut sequence
    // yang sama supaya bila ada full-replace baru di tengah-tengah,
    // append yang stale ikut di-drop.
    _loadSequence++;
    final mySequence = _loadSequence;

    // Set loading state
    if (append) {
      _isLoadingMore = true;
    } else {
      _isLoading = true;
      // Reset flag append yang mungkin nyangkut dari respons stale yang
      // di-drop tanpa sempat reset flag-nya sendiri.
      _isLoadingMore = false;
      _errorMessage = null;
    }
    notifyListeners();

    try {
      // Get products from API with customer ID and optional filters
      final response = await _apiService.getProducts(
        customerId: _customerId,
        page: page,
        perPage: perPage, // Load items per page for pagination
        activeOnly: true,
        categoryId:
            categoryId ??
            _selectedCategoryId, // Use parameter or current selection
        search: search ?? _searchQuery, // Add search parameter
      );

      // Drop respons yang sudah kadaluarsa (ada load lebih baru terjadi
      // sebelum respons ini tiba). Tanpa guard ini, respons lambat dari
      // load awal bisa override hasil search yang sudah datang duluan.
      if (mySequence != _loadSequence) {
        return;
      }

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

        _totalLoadedPageSize = _products.isEmpty ? _pageSize : _products.length;

        notifyListeners();
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      // Stale error juga di-drop supaya tidak menimpa state load yang lebih baru.
      if (mySequence != _loadSequence) {
        return;
      }
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
  Product _convertApiProductToLocalProduct(api_product.Product apiProduct) {
    final firstVariant = apiProduct.variants.first;
    return Product(
      id: apiProduct.id,
      productVariantId: firstVariant.id,
      name: '${apiProduct.name} ${firstVariant.name}',
      code: apiProduct.sku,
      description: apiProduct.description,
      // Pakai finalPrice supaya harga sesuai customer group (dari pricing_info).
      // Fallback ke base price kalau pricing_info tidak ada.
      price: firstVariant.finalPrice,
      stock: firstVariant.stock,
      minStock: firstVariant.minStock,
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
    _totalLoadedPageSize = 0;

    notifyListeners();
    // Reload all products without filters
    _loadProductsFromApi(search: '', page: 1);
  }

  /// Reset filter pencarian & kategori lalu reload produk dari API tanpa
  /// filter. Versi awaitable dari [clearSearch] untuk dipakai pada alur
  /// resume pending transaction supaya pemanggil bisa menunggu data
  /// produk siap sebelum mengisi cart / navigasi.
  Future<void> resetFilters() async {
    _searchQuery = '';
    _selectedCategory = '';
    _selectedCategoryId = null;
    _currentPage = 1;
    _isSearching = false;
    _searchDebounceTimer?.cancel();
    _searchSequence++;
    _totalLoadedPageSize = 0;

    notifyListeners();

    await _loadProductsFromApi(search: '', page: 1);
  }

  // Category filter - Server-side filtering
  Future<void> filterByCategory(String categoryName) async {
    // Toggle behavior: Jika kategori yang sama diklik lagi, unselect (kosongkan filter)
    if (_selectedCategory == categoryName) {
      // Clear filter - load all products
      _selectedCategory = '';
      _selectedCategoryId = null;
      _currentPage = 1; // Reset pagination
      _totalLoadedPageSize = 0;
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

  // Get products by category
  List<Product> getProductsByCategory(String category) {
    if (category == 'Semua') return _products;
    return _products.where((product) => product.category == category).toList();
  }

  // Get low stock products
  List<Product> getLowStockProducts() {
    return _products
        .where((product) => product.stock <= product.minStock)
        .toList();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Retry loading products from API
  Future<void> retryLoadProducts() async {
    _currentPage = 1; // Reset pagination
    await _loadProductsFromApi(
      page: 1,
      perPage: _totalLoadedPageSize > 0 ? _totalLoadedPageSize : _pageSize,
    );
  }

  // Refresh products
  Future<void> refreshProducts() async {
    _currentPage = 1; // Reset pagination
    await _loadProductsFromApi(
      page: 1,
      perPage: _totalLoadedPageSize > 0 ? _totalLoadedPageSize : _pageSize,
    );
  }

  /// Refresh produk di latar belakang TANPA mengubah jumlah item yang sudah
  /// tampil. Memuat ulang semua produk yang sedang ditampilkan dalam SATU
  /// panggilan (`page=1`, `per_page = _pageSize * currentPage`), lalu mengganti
  /// list sekaligus — panjang list (dan posisi scroll user) tetap terjaga.
  ///
  /// Dipakai untuk refresh otomatis (periodik, kembali dari halaman lain, app
  /// resume). Pull-to-refresh tetap memakai [refreshProducts] (reset ke page 1).
  Future<void> silentRefreshProducts() async {
    // Jangan bentrok dengan load primary / pagination / search yang berjalan.
    if (_isLoading || _isLoadingMore || _isSearching) return;

    // Muat ulang persis sebanyak item yang SEDANG tampil — bukan
    // _pageSize * currentPage (yang mengasumsikan tiap halaman penuh &
    // per-page = _pageSize default). _products.length selalu akurat.
    final refreshSize = _products.isEmpty ? _pageSize : _products.length;

    // Ikut sequence full-replace supaya load lain yang lebih baru bisa
    // membatalkan refresh ini (dan sebaliknya).
    _loadSequence++;
    final mySequence = _loadSequence;

    try {
      final response = await _apiService.getProducts(
        customerId: _customerId,
        page: 1,
        perPage: refreshSize, // muat ulang semua item yang sedang tampil
        activeOnly: true,
        categoryId: _selectedCategoryId,
        search: _searchQuery,
      );

      // Ada load lebih baru → buang hasil refresh ini.
      if (mySequence != _loadSequence) return;
      if (response.status != 'success') return; // background: diamkan

      final refreshed = response.data.data
          .map(_convertApiProductToLocalProduct)
          .toList();
      final total = response.data.meta.total;

      _products
        ..clear()
        ..addAll(refreshed);

      // Hitung ulang state pagination dalam satuan halaman _pageSize (bukan
      // satuan refreshSize dari respons), supaya loadMore berikutnya tetap
      // mengambil halaman yang benar.
      _currentPage = (_products.length / _pageSize).ceil().clamp(1, 1 << 30);
      _totalPages = (total / _pageSize).ceil().clamp(1, 1 << 30);
      _hasMore = _products.length < total;
      notifyListeners();
    } catch (e) {
      // Refresh latar belakang: jangan ganggu UI dengan pesan error.
      debugPrint('⚠️ silentRefreshProducts gagal: $e');
    }
  }

  // Load more products for infinite scroll
  Future<void> loadMoreProducts() async {
    // Jangan paginate saat load primary (search/filter/refresh) sedang
    // berjalan — hasil append akan di-drop oleh guard sequence di
    // _loadProductsFromApi dan respons utama akan reset list-nya.
    if (_isLoadingMore || !_hasMore || _isLoading || _isSearching) {
      return;
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
