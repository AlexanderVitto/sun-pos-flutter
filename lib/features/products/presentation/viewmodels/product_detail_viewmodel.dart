import 'package:flutter/material.dart';
import '../../data/services/product_api_service.dart';
import '../../data/models/product_detail_response.dart';
import '../../../sales/providers/cart_provider.dart';
import '../../../../data/models/product.dart';

class ProductDetailViewModel extends ChangeNotifier {
  final ProductApiService _apiService;
  CartProvider? _cartProvider;
  int _productId;
  bool _disposed = false;

  ProductDetailViewModel({
    required int productId,
    required ProductApiService apiService,
  }) : _productId = productId,
       _apiService = apiService {
    _quantityController = TextEditingController(text: _quantity.toString());
    loadProductDetail();
  }

  // State
  ProductDetail? _productDetail;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedVariantIndex = 0;
  int _quantity = 1;
  late TextEditingController _quantityController;

  // Getters
  ProductDetail? get productDetail => _productDetail;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get selectedVariantIndex => _selectedVariantIndex;
  int get quantity => _quantity;
  TextEditingController get quantityController => _quantityController;
  CartProvider? get cartProvider => _cartProvider;
  int get productId => _productId;

  ProductVariant? get selectedVariant {
    if (_productDetail?.variants.isNotEmpty == true) {
      return _productDetail!.variants[_selectedVariantIndex];
    }
    return null;
  }

  int get maxStock => selectedVariant?.stock ?? 0;
  double get subtotal => (selectedVariant?.price ?? 0) * _quantity;
  bool get isAvailable => maxStock > 0;

  /// Update method yang dipanggil oleh ChangeNotifierProxyProvider
  /// Sesuai dengan dokumentasi: reuse instance dan update properties
  void updateCartProvider(CartProvider cartProvider) {
    if (_cartProvider != cartProvider) {
      print(
        '🔄 ProductDetailViewModel: Updating CartProvider instance ${cartProvider.hashCode}',
      );
      _cartProvider = cartProvider;
      // Tidak perlu notifyListeners() karena CartProvider changes tidak mempengaruhi UI langsung
    }
  }

  /// Update productId jika dibutuhkan (untuk reuse ViewModel dengan product berbeda)
  void updateProductId(int newProductId) {
    if (_productId != newProductId) {
      _productId = newProductId;
      // Reset state untuk product baru
      _productDetail = null;
      _isLoading = true;
      _errorMessage = null;
      _selectedVariantIndex = 0;
      _quantity = 1;
      _quantityController.text = _quantity.toString();
      loadProductDetail();
    }
  }

  // Methods
  Future<void> loadProductDetail() async {
    try {
      _setLoading(true);
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.getProduct(_productId);

      if (response.status == 'success') {
        _productDetail = response.data;
        _isLoading = false;
        _errorMessage = null;
      } else {
        _productDetail = null;
        _isLoading = false;
        _errorMessage =
            response.message.isNotEmpty
                ? response.message
                : 'Failed to load product details';
      }
    } catch (e) {
      _productDetail = null;
      _isLoading = false;
      _errorMessage = 'Error: ${e.toString()}';
    }
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
  }

  void selectVariant(int index) {
    if (_productDetail?.variants.isNotEmpty == true &&
        index >= 0 &&
        index < _productDetail!.variants.length) {
      _selectedVariantIndex = index;
      _resetQuantity(); // Reset quantity when variant changes
      notifyListeners();
    }
  }

  void _resetQuantity() {
    _quantity = 1;
    _quantityController.text = _quantity.toString();
  }

  void onQuantityChanged(String value) {
    if (value.isEmpty) return;

    final newQuantity = int.tryParse(value);
    if (newQuantity == null) return;

    // Validate quantity range
    int validQuantity = newQuantity;
    if (validQuantity < 1) {
      validQuantity = 1;
    } else if (validQuantity > maxStock) {
      validQuantity = maxStock;
    }

    _quantity = validQuantity;

    // Update controller if the value was corrected
    if (validQuantity != newQuantity) {
      _quantityController.text = validQuantity.toString();
      _quantityController.selection = TextSelection.fromPosition(
        TextPosition(offset: _quantityController.text.length),
      );
    }
    notifyListeners();
  }

  void increaseQuantity() {
    if (_quantity < maxStock) {
      _quantity++;
      _quantityController.text = _quantity.toString();
      notifyListeners();
    }
  }

  void decreaseQuantity() {
    if (_quantity > 1) {
      _quantity--;
      _quantityController.text = _quantity.toString();
      notifyListeners();
    }
  }

  Future<bool> addToCart() async {
    try {
      if (_productDetail == null ||
          selectedVariant == null ||
          _cartProvider == null) {
        return false;
      }

      print(
        '🛒 ProductDetailViewModel: Using CartProvider instance ${_cartProvider!.hashCode}',
      );

      // Convert ProductDetail to Product model that CartProvider expects
      final product = Product(
        id: _productDetail!.id,
        name: _productDetail!.name,
        code: _productDetail!.sku,
        description: _productDetail!.description,
        price: selectedVariant!.price.toDouble(),
        stock: selectedVariant!.stock,
        category: _productDetail!.category.name,
        imagePath: _productDetail!.image,
        createdAt: DateTime.parse(_productDetail!.createdAt),
        updatedAt: DateTime.parse(_productDetail!.updatedAt),
      );

      // Add to cart with specified quantity
      _cartProvider!.addItem(product, quantity: _quantity);

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    if (!_disposed) {
      _disposed = true;
      _quantityController.dispose();
      super.dispose();
    }
  }
}
