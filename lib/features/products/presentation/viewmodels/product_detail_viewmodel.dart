import 'package:flutter/material.dart';
import '../../data/services/product_api_service.dart';
import '../../data/models/product_detail_response.dart';
import '../../../sales/providers/cart_provider.dart';
import '../../../sales/presentation/services/payment_service.dart';
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

  /// Get remaining stock considering current cart quantity
  int get remainingStock {
    final productInCart = _cartProvider?.getItemByProductId(_productId);
    final quantityInCart = productInCart?.quantity ?? 0;
    return maxStock - quantityInCart;
  }

  /// Get current quantity in cart
  int get quantityInCart {
    final productInCart = _cartProvider?.getItemByProductId(_productId);
    return productInCart?.quantity ?? 0;
  }

  /// Check if product is currently in cart
  bool get isInCart {
    return _cartProvider?.isProductInCart(_productId) ?? false;
  }

  /// Update method yang dipanggil oleh ChangeNotifierProxyProvider
  /// Sesuai dengan dokumentasi: reuse instance dan update properties
  void updateCartProvider(CartProvider cartProvider) {
    if (_cartProvider != cartProvider) {
      print(
        '🔄 ProductDetailViewModel: Updating CartProvider instance ${cartProvider.hashCode}',
      );
      _cartProvider = cartProvider;

      // Reinitialize quantity based on updated cart provider
      if (_productDetail != null) {
        _initializeQuantityFromCart();
        notifyListeners();
      }
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

        // Initialize quantity controller with existing cart quantity + 1 as default addition
        _initializeQuantityFromCart();
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

  /// Initialize quantity controller based on existing cart quantity
  void _initializeQuantityFromCart() {
    if (_cartProvider == null) {
      _quantity = 1;
      _quantityController.text = '1';
      return;
    }

    // Get current quantity of this product in cart
    final quantityInCart = this.quantityInCart;

    // Set initial quantity based on cart status
    if (quantityInCart > 0) {
      // If product already in cart, show current cart quantity
      _quantity = quantityInCart;
    } else {
      // If product not in cart, default to 1 (minimum purchase)
      _quantity = 1;
    }

    _quantityController.text = _quantity.toString();
  }

  void selectVariant(int index) {
    if (_productDetail?.variants.isNotEmpty == true &&
        index >= 0 &&
        index < _productDetail!.variants.length) {
      _selectedVariantIndex = index;
      _initializeQuantityFromCart(); // Use cart-aware initialization instead of just reset
      notifyListeners();
    }
  }

  void onQuantityChanged(String value) {
    if (value.isEmpty) return;

    final newQuantity = int.tryParse(value);
    if (newQuantity == null) return;

    // Get remaining stock
    final remaining = remainingStock;

    // Validate quantity range against remaining stock
    int validQuantity = newQuantity;
    if (validQuantity < 0) {
      validQuantity = 0;
    } else if (validQuantity > remaining) {
      validQuantity = remaining;
    }

    // Only allow 0 if product is in cart (for removal purpose)
    if (validQuantity == 0 && !isInCart) {
      validQuantity = 1;
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
    if (_quantity < remainingStock) {
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
    } else if (_quantity == 1 && isInCart) {
      // Allow quantity to go to 0 only if product is in cart (for removal)
      _quantity = 0;
      _quantityController.text = _quantity.toString();
      notifyListeners();
    }
  }

  /// Remove product from cart completely
  Future<bool> removeFromCart({BuildContext? context}) async {
    try {
      if (_cartProvider == null) return false;

      final productInCart = _cartProvider!.getItemByProductId(_productId);
      if (productInCart != null) {
        _cartProvider!.removeItem(productInCart.id);

        // Set quantity to 1 after removal for potential re-add
        _quantity = 1;
        _quantityController.text = _quantity.toString();
        notifyListeners();

        print(
          '🗑️ ProductDetailViewModel: Removed product $_productId from cart',
        );

        // Update draft transaction on server after removing from cart
        if (context != null) {
          await _updateDraftTransactionOnServer(context);
        }

        // Reload product detail to refresh stock info and cart status
        await _reloadProductDetail();

        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error removing product from cart: ${e.toString()}');
      return false;
    }
  }

  /// Update cart with current quantity (add or update existing)
  Future<bool> updateCartQuantity({BuildContext? context}) async {
    try {
      if (_productDetail == null ||
          selectedVariant == null ||
          _cartProvider == null) {
        return false;
      }

      // If quantity is 0, remove from cart
      if (_quantity == 0) {
        return await removeFromCart(context: context);
      }

      print(
        '🛒 ProductDetailViewModel: Using CartProvider instance ${_cartProvider!.hashCode}',
      );

      // Convert ProductDetail to Product model that CartProvider expects
      final product = Product(
        id: _productDetail!.id,
        productVariantId: _productDetail!.variants.first.id,
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

      // Check if product already exists in cart
      final existingItem = _cartProvider!.getItemByProductId(_productId);

      if (existingItem != null) {
        // Update existing item quantity
        _cartProvider!.updateItemQuantity(existingItem.id, _quantity);
        print('📝 ProductDetailViewModel: Updated cart quantity to $_quantity');
      } else {
        // Add new item to cart
        _cartProvider!.addItem(product, quantity: _quantity);
        print(
          '➕ ProductDetailViewModel: Added new item to cart with quantity $_quantity',
        );
      }

      // Update draft transaction on server after cart changes
      if (context != null) {
        await _updateDraftTransactionOnServer(context);
      }

      // Reload product detail to refresh stock info and cart status
      await _reloadProductDetail();

      return true;
    } catch (e) {
      print('❌ Error updating cart: ${e.toString()}');
      return false;
    }
  }

  /// Update draft transaction on server after cart changes
  Future<void> _updateDraftTransactionOnServer(BuildContext context) async {
    try {
      // Only proceed if we have a cart provider
      if (_cartProvider == null) return;

      // Use PaymentService to update draft transaction on server
      await PaymentService.processDraftTransaction(
        context: context,
        cartProvider: _cartProvider!,
      );

      print('📡 ProductDetailViewModel: Draft transaction updated on server');
    } catch (e) {
      // Silent failure for draft transaction updates to not interrupt UX
      print('Failed to update draft transaction on server: ${e.toString()}');
    }
  }

  /// Reload product detail data to refresh stock info and cart status
  /// This method doesn't show loading indicator to avoid UI flickering
  Future<void> _reloadProductDetail() async {
    try {
      print('🔄 ProductDetailViewModel: Reloading product detail data');

      final response = await _apiService.getProduct(_productId);

      if (response.status == 'success') {
        _productDetail = response.data;

        // Reinitialize quantity from cart after reload
        _initializeQuantityFromCart();

        print('✅ ProductDetailViewModel: Product detail reloaded successfully');
      } else {
        print('⚠️ ProductDetailViewModel: Failed to reload product detail');
      }

      notifyListeners();
    } catch (e) {
      // Silent failure for reload to not interrupt UX
      print('❌ Error reloading product detail: ${e.toString()}');
    }
  }

  Future<bool> addToCart({BuildContext? context}) async {
    // Use the new updateCartQuantity method for consistency
    return await updateCartQuantity(context: context);
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
