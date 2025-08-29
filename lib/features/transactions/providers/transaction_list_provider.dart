import 'package:flutter/material.dart';
import '../data/models/transaction_list_response.dart';
import '../data/services/transaction_api_service.dart';

class TransactionListProvider with ChangeNotifier {
  final TransactionApiService _apiService = TransactionApiService();

  // State variables
  List<TransactionListItem> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;
  TransactionMeta? _meta;
  TransactionLinks? _links;

  // Filters
  int _currentPage = 1;
  int _perPage = 10;
  String? _search;
  int _storeId = 1; // Default store ID
  int _userId = 1; // Default user ID
  String? _dateFrom;
  String? _dateTo;
  double? _minAmount;
  double? _maxAmount;
  String _sortBy = 'created_at';
  String _sortDirection = 'desc';
  String? _paymentMethod;
  String? _status;

  // Getters
  List<TransactionListItem> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TransactionMeta? get meta => _meta;
  TransactionLinks? get links => _links;

  // Filter getters
  int get currentPage => _currentPage;
  int get perPage => _perPage;
  String? get search => _search;
  int get storeId => _storeId;
  int get userId => _userId;
  String? get dateFrom => _dateFrom;
  String? get dateTo => _dateTo;
  double? get minAmount => _minAmount;
  double? get maxAmount => _maxAmount;
  String get sortBy => _sortBy;
  String get sortDirection => _sortDirection;
  String? get paymentMethod => _paymentMethod;
  String? get status => _status;

  // Computed getters
  bool get hasNextPage => _links?.next != null;
  bool get hasPrevPage => _links?.prev != null;
  int get totalTransactions => _meta?.total ?? 0;
  int get totalPages => _meta?.lastPage ?? 1;

  /// Load transactions with current filters
  Future<void> loadTransactions({bool refresh = false}) async {
    if (_isLoading) return;

    // Reset page if refresh
    if (refresh) {
      _currentPage = 1;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getTransactions(
        page: _currentPage,
        perPage: _perPage,
        search: _search,
        storeId: _storeId,
        userId: _userId,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
        minAmount: _minAmount,
        maxAmount: _maxAmount,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
        paymentMethod: _paymentMethod,
        status: _status,
      );

      final transactionListResponse = TransactionListResponse.fromJson(
        response,
      );

      if (refresh) {
        _transactions = transactionListResponse.data.data;
      } else {
        _transactions.addAll(transactionListResponse.data.data);
      }

      _meta = transactionListResponse.data.meta;
      _links = transactionListResponse.data.links;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load next page
  Future<void> loadNextPage() async {
    if (hasNextPage && !_isLoading) {
      _currentPage++;
      await loadTransactions();
    }
  }

  /// Load previous page
  Future<void> loadPreviousPage() async {
    if (hasPrevPage && !_isLoading && _currentPage > 1) {
      _currentPage--;
      await loadTransactions(refresh: true);
    }
  }

  /// Go to specific page
  Future<void> goToPage(int page) async {
    if (page != _currentPage && page > 0 && page <= totalPages && !_isLoading) {
      _currentPage = page;
      await loadTransactions(refresh: true);
    }
  }

  /// Refresh transactions
  Future<void> refreshTransactions() async {
    await loadTransactions(refresh: true);
  }

  // Filter setters
  void setSearch(String? search) {
    if (_search != search) {
      _search = search;
      _currentPage = 1;
      notifyListeners();
    }
  }

  void setStoreId(int storeId) {
    if (_storeId != storeId) {
      _storeId = storeId;
      _currentPage = 1;
      notifyListeners();
    }
  }

  void setUserId(int userId) {
    if (_userId != userId) {
      _userId = userId;
      _currentPage = 1;
      notifyListeners();
    }
  }

  void setDateRange(String? dateFrom, String? dateTo) {
    if (_dateFrom != dateFrom || _dateTo != dateTo) {
      _dateFrom = dateFrom;
      _dateTo = dateTo;
      _currentPage = 1;
      notifyListeners();
    }
  }

  void setAmountRange(double? minAmount, double? maxAmount) {
    if (_minAmount != minAmount || _maxAmount != maxAmount) {
      _minAmount = minAmount;
      _maxAmount = maxAmount;
      _currentPage = 1;
      notifyListeners();
    }
  }

  void setSorting(String sortBy, String sortDirection) {
    if (_sortBy != sortBy || _sortDirection != sortDirection) {
      _sortBy = sortBy;
      _sortDirection = sortDirection;
      _currentPage = 1;
      notifyListeners();
    }
  }

  void setPaymentMethod(String? paymentMethod) {
    if (_paymentMethod != paymentMethod) {
      _paymentMethod = paymentMethod;
      _currentPage = 1;
      notifyListeners();
    }
  }

  void setStatus(String? status) {
    if (_status != status) {
      _status = status;
      _currentPage = 1;
      notifyListeners();
    }
  }

  void setPerPage(int perPage) {
    if (_perPage != perPage) {
      _perPage = perPage;
      _currentPage = 1;
      notifyListeners();
    }
  }

  /// Clear all filters
  void clearFilters() {
    _search = null;
    _storeId = 1;
    _userId = 1;
    _dateFrom = null;
    _dateTo = null;
    _minAmount = null;
    _maxAmount = null;
    _sortBy = 'created_at';
    _sortDirection = 'desc';
    _paymentMethod = null;
    _status = null;
    _currentPage = 1;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get transaction by ID from current list
  TransactionListItem? getTransactionById(int id) {
    try {
      return _transactions.firstWhere((transaction) => transaction.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Apply current month filter
  void applyCurrentMonthFilter() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);

    setDateRange(
      '${firstDay.year}-${firstDay.month.toString().padLeft(2, '0')}-${firstDay.day.toString().padLeft(2, '0')}',
      '${lastDay.year}-${lastDay.month.toString().padLeft(2, '0')}-${lastDay.day.toString().padLeft(2, '0')}',
    );
  }

  /// Apply today filter
  void applyTodayFilter() {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    setDateRange(todayStr, todayStr);
  }

  /// Apply today and yesterday filter
  void applyTodayAndYesterdayFilter() {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    final yesterdayStr =
        '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    setDateRange(yesterdayStr, todayStr);
  }

  /// Apply this week filter
  void applyThisWeekFilter() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    setDateRange(
      '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}',
      '${weekEnd.year}-${weekEnd.month.toString().padLeft(2, '0')}-${weekEnd.day.toString().padLeft(2, '0')}',
    );
  }
}
