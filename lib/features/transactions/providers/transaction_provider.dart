import 'package:flutter/material.dart';
import '../data/models/create_transaction_request.dart';
import '../data/models/create_transaction_response.dart';
import '../data/models/transaction_detail.dart';
import '../data/services/transaction_api_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionApiService _apiService = TransactionApiService();

  bool _isLoading = false;
  String? _errorMessage;
  CreateTransactionResponse? _lastTransactionResponse;

  // Transaction form data
  int _storeId = 1;
  String _paymentMethod = 'cash';
  double _paidAmount = 0.0;
  String? _notes;
  String _transactionDate = DateTime.now().toIso8601String().split('T')[0];
  List<TransactionDetail> _details = [];
  String? _customerName;
  String? _customerPhone;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CreateTransactionResponse? get lastTransactionResponse =>
      _lastTransactionResponse;

  int get storeId => _storeId;
  String get paymentMethod => _paymentMethod;
  double get paidAmount => _paidAmount;
  String? get notes => _notes;
  String get transactionDate => _transactionDate;
  List<TransactionDetail> get details => List.unmodifiable(_details);
  String? get customerName => _customerName;
  String? get customerPhone => _customerPhone;

  // Calculated values
  double get totalAmount {
    return _details.fold(0.0, (sum, detail) => sum + detail.subtotal);
  }

  double get changeAmount {
    final change = _paidAmount - totalAmount;
    return change > 0 ? change : 0.0;
  }

  bool get isPaidAmountSufficient => _paidAmount >= totalAmount;

  int get totalItems {
    return _details.fold(0, (sum, detail) => sum + (detail.quantity ?? 0));
  }

  bool get hasItems => _details.isNotEmpty;

  // Setters
  void setStoreId(int storeId) {
    _storeId = storeId;
    notifyListeners();
  }

  void setPaymentMethod(String paymentMethod) {
    _paymentMethod = paymentMethod;
    notifyListeners();
  }

  void setPaidAmount(double paidAmount) {
    _paidAmount = paidAmount;
    notifyListeners();
  }

  void setNotes(String? notes) {
    _notes = notes;
    notifyListeners();
  }

  void setTransactionDate(String transactionDate) {
    _transactionDate = transactionDate;
    notifyListeners();
  }

  void setCustomerName(String? customerName) {
    _customerName = customerName;
    notifyListeners();
  }

  void setCustomerPhone(String? customerPhone) {
    _customerPhone = customerPhone;
    notifyListeners();
  }

  // Transaction details management
  void addTransactionDetail(TransactionDetail detail) {
    // Check if product variant already exists
    final existingIndex = _details.indexWhere(
      (d) =>
          d.productId == detail.productId &&
          d.productVariantId == detail.productVariantId,
    );

    if (existingIndex != -1) {
      // Update existing detail by adding quantity
      final existingDetail = _details[existingIndex];
      final updatedDetail = TransactionDetail(
        productId: existingDetail.productId,
        productVariantId: existingDetail.productVariantId,
        quantity: (existingDetail.quantity ?? 0) + (detail.quantity ?? 0),
        unitPrice: existingDetail.unitPrice,
      );
      _details[existingIndex] = updatedDetail;
    } else {
      // Add new detail
      _details.add(detail);
    }
    notifyListeners();
  }

  void updateTransactionDetail(int index, TransactionDetail detail) {
    if (index >= 0 && index < _details.length) {
      _details[index] = detail;
      notifyListeners();
    }
  }

  void removeTransactionDetail(int index) {
    if (index >= 0 && index < _details.length) {
      _details.removeAt(index);
      notifyListeners();
    }
  }

  void removeTransactionDetailByProduct(int productId, int productVariantId) {
    _details.removeWhere(
      (d) => d.productId == productId && d.productVariantId == productVariantId,
    );
    notifyListeners();
  }

  void clearTransactionDetails() {
    _details.clear();
    notifyListeners();
  }

  void updateQuantity(int index, int quantity) {
    if (index >= 0 && index < _details.length && quantity > 0) {
      final detail = _details[index];
      _details[index] = TransactionDetail(
        productId: detail.productId,
        productVariantId: detail.productVariantId,
        quantity: quantity,
        unitPrice: detail.unitPrice,
      );
      notifyListeners();
    }
  }

  void increaseQuantity(int index) {
    if (index >= 0 && index < _details.length) {
      final detail = _details[index];
      updateQuantity(index, (detail.quantity ?? 0) + 1);
    }
  }

  void decreaseQuantity(int index) {
    if (index >= 0 && index < _details.length) {
      final detail = _details[index];
      if ((detail.quantity ?? 0) > 1) {
        updateQuantity(index, (detail.quantity ?? 0) - 1);
      } else {
        removeTransactionDetail(index);
      }
    }
  }

  // Transaction operations
  Future<bool> createTransaction() async {
    if (!hasItems) {
      _errorMessage = 'No items in transaction';
      notifyListeners();
      return false;
    }

    if (!isPaidAmountSufficient) {
      _errorMessage = 'Paid amount is insufficient';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = CreateTransactionRequest(
        storeId: _storeId,
        paymentMethod: _paymentMethod,
        paidAmount: _paidAmount,
        notes: _notes,
        transactionDate: _transactionDate,
        details: _details,
        customerName: _customerName,
        customerPhone: _customerPhone,
      );

      final response = await _apiService.createTransaction(request);
      _lastTransactionResponse = response;

      if (response.success) {
        // Clear form after successful transaction
        clearForm();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Form management
  void clearForm() {
    _paidAmount = 0.0;
    _notes = null;
    _transactionDate = DateTime.now().toIso8601String().split('T')[0];
    _details.clear();
    _errorMessage = null;
    _lastTransactionResponse = null;
    _customerName = null;
    _customerPhone = null;
  }

  void resetToDefaults() {
    _storeId = 1;
    _paymentMethod = 'cash';
    clearForm();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Quick transaction creation
  Future<bool> createQuickTransaction({
    required List<TransactionDetail> items,
    required double paidAmount,
    String paymentMethod = 'cash',
    String? notes,
    int storeId = 1,
  }) async {
    // Set transaction data
    setStoreId(storeId);
    setPaymentMethod(paymentMethod);
    setPaidAmount(paidAmount);
    setNotes(notes);

    // Clear existing details and add new ones
    clearTransactionDetails();
    for (final item in items) {
      addTransactionDetail(item);
    }

    // Create transaction
    return await createTransaction();
  }

  // Validation helpers
  String? validatePaidAmount() {
    if (_paidAmount <= 0) {
      return 'Paid amount must be greater than 0';
    }
    if (!isPaidAmountSufficient) {
      return 'Paid amount is insufficient';
    }
    return null;
  }

  String? validateTransactionDetails() {
    if (!hasItems) {
      return 'Please add at least one item';
    }
    for (int i = 0; i < _details.length; i++) {
      final detail = _details[i];
      if ((detail.quantity ?? 0) <= 0) {
        return 'Item ${i + 1}: Quantity must be greater than 0';
      }
      if ((detail.unitPrice ?? 0) < 0) {
        return 'Item ${i + 1}: Unit price cannot be negative';
      }
    }
    return null;
  }

  String? validateTransaction() {
    final paidAmountError = validatePaidAmount();
    if (paidAmountError != null) return paidAmountError;

    final detailsError = validateTransactionDetails();
    if (detailsError != null) return detailsError;

    return null;
  }
}
