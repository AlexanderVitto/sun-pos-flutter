import 'package:flutter/material.dart';
import '../data/models/refund_list_response.dart';
import '../data/models/create_refund_request.dart';
import '../data/services/refund_api_service.dart';

class RefundListProvider with ChangeNotifier {
  final RefundApiService _apiService = RefundApiService();

  // State variables
  List<RefundItem> _refunds = [];
  bool _isLoading = false;
  String? _errorMessage;
  RefundMeta? _meta;
  RefundLinks? _links;

  // Filters
  int _currentPage = 1;
  int _perPage = 10;
  String? _search;
  int _storeId = 1; // Default store ID
  int? _userId;
  int? _customerId;
  String? _dateFrom;
  String? _dateTo;
  String? _status;
  String? _refundMethod;
  double? _minAmount;
  double? _maxAmount;
  String _sortBy = 'created_at';
  String _sortDirection = 'desc';

  // Getters
  List<RefundItem> get refunds => _refunds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RefundMeta? get meta => _meta;
  RefundLinks? get links => _links;

  // Filter getters
  int get currentPage => _currentPage;
  int get perPage => _perPage;
  String? get search => _search;
  int get storeId => _storeId;
  int? get userId => _userId;
  int? get customerId => _customerId;
  String? get dateFrom => _dateFrom;
  String? get dateTo => _dateTo;
  String? get status => _status;
  String? get refundMethod => _refundMethod;
  double? get minAmount => _minAmount;
  double? get maxAmount => _maxAmount;
  String get sortBy => _sortBy;
  String get sortDirection => _sortDirection;

  // Computed getters
  bool get hasNextPage => _links?.next != null;
  bool get hasPrevPage => _links?.prev != null;
  int get totalRefunds => _meta?.total ?? 0;
  int get totalPages => _meta?.lastPage ?? 1;

  /// Get list of transaction IDs that have been refunded
  Set<int> get refundedTransactionIds {
    return _refunds.map((refund) => refund.transactionId).toSet();
  }

  /// Load refunds with current filters
  Future<void> loadRefunds({bool refresh = false}) async {
    if (_isLoading) return;

    // Reset page if refresh
    if (refresh) {
      _currentPage = 1;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getRefunds(
        page: _currentPage,
        perPage: _perPage,
        search: _search,
        storeId: _storeId,
        userId: _userId,
        customerId: _customerId,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
        status: _status,
        refundMethod: _refundMethod,
        minAmount: _minAmount,
        maxAmount: _maxAmount,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
      );

      debugPrint('📦 Refund API Response: $response');

      final refundListResponse = RefundListResponse.fromJson(response);

      if (refresh) {
        _refunds = refundListResponse.data.data;
      } else {
        _refunds.addAll(refundListResponse.data.data);
      }

      _meta = refundListResponse.data.meta;
      _links = refundListResponse.data.links;

      debugPrint('✅ Loaded ${_refunds.length} refunds successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading refunds: $e');
      debugPrint('Stack trace: $stackTrace');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load next page
  Future<void> loadNextPage() async {
    if (!hasNextPage || _isLoading) return;

    _currentPage++;
    await loadRefunds();
  }

  /// Load previous page
  Future<void> loadPrevPage() async {
    if (!hasPrevPage || _isLoading) return;

    _currentPage--;
    await loadRefunds();
  }

  /// Set search filter
  void setSearch(String? search) {
    _search = search;
    notifyListeners();
  }

  /// Set store filter
  void setStore(int storeId) {
    _storeId = storeId;
    notifyListeners();
  }

  /// Set user filter
  void setUser(int? userId) {
    _userId = userId;
    notifyListeners();
  }

  /// Set customer filter
  void setCustomer(int? customerId) {
    _customerId = customerId;
    notifyListeners();
  }

  /// Set date range filter
  void setDateRange(String? from, String? to) {
    _dateFrom = from;
    _dateTo = to;
    notifyListeners();
  }

  /// Set status filter
  void setStatus(String? status) {
    _status = status;
    notifyListeners();
  }

  /// Set refund method filter
  void setRefundMethod(String? method) {
    _refundMethod = method;
    notifyListeners();
  }

  /// Set amount range filter
  void setAmountRange(double? min, double? max) {
    _minAmount = min;
    _maxAmount = max;
    notifyListeners();
  }

  /// Set sorting
  void setSorting(String sortBy, String direction) {
    _sortBy = sortBy;
    _sortDirection = direction;
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _currentPage = 1;
    _search = null;
    _userId = null;
    _customerId = null;
    _dateFrom = null;
    _dateTo = null;
    _status = null;
    _refundMethod = null;
    _minAmount = null;
    _maxAmount = null;
    _sortBy = 'created_at';
    _sortDirection = 'desc';
    notifyListeners();
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadRefunds(refresh: true);
  }

  /// Reset provider state
  void reset() {
    _refunds = [];
    _isLoading = false;
    _errorMessage = null;
    _meta = null;
    _links = null;
    clearFilters();
    notifyListeners();
  }

  /// Check if a transaction has been refunded
  bool isTransactionRefunded(int transactionId) {
    return _refunds.any((refund) => refund.transactionId == transactionId);
  }

  /// Get refunds for a specific transaction
  List<RefundItem> getRefundsByTransactionId(int transactionId) {
    return _refunds
        .where((refund) => refund.transactionId == transactionId)
        .toList();
  }

  /// Create new refund
  Future<void> createRefund(CreateRefundRequest request) async {
    try {
      debugPrint('📤 Creating refund for transaction ${request.transactionId}');

      final response = await _apiService.createRefund(request.toJson());

      debugPrint('✅ Refund created successfully');
      debugPrint('📥 Response: $response');

      // Refresh the list after creating
      await loadRefunds(refresh: true);
    } catch (e) {
      debugPrint('❌ Error creating refund: $e');
      rethrow;
    }
  }
}
