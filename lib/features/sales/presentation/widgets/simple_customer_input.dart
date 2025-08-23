import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../customers/providers/customer_provider.dart';
import '../../../customers/data/models/customer.dart';

class SimpleCustomerInput extends StatefulWidget {
  final Function(Customer?) onCustomerSelected;
  final Customer? initialCustomer;

  const SimpleCustomerInput({
    super.key,
    required this.onCustomerSelected,
    this.initialCustomer,
  });

  @override
  State<SimpleCustomerInput> createState() => _SimpleCustomerInputState();
}

class _SimpleCustomerInputState extends State<SimpleCustomerInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Customer> _suggestions = [];
  bool _isLoading = false;
  Customer? _selectedCustomer;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _selectedCustomer = widget.initialCustomer;
    if (_selectedCustomer != null) {
      _controller.text = _selectedCustomer!.name;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    if (value.trim().isEmpty) {
      setState(() {
        _suggestions.clear();
        _showSuggestions = false;
        _selectedCustomer = null;
      });
      widget.onCustomerSelected(null);
      return;
    }

    setState(() {
      _isLoading = true;
      _showSuggestions = true;
    });

    _searchCustomers(value.trim());
  }

  Future<void> _searchCustomers(String query) async {
    try {
      final customerProvider = Provider.of<CustomerProvider>(
        context,
        listen: false,
      );
      final results = await customerProvider.searchCustomers(query);

      if (mounted) {
        setState(() {
          _suggestions = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestions.clear();
          _isLoading = false;
        });
      }
    }
  }

  void _selectCustomer(Customer customer) {
    setState(() {
      _selectedCustomer = customer;
      _controller.text = customer.name;
      _suggestions.clear();
      _showSuggestions = false;
    });
    _focusNode.unfocus();
    widget.onCustomerSelected(customer);
  }

  void _clearSelection() {
    setState(() {
      _selectedCustomer = null;
      _suggestions.clear();
      _showSuggestions = false;
    });
    _controller.clear();
    widget.onCustomerSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input field
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: 'Nama Customer',
            hintText: 'Ketik nama customer...',
            prefixIcon: Icon(
              _selectedCustomer != null ? Icons.person : Icons.person_outline,
              color: _selectedCustomer != null ? Colors.green : null,
            ),
            suffixIcon:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                    : _selectedCustomer != null || _controller.text.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSelection,
                    )
                    : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            isDense: true,
          ),
          style: const TextStyle(fontSize: 14),
          onChanged: _onTextChanged,
          onTap: () {
            if (_controller.text.isNotEmpty &&
                _suggestions.isEmpty &&
                !_isLoading) {
              _searchCustomers(_controller.text);
            }
          },
        ),

        // Suggestions dropdown
        if (_showSuggestions && (_suggestions.isNotEmpty || _isLoading)) ...[
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child:
                _isLoading
                    ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'Mencari...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                    : _suggestions.isEmpty
                    ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'Tidak ditemukan',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final customer = _suggestions[index];
                        return ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.person,
                            color: Colors.blue,
                            size: 20,
                          ),
                          title: Text(
                            customer.name,
                            style: const TextStyle(fontSize: 14),
                          ),
                          subtitle: Text(
                            customer.phone,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onTap: () => _selectCustomer(customer),
                        );
                      },
                    ),
          ),
        ],

        // Selected customer indicator
        if (_selectedCustomer != null) ...[
          const SizedBox(height: 4),
          Text(
            '✓ ${_selectedCustomer!.phone}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],

        // Helper text when empty
        if (_controller.text.isEmpty && _selectedCustomer == null) ...[
          const SizedBox(height: 4),
          Text(
            'Opsional - customer existing akan muncul saat mengetik',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }
}
