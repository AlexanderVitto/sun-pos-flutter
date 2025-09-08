import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../data/models/cart_item.dart';
import '../../customers/data/models/customer.dart';
import '../data/services/pending_transaction_api_service.dart';
import '../data/models/pending_transaction_api_models.dart';

class PendingTransactionProvider extends ChangeNotifier {
  // API service for pending transactions
  final PendingTransactionApiService _apiService =
      PendingTransactionApiService();

  // Direct flutter secure storage instance for pending transactions (fallback)
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      sharedPreferencesName: 'sun_pos_pending_prefs',
      preferencesKeyPrefix: 'pending_',
    ),
    iOptions: IOSOptions(
      groupId: 'group.com.sunpos.pending',
      accountName: 'sun_pos_pending',
    ),
  );

  // Local storage for backward compatibility
  Map<String, PendingTransaction> _pendingTransactions = {};

  // API data
  List<PendingTransactionItem> _apiPendingTransactions = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _useApiData = true; // Flag to determine data source

  // Getters for local storage (backward compatibility)
  Map<String, PendingTransaction> get pendingTransactions =>
      Map.unmodifiable(_pendingTransactions);

  List<PendingTransaction> get pendingTransactionsList =>
      _pendingTransactions.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  // Getters for API data
  List<PendingTransactionItem> get apiPendingTransactionsList =>
      List.unmodifiable(_apiPendingTransactions);

  // Combined getter that returns the appropriate data source
  List<PendingTransactionItem> get allPendingTransactionsList {
    if (_useApiData && _apiPendingTransactions.isNotEmpty) {
      return _apiPendingTransactions;
    }
    return [];
  }

  bool get hasPendingTransactions =>
      _useApiData
          ? _apiPendingTransactions.isNotEmpty
          : _pendingTransactions.isNotEmpty;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load all pending transactions from API
  Future<void> loadPendingTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Try to load from API first
      final response = await _apiService.getPendingTransactions();

      if (response.status == 'success') {
        _apiPendingTransactions = response.data.data;
        _useApiData = true;
        debugPrint(
          'Loaded ${_apiPendingTransactions.length} pending transactions from API',
        );
      } else {
        throw Exception(response.message);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading pending transactions from API: $e');

      // Fallback to local storage
      await _loadFromLocalStorage();
      _useApiData = false;
      _errorMessage = 'Using offline data: ${e.toString()}';

      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fallback method to load from local storage
  Future<void> _loadFromLocalStorage() async {
    try {
      final allData = await _storage.readAll();
      final pendingKeys = allData.keys.where(
        (key) => key.startsWith('pending_transaction_'),
      );

      _pendingTransactions.clear();

      for (final key in pendingKeys) {
        final jsonData = allData[key];
        if (jsonData != null) {
          try {
            final data = json.decode(jsonData);
            final transaction = PendingTransaction.fromJson(data);
            _pendingTransactions[transaction.customerId] = transaction;
          } catch (e) {
            debugPrint('Error parsing pending transaction $key: $e');
            // Remove corrupted data
            await _storage.delete(key: key);
          }
        }
      }

      debugPrint(
        'Loaded ${_pendingTransactions.length} pending transactions from local storage',
      );
    } catch (e) {
      debugPrint('Error loading pending transactions from local storage: $e');
    }
  }

  /// Save pending transaction for specific customer
  Future<void> savePendingTransaction({
    required String customerId,
    required String customerName,
    required String? customerPhone,
    required List<CartItem> cartItems,
    String? notes,
  }) async {
    try {
      final transaction = PendingTransaction(
        customerId: customerId,
        customerName: customerName,
        customerPhone: customerPhone,
        cartItems: cartItems,
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final key = 'pending_transaction_$customerId';
      await _storage.write(key: key, value: json.encode(transaction.toJson()));

      _pendingTransactions[customerId] = transaction;
      notifyListeners();

      debugPrint('Pending transaction saved for customer: $customerName');
    } catch (e) {
      debugPrint('Error saving pending transaction: $e');
      throw Exception('Failed to save pending transaction');
    }
  }

  /// Get pending transaction for specific customer
  PendingTransaction? getPendingTransaction(String customerId) {
    if (_useApiData) {
      // For API data, we need to convert to local format (not ideal but for compatibility)
      try {
        _apiPendingTransactions.firstWhere((t) => t.customerId == customerId);
        return null; // Return null since we can't convert without cart items
      } catch (e) {
        return null;
      }
    }
    return _pendingTransactions[customerId];
  }

  /// Get pending transaction detail from API
  Future<PendingTransactionDetail> getPendingTransactionDetail(
    int transactionId,
  ) async {
    try {
      final detail = await _apiService.getPendingTransactionDetail(
        transactionId,
      );
      return detail;
    } catch (e) {
      debugPrint('Error getting pending transaction detail: $e');
      throw Exception('Failed to get transaction detail: $e');
    }
  }

  /// Get API pending transaction by customer ID
  PendingTransactionItem? getApiPendingTransaction(String customerId) {
    if (!_useApiData) return null;

    try {
      return _apiPendingTransactions.firstWhere(
        (t) => t.customerId == customerId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get API pending transaction by transaction ID
  PendingTransactionItem? getApiPendingTransactionById(int transactionId) {
    if (!_useApiData) return null;

    try {
      return _apiPendingTransactions.firstWhere((t) => t.id == transactionId);
    } catch (e) {
      return null;
    }
  }

  /// Delete pending transaction for specific customer
  Future<void> deletePendingTransaction(String customerId) async {
    try {
      if (_useApiData) {
        // Find transaction by customer ID in API data
        final transaction = _apiPendingTransactions.firstWhere(
          (t) => t.customerId == customerId,
          orElse: () => throw Exception('Transaction not found'),
        );

        // Delete from API
        await _apiService.deleteTransaction(transaction.id);

        // Remove from local list
        _apiPendingTransactions.removeWhere((t) => t.customerId == customerId);

        debugPrint(
          'Pending transaction deleted from API for customer ID: $customerId',
        );
      } else {
        // Delete from local storage (fallback)
        final key = 'pending_transaction_$customerId';
        await _storage.delete(key: key);
        _pendingTransactions.remove(customerId);

        debugPrint(
          'Pending transaction deleted from local storage for customer ID: $customerId',
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting pending transaction: $e');
      throw Exception('Failed to delete pending transaction: $e');
    }
  }

  /// Delete transaction by API transaction ID (for API data)
  Future<void> deletePendingTransactionById(int transactionId) async {
    try {
      // Delete from API
      await _apiService.deleteTransaction(transactionId);

      // Remove from local list
      _apiPendingTransactions.removeWhere((t) => t.id == transactionId);

      notifyListeners();
      debugPrint(
        'Pending transaction deleted from API for transaction ID: $transactionId',
      );
    } catch (e) {
      debugPrint('Error deleting pending transaction by ID: $e');
      throw Exception('Failed to delete pending transaction: $e');
    }
  }

  /// Update existing pending transaction
  Future<void> updatePendingTransaction({
    required String customerId,
    required List<CartItem> cartItems,
    String? notes,
  }) async {
    try {
      final existing = _pendingTransactions[customerId];
      if (existing == null) {
        throw Exception(
          'Pending transaction not found for customer: $customerId',
        );
      }

      final updated = existing.copyWith(
        cartItems: cartItems,
        notes: notes,
        updatedAt: DateTime.now(),
      );

      final key = 'pending_transaction_$customerId';
      await _storage.write(key: key, value: json.encode(updated.toJson()));

      _pendingTransactions[customerId] = updated;
      notifyListeners();

      debugPrint(
        'Pending transaction updated for customer: ${existing.customerName}',
      );
    } catch (e) {
      debugPrint('Error updating pending transaction: $e');
      throw Exception('Failed to update pending transaction');
    }
  }

  /// Clear all pending transactions
  Future<void> clearAllPendingTransactions() async {
    try {
      final allData = await _storage.readAll();
      final pendingKeys = allData.keys.where(
        (key) => key.startsWith('pending_transaction_'),
      );

      for (final key in pendingKeys) {
        await _storage.delete(key: key);
      }

      _pendingTransactions.clear();
      notifyListeners();

      debugPrint('All pending transactions cleared');
    } catch (e) {
      debugPrint('Error clearing pending transactions: $e');
      throw Exception('Failed to clear pending transactions');
    }
  }

  /// Get total amount for pending transaction
  double getPendingTransactionTotal(String customerId) {
    final transaction = _pendingTransactions[customerId];
    if (transaction == null) return 0.0;

    return transaction.cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  /// Get total items count for pending transaction
  int getPendingTransactionItemCount(String customerId) {
    final transaction = _pendingTransactions[customerId];
    if (transaction == null) return 0;

    return transaction.cartItems.fold(0, (sum, item) => sum + item.quantity);
  }
}

class PendingTransaction {
  final String customerId;
  final String customerName;
  final String? customerPhone;
  final List<CartItem> cartItems;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PendingTransaction({
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    required this.cartItems,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  double get totalAmount =>
      cartItems.fold(0.0, (sum, item) => sum + item.subtotal);

  int get totalItems => cartItems.fold(0, (sum, item) => sum + item.quantity);

  bool get hasItems => cartItems.isNotEmpty;

  /// Create customer object from pending transaction
  Customer get customer => Customer(
    id: int.tryParse(customerId) ?? 0, // Convert string to int
    name: customerName,
    phone: customerPhone ?? '',
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory PendingTransaction.fromJson(Map<String, dynamic> json) {
    return PendingTransaction(
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'],
      cartItems:
          (json['cartItems'] as List<dynamic>? ?? [])
              .map((item) => CartItem.fromJson(item))
              .toList(),
      notes: json['notes'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'cartItems': cartItems.map((item) => item.toJson()).toList(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  PendingTransaction copyWith({
    String? customerId,
    String? customerName,
    String? customerPhone,
    List<CartItem>? cartItems,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PendingTransaction(
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      cartItems: cartItems ?? this.cartItems,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'PendingTransaction(customerId: $customerId, customerName: $customerName, totalAmount: $totalAmount, totalItems: $totalItems)';
  }
}
