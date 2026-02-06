import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../data/models/customer.dart';
import 'add_customer_page.dart';
import '../widgets/customer_list_item.dart';
import 'customer_detail_page.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _currentSearch = '';

  @override
  void initState() {
    super.initState();

    // Load initial customers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadCustomersWithPagination();
    });

    // Setup infinite scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when near the bottom
      final provider = context.read<CustomerProvider>();
      if (provider.hasNextPage &&
          !provider.isLoadingMore &&
          !provider.isLoading) {
        provider.loadNextPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: _showAddCustomerDialog,
            icon: const Icon(Icons.person_add),
            tooltip: 'Add Customer',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search customers by name or phone...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // Customer List
          Expanded(
            child: Consumer<CustomerProvider>(
              builder: (context, customerProvider, child) {
                return RefreshIndicator(
                  onRefresh: () => _refreshCustomers(),
                  child: _buildCustomerList(customerProvider),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCustomerDialog,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCustomerList(CustomerProvider provider) {
    if (provider.isLoading && provider.customers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.customers.isEmpty) {
      return _buildErrorWidget(provider);
    }

    if (provider.customers.isEmpty) {
      return _buildEmptyWidget();
    }

    return Column(
      children: [
        // Statistics Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing ${provider.customers.length} of ${provider.totalCustomers} customers',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              if (_currentSearch.isNotEmpty)
                Text(
                  'Search: "$_currentSearch"',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),

        // Customer List
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount:
                provider.customers.length + (provider.hasNextPage ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= provider.customers.length) {
                // Loading more indicator
                return Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: provider.isLoadingMore
                      ? const CircularProgressIndicator()
                      : const SizedBox.shrink(),
                );
              }

              final customer = provider.customers[index];
              return CustomerListItem(
                customer: customer,
                onTap: () => _onCustomerTap(customer),
                onEdit: () => _onCustomerEdit(customer),
                onDelete: () => _onCustomerDelete(customer),
              );
            },
          ),
        ),

        // Pagination Info Footer
        if (provider.paginationMeta != null)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Page ${provider.currentPage} of ${provider.totalPages}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: provider.hasPrevPage
                          ? () => _loadPage(provider.currentPage - 1)
                          : null,
                      icon: const Icon(Icons.chevron_left),
                      iconSize: 20,
                    ),
                    IconButton(
                      onPressed: provider.hasNextPage
                          ? () => _loadPage(provider.currentPage + 1)
                          : null,
                      icon: const Icon(Icons.chevron_right),
                      iconSize: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildErrorWidget(CustomerProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Failed to load customers',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage!,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshCustomers,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _currentSearch.isNotEmpty
                  ? 'No customers found'
                  : 'No customers yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _currentSearch.isNotEmpty
                  ? 'Try adjusting your search terms'
                  : 'Add your first customer to get started',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddCustomerDialog,
              icon: const Icon(Icons.person_add),
              label: const Text('Add Customer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSearchChanged(String value) {
    if (value == _currentSearch) return;

    _currentSearch = value;

    // Debounce search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (value == _searchController.text && mounted) {
        _performSearch(value.trim());
      }
    });
  }

  void _performSearch(String query) {
    context.read<CustomerProvider>().loadCustomersWithPagination(
      page: 1,
      search: query.isEmpty ? null : query,
      refresh: true,
    );
  }

  void _clearSearch() {
    _searchController.clear();
    _currentSearch = '';
    _performSearch('');
  }

  Future<void> _refreshCustomers() async {
    final search = _currentSearch.isEmpty ? null : _currentSearch;
    await context.read<CustomerProvider>().refreshCustomers(search: search);
  }

  void _loadPage(int page) {
    final search = _currentSearch.isEmpty ? null : _currentSearch;
    context.read<CustomerProvider>().loadCustomersWithPagination(
      page: page,
      search: search,
      refresh: true,
    );
  }

  Future<void> _showAddCustomerDialog() async {
    final customer = await Navigator.push<Customer>(
      context,
      MaterialPageRoute(builder: (context) => const AddCustomerPage()),
    );

    if (customer != null && mounted) {
      // Refresh the list to show the new customer
      _refreshCustomers();
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'refresh':
        _refreshCustomers();
        break;
    }
  }

  void _onCustomerTap(Customer customer) {
    // Navigate to customer details page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            CustomerDetailPage(customerId: customer.id, customer: customer),
      ),
    );
  }

  void _onCustomerEdit(Customer customer) {
    // Navigate to customer details page and show edit
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            CustomerDetailPage(customerId: customer.id, customer: customer),
      ),
    );
  }

  void _onCustomerDelete(Customer customer) {
    // Show delete confirmation with provider integration
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this customer?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                border: Border.all(color: Colors.red[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer: ${customer.name}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  Text(
                    'Phone: ${customer.phone}',
                    style: TextStyle(color: Colors.red[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          Consumer<CustomerProvider>(
            builder: (context, provider, child) {
              return ElevatedButton(
                onPressed: provider.isLoading
                    ? null
                    : () => _deleteCustomer(customer),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: provider.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Delete'),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCustomer(Customer customer) async {
    final success = await context.read<CustomerProvider>().deleteCustomer(
      customer.id,
    );

    if (mounted) {
      Navigator.of(context).pop(); // Close dialog

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${customer.name} has been deleted'),
            backgroundColor: Colors.red,
          ),
        );
        // Refresh the list
        _refreshCustomers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete ${customer.name}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
