import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../sales/providers/cart_provider.dart';
import '../providers/customer_provider.dart';
import '../data/models/customer.dart';
import '../presentation/pages/add_customer_page.dart';

class CustomerSelectionCard extends StatefulWidget {
  const CustomerSelectionCard({super.key});

  @override
  State<CustomerSelectionCard> createState() => _CustomerSelectionCardState();
}

class _CustomerSelectionCardState extends State<CustomerSelectionCard> {
  final TextEditingController _searchController = TextEditingController();
  List<Customer> _searchResults = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load customers when widget is ready
      Provider.of<CustomerProvider>(context, listen: false).loadCustomers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CartProvider, CustomerProvider>(
      builder: (context, cartProvider, customerProvider, child) {
        final selectedCustomer = cartProvider.selectedCustomer;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.blue, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Customer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (selectedCustomer != null)
                      IconButton(
                        onPressed: () => cartProvider.setCustomer(null),
                        icon: const Icon(Icons.clear, size: 20),
                        tooltip: 'Remove customer',
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Selected Customer Display
                if (selectedCustomer != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      border: Border.all(color: Colors.blue[200]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 20,
                          child: Text(
                            selectedCustomer.name.isNotEmpty
                                ? selectedCustomer.name[0].toUpperCase()
                                : 'C',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedCustomer.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                selectedCustomer.phone,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Customer Search/Selection
                  Column(
                    children: [
                      // Search Field
                      Stack(
                        children: [
                          TextFormField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search customer by name or phone...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      onPressed: _clearSearch,
                                      icon: const Icon(Icons.clear),
                                    )
                                  : null,
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            onChanged: _onSearchChanged,
                            onTap: () {
                              setState(() => _showSuggestions = true);
                            },
                          ),

                          // Search Results Dropdown
                          if (_showSuggestions && _searchResults.isNotEmpty)
                            Positioned(
                              top: 56,
                              left: 0,
                              right: 0,
                              child: Material(
                                elevation: 4,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  constraints: const BoxConstraints(
                                    maxHeight: 200,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: _searchResults.length,
                                    itemBuilder: (context, index) {
                                      final customer = _searchResults[index];
                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.blue[100],
                                          child: Text(
                                            customer.name.isNotEmpty
                                                ? customer.name[0].toUpperCase()
                                                : 'C',
                                            style: TextStyle(
                                              color: Colors.blue[700],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        title: Text(customer.name),
                                        subtitle: Text(customer.phone),
                                        onTap: () => _selectCustomer(customer),
                                        dense: true,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Add New Customer Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _showAddCustomerDialog,
                          icon: const Icon(Icons.person_add),
                          label: const Text('Add New Customer'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.blue[300]!),
                            foregroundColor: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Loading indicator
                if (customerProvider.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  ),

                // Error message
                if (customerProvider.errorMessage != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red[200]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      customerProvider.errorMessage!,
                      style: TextStyle(color: Colors.red[700], fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _showSuggestions = false;
      });
      return;
    }

    // Debounce search
    Future.delayed(const Duration(milliseconds: 300), () async {
      if (query == _searchController.text) {
        final customerProvider = Provider.of<CustomerProvider>(
          context,
          listen: false,
        );
        final results = await customerProvider.searchCustomers(query);

        if (mounted) {
          setState(() {
            _searchResults = results;
            _showSuggestions = true;
          });
        }
      }
    });
  }

  void _selectCustomer(Customer customer) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.setCustomerFromApi(customer);

    setState(() {
      _showSuggestions = false;
      _searchController.clear();
      _searchResults.clear();
    });

    // Hide keyboard
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Customer "${customer.name}" selected'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchResults.clear();
      _showSuggestions = false;
    });
  }

  Future<void> _showAddCustomerDialog() async {
    // Hide suggestions
    setState(() => _showSuggestions = false);

    final customer = await Navigator.push<Customer>(
      context,
      MaterialPageRoute(builder: (context) => const AddCustomerPage()),
    );

    if (customer != null) {
      // Automatically select the newly created customer
      _selectCustomer(customer);

      // Refresh customer list
      if (mounted) {
        Provider.of<CustomerProvider>(
          context,
          listen: false,
        ).loadCustomers(refresh: true);
      }
    }
  }
}
