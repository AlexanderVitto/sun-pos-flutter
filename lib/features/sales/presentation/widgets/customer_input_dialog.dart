import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../customers/providers/customer_provider.dart';
import '../../../customers/data/models/customer.dart';

class CustomerInputDialog extends StatefulWidget {
  final Customer? initialCustomer;

  const CustomerInputDialog({super.key, this.initialCustomer});

  @override
  State<CustomerInputDialog> createState() => _CustomerInputDialogState();
}

class _CustomerInputDialogState extends State<CustomerInputDialog> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Customer> _searchResults = [];
  bool _isSearching = false;
  Customer? _selectedCustomer;

  @override
  void initState() {
    super.initState();
    _selectedCustomer = widget.initialCustomer;
    if (_selectedCustomer != null) {
      _searchController.text = _selectedCustomer!.name;
    }

    // Auto focus pada search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
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
        _searchResults.clear();
        _isSearching = false;
      });
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
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults.clear();
          _isSearching = false;
        });
      }
    }
  }

  void _selectCustomer(Customer customer) {
    setState(() {
      _selectedCustomer = customer;
      _searchController.text = customer.name;
      _searchResults.clear();
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedCustomer = null;
      _searchResults.clear();
    });
    _searchController.clear();
    _focusNode.requestFocus();
  }

  void _confirmSelection() {
    Navigator.of(context).pop(_selectedCustomer);
  }

  void _cancelDialog() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.8, // Max 80% of screen height
          minHeight: 300,
        ),
        child: Column(
          children: [
            // Fixed Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  const Icon(Icons.person_search, color: Colors.blue, size: 24),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Masukkan Pembeli',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _cancelDialog,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Field
                    TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        labelText: 'Nama Pembeli',
                        hintText: 'Ketik nama pembeli...',
                        prefixIcon: Icon(
                          _selectedCustomer != null
                              ? Icons.person
                              : Icons.person_outline,
                          color:
                              _selectedCustomer != null ? Colors.green : null,
                        ),
                        suffixIcon:
                            _isSearching
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                                : _searchController.text.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: _clearSelection,
                                )
                                : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: _onSearchChanged,
                    ),

                    const SizedBox(height: 16),

                    // Selected Customer Display
                    if (_selectedCustomer != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedCustomer!.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedCustomer!.phone,
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Search Results
                    if (_searchResults.isNotEmpty) ...[
                      const Text(
                        'Pilih Pembeli:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 150),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final customer = _searchResults[index];
                            final isSelected =
                                _selectedCustomer?.id == customer.id;

                            return ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.person,
                                color: isSelected ? Colors.green : Colors.blue,
                              ),
                              title: Text(
                                customer.name,
                                style: TextStyle(
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  color:
                                      isSelected ? Colors.green : Colors.black,
                                ),
                              ),
                              subtitle: Text(
                                customer.phone,
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? Colors.green[700]
                                          : Colors.grey[600],
                                ),
                              ),
                              trailing:
                                  isSelected
                                      ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      )
                                      : null,
                              onTap: () => _selectCustomer(customer),
                              tileColor: isSelected ? Colors.green[50] : null,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ] else if (_isSearching) ...[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 8),
                              Text(
                                'Mencari pembeli...',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else if (_searchController.text.isNotEmpty &&
                        _searchResults.isEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              color: Colors.grey,
                              size: 32,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Pembeli tidak ditemukan',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Helper Text
                    if (_searchController.text.isEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 32,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Ketik nama pembeli untuk mencari',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Pembeli yang sudah terdaftar akan muncul dalam daftar',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Fixed Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                children: [
                  // Skip Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Lewati',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Confirm Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _selectedCustomer != null ? _confirmSelection : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Pilih Pembeli',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
