import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/product.dart';
import '../../../data/models/cart_item.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/sale.dart';
import '../../customers/data/models/customer.dart' as api_customer;
import '../../auth/data/models/user.dart';
import '../presentation/services/payment_service.dart';
import '../../products/providers/product_provider.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  final Uuid _uuid = const Uuid();
  Customer? _selectedCustomer;
  double _discountAmount = 0.0;
  bool _isProcessing = false;
  String? _errorMessage;
  String? _customerName;
  String? _customerPhone;
  User? _currentUser;
  int? _draftTransactionId; // ✅ Added to track draft transaction ID
  int _itemIdCounter = 1; // ✅ Added counter for unique IDs
  Timer? _refreshTimer; // ✅ Timer for debounced product refresh
  Map<int, int> _initialQuantities =
      {}; // ✅ Store initial quantities per product ID
  bool _hasUserAction = false; // ✅ Track if user has made any cart action

  // Getters
  List<CartItem> get items => List.unmodifiable(_items);
  Customer? get selectedCustomer => _selectedCustomer;
  double get discountAmount => _discountAmount;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  String? get customerName => _customerName;
  String? get customerPhone => _customerPhone;
  User? get currentUser => _currentUser;
  int? get draftTransactionId => _draftTransactionId; // ✅ Added getter
  Map<int, int> get initialQuantities =>
      Map.unmodifiable(_initialQuantities); // ✅ Getter for initial quantities
  bool get hasUserAction => _hasUserAction; // ✅ Getter for user action flag

  int get itemCount => _items.fold(
    0,
    (sum, item) => sum + item.quantity,
  ); // ✅ Total quantity instead of unique items count
  int get uniqueItemsCount =>
      _items.length; // ✅ Added for unique items count if needed
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  // Calculate totals
  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.subtotal);
  // double get total => subtotal + taxAmount - _discountAmount;
  double get total => subtotal;

  // Add item to cart
  void addItem(Product product, {int quantity = 1, BuildContext? context}) {
    debugPrint('🛒 CartProvider: Adding item ${product.name} x $quantity');
    debugPrint('🛒 CartProvider instance: $hashCode');
    debugPrint('🛒 Current items before add: ${_items.length}');

    if (quantity <= 0) return;

    // Check if product already exists in cart
    final existingIndex = _items.indexWhere(
      (item) => item.product.productVariantId == product.productVariantId,
    );

    if (existingIndex >= 0) {
      // Update quantity of existing item
      final existingItem = _items[existingIndex];
      final newQuantity = existingItem.quantity + quantity;

      // Check stock availability
      if (newQuantity > product.stock && context != null) {
        _errorMessage = 'Not enough stock. Available: ${product.stock}';
        notifyListeners();
        return;
      }

      _items[existingIndex] = existingItem.copyWith(quantity: newQuantity);
      debugPrint('🛒 Updated existing item quantity to: $newQuantity');
    } else {
      // Check stock availability
      if (quantity > product.stock && context != null) {
        _errorMessage = 'Not enough stock. Available: ${product.stock}';
        notifyListeners();
        return;
      }

      // Generate unique ID using counter + timestamp to avoid collisions
      // This ensures each cart item has a truly unique ID even if added simultaneously
      final uniqueId =
          _itemIdCounter * 1000000000 +
          DateTime.now().millisecondsSinceEpoch % 1000000000;
      _itemIdCounter++; // Increment counter for next item

      // Add new item
      final cartItem = CartItem(
        id: uniqueId,
        product: product,
        quantity: quantity,
        addedAt: DateTime.now(),
      );
      _items.add(cartItem);
      debugPrint('🛒 Added new item to cart with unique ID: $uniqueId');
    }

    debugPrint('🛒 Current items after add: ${_items.length}');
    markUserAction(); // ✅ Mark that user has taken action
    _clearError();
    notifyListeners();

    // Process draft transaction when context is available
    if (context != null) {
      _processDraftTransaction(context);
    }
  } // Update item quantity

  void updateItemQuantity(
    int itemId,
    int newQuantity, {
    BuildContext? context,
  }) {
    if (newQuantity < 0) return;

    final index = _items.indexWhere((item) => item.id == itemId);
    if (index == -1) return;

    final item = _items[index];

    if (newQuantity == 0) {
      // Remove item if quantity is 0
      removeItem(itemId, context: context);
      return;
    }

    // Check stock availability
    if (newQuantity > item.product.stock) {
      _errorMessage = 'Not enough stock. Available: ${item.product.stock}';
      notifyListeners();
      return;
    }

    _items[index] = item.copyWith(quantity: newQuantity);
    markUserAction(); // ✅ Mark that user has taken action
    _clearError();
    notifyListeners();

    // Process draft transaction when context is available
    if (context != null) {
      _processDraftTransaction(context);
    }
  }

  // Increase item quantity
  void increaseQuantity(String itemId, {BuildContext? context}) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index == -1) return;

    final item = _items[index];
    final newQuantity = item.quantity + 1;

    // Check stock availability
    if (newQuantity > item.product.stock) {
      _errorMessage = 'Not enough stock. Available: ${item.product.stock}';
      notifyListeners();
      return;
    }

    _items[index] = item.copyWith(quantity: newQuantity);
    _clearError();
    notifyListeners();

    // Process draft transaction when context is available
    if (context != null) {
      _processDraftTransaction(context);
    }
  }

  // Decrease item quantity
  void decreaseQuantity(int itemId, {BuildContext? context}) {
    debugPrint('🛒 CartProvider: Decreasing quantity for item ID: $itemId');
    debugPrint('🛒 Current cart items:');
    for (var i = 0; i < _items.length; i++) {
      debugPrint(
        '   [$i] ID: ${_items[i].id}, Product: ${_items[i].product.name}, Qty: ${_items[i].quantity}',
      );
    }

    final index = _items.indexWhere((item) => item.id == itemId);
    debugPrint('🛒 Found item at index: $index');

    if (index == -1) {
      debugPrint('❌ Item with ID $itemId not found in cart!');
      return;
    }

    final item = _items[index];
    final newQuantity = item.quantity - 1;

    if (newQuantity <= 0) {
      removeItem(itemId, context: context);
      return;
    }

    _items[index] = item.copyWith(quantity: newQuantity);
    debugPrint('✅ Updated item at index $index to quantity: $newQuantity');
    markUserAction(); // ✅ Mark that user has taken action
    notifyListeners();

    // Process draft transaction when context is available
    if (context != null) {
      _processDraftTransaction(context);
    }
  }

  // Decrease item quantity by product ID
  void decreaseQuantityByProductId(String productId, {BuildContext? context}) {
    final index = _items.indexWhere(
      (item) => item.product.id.toString() == productId,
    );
    if (index == -1) return;

    final item = _items[index];
    final newQuantity = item.quantity - 1;

    if (newQuantity <= 0) {
      removeItem(item.id, context: context);
      return;
    }

    _items[index] = item.copyWith(quantity: newQuantity);
    markUserAction(); // ✅ Mark that user has taken action
    notifyListeners();

    // Process draft transaction when context is available
    if (context != null) {
      _processDraftTransaction(context);
    }
  }

  // Remove item from cart
  void removeItem(int itemId, {BuildContext? context}) {
    _items.removeWhere((item) => item.id == itemId);
    _clearError();
    notifyListeners();

    // Process draft transaction when context is available
    if (context != null) {
      _processDraftTransaction(context);
    }
  }

  // Clear cart
  void clearCart() {
    _items.clear();
    _selectedCustomer = null;
    _discountAmount = 0.0;
    _customerName = null;
    _customerPhone = null;
    _draftTransactionId = null; // ✅ Clear draft transaction ID
    _initialQuantities.clear(); // ✅ Clear initial quantities
    _hasUserAction = false; // ✅ Reset user action flag
    _clearError();
    notifyListeners();
  }

  void clearItems() {
    _items.clear();
    _initialQuantities
        .clear(); // ✅ Clear initial quantities when clearing items
    _hasUserAction = false; // ✅ Reset user action flag
    notifyListeners();
  }

  // Set selected customer
  void setCustomer(Customer? customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }

  // Set customer from API customer model
  void setCustomerFromApi(api_customer.Customer? apiCustomer) {
    debugPrint('🛒 CartProvider: Setting customer from API');
    debugPrint(
      '🛒 API Customer: ${apiCustomer?.name} (ID: ${apiCustomer?.id})',
    );

    if (apiCustomer == null) {
      _selectedCustomer = null;
      debugPrint('🛒 Customer cleared');
    } else {
      _selectedCustomer = Customer(
        id: apiCustomer.id.toString(),
        name: apiCustomer.name,
        phone: apiCustomer.phone,
        createdAt: apiCustomer.createdAt,
        updatedAt: apiCustomer.updatedAt,
        address: apiCustomer.address,
      );
      debugPrint(
        '🛒 Customer set: ${_selectedCustomer?.name}, ${_selectedCustomer?.phone}',
      );
    }
    notifyListeners();
  }

  // Set discount amount
  void setDiscountAmount(double amount) {
    if (amount < 0 || amount > subtotal) return;
    _discountAmount = amount;
    notifyListeners();
  }

  // Set discount percentage
  void setDiscountPercentage(double percentage) {
    if (percentage < 0 || percentage > 100) return;
    _discountAmount = subtotal * (percentage / 100);
    notifyListeners();
  }

  // Set customer information
  void setCustomerName(String? name) {
    _customerName = name;
    notifyListeners();
  }

  void setCustomerPhone(String? phone) {
    _customerPhone = phone;
    notifyListeners();
  }

  // Get item by product ID (supports both int and String for backward compatibility)
  CartItem? getItemByProductId(dynamic productId) {
    try {
      return _items.firstWhere(
        (item) => item.product.id.toString() == productId.toString(),
      );
    } catch (e) {
      return null;
    }
  }

  // Check if product is in cart (supports both int and String for backward compatibility)
  bool isProductInCart(dynamic productId) {
    return _items.any(
      (item) => item.product.id.toString() == productId.toString(),
    );
  }

  // Get quantity of product in cart (supports both int and String for backward compatibility)
  int getProductQuantity(dynamic productId) {
    final item = getItemByProductId(productId);
    return item?.quantity ?? 0;
  }

  // Get quantity of product variant in cart by productVariantId
  int getProductVariantQuantity(int? productVariantId) {
    if (productVariantId == null) return 0;

    try {
      final item = _items.firstWhere(
        (item) => item.product.productVariantId == productVariantId,
      );
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }

  // Get remaining stock for a product variant (actual stock - quantity in cart)
  int getRemainingStock(int actualStock, int? productVariantId) {
    final quantityInCart = getProductVariantQuantity(productVariantId);
    return actualStock - quantityInCart;
  }

  // Process checkout
  Future<Sale?> checkout(PaymentMethod paymentMethod) async {
    if (_items.isEmpty) {
      _errorMessage = 'Cart is empty';
      notifyListeners();
      return null;
    }

    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate processing delay
      await Future.delayed(const Duration(seconds: 2));

      // Create sale items
      final saleItems = _items
          .map(
            (cartItem) => SaleItem(
              productId: cartItem.product.id.toString(),
              productName: cartItem.product.name,
              price: cartItem.product.price,
              quantity: cartItem.quantity,
            ),
          )
          .toList();

      // Create sale
      final sale = Sale(
        id: _uuid.v4(),
        customerId: _selectedCustomer?.id,
        customerName: _selectedCustomer?.name,
        items: saleItems,
        discount: _discountAmount,
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
      );

      // Clear cart after successful checkout
      clearCart();

      _isProcessing = false;
      notifyListeners();

      return sale;
    } catch (e) {
      _errorMessage = 'Checkout failed: $e';
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }

  // Validate cart before checkout
  bool validateCart() {
    if (_items.isEmpty) {
      _errorMessage = 'Cart is empty';
      notifyListeners();
      return false;
    }

    // Check if all items have sufficient stock
    for (final item in _items) {
      if (item.quantity > item.product.stock) {
        _errorMessage = 'Insufficient stock for ${item.product.name}';
        notifyListeners();
        return false;
      }
    }

    _clearError();
    return true;
  }

  // Save cart for later
  Map<String, dynamic> saveCart() {
    return {
      'items': _items.map((item) => item.toJson()).toList(),
      'customer': _selectedCustomer?.toJson(),
      'discountAmount': _discountAmount,
      'savedAt': DateTime.now().toIso8601String(),
    };
  }

  // Restore cart from saved data
  void restoreCart(Map<String, dynamic> cartData) {
    try {
      _items.clear();

      if (cartData['items'] != null) {
        final itemsData = cartData['items'] as List;
        for (final itemData in itemsData) {
          _items.add(CartItem.fromJson(itemData));
        }
      }

      if (cartData['customer'] != null) {
        _selectedCustomer = Customer.fromJson(cartData['customer']);
      }

      _discountAmount = cartData['discountAmount'] ?? 0.0;

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to restore cart: $e';
      notifyListeners();
    }
  }

  // Clear error message
  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  // User management methods
  void setCurrentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  // Initialize user from AuthProvider
  void initializeWithUser(User? user) {
    _currentUser = user;
    // Don't notify listeners here since it's initialization
  }

  // Sync user data from AuthProvider (with change detection)
  void syncUserData(User? authUser) {
    if (authUser == null) {
      // Clear user if auth user is null
      if (_currentUser != null) {
        _currentUser = null;
        notifyListeners();
      }
    } else {
      // Update user if different or not set
      if (_currentUser == null || _currentUser!.id != authUser.id) {
        _currentUser = authUser;
        notifyListeners();
      }
    }
  }

  // Get user information
  String? get userName => _currentUser?.name;
  String? get userEmail => _currentUser?.email;
  int? get userId => _currentUser?.id;
  String? get userRole => _currentUser?.roles.isNotEmpty == true
      ? _currentUser!.roles.first.name
      : null;

  // Get full user object
  User? get user => _currentUser;

  // Check if user is logged in
  bool get hasUser => _currentUser != null;

  // Clear user data
  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }

  // ✅ Capture initial quantities for stock calculation
  void captureInitialQuantities() {
    _initialQuantities.clear();
    for (var item in _items) {
      _initialQuantities[item.product.id] = item.quantity;
    }
    _hasUserAction = false; // Reset user action flag
    debugPrint('📊 Captured initial quantities: $_initialQuantities');
  }

  // ✅ Mark that user has performed an action
  void markUserAction() {
    if (!_hasUserAction) {
      _hasUserAction = true;
      notifyListeners();
      debugPrint('✋ User action marked');
    }
  }

  // Process draft transaction when items are added to cart
  void _processDraftTransaction(BuildContext context) async {
    try {
      await PaymentService.processDraftTransaction(
        context: context,
        cartProvider: this,
      );

      // Debounced product refresh to show updated stock
      // Cancel previous timer if exists
      _refreshTimer?.cancel();

      // Schedule refresh after 1 second of inactivity
      _refreshTimer = Timer(const Duration(seconds: 1), () {
        _reloadProductsData(context);
      });
    } catch (e) {
      // Silent failure to not interrupt user experience
      debugPrint('Failed to process draft transaction: ${e.toString()}');
    }
  }

  // Reload products data after draft transaction
  void _reloadProductsData(BuildContext context) {
    try {
      // Find ProductProvider and reload data
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );

      // Call refreshProducts method from ProductProvider
      productProvider.refreshProducts();

      debugPrint(
        '🛒 Products data reloaded after draft transaction using ProductProvider',
      );
    } catch (e) {
      debugPrint('Failed to reload products data: ${e.toString()}');
    }
  }

  // Set draft transaction ID (used when resuming from pending transaction)
  void setDraftTransactionId(int? transactionId) {
    _draftTransactionId = transactionId;
    debugPrint('🛒 Draft transaction ID set: $_draftTransactionId');
    notifyListeners();
  }

  // Check if this is an existing draft transaction
  bool get hasExistingDraftTransaction => _draftTransactionId != null;

  // Public method to manually reload products data
  void reloadProductsData(BuildContext context) {
    _reloadProductsData(context);
  }

  // Alternative method with ProductProvider directly (recommended)
  void reloadProductsWithProvider(ProductProvider productProvider) {
    try {
      productProvider.refreshProducts();
      debugPrint(
        '🛒 Products reloaded using ProductProvider.refreshProducts()',
      );
    } catch (e) {
      debugPrint('Failed to reload products with provider: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
