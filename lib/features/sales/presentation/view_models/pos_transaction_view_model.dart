import 'package:flutter/material.dart';
import '../../providers/cart_provider.dart';
import '../../providers/transaction_provider.dart';

class POSTransactionViewModel extends ChangeNotifier {
  CartProvider? _cartProvider;
  TransactionProvider? _transactionProvider;

  // Controllers
  final TextEditingController _notesController = TextEditingController();

  // Search and filter state
  String _searchQuery = '';
  String _selectedCategory = '';

  POSTransactionViewModel() {
    // Listener untuk CartProvider akan di-setup di updateCartProvider
  }

  // Getters
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  TextEditingController get notesController => _notesController;
  CartProvider? get cartProvider => _cartProvider;
  TransactionProvider? get transactionProvider => _transactionProvider;

  /// Update method sesuai dokumentasi ChangeNotifierProxyProvider
  /// Reuse instance dan update properties, jangan create instance baru
  void updateCartProvider(CartProvider cartProvider) {
    if (_cartProvider != cartProvider) {
      print(
        '🔄 POSTransactionViewModel: Updating CartProvider instance ${cartProvider.hashCode}',
      );

      // Remove listener dari CartProvider lama jika ada
      _cartProvider?.removeListener(_onCartChanged);

      _cartProvider = cartProvider;

      // Add listener ke CartProvider baru untuk notifyListeners ketika cart berubah
      _cartProvider?.addListener(_onCartChanged);

      // Notify listeners karena CartProvider reference berubah
      notifyListeners();
    }
  }

  /// Callback ketika CartProvider berubah - akan trigger rebuild di POSAppBar
  void _onCartChanged() {
    print(
      '🔔 POSTransactionViewModel: CartProvider changed, notifying listeners',
    );
    notifyListeners();
  }

  /// Update TransactionProvider sesuai pattern dokumentasi
  void updateTransactionProvider(TransactionProvider transactionProvider) {
    if (_transactionProvider != transactionProvider) {
      _transactionProvider = transactionProvider;
      // Tidak perlu notifyListeners() karena TransactionProvider changes tidak mempengaruhi UI langsung
    }
  }

  // Search and filter methods
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateSelectedCategory(String category) {
    // Jika kategori yang dipilih sama dengan yang sudah terpilih, unselect (kosongkan filter)
    if (_selectedCategory == category) {
      _selectedCategory = '';
    } else {
      _selectedCategory = category;
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _selectedCategory = '';
    notifyListeners();
  }

  // Cart methods
  bool get hasItems => (_cartProvider?.itemCount ?? 0) > 0;
  double get totalAmount => _cartProvider?.total ?? 0.0;
  int get itemCount => _cartProvider?.itemCount ?? 0;

  // Payment processing
  Future<void> processPayment({
    required BuildContext context,
    required double receivedAmount,
    String? customerName,
    String? customerPhone,
    String? notes,
  }) async {
    try {
      if (!hasItems || _cartProvider == null || _transactionProvider == null) {
        throw Exception('Keranjang masih kosong atau provider tidak tersedia');
      }

      // Process the transaction
      await _transactionProvider!.processPayment(
        cartItems: _cartProvider!.items,
        totalAmount: totalAmount,
        notes: notes ?? _notesController.text.trim(),
        customerName: customerName,
        customerPhone: customerPhone,
      );

      // Clear the cart and notes after successful payment
      _cartProvider!.clearCart();
      _notesController.clear();

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    // Remove listener dari CartProvider sebelum dispose
    _cartProvider?.removeListener(_onCartChanged);
    _notesController.dispose();
    super.dispose();
  }
}
