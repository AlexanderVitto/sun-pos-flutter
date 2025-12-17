import 'package:flutter/material.dart';
import '../../providers/cart_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../../../data/models/product.dart';
import '../../../../data/models/cart_item.dart';
import '../../../transactions/data/models/store.dart';

class POSTransactionViewModel extends ChangeNotifier {
  final CartProvider _cartProvider;
  final TransactionProvider _transactionProvider;
  bool _disposed = false;

  POSTransactionViewModel({
    required CartProvider cartProvider,
    required TransactionProvider transactionProvider,
  }) : _cartProvider = cartProvider,
       _transactionProvider = transactionProvider {
    _notesController = TextEditingController();
  }

  // State
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  late TextEditingController _notesController;
  bool _isProcessingPayment = false;

  // Getters
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  TextEditingController get notesController => _notesController;
  bool get isProcessingPayment => _isProcessingPayment;
  CartProvider get cartProvider => _cartProvider;
  TransactionProvider get transactionProvider => _transactionProvider;

  // Computed properties
  int get itemCount => _cartProvider.itemCount;
  double get total => _cartProvider.total;
  List<CartItem> get cartItems => _cartProvider.items;
  bool get hasItems => _cartProvider.items.isNotEmpty;

  // Methods
  void updateSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  void updateSelectedCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  void addToCart(Product product, {int quantity = 1, BuildContext? context}) {
    _cartProvider.addItem(product, quantity: quantity, context: context);
    // Note: CartProvider will notify its own listeners
  }

  void removeFromCart(int itemId, {BuildContext? context}) {
    _cartProvider.removeItem(itemId, context: context);
  }

  void increaseQuantity(String itemId, {BuildContext? context}) {
    _cartProvider.addItem(
      _cartProvider.items.firstWhere((item) => item.id == itemId).product,
      context: context,
    );
  }

  void decreaseQuantity(int itemId, {BuildContext? context}) {
    _cartProvider.decreaseQuantity(itemId, context: context);
  }

  void clearCart() {
    _cartProvider.clearCart();
    _notesController.clear();
  }

  void setCustomerInfo(String? name, String? phone) {
    if (name != null && name.isNotEmpty) {
      _cartProvider.setCustomerName(name);
    }
    if (phone != null && phone.isNotEmpty) {
      _cartProvider.setCustomerPhone(phone);
    }
  }

  Future<bool> processPayment({
    required String customerName,
    required String customerPhone,
    String paymentMethod = 'cash',
    required int storeId,
  }) async {
    if (_cartProvider.items.isEmpty) {
      return false;
    }

    try {
      _setProcessingPayment(true);

      // Set customer information
      setCustomerInfo(customerName, customerPhone);

      // Process payment using transaction provider
      final transactionResponse = await _transactionProvider.processPayment(
        cartItems: _cartProvider.items,
        totalAmount: _cartProvider.total,
        notes: _notesController.text.trim(),
        paymentMethod: paymentMethod,
        customerName: customerName.isNotEmpty ? customerName : 'Customer',
        customerPhone: customerPhone,
        storeId: storeId,
      );

      _setProcessingPayment(false);

      if (transactionResponse != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      _setProcessingPayment(false);
      return false;
    }
  }

  void _setProcessingPayment(bool processing) {
    _isProcessingPayment = processing;
    notifyListeners();
  }

  // Helper methods for navigation and UI feedback
  String? getErrorMessage() {
    return _transactionProvider.errorMessage;
  }

  Store createMockStore() {
    return Store(
      id: 1,
      name: 'Sun POS Store',
      address: 'Jl. Contoh No. 123, Jakarta',
      phoneNumber: '021-12345678',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Helper method to get product ID for navigation
  int getProductId(Product product) {
    return product.id; // ID is already int
  }

  @override
  void dispose() {
    if (!_disposed) {
      _disposed = true;
      _notesController.dispose();
      super.dispose();
    }
  }
}
