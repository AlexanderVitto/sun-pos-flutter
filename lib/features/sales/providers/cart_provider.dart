import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/product.dart';
import '../../../data/models/cart_item.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/sale.dart';
import '../../customers/data/models/customer.dart' as api_customer;

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  final Uuid _uuid = const Uuid();
  Customer? _selectedCustomer;
  double _discountAmount = 0.0;
  bool _isProcessing = false;
  String? _errorMessage;
  String? _customerName;
  String? _customerPhone;

  // Getters
  List<CartItem> get items => List.unmodifiable(_items);
  Customer? get selectedCustomer => _selectedCustomer;
  double get discountAmount => _discountAmount;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  String? get customerName => _customerName;
  String? get customerPhone => _customerPhone;

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
  void addItem(Product product, {int quantity = 1}) {
    if (quantity <= 0) return;

    // Check if product already exists in cart
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      // Update quantity of existing item
      final existingItem = _items[existingIndex];
      final newQuantity = existingItem.quantity + quantity;

      // Check stock availability
      if (newQuantity > product.stock) {
        _errorMessage = 'Not enough stock. Available: ${product.stock}';
        notifyListeners();
        return;
      }

      _items[existingIndex] = existingItem.copyWith(quantity: newQuantity);
    } else {
      // Check stock availability
      if (quantity > product.stock) {
        _errorMessage = 'Not enough stock. Available: ${product.stock}';
        notifyListeners();
        return;
      }

      // Add new item
      final cartItem = CartItem(
        id: _uuid.v4(),
        product: product,
        quantity: quantity,
        addedAt: DateTime.now(),
      );
      _items.add(cartItem);
    }

    _clearError();
    notifyListeners();
  }

  // Update item quantity
  void updateItemQuantity(String itemId, int newQuantity) {
    if (newQuantity < 0) return;

    final index = _items.indexWhere((item) => item.id == itemId);
    if (index == -1) return;

    final item = _items[index];

    if (newQuantity == 0) {
      // Remove item if quantity is 0
      removeItem(itemId);
      return;
    }

    // Check stock availability
    if (newQuantity > item.product.stock) {
      _errorMessage = 'Not enough stock. Available: ${item.product.stock}';
      notifyListeners();
      return;
    }

    _items[index] = item.copyWith(quantity: newQuantity);
    _clearError();
    notifyListeners();
  }

  // Increase item quantity
  void increaseQuantity(String itemId) {
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
  }

  // Decrease item quantity
  void decreaseQuantity(String itemId) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index == -1) return;

    final item = _items[index];
    final newQuantity = item.quantity - 1;

    if (newQuantity <= 0) {
      removeItem(itemId);
      return;
    }

    _items[index] = item.copyWith(quantity: newQuantity);
    notifyListeners();
  }

  // Decrease item quantity by product ID
  void decreaseQuantityByProductId(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index == -1) return;

    final item = _items[index];
    final newQuantity = item.quantity - 1;

    if (newQuantity <= 0) {
      removeItem(item.id);
      return;
    }

    _items[index] = item.copyWith(quantity: newQuantity);
    notifyListeners();
  }

  // Remove item from cart
  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    _clearError();
    notifyListeners();
  }

  // Clear cart
  void clearCart() {
    _items.clear();
    _selectedCustomer = null;
    _discountAmount = 0.0;
    _customerName = null;
    _customerPhone = null;
    _clearError();
    notifyListeners();
  }

  // Set selected customer
  void setCustomer(Customer? customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }

  // Set customer from API customer model
  void setCustomerFromApi(api_customer.Customer? apiCustomer) {
    if (apiCustomer == null) {
      _selectedCustomer = null;
    } else {
      _selectedCustomer = Customer(
        id: apiCustomer.id.toString(),
        name: apiCustomer.name,
        phone: apiCustomer.phone,
        createdAt: apiCustomer.createdAt,
        updatedAt: apiCustomer.updatedAt,
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

  // Get item by product ID
  CartItem? getItemByProductId(String productId) {
    try {
      return _items.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Check if product is in cart
  bool isProductInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  // Get quantity of product in cart
  int getProductQuantity(String productId) {
    final item = getItemByProductId(productId);
    return item?.quantity ?? 0;
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
      final saleItems =
          _items
              .map(
                (cartItem) => SaleItem(
                  productId: cartItem.product.id,
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
}
