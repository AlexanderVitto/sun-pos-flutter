import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/utils/role_permissions.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/customer_provider.dart';
import '../data/models/customer.dart';
import 'customer_outstanding_detail_page.dart';

class OutstandingCustomersPage extends StatefulWidget {
  const OutstandingCustomersPage({super.key});

  @override
  State<OutstandingCustomersPage> createState() =>
      _OutstandingCustomersPageState();
}

class _OutstandingCustomersPageState extends State<OutstandingCustomersPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CustomerProvider>();
      provider.loadCustomersWithOutstanding(
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );
    });
  }

  void _onScroll() {
    // Load more data when reaching bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final provider = context.read<CustomerProvider>();
      if (provider.hasNextPage && !provider.isLoadingMore) {
        provider.loadCustomersWithOutstanding(
          page: provider.currentPage + 1,
          loadMore: true,
          search: _searchQuery.isEmpty ? null : _searchQuery,
        );
      }
    }
  }

  Future<void> _refreshData() async {
    final provider = context.read<CustomerProvider>();
    await provider.loadCustomersWithOutstanding(
      search: _searchQuery.isEmpty ? null : _searchQuery,
    );
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });

    // Debounce search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchQuery == value) {
        _loadData();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _isSearching = false;
    });
    _loadData();
  }

  String _formatCurrency(double? amount) {
    if (amount == null) return 'Rp 0';
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        // Check if user has permission to access this page
        if (!RolePermissions.canAccessOutstandingCustomersByUser(user)) {
          return Scaffold(
            backgroundColor: const Color(0xFFf8fafc),
            appBar: AppBar(
              title: const Text(
                'Pelanggan Berhutang',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: const Color(0xFF6366f1),
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFef4444),
                            const Color(0xFFdc2626),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFef4444,
                            ).withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        LucideIcons.lock,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Akses Terbatas',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1f2937),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Maaf, Anda tidak memiliki akses ke halaman Pelanggan Berhutang. Silakan hubungi administrator untuk informasi lebih lanjut.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(LucideIcons.arrowLeft),
                      label: const Text('Kembali'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366f1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // User has access, show the normal page
        return Scaffold(
          backgroundColor: const Color(0xFFf8fafc),
          appBar: AppBar(
            title: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      hintText: 'Cari nama pelanggan...',
                      hintStyle: TextStyle(color: Colors.black),
                      border: InputBorder.none,
                    ),
                    onChanged: _onSearchChanged,
                  )
                : const Text(
                    'Pelanggan Berhutang',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
            backgroundColor: const Color(0xFF6366f1),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              if (_isSearching)
                IconButton(
                  icon: const Icon(LucideIcons.x, color: Colors.white),
                  onPressed: _clearSearch,
                )
              else
                IconButton(
                  icon: const Icon(LucideIcons.search, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
            ],
          ),
          body: Consumer<CustomerProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.customers.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.errorMessage != null && provider.customers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        LucideIcons.alertCircle,
                        size: 64,
                        color: Color(0xFFef4444),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        provider.errorMessage ?? 'Terjadi kesalahan',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6b7280),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadData,
                        icon: const Icon(LucideIcons.refreshCw),
                        label: const Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366f1),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (provider.customers.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _refreshData,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                      ),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF10b981,
                                ).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                LucideIcons.userCheck,
                                size: 64,
                                color: Color(0xFF10b981),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Tidak Ada Pelanggan Berhutang',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1f2937),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Semua pelanggan sudah lunas',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _refreshData,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Summary Card as SliverAppBar
                    SliverAppBar(
                      automaticallyImplyLeading: false,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      floating: true,
                      pinned: false,
                      snap: false,
                      expandedHeight: 200,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFef4444),
                                const Color(0xFFdc2626),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFef4444,
                                ).withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      LucideIcons.users,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${provider.totalCustomers} Pelanggan',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Memiliki hutang yang belum dibayar',
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.9,
                                            ),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Divider(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Total Hutang',
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.9,
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatCurrency(
                                            provider.customers.fold<double>(
                                              0,
                                              (sum, customer) =>
                                                  sum +
                                                  (customer
                                                          .totalOutstandingAmount ??
                                                      0),
                                            ),
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Total Transaksi',
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.9,
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatCurrency(
                                            provider.customers.fold<double>(
                                              0,
                                              (sum, customer) =>
                                                  sum +
                                                  (customer
                                                          .totalTransactionAmount ??
                                                      0),
                                            ),
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Customer List as SliverList
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index >= provider.customers.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final customer = provider.customers[index];
                            return _buildCustomerCard(customer);
                          },
                          childCount:
                              provider.customers.length +
                              (provider.isLoadingMore ? 1 : 0),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    final outstandingAmount = customer.totalOutstandingAmount ?? 0;
    final totalAmount = customer.totalTransactionAmount ?? 0;
    final paidAmount = totalAmount - outstandingAmount;
    final paymentPercentage = totalAmount > 0
        ? (paidAmount / totalAmount) * 100
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366f1).withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CustomerOutstandingDetailPage(customer: customer),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Info Header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6366f1),
                            const Color(0xFF8b5cf6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF6366f1,
                            ).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          customer.name.isNotEmpty
                              ? customer.name[0].toUpperCase()
                              : 'C',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  customer.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1f2937),
                                  ),
                                ),
                              ),
                              if (customer.hasCustomerGroup &&
                                  customer.customerGroupName != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF6366f1,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF6366f1,
                                      ).withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    'Grup ${customer.customerGroupName}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6366f1),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.phone,
                                size: 12,
                                color: Color(0xFF6b7280),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                customer.phone,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6b7280),
                                ),
                              ),
                              if (customer.transactionsCount != null) ...[
                                const SizedBox(width: 12),
                                const Icon(
                                  LucideIcons.shoppingCart,
                                  size: 12,
                                  color: Color(0xFF6b7280),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${customer.transactionsCount} transaksi',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6b7280),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Divider(color: Colors.grey.withValues(alpha: 0.2)),
                const SizedBox(height: 16),

                // Outstanding Amount (Main focus)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFfef2f2),
                        const Color(0xFFfee2e2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFef4444).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFef4444).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          LucideIcons.alertCircle,
                          color: Color(0xFFef4444),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Hutang',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF7f1d1d),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatCurrency(outstandingAmount),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFef4444),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Payment Progress
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sudah Dibayar: ${_formatCurrency(paidAmount)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6b7280),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${paymentPercentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: paymentPercentage >= 50
                                ? const Color(0xFF10b981)
                                : const Color(0xFFf59e0b),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: paymentPercentage / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          paymentPercentage >= 50
                              ? const Color(0xFF10b981)
                              : const Color(0xFFf59e0b),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Transaksi: ${_formatCurrency(totalAmount)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6b7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
