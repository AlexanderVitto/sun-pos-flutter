import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../customers/providers/customer_provider.dart';
import '../../../customers/data/models/customer.dart';

class CustomerSelectorWidget extends StatefulWidget {
  final Function(Customer?) onCustomerSelected;
  final Customer? initialCustomer;

  const CustomerSelectorWidget({
    super.key,
    required this.onCustomerSelected,
    this.initialCustomer,
  });

  @override
  State<CustomerSelectorWidget> createState() => _CustomerSelectorWidgetState();
}

class _CustomerSelectorWidgetState extends State<CustomerSelectorWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;
  List<Customer> _searchResults = [];
  Customer? _selectedCustomer;
  bool _showCreateOption = false;

  @override
  void initState() {
    super.initState();
    _selectedCustomer = widget.initialCustomer;
    if (_selectedCustomer != null) {
      _searchController.text = _selectedCustomer!.name;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults.clear();
        _showCreateOption = false;
        _selectedCustomer = null;
      });
      widget.onCustomerSelected(null);
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _performSearch(query.trim());
  }

  Future<void> _performSearch(String query) async {
    try {
      final customerProvider = Provider.of<CustomerProvider>(
        context,
        listen: false,
      );
      final results = await customerProvider.searchCustomers(query);

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
          _showCreateOption =
              results.isEmpty ||
              !results.any((c) => c.name.toLowerCase() == query.toLowerCase());
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults.clear();
          _isSearching = false;
          _showCreateOption = true;
        });
      }
    }
  }

  void _selectCustomer(Customer customer) {
    setState(() {
      _selectedCustomer = customer;
      _searchController.text = customer.name;
      _searchResults.clear();
      _showCreateOption = false;
    });
    _focusNode.unfocus();
    widget.onCustomerSelected(customer);
  }

  Future<void> _createNewCustomer(String name) async {
    // Show phone input dialog
    final phone = await _showPhoneInputDialog(name);
    if (phone == null || phone.trim().isEmpty) return;

    try {
      final customerProvider = Provider.of<CustomerProvider>(
        context,
        listen: false,
      );
      final newCustomer = await customerProvider.createCustomer(
        name: name.trim(),
        phone: phone.trim(),
      );

      if (newCustomer != null && mounted) {
        _selectCustomer(newCustomer);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Customer "${newCustomer.name}" berhasil dibuat'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuat customer baru'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _showPhoneInputDialog(String customerName) async {
    final phoneController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Nomor Telepon Customer'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer: $customerName',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Telepon',
                    hintText: 'Masukkan nomor telepon...',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  final phone = phoneController.text.trim();
                  if (phone.isNotEmpty) {
                    Navigator.of(context).pop(phone);
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input field
        TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: 'Nama Customer',
            hintText: 'Ketik nama customer...',
            prefixIcon: const Icon(Icons.person_search),
            suffixIcon:
                _isSearching
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : _selectedCustomer != null
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _selectedCustomer = null;
                          _searchResults.clear();
                          _showCreateOption = false;
                        });
                        widget.onCustomerSelected(null);
                      },
                    )
                    : null,
            border: const OutlineInputBorder(),
          ),
          onChanged: _onSearchChanged,
          onTap: () {
            if (_searchController.text.isNotEmpty &&
                _searchResults.isEmpty &&
                !_isSearching) {
              _performSearch(_searchController.text);
            }
          },
        ),

        // Selected customer info
        if (_selectedCustomer != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              border: Border.all(color: Colors.green),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedCustomer!.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        _selectedCustomer!.phone,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        // Search results dropdown
        if (_searchResults.isNotEmpty || _showCreateOption) ...[
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                // Existing customers
                ..._searchResults
                    .map(
                      (customer) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.person, color: Colors.blue),
                        title: Text(customer.name),
                        subtitle: Text(customer.phone),
                        onTap: () => _selectCustomer(customer),
                      ),
                    )
                    .toList(),

                // Create new customer option
                if (_showCreateOption &&
                    _searchController.text.trim().isNotEmpty)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.add_circle, color: Colors.green),
                    title: Text(
                      'Buat customer baru: "${_searchController.text.trim()}"',
                    ),
                    subtitle: const Text('Klik untuk menambah customer'),
                    onTap:
                        () => _createNewCustomer(_searchController.text.trim()),
                  ),
              ],
            ),
          ),
        ],

        // Helper text
        if (_searchController.text.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Ketik nama customer untuk mencari atau membuat yang baru',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
      ],
    );
  }
}
