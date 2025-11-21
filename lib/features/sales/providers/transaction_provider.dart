import 'package:flutter/foundation.dart';
import '../../transactions/data/services/transaction_api_service.dart';
import '../../transactions/data/models/create_transaction_request.dart';
import '../../transactions/data/models/transaction_detail.dart';
import '../../transactions/data/models/create_transaction_response.dart';
import '../../transactions/data/models/payment_history.dart';
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
    double? cashAmount,
    double transferAmount = 0,
    String? outstandingReminderDate,
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
        cashAmount: cashAmount,
        transferAmount: transferAmount,
        outstandingReminderDate: outstandingReminderDate,
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
    List<CartItem>? cartItems,
    double? totalAmount,
    String? notes,
    String? paymentMethod,
    int? storeId,
    String? customerName,
    String? customerPhone,
    String? status,
    double? cashAmount,
    double transferAmount = 0,
    String? outstandingReminderDate,
  }) {
    // Get current datetime in ISO format with time
    final now = DateTime.now();
    final transactionDate = now.toIso8601String();

    // Convert cart items to transaction details
    final details = cartItems?.map((cartItem) {
      return TransactionDetail(
        productVariantId: cartItem.product.productVariantId ?? 0,
        quantity: cartItem.quantity,
        // unitPrice already contains discounted price per item
        // The cartItems received should have already been processed
        // with discount applied at the item level
        unitPrice: cartItem.product.price,
      );
    }).toList();

    // Create payments array based on payment method and amounts
    final payments = <PaymentHistory>[];

    if ((cashAmount ?? 0) > 0) {
      payments.add(
        PaymentHistory(
          paymentMethod: 'cash',
          amount: cashAmount!,
          paymentDate: transactionDate,
        ),
      );
    }

    if (transferAmount > 0) {
      payments.add(
        PaymentHistory(
          paymentMethod: 'bank_transfer',
          amount: transferAmount,
          paymentDate: transactionDate,
        ),
      );
    }

    // If no specific amounts provided, use the payment method and total amount
    if (payments.isEmpty) {
      payments.add(
        PaymentHistory(
          paymentMethod: paymentMethod ?? 'cash',
          amount: totalAmount ?? 0,
          paymentDate: transactionDate,
        ),
      );
    }

    return CreateTransactionRequest(
      storeId: storeId,
      payments: payments,
      notes: notes?.trim() ?? '',
      transactionDate: transactionDate,
      details: details,
      customerName: customerName,
      customerPhone: customerPhone,
      status: status ?? 'pending',
      outstandingReminderDate: outstandingReminderDate,
    );
  }

  /// Update existing transaction
  Future<CreateTransactionResponse?> updateTransaction({
    required int transactionId,
    required List<CartItem> cartItems,
    required double totalAmount,
    String? notes,
    String paymentMethod = 'cash',
    int storeId = 1,
    String? customerName,
    String? customerPhone,
    String? status,
    double cashAmount = 0,
    double transferAmount = 0,
    String? outstandingReminderDate,
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
        cashAmount: cashAmount,
        transferAmount: transferAmount,
        outstandingReminderDate: outstandingReminderDate,
      );

      final response = await _transactionService.updateTransaction(
        transactionId,
        transactionRequest,
      );

      if (response.data != null) {
        _lastTransactionNumber = response.data!.transactionNumber;
        _errorMessage = null;

        // Emit transaction updated event for real-time updates
        TransactionEvents.instance.transactionUpdated(
          response.data!.transactionNumber,
        );
      } else {
        _errorMessage = 'Gagal mengupdate transaksi: ${response.message}';
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
