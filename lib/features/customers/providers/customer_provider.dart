import 'package:flutter/material.dart';
import '../data/services/customer_api_service.dart';
import '../data/models/customer.dart';
import '../data/models/create_customer_request.dart';
import '../data/models/update_customer_request.dart';
import '../data/models/customer_list_response.dart';
import '../data/models/customer_group.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerApiService _apiService = CustomerApiService();

  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isCreating = false;

  // Pagination properties
  PaginationMeta? _paginationMeta;
  bool _isLoadingMore = false;
  String? _currentSearchQuery;

  // Customer detail properties
  Customer? _customerDetail;
  bool _isLoadingDetail = false;
  bool _isUpdating = false;

  // Customer groups properties
  List<CustomerGroup> _customerGroups = [];
  bool _isLoadingGroups = false;
  String? _groupsErrorMessage;

  // Getters
  List<Customer> get customers => _customers;
  Customer? get selectedCustomer => _selectedCustomer;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isCreating => _isCreating;

  // Pagination getters
  PaginationMeta? get paginationMeta => _paginationMeta;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasNextPage => _paginationMeta?.hasNextPage ?? false;
  bool get hasPrevPage => _paginationMeta?.hasPrevPage ?? false;
  int get currentPage => _paginationMeta?.currentPage ?? 1;
  int get totalPages => _paginationMeta?.lastPage ?? 1;
  int get totalCustomers => _paginationMeta?.total ?? 0;

  // Customer detail getters
  Customer? get customerDetail => _customerDetail;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get isUpdating => _isUpdating;

  // Customer groups getters
  List<CustomerGroup> get customerGroups => _customerGroups;
  bool get isLoadingGroups => _isLoadingGroups;
  String? get groupsErrorMessage => _groupsErrorMessage;

  /// Create new customer
  Future<Customer?> createCustomer({
    required String name,
    required String phone,
    String? address,
    int? customerGroupId,
  }) async {
    _isCreating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = CreateCustomerRequest(
        name: name.trim(),
        phone: phone.trim(),
        address: address,
        customerGroupId: customerGroupId,
      );

      final response = await _apiService.createCustomer(request);

      if (response.isSuccess && response.data != null) {
        // Add new customer to local list
        _customers.insert(0, response.data!);
        _errorMessage = null;

        _isCreating = false;
        notifyListeners();

        return response.data;
      } else {
        _errorMessage = response.message;
        _isCreating = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = 'Failed to create customer: ${e.toString()}';
      _isCreating = false;
      notifyListeners();
      return null;
    }
  }

  /// Load customers with pagination
  Future<void> loadCustomersWithPagination({
    int page = 1,
    String? search,
    bool refresh = false,
  }) async {
    // If refreshing or first page, show full loading
    if (refresh || page == 1) {
      _isLoading = true;
      _customers.clear();
      _paginationMeta = null;
    } else {
      // Loading more pages
      _isLoadingMore = true;
    }

    _errorMessage = null;
    _currentSearchQuery = search;
    notifyListeners();

    try {
      final response = await _apiService.getCustomersWithPagination(
        page: page,
        perPage: 15,
        search: search,
      );

      if (response.isSuccess && response.data != null) {
        _paginationMeta = response.data!.meta;

        if (page == 1 || refresh) {
          // Replace customers for first page or refresh
          _customers = response.data!.data;
        } else {
          // Append customers for additional pages
          _customers.addAll(response.data!.data);
        }

        _errorMessage = null;
      } else {
        _errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Failed to load customers';
      }
    } catch (e) {
      _errorMessage = 'Failed to load customers: ${e.toString()}';
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Load next page of customers
  Future<void> loadNextPage() async {
    if (!hasNextPage || _isLoadingMore || _isLoading) return;

    await loadCustomersWithPagination(
      page: currentPage + 1,
      search: _currentSearchQuery,
    );
  }

  /// Refresh customers list
  Future<void> refreshCustomers({String? search}) async {
    await loadCustomersWithPagination(page: 1, search: search, refresh: true);
  }

  /// Load customers from API (Legacy method)
  Future<void> loadCustomers({bool refresh = false}) async {
    if (!refresh && _customers.isNotEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getCustomers(perPage: 100);

      final List<dynamic>? customersData = response['data']?['data'];
      if (customersData != null) {
        _customers = customersData
            .map((customerJson) => Customer.fromJson(customerJson))
            .toList();
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load customers: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search customers
  Future<List<Customer>> searchCustomers(String query) async {
    if (query.trim().isEmpty) return _customers;

    try {
      return await _apiService.searchCustomers(query.trim());
    } catch (e) {
      _errorMessage = 'Search failed: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }

  /// Select customer
  void selectCustomer(Customer? customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }

  /// Clear selected customer
  void clearSelection() {
    _selectedCustomer = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Check if customer exists by phone
  bool isCustomerExistsByPhone(String phone) {
    return _customers.any((customer) => customer.phone == phone.trim());
  }

  /// Get customer by phone
  Customer? getCustomerByPhone(String phone) {
    try {
      return _customers.firstWhere(
        (customer) => customer.phone == phone.trim(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get customer detail by ID
  Future<Customer?> getCustomerDetail(int customerId) async {
    _isLoadingDetail = true;
    _errorMessage = null;
    _customerDetail = null;
    notifyListeners();

    try {
      final customer = await _apiService.getCustomer(customerId);
      _customerDetail = customer;
      _errorMessage = null;

      notifyListeners();
      return customer;
    } catch (e) {
      _errorMessage = 'Failed to load customer details: ${e.toString()}';
      notifyListeners();
      return null;
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  /// Update customer by ID
  Future<Customer?> updateCustomer({
    required int customerId,
    required String name,
    required String phone,
    String? address,
    int? customerGroupId,
  }) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = UpdateCustomerRequest(
        name: name.trim(),
        phone: phone.trim(),
        address: address,
        customerGroupId: customerGroupId,
      );

      final response = await _apiService.updateCustomer(customerId, request);

      if (response.isSuccess && response.data != null) {
        // Update customer in local list
        final index = _customers.indexWhere((c) => c.id == customerId);
        if (index != -1) {
          _customers[index] = response.data!;
        }

        // Update customer detail if it's the same customer
        if (_customerDetail?.id == customerId) {
          _customerDetail = response.data!;
        }

        // Update selected customer if it's the same customer
        if (_selectedCustomer?.id.toString() == customerId.toString()) {
          _selectedCustomer = response.data!;
        }

        _errorMessage = null;
        _isUpdating = false;
        notifyListeners();

        return response.data;
      } else {
        _errorMessage = response.message;
        _isUpdating = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = 'Failed to update customer: ${e.toString()}';
      _isUpdating = false;
      notifyListeners();
      return null;
    }
  }

  /// Delete customer by ID
  Future<bool> deleteCustomer(int customerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.deleteCustomer(customerId);

      // Remove from local list
      _customers.removeWhere((c) => c.id == customerId);

      // Clear detail if it's the deleted customer
      if (_customerDetail?.id == customerId) {
        _customerDetail = null;
      }

      // Clear selection if it's the deleted customer
      if (_selectedCustomer?.id.toString() == customerId.toString()) {
        _selectedCustomer = null;
      }

      _errorMessage = null;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete customer: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load customer groups
  Future<void> loadCustomerGroups() async {
    _isLoadingGroups = true;
    _groupsErrorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getCustomerGroups();

      if (response.isSuccess) {
        _customerGroups = response.data;
        _groupsErrorMessage = null;
      } else {
        _groupsErrorMessage = response.message;
      }
    } catch (e) {
      _groupsErrorMessage = 'Failed to load customer groups: ${e.toString()}';
    } finally {
      _isLoadingGroups = false;
      notifyListeners();
    }
  }

  /// Clear customer detail
  void clearCustomerDetail() {
    _customerDetail = null;
    notifyListeners();
  }

  /// Load customers with outstanding debts
  Future<void> loadCustomersWithOutstanding({
    int page = 1,
    bool loadMore = false,
    String sortDirection = 'asc',
  }) async {
    if (loadMore) {
      _isLoadingMore = true;
    } else {
      _isLoading = true;
      _customers = [];
    }
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getCustomersWithOutstanding(
        page: page,
        perPage: 15,
        sortDirection: sortDirection,
      );

      if (response.isSuccess && response.data != null) {
        if (loadMore) {
          _customers.addAll(response.data!.data);
        } else {
          _customers = response.data!.data;
        }
        _paginationMeta = response.data!.meta;
        _errorMessage = null;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage =
          'Failed to load customers with outstanding: ${e.toString()}';
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
