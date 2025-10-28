import 'package:flutter/material.dart';
import '../../data/services/product_api_service.dart';
import '../../data/models/product_detail_response.dart';
import '../../providers/product_provider.dart';
import '../../../sales/providers/cart_provider.dart';
import '../../../sales/presentation/services/payment_service.dart';
import '../../../../data/models/product.dart';

class ProductDetailViewModel extends ChangeNotifier {
  final ProductApiService _apiService;
  CartProvider? _cartProvider;
  ProductProvider? _productProvider;
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

  // Multi-variant selection state
  // Map of variant ID to quantity
  final Map<int, int> _variantQuantities = {};

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

  // Multi-variant getters
  Map<int, int> get variantQuantities => Map.unmodifiable(_variantQuantities);

  /// Get quantity for specific variant
  int getVariantQuantity(int variantId) => _variantQuantities[variantId] ?? 0;

  /// Get total items across all variants
  int get totalSelectedItems {
    return _variantQuantities.values.fold(0, (sum, qty) => sum + qty);
  }

  /// Get total price across all selected variants
  double get totalPrice {
    if (_productDetail == null) return 0;

    double total = 0;
    _variantQuantities.forEach((variantId, quantity) {
      try {
        final variant = _productDetail!.variants.firstWhere(
          (v) => v.id == variantId,
        );
        total += variant.price * quantity;
      } catch (e) {
        // Variant not found, skip
        print('⚠️ Variant $variantId not found in totalPrice calculation');
      }
    });
    return total;
  }

  /// Get list of selected variants (quantity > 0)
  List<Map<String, dynamic>> get selectedVariants {
    if (_productDetail == null) return [];

    return _variantQuantities.entries
        .where((entry) => entry.value > 0)
        .map((entry) {
          try {
            final variant = _productDetail!.variants.firstWhere(
              (v) => v.id == entry.key,
            );
            return {'variant': variant, 'quantity': entry.value};
          } catch (e) {
            // Variant not found, return null and filter it out later
            print('⚠️ Variant ${entry.key} not found in selectedVariants');
            return null;
          }
        })
        .where((item) => item != null)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  /// Check if any variant is selected
  bool get hasSelectedVariants => totalSelectedItems > 0;

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

  /// Update ProductProvider reference
  void updateProductProvider(ProductProvider productProvider) {
    if (_productProvider != productProvider) {
      print(
        '🔄 ProductDetailViewModel: Updating ProductProvider instance ${productProvider.hashCode}',
      );
      _productProvider = productProvider;
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

        // Initialize variant quantities from cart
        _initializeVariantQuantitiesFromCart();
      } else {
        _productDetail = null;
        _isLoading = false;
        _errorMessage = response.message.isNotEmpty
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

  /// Initialize variant quantities from cart
  void _initializeVariantQuantitiesFromCart() {
    _variantQuantities.clear();

    if (_productDetail == null || (_cartProvider?.items.length ?? 0) == 0)
      return;

    // Check cart for each variant
    for (final variant in _productDetail!.variants) {
      try {
        final productInCart = _cartProvider!.items.firstWhere(
          (item) => item.product.productVariantId == variant.id,
        );
        // If found in cart, set the quantity
        _variantQuantities[variant.id] = productInCart.quantity;
      } catch (e) {
        // Variant not found in cart, skip
        continue;
      }
    }
  }

  /// Set quantity for a specific variant
  void setVariantQuantity(int variantId, int quantity) {
    if (quantity < 0) return;

    // Get the variant to check stock
    ProductVariant? variant;
    try {
      variant = _productDetail?.variants.firstWhere((v) => v.id == variantId);
    } catch (e) {
      // Variant not found
      print('⚠️ Variant with ID $variantId not found');
      return;
    }

    if (variant == null) return;

    // Calculate remaining stock
    final remainingStock = variant.stock;

    // Validate quantity against remaining stock
    int validQuantity = quantity;
    if (validQuantity > remainingStock) {
      validQuantity = remainingStock;
    }

    // Allow 0 to mark item for removal from cart
    // Store the quantity (including 0) to track removal intent
    _variantQuantities[variantId] = validQuantity;

    notifyListeners();
  }

  /// Increase quantity for a specific variant
  void increaseVariantQuantity(int variantId) {
    final currentQty = getVariantQuantity(variantId);
    setVariantQuantity(variantId, currentQty + 1);
  }

  /// Decrease quantity for a specific variant
  void decreaseVariantQuantity(int variantId) {
    final currentQty = getVariantQuantity(variantId);
    if (currentQty > 0) {
      setVariantQuantity(variantId, currentQty - 1);
    }
  }

  /// Clear all variant quantities
  void clearVariantQuantities() {
    _variantQuantities.clear();
    notifyListeners();
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
  /// Now supports multi-variant selection
  /// If quantity = 0, remove the item from cart
  Future<bool> updateCartQuantity({BuildContext? context}) async {
    try {
      if (_productDetail == null || _cartProvider == null) {
        return false;
      }

      print(
        '🛒 ProductDetailViewModel: Using CartProvider instance ${_cartProvider!.hashCode}',
      );

      // Track all variants that should be in cart (quantity > 0)
      final variantsToUpdate = <int, int>{};
      for (final entry in _variantQuantities.entries) {
        if (entry.value > 0) {
          variantsToUpdate[entry.key] = entry.value;
        }
      }

      // First, check for items to remove (quantity = 0)
      final itemsToRemove = <int>[];
      for (final entry in _variantQuantities.entries) {
        final variantId = entry.key;
        final quantity = entry.value;

        if (quantity == 0) {
          // Check if this variant exists in cart
          try {
            final existingItem = _cartProvider!.items.firstWhere(
              (item) => item.product.productVariantId == variantId,
            );
            // Mark for removal
            itemsToRemove.add(existingItem.id);
            print(
              '🗑️ ProductDetailViewModel: Marking variant $variantId for removal (quantity = 0)',
            );
          } catch (e) {
            // Item not found in cart, nothing to remove
            print(
              '⚠️ ProductDetailViewModel: Variant $variantId not found in cart for removal',
            );
          }
        }
      }

      // Remove items with quantity = 0
      for (final itemId in itemsToRemove) {
        _cartProvider!.removeItem(itemId);
        print('🗑️ ProductDetailViewModel: Removed item $itemId from cart');
      }

      // Process each selected variant (quantity > 0)
      for (final entry in variantsToUpdate.entries) {
        final variantId = entry.key;
        final quantity = entry.value;

        // Find the variant
        ProductVariant? variant;
        try {
          variant = _productDetail!.variants.firstWhere(
            (v) => v.id == variantId,
          );
        } catch (e) {
          print('⚠️ ProductDetailViewModel: Variant $variantId not found');
          continue;
        }

        // Convert ProductDetail + Variant to Product model
        final product = Product(
          id: _productDetail!.id,
          productVariantId: variant.id,
          name: '${_productDetail!.name} - ${variant.name}',
          code: variant.sku,
          description: _productDetail!.description,
          price: variant.price.toDouble(),
          stock: variant.stock,
          category: _productDetail!.category.name,
          imagePath: variant.image ?? _productDetail!.image,
          createdAt: DateTime.parse(_productDetail!.createdAt),
          updatedAt: DateTime.parse(_productDetail!.updatedAt),
        );

        // Check if this variant already exists in cart
        try {
          final existingItem = _cartProvider!.items.firstWhere(
            (item) => item.product.productVariantId == variantId,
          );
          // Update existing item quantity - set to new quantity (not add)
          // Don't pass context to prevent automatic draft transaction processing
          // We'll manually update draft transaction later
          _cartProvider!.updateItemQuantity(existingItem.id, quantity);
          print(
            '📝 ProductDetailViewModel: Updated variant $variantId quantity to $quantity',
          );
        } catch (e) {
          // Add new item to cart
          // Don't pass context to prevent automatic draft transaction processing
          // We'll manually update draft transaction later
          _cartProvider!.addItem(product, quantity: quantity);
          print(
            '➕ ProductDetailViewModel: Added variant $variantId to cart with quantity $quantity',
          );
        }
      }

      // Update draft transaction on server after cart changes
      if (context != null) {
        await _updateDraftTransactionOnServer(context);
      }

      // Clear variant quantities after successful update to prevent double-adding
      // This ensures that the next time user adds, it starts fresh
      _variantQuantities.clear();
      print(
        '🧹 ProductDetailViewModel: Cleared variant quantities after successful cart update',
      );

      // Reload product detail to refresh stock info and cart status
      await _reloadProductDetail();

      // Refresh product list in POS to update stock display
      await _refreshProductList();

      return true;
    } catch (e) {
      print('❌ Error updating cart: ${e.toString()}');
      return false;
    }
  }

  /// Refresh product list to update stock display in POS
  Future<void> _refreshProductList() async {
    try {
      if (_productProvider != null) {
        print('🔄 ProductDetailViewModel: Refreshing product list in POS');
        await _productProvider!.refreshProducts();
        print('✅ ProductDetailViewModel: Product list refreshed successfully');
      } else {
        print(
          '⚠️ ProductDetailViewModel: ProductProvider not available for refresh',
        );
      }
    } catch (e) {
      // Silent failure for refresh to not interrupt UX
      print('❌ Error refreshing product list: ${e.toString()}');
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

        // Reinitialize variant quantities from cart to show current cart state
        _initializeVariantQuantitiesFromCart();

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
