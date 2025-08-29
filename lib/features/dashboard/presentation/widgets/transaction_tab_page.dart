import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../transactions/providers/transaction_list_provider.dart';
import '../pages/transaction_detail_page.dart';

class TransactionTabPage extends StatefulWidget {
  const TransactionTabPage({super.key});

  @override
  State<TransactionTabPage> createState() => _TransactionTabPageState();
}

class _TransactionTabPageState extends State<TransactionTabPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _selectedStatus = 'pending'; // Default to pending

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Load initial data with pending status filter only
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TransactionListProvider>(
        context,
        listen: false,
      );
      // Set status filter to pending only
      provider.setStatus('pending');
      // Set sorting to show newest transactions first
      provider.setSorting('created_at', 'desc');
      provider.loadTransactions(refresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final provider = Provider.of<TransactionListProvider>(
        context,
        listen: false,
      );
      provider.loadNextPage();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Consumer<TransactionListProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                _buildHeader(),
                _buildStatusFilter(provider),
                Expanded(child: _buildTransactionsList(provider)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaksi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      'Kelola transaksi pending dan selesai',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    LucideIcons.receipt,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilter(TransactionListProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const Text(
          //   'Filter Status',
          //   style: TextStyle(
          //     fontSize: 16,
          //     fontWeight: FontWeight.w600,
          //     color: Color(0xFF1F2937),
          //   ),
          // ),
          // const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusChip('pending', 'Pending', provider),
                const SizedBox(width: 8),
                _buildStatusChip('completed', 'Success', provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
    String value,
    String label,
    TransactionListProvider provider,
  ) {
    final isSelected = _selectedStatus == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF6366f1),
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _selectedStatus = value;
          });

          // Apply filter based on selection
          provider.setStatus(value);

          // Ensure newest transactions are shown first
          provider.setSorting('created_at', 'desc');
          provider.loadTransactions(refresh: true);
        }
      },
      selectedColor: const Color(0xFF6366f1),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? const Color(0xFF6366f1) : const Color(0xFFE5E7EB),
        width: 1,
      ),
      showCheckmark: false,
      elevation: isSelected ? 2 : 0,
      shadowColor: const Color(0xFF6366f1).withValues(alpha: 0.3),
    );
  }

  Widget _buildTransactionsList(TransactionListProvider provider) {
    if (provider.isLoading && provider.transactions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366f1)),
            ),
            SizedBox(height: 16),
            Text(
              'Memuat transaksi...',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.alertCircle,
              color: Color(0xFFEF4444),
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat transaksi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage!,
              style: const TextStyle(color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                provider.loadTransactions(refresh: true);
              },
              icon: const Icon(LucideIcons.refreshCw),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366f1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (provider.transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF6366f1).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                LucideIcons.receipt,
                color: Color(0xFF6366f1),
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum ada transaksi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Transaksi ${_selectedStatus == 'pending' ? 'pending' : 'yang selesai'} akan muncul di sini',
              style: const TextStyle(fontSize: 16, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await provider.loadTransactions(refresh: true);
      },
      color: const Color(0xFF6366f1),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        itemCount: provider.transactions.length + (provider.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= provider.transactions.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366f1)),
                ),
              ),
            );
          }

          final transaction = provider.transactions[index];
          return _buildTransactionCard(transaction);
        },
      ),
    );
  }

  Widget _buildTransactionCard(transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
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
          onTap: () => _navigateToTransactionDetail(transaction),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          transaction.status,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusText(transaction.status),
                        style: TextStyle(
                          color: _getStatusColor(transaction.status),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      LucideIcons.chevronRight,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  transaction.transactionNumber,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat(
                    'dd MMM yyyy, HH:mm',
                  ).format(transaction.createdAt),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(transaction.totalAmount),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Items',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${transaction.detailsCount} barang',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B); // Orange
      case 'completed':
        return const Color(0xFF10B981); // Green
      case 'cancelled':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  void _navigateToTransactionDetail(transaction) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TransactionDetailPage(transaction: transaction),
      ),
    );
  }
}
