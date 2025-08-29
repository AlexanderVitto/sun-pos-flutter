import 'package:flutter/material.dart';
import '../data/services/cash_flow_api_service.dart';
import '../data/models/cash_flow.dart';
import '../data/models/create_cash_flow_request.dart';
import '../data/models/cash_flow_response.dart';

class CashFlowProvider extends ChangeNotifier {
  final CashFlowApiService _apiService = CashFlowApiService();

  // State variables
  List<CashFlow> _cashFlows = [];
  bool _isLoading = false;
  bool _isCreating = false;
  String? _errorMessage;
  PaginationMeta? _paginationMeta;

  // Filters
  String? _selectedType;
  String? _selectedCategory;
  String? _dateFrom;
  String? _dateTo;
  int _currentPage = 1;
  final int _perPage = 15;

  // Getters
  List<CashFlow> get cashFlows => _cashFlows;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  String? get errorMessage => _errorMessage;
  PaginationMeta? get paginationMeta => _paginationMeta;
  String? get selectedType => _selectedType;
  String? get selectedCategory => _selectedCategory;
  String? get dateFrom => _dateFrom;
  String? get dateTo => _dateTo;
  int get currentPage => _currentPage;

  // Filter categories
  final List<String> categories = [
    'sales',
    'expense',
    'transfer',
    'investment',
    'loan',
    'other',
  ];

  // Filter types
  final List<String> types = ['in', 'out'];

  /// Load cash flows with current filters
  Future<void> loadCashFlows({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _cashFlows.clear();
      }

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.getCashFlows(
        storeId: 1,
        type: _selectedType,
        category: _selectedCategory,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
        page: _currentPage,
        perPage: _perPage,
      );

      if (response.success) {
        if (refresh || _currentPage == 1) {
          _cashFlows = response.cashFlows;
        } else {
          _cashFlows.addAll(response.cashFlows);
        }
        _paginationMeta = response.pagination;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more cash flows (pagination)
  Future<void> loadMoreCashFlows() async {
    if (_paginationMeta?.hasNextPage == true && !_isLoading) {
      _currentPage++;
      await loadCashFlows(refresh: false);
    }
  }

  /// Create new cash flow
  Future<bool> createCashFlow(CreateCashFlowRequest request) async {
    try {
      _isCreating = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.createCashFlow(request);

      if (response.success) {
        // Add new cash flow to the beginning of the list
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  /// Set type filter
  void setTypeFilter(String? type) {
    if (_selectedType != type) {
      _selectedType = type;
      _currentPage = 1;
      loadCashFlows(refresh: true);
    }
  }

  /// Set category filter
  void setCategoryFilter(String? category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      _currentPage = 1;
      loadCashFlows(refresh: true);
    }
  }

  /// Set date range filter
  void setDateRangeFilter(String? dateFrom, String? dateTo) {
    if (_dateFrom != dateFrom || _dateTo != dateTo) {
      _dateFrom = dateFrom;
      _dateTo = dateTo;
      _currentPage = 1;
      loadCashFlows(refresh: true);
    }
  }

  /// Clear all filters
  void clearFilters() {
    _selectedType = null;
    _selectedCategory = null;
    _dateFrom = null;
    _dateTo = null;
    _currentPage = 1;
    loadCashFlows(refresh: true);
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get total amount for current filters
  double get totalInAmount {
    return _cashFlows
        .where((cf) => cf.type == 'in')
        .fold(0.0, (sum, cf) => sum + cf.amount);
  }

  double get totalOutAmount {
    return _cashFlows
        .where((cf) => cf.type == 'out')
        .fold(0.0, (sum, cf) => sum + cf.amount);
  }

  double get netAmount => totalInAmount - totalOutAmount;

  /// Get formatted category name
  String getFormattedCategory(String category) {
    switch (category.toLowerCase()) {
      case 'sales':
        return 'Penjualan';
      case 'expense':
        return 'Pengeluaran';
      case 'transfer':
        return 'Transfer';
      case 'investment':
        return 'Investasi';
      case 'loan':
        return 'Pinjaman';
      default:
        return 'Lainnya';
    }
  }

  /// Get formatted type name
  String getFormattedType(String type) {
    return type == 'in' ? 'Masuk' : 'Keluar';
  }
}
