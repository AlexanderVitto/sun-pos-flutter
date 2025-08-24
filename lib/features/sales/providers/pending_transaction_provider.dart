import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../data/models/cart_item.dart';
import '../../customers/data/models/customer.dart';

class PendingTransactionProvider extends ChangeNotifier {
  // Direct flutter secure storage instance for pending transactions
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

  Map<String, PendingTransaction> _pendingTransactions = {};

  Map<String, PendingTransaction> get pendingTransactions =>
      Map.unmodifiable(_pendingTransactions);

  List<PendingTransaction> get pendingTransactionsList =>
      _pendingTransactions.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  bool get hasPendingTransactions => _pendingTransactions.isNotEmpty;

  /// Load all pending transactions from storage
  Future<void> loadPendingTransactions() async {
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

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading pending transactions: $e');
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
    return _pendingTransactions[customerId];
  }

  /// Delete pending transaction for specific customer
  Future<void> deletePendingTransaction(String customerId) async {
    try {
      final key = 'pending_transaction_$customerId';
      await _storage.delete(key: key);

      _pendingTransactions.remove(customerId);
      notifyListeners();

      debugPrint('Pending transaction deleted for customer ID: $customerId');
    } catch (e) {
      debugPrint('Error deleting pending transaction: $e');
      throw Exception('Failed to delete pending transaction');
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
