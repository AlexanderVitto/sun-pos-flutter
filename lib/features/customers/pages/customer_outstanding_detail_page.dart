import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../data/models/customer.dart';
import '../../transactions/data/services/transaction_api_service.dart';
import '../../transactions/data/models/transaction_list_response.dart';
import 'customer_payment_page.dart';

class CustomerOutstandingDetailPage extends StatefulWidget {
  final Customer customer;

  const CustomerOutstandingDetailPage({super.key, required this.customer});

  @override
  State<CustomerOutstandingDetailPage> createState() =>
      _CustomerOutstandingDetailPageState();
}

class _CustomerOutstandingDetailPageState
    extends State<CustomerOutstandingDetailPage> {
  final TransactionApiService _apiService = TransactionApiService();
  final ScrollController _scrollController = ScrollController();

  List<TransactionListItem> _transactions = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoadingMore && _hasMore) {
        _loadMoreTransactions();
      }
    }
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.getTransactions(
        customerId: widget.customer.id,
        status: 'outstanding',
        page: 1,
        perPage: 15,
      );

      setState(() {
        _transactions = response.data.data
            .where((transaction) => transaction.outstandingAmount > 0)
            .toList();
        _currentPage = response.data.meta.currentPage;
        _totalPages = response.data.meta.lastPage;
        _hasMore = _currentPage < _totalPages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreTransactions() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await _apiService.getTransactions(
        customerId: widget.customer.id,
        status: 'outstanding',
        page: _currentPage + 1,
        perPage: 15,
      );

      setState(() {
        _transactions.addAll(
          response.data.data
              .where((transaction) => transaction.outstandingAmount > 0)
              .toList(),
        );
        _currentPage = response.data.meta.currentPage;
        _totalPages = response.data.meta.lastPage;
        _hasMore = _currentPage < _totalPages;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _currentPage = 1;
      _hasMore = true;
    });
    await _loadTransactions();
  }

  String _formatCurrency(double? amount) {
    if (amount == null) return 'Rp 0';
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final hasOutstanding =
        _transactions.isNotEmpty &&
        _transactions.any((t) => t.outstandingAmount > 0);

    return Scaffold(
      backgroundColor: const Color(0xFFf8fafc),
      appBar: AppBar(
        title: const Text(
          'Detail Transaksi Berhutang',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6366f1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Customer Info Header
          _buildCustomerHeader(),

          // Transactions List
          Expanded(child: _buildTransactionsList()),
        ],
      ),
      floatingActionButton: hasOutstanding ? _buildPaymentFAB() : null,
    );
  }

  Widget _buildPaymentFAB() {
    return FloatingActionButton.extended(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CustomerPaymentPage(customer: widget.customer),
          ),
        );

        // Refresh data if payment was successful
        if (result == true && mounted) {
          _refreshData();
        }
      },
      backgroundColor: const Color(0xFF10b981),
      icon: const Icon(LucideIcons.wallet, color: Colors.white),
      label: const Text(
        'Bayar Utang',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      elevation: 4,
    );
  }

  Widget _buildCustomerHeader() {
    final totalOutstanding = widget.customer.totalOutstandingAmount ?? 0;
    final totalTransaction = widget.customer.totalTransactionAmount ?? 0;
    final transactionCount = widget.customer.transactionsCount ?? 0;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF6366f1), const Color(0xFF8b5cf6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366f1).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Customer Name & Info
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    widget.customer.name.isNotEmpty
                        ? widget.customer.name[0].toUpperCase()
                        : 'C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
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
                    Text(
                      widget.customer.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.phone,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.customer.phone,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(height: 16),

          // Statistics
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Hutang',
                  _formatCurrency(totalOutstanding),
                  LucideIcons.alertCircle,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Total Transaksi',
                  _formatCurrency(totalTransaction),
                  LucideIcons.receipt,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Jumlah',
                  '$transactionCount',
                  LucideIcons.shoppingCart,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 20),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTransactionsList() {
    if (_isLoading && _transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _transactions.isEmpty) {
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
              _errorMessage ?? 'Terjadi kesalahan',
              style: const TextStyle(fontSize: 16, color: Color(0xFF6b7280)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadTransactions,
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

    if (_transactions.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10b981).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.checkCircle,
                      size: 64,
                      color: Color(0xFF10b981),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Tidak Ada Transaksi Berhutang',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1f2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Semua transaksi sudah lunas',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: _transactions.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _transactions.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final transaction = _transactions[index];
          return _buildTransactionCard(transaction);
        },
      ),
    );
  }

  Widget _buildTransactionCard(TransactionListItem transaction) {
    final outstandingAmount = transaction.outstandingAmount;
    final totalAmount = transaction.totalAmount;
    final paidAmount = transaction.totalPaid;
    final paymentPercentage = totalAmount > 0
        ? (paidAmount / totalAmount) * 100
        : 0;
    final isFullyPaid = transaction.isFullyPaid ?? false;

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
          color: isFullyPaid
              ? const Color(0xFF10b981).withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color:
                (isFullyPaid
                        ? const Color(0xFF10b981)
                        : const Color(0xFF6366f1))
                    .withValues(alpha: 0.1),
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
            // TODO: Navigate to transaction detail
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isFullyPaid
                              ? [
                                  const Color(0xFF10b981),
                                  const Color(0xFF059669),
                                ]
                              : [
                                  const Color(0xFFef4444),
                                  const Color(0xFFdc2626),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (isFullyPaid
                                        ? const Color(0xFF10b981)
                                        : const Color(0xFFef4444))
                                    .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isFullyPaid
                            ? LucideIcons.checkCircle
                            : LucideIcons.alertCircle,
                        color: Colors.white,
                        size: 24,
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
                                  transaction.transactionNumber,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1f2937),
                                  ),
                                ),
                              ),
                              if (isFullyPaid)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF10b981,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF10b981,
                                      ).withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: const Text(
                                    'LUNAS',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF10b981),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.calendar,
                                size: 12,
                                color: Color(0xFF6b7280),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(transaction.transactionDate),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6b7280),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                LucideIcons.package,
                                size: 12,
                                color: Color(0xFF6b7280),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${transaction.detailsCount} item',
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
                  ],
                ),

                const SizedBox(height: 16),
                Divider(color: Colors.grey.withValues(alpha: 0.2)),
                const SizedBox(height: 16),

                // Amount Details
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Transaksi',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatCurrency(totalAmount),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1f2937),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sisa Hutang',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatCurrency(outstandingAmount),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isFullyPaid
                                  ? const Color(0xFF10b981)
                                  : const Color(0xFFef4444),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                            color: isFullyPaid
                                ? const Color(0xFF10b981)
                                : paymentPercentage >= 50
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
                          isFullyPaid
                              ? const Color(0xFF10b981)
                              : paymentPercentage >= 50
                              ? const Color(0xFF10b981)
                              : const Color(0xFFf59e0b),
                        ),
                      ),
                    ),
                  ],
                ),

                // Notes
                if (transaction.notes != null &&
                    transaction.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          LucideIcons.fileText,
                          size: 16,
                          color: Color(0xFF6b7280),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            transaction.notes!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4b5563),
                            ),
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
      ),
    );
  }
}
