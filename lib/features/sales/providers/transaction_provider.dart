import 'package:flutter/foundation.dart';
import '../../transactions/data/services/transaction_api_service.dart';
import '../../transactions/data/models/create_transaction_request.dart';
import '../../transactions/data/models/transaction_detail.dart';
import '../../transactions/data/models/create_transaction_response.dart';
import '../../../data/models/cart_item.dart';
import '../../../core/events/transaction_events.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionApiService _transactionService = TransactionApiService();

  bool _isProcessingPayment = false;
  String? _lastTransactionNumber;
  String? _errorMessage;

  bool get isProcessingPayment => _isProcessingPayment;
  String? get lastTransactionNumber => _lastTransactionNumber;
  String? get errorMessage => _errorMessage;

  /// Process payment for the given cart items
  Future<CreateTransactionResponse?> processPayment({
    required List<CartItem> cartItems,
    required double totalAmount,
    String? notes,
    String paymentMethod = '',
    int storeId = 1,
    String? customerName,
    String? customerPhone,
    String? status,
  }) async {
    if (cartItems.isEmpty) {
      _errorMessage = 'Keranjang kosong!';
      notifyListeners();
      return null;
    }

    _isProcessingPayment = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final transactionRequest = _createTransactionRequest(
        cartItems: cartItems,
        totalAmount: totalAmount,
        notes: notes,
        paymentMethod: paymentMethod,
        storeId: storeId,
        customerName: customerName,
        customerPhone: customerPhone,
        status: status,
      );

      final response = await _transactionService.createTransaction(
        transactionRequest,
      );

      if (response.data != null) {
        _lastTransactionNumber = response.data!.transactionNumber;
        _errorMessage = null;

        // Emit transaction created event for real-time updates
        TransactionEvents.instance.transactionCreated(
          response.data!.transactionNumber,
        );
      } else {
        _errorMessage = 'Gagal memproses transaksi: ${response.message}';
      }

      _isProcessingPayment = false;
      notifyListeners();

      return response;
    } catch (e) {
      _isProcessingPayment = false;
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  /// Create transaction request from cart items
  CreateTransactionRequest _createTransactionRequest({
    required List<CartItem> cartItems,
    required double totalAmount,
    String? notes,
    required String paymentMethod,
    required int storeId,
    String? customerName,
    String? customerPhone,
    String? status,
  }) {
    // Get current date in YYYY-MM-DD format
    final now = DateTime.now();
    final transactionDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Convert cart items to transaction details
    final details =
        cartItems.map((cartItem) {
          return TransactionDetail(
            productId: int.tryParse(cartItem.product.id) ?? 1,
            productVariantId: int.tryParse(cartItem.product.id) ?? 1,
            quantity: cartItem.quantity,
            unitPrice: cartItem.product.price,
          );
        }).toList();

    return CreateTransactionRequest(
      storeId: storeId,
      paymentMethod: paymentMethod,
      paidAmount: totalAmount,
      notes:
          notes?.trim().isEmpty == true
              ? 'POS Transaction - ${cartItems.length} items'
              : notes?.trim() ?? 'POS Transaction',
      transactionDate: transactionDate,
      details: details,
      customerName: customerName,
      customerPhone: customerPhone,
      status: status ?? 'pending',
    );
  }

  /// Clear any error messages
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _isProcessingPayment = false;
    _lastTransactionNumber = null;
    _errorMessage = null;
    notifyListeners();
  }
}
