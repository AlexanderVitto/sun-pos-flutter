import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../customers/providers/customer_provider.dart';
import '../../../customers/data/models/customer.dart' as ApiCustomer;
import 'pos_transaction_page.dart';
import '../../providers/pending_transaction_provider.dart';
import '../../providers/cart_provider.dart';

class CustomerSelectionPage extends StatefulWidget {
  const CustomerSelectionPage({super.key});

  @override
  State<CustomerSelectionPage> createState() => _CustomerSelectionPageState();
}

class _CustomerSelectionPageState extends State<CustomerSelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearching = false;
  List<ApiCustomer.Customer> _searchResults = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Load initial customers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerProvider = Provider.of<CustomerProvider>(
        context,
        listen: false,
      );
      customerProvider.loadCustomers(refresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final customerProvider = Provider.of<CustomerProvider>(
        context,
        listen: false,
      );
      customerProvider.loadNextPage();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });

    if (query.trim().isEmpty) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
      return;
    }

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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching customers: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectCustomer(ApiCustomer.Customer customer) async {
    final pendingProvider = Provider.of<PendingTransactionProvider>(
      context,
      listen: false,
    );
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // Check if there's already a pending transaction for this customer
    final existingTransaction = pendingProvider.getPendingTransaction(
      customer.id.toString(),
    );

    if (existingTransaction != null) {
      // Load existing transaction into cart
      cartProvider.clearCart();
      for (final item in existingTransaction.cartItems) {
        // CartItem already contains Product, so just add the CartItem back
        cartProvider.addItem(item.product, quantity: item.quantity);
      }
      cartProvider.setCustomerFromApi(customer);

      // Show confirmation message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Melanjutkan transaksi untuk ${customer.name}'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } else {
      // Start fresh transaction
      cartProvider.clearCart();
      cartProvider.setCustomerFromApi(customer);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Memulai transaksi baru untuk ${customer.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }

    // Navigate to POS transaction page
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const POSTransactionPage()),
      );
    }
  }

  Future<void> _createNewCustomer() async {
    if (_searchQuery.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan nama customer terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final phone = await _showPhoneInputDialog(_searchQuery.trim());
    if (phone == null || phone.trim().isEmpty) return;

    try {
      final customerProvider = Provider.of<CustomerProvider>(
        context,
        listen: false,
      );
      final newCustomer = await customerProvider.createCustomer(
        name: _searchQuery.trim(),
        phone: phone.trim(),
      );

      if (newCustomer != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer "${newCustomer.name}" berhasil dibuat'),
            backgroundColor: Colors.green,
          ),
        );

        // Auto-select the newly created customer
        await _selectCustomer(newCustomer);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat customer: $e'),
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
                Text('Customer: $customerName'),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Telepon',
                    hintText: 'Contoh: 081234567890',
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Pilih Pelanggan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, color: Color(0xFF6B7280)),
            onPressed: () {
              final customerProvider = Provider.of<CustomerProvider>(
                context,
                listen: false,
              );
              customerProvider.loadCustomers(refresh: true);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Modern Header with gradient
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6366f1), // Indigo
                  const Color(0xFF8b5cf6), // Purple
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366f1).withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih pelanggan untuk memulai transaksi',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Cari Pelanggan',
                        hintText: 'Ketik nama pelanggan...',
                        prefixIcon: const Icon(
                          LucideIcons.search,
                          color: Color(0xFF6B7280),
                        ),
                        suffixIcon:
                            _isSearching
                                ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                                : (_searchController.text.isNotEmpty
                                    ? IconButton(
                                      icon: const Icon(
                                        LucideIcons.x,
                                        color: Color(0xFF6B7280),
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        _onSearchChanged('');
                                      },
                                    )
                                    : null),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Results
          Expanded(child: _buildCustomerList()),
        ],
      ),
    );
  }

  Widget _buildCustomerList() {
    if (_searchQuery.isNotEmpty) {
      // Show search results
      return _buildSearchResults();
    } else {
      // Show all customers
      return _buildAllCustomers();
    }
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty && _searchQuery.isNotEmpty) {
      return _buildNoResultsFound();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final customer = _searchResults[index];
        return _buildCustomerCard(customer);
      },
    );
  }

  Widget _buildAllCustomers() {
    return Consumer<CustomerProvider>(
      builder: (context, customerProvider, child) {
        if (customerProvider.isLoading && customerProvider.customers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (customerProvider.customers.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      LucideIcons.users,
                      size: 40,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Belum ada pelanggan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ketik nama untuk membuat pelanggan baru',
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          itemCount:
              customerProvider.customers.length +
              (customerProvider.hasNextPage ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= customerProvider.customers.length) {
              // Loading indicator for next page
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final customer = customerProvider.customers[index];
            return _buildCustomerCard(customer);
          },
        );
      },
    );
  }

  Widget _buildNoResultsFound() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                LucideIcons.searchX,
                size: 40,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Pelanggan "${_searchQuery}" tidak ditemukan',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _createNewCustomer,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.plus,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Buat Pelanggan: "$_searchQuery"',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(ApiCustomer.Customer customer) {
    return Consumer<PendingTransactionProvider>(
      builder: (context, pendingProvider, child) {
        final hasPendingTransaction =
            pendingProvider.getPendingTransaction(customer.id.toString()) !=
            null;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  hasPendingTransaction
                      ? const Color(0xFFFB923C)
                      : const Color(0xFFE2E8F0),
              width: hasPendingTransaction ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _selectCustomer(customer),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors:
                              hasPendingTransaction
                                  ? [
                                    const Color(0xFFFB923C),
                                    const Color(0xFFF97316),
                                  ]
                                  : [
                                    const Color(0xFF3B82F6),
                                    const Color(0xFF1E40AF),
                                  ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (hasPendingTransaction
                                    ? const Color(0xFFFB923C)
                                    : const Color(0xFF3B82F6))
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          customer.name.isNotEmpty
                              ? customer.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Customer Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.phone,
                                size: 14,
                                color: Color(0xFF64748B),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                customer.phone,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          if (hasPendingTransaction) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFED7AA),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    LucideIcons.clock,
                                    size: 12,
                                    color: Color(0xFFFB923C),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Ada transaksi pending',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFFB923C),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Arrow
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        LucideIcons.chevronRight,
                        size: 16,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
