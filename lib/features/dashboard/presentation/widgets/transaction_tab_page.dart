import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';
import '../../../transactions/data/models/transaction_list_response.dart';
import '../../../transactions/providers/transaction_list_provider.dart';
import '../../../refunds/providers/refund_list_provider.dart';
import '../../../refunds/presentation/pages/refund_detail_page.dart';
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
  String _searchQuery = '';
  bool _isSearching = false;
  Timer? _debounceTimer;

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

      // Load refunds data to check which transactions have been refunded
      final refundProvider = Provider.of<RefundListProvider>(
        context,
        listen: false,
      );
      refundProvider.loadRefunds(refresh: true);
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
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = true;
    });

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Set up new timer for debouncing
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    final provider = Provider.of<TransactionListProvider>(
      context,
      listen: false,
    );

    // Set search query in provider
    provider.setSearch(query.trim().isEmpty ? null : query.trim());

    // Reload transactions with search
    provider.loadTransactions(refresh: true).then((_) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    });
  }

  void _clearSearch() {
    _debounceTimer?.cancel();
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _isSearching = false;
    });
    _onSearchChanged('');
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
                _buildSearchBar(),
                _buildStatusFilter(provider),
                const SizedBox(height: 8), // Spacing sebelum list
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
                Flexible(
                  child: const Column(
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
                        'Kelola transaksi pending, outstanding, dan selesai',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Container(
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
        child: TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _performSearch(_searchQuery),
          style: const TextStyle(fontSize: 16, color: Color(0xFF1F2937)),
          decoration: InputDecoration(
            hintText: 'Cari berdasarkan nama customer atau nomor transaksi...',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
            prefixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: const Icon(
                LucideIcons.search,
                color: Color(0xFF6B7280),
                size: 20,
              ),
            ),
            suffixIcon:
                _isSearching
                    ? Container(
                      padding: const EdgeInsets.all(12),
                      child: const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF6366f1),
                          ),
                        ),
                      ),
                    )
                    : _searchQuery.isNotEmpty
                    ? Container(
                      padding: const EdgeInsets.all(4),
                      child: IconButton(
                        icon: const Icon(
                          LucideIcons.x,
                          color: Color(0xFF6B7280),
                          size: 18,
                        ),
                        onPressed: _clearSearch,
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFF3F4F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(8),
                          minimumSize: const Size(32, 32),
                        ),
                      ),
                    )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF6366f1), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
          onChanged: _onSearchChanged,
        ),
      ),
    );
  }

  Widget _buildStatusFilter(TransactionListProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_searchQuery.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF0EA5E9), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.search,
                    size: 16,
                    color: Color(0xFF0EA5E9),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pencarian: "$_searchQuery"',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF0369A1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _clearSearch,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        LucideIcons.x,
                        size: 14,
                        color: Color(0xFF0EA5E9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusChip('pending', 'Pending', provider),
                const SizedBox(width: 12),
                _buildStatusChip('outstanding', 'Outstanding', provider),
                const SizedBox(width: 12),
                _buildStatusChip('completed', 'Success', provider),
                const SizedBox(width: 12),
                _buildStatusChip('refund', 'Refund', provider),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    color: const Color(0xFF6366f1).withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: FilterChip(
        label: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF6366f1),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        selected: isSelected,
        onSelected: (bool selected) {
          if (selected) {
            setState(() {
              _selectedStatus = value;
            });

            // Apply filter based on selection
            if (value == 'refund') {
              // For refund, we don't filter by status but will show refunded transactions
              // This will be handled in the build method
              final refundProvider = Provider.of<RefundListProvider>(
                context,
                listen: false,
              );
              refundProvider.loadRefunds(refresh: true);
            } else {
              provider.setStatus(value);
              // Ensure newest transactions are shown first
              provider.setSorting('created_at', 'desc');
              provider.loadTransactions(refresh: true);
            }
          }
        },
        selectedColor: const Color(0xFF6366f1),
        backgroundColor: Colors.white,
        side: BorderSide(
          color: isSelected ? const Color(0xFF6366f1) : const Color(0xFFE5E7EB),
          width: 1,
        ),
        showCheckmark: false,
        elevation: 0,
        pressElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildTransactionsList(TransactionListProvider provider) {
    // If refund filter is selected, show refunded transactions instead
    if (_selectedStatus == 'refund') {
      return Consumer<RefundListProvider>(
        builder: (context, refundProvider, child) {
          return _buildRefundsList(refundProvider);
        },
      );
    }

    if (provider.isLoading && provider.transactions.isEmpty) {
      return _buildShimmerLoading();
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
      String emptyMessage;
      String emptyDescription;
      IconData emptyIcon;

      if (_searchQuery.isNotEmpty) {
        emptyMessage = 'Transaksi tidak ditemukan';
        emptyDescription =
            'Tidak ada transaksi yang cocok dengan pencarian "$_searchQuery"';
        emptyIcon = LucideIcons.searchX;
      } else {
        emptyMessage = 'Belum ada transaksi';
        String statusText;
        switch (_selectedStatus) {
          case 'pending':
            statusText = 'pending';
            break;
          case 'outstanding':
            statusText = 'outstanding';
            break;
          case 'completed':
            statusText = 'yang selesai';
            break;
          case 'refund':
            statusText = 'yang direfund';
            break;
          default:
            statusText = _selectedStatus;
        }
        emptyDescription = 'Transaksi $statusText akan muncul di sini';
        emptyIcon = LucideIcons.receipt;
      }

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
              child: Icon(emptyIcon, color: const Color(0xFF6366f1), size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              emptyDescription,
              style: const TextStyle(fontSize: 16, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _clearSearch,
                icon: const Icon(LucideIcons.x),
                label: const Text('Hapus Pencarian'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366f1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
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

  Widget _buildTransactionCard(TransactionListItem transaction) {
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
                _buildHighlightedText(
                  transaction.customer?.name ?? '',
                  _searchQuery,
                  const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                _buildHighlightedText(
                  transaction.transactionNumber,
                  _searchQuery,
                  TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat(
                    'dd MMM yyyy, HH:mm',
                  ).format(transaction.transactionDate),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                // Outstanding reminder date section (only for outstanding transactions)
                if (transaction.status.toLowerCase() == 'outstanding' &&
                    transaction.outstandingReminderDate != null) ...[
                  _buildOutstandingReminder(transaction),
                  const SizedBox(height: 12),
                ],
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

  Widget _buildOutstandingReminder(TransactionListItem transaction) {
    if (transaction.outstandingReminderDate == null) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final dueDate = transaction.outstandingReminderDate!;
    final difference = dueDate.difference(now);

    final isOverdue = difference.isNegative;
    final isDueToday = !isOverdue && difference.inDays == 0;
    final isDueTomorrow = !isOverdue && difference.inDays == 1;

    Color backgroundColor;
    Color textColor;
    Color iconColor;
    IconData icon;
    String message;
    String timeText;

    if (isOverdue) {
      // Overdue - Red
      backgroundColor = const Color(0xFFEF4444).withValues(alpha: 0.1);
      textColor = const Color(0xFFDC2626);
      iconColor = const Color(0xFFDC2626);
      icon = LucideIcons.alertTriangle;
      final overdueDays = difference.inDays.abs();
      message = 'Terlambat';
      timeText =
          overdueDays == 0
              ? 'Jatuh tempo hari ini'
              : '$overdueDays hari yang lalu';
    } else if (isDueToday) {
      // Due today - Orange/Amber
      backgroundColor = const Color(0xFFF59E0B).withValues(alpha: 0.1);
      textColor = const Color(0xFFD97706);
      iconColor = const Color(0xFFD97706);
      icon = LucideIcons.clock;
      message = 'Jatuh tempo hari ini';
      final hoursLeft = difference.inHours;
      timeText =
          hoursLeft > 0
              ? '$hoursLeft jam lagi'
              : '${difference.inMinutes} menit lagi';
    } else if (isDueTomorrow) {
      // Due tomorrow - Yellow
      backgroundColor = const Color(0xFFFBBF24).withValues(alpha: 0.1);
      textColor = const Color(0xFFD97706);
      iconColor = const Color(0xFFD97706);
      icon = LucideIcons.calendar;
      message = 'Jatuh tempo besok';
      timeText = DateFormat('HH:mm').format(dueDate);
    } else {
      // Future due date - Blue
      backgroundColor = const Color(0xFF3B82F6).withValues(alpha: 0.1);
      textColor = const Color(0xFF2563EB);
      iconColor = const Color(0xFF2563EB);
      icon = LucideIcons.calendarDays;
      final daysLeft = difference.inDays;
      message = 'Jatuh tempo dalam $daysLeft hari';
      timeText = DateFormat('dd MMM yyyy').format(dueDate);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: textColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeText,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          // Countdown timer for due today and overdue
          if (isDueToday || isOverdue) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isOverdue ? 'TERLAMBAT' : 'HARI INI',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B); // Orange
      case 'outstanding':
        return const Color(0xFF8B5CF6); // Purple
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
      case 'outstanding':
        return 'Outstanding';
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

  Widget _buildRefundsList(RefundListProvider provider) {
    if (provider.isLoading && provider.refunds.isEmpty) {
      return _buildShimmerLoading();
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
              'Gagal memuat data refund',
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
                provider.loadRefunds(refresh: true);
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

    if (provider.refunds.isEmpty) {
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
              'Belum ada refund',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Transaksi yang direfund akan muncul di sini',
              style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await provider.loadRefunds(refresh: true);
      },
      color: const Color(0xFF6366f1),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        itemCount: provider.refunds.length + (provider.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= provider.refunds.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366f1)),
                ),
              ),
            );
          }

          final refund = provider.refunds[index];
          return _buildRefundCard(refund);
        },
      ),
    );
  }

  Widget _buildRefundCard(refund) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

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
          onTap: () {
            // Navigate to refund detail page
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RefundDetailPage(refundId: refund.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with refund number and badge
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.receipt,
                                size: 16,
                                color: Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  refund.refundNumber,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (refund.transaction != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Transaksi: ${refund.transaction.transactionNumber}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.arrowLeftRight,
                            size: 14,
                            color: Color(0xFFEF4444),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Refund',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                const SizedBox(height: 16),

                // Customer info
                if (refund.customer != null) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366f1).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          LucideIcons.user,
                          size: 16,
                          color: Color(0xFF6366f1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Customer',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              refund.customer.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            if (refund.customer.phone != null) ...[
                              Text(
                                refund.customer.phone!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Refund amount and method
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFEF4444).withValues(alpha: 0.1),
                        const Color(0xFFDC2626).withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Refund',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currencyFormat.format(refund.totalRefundAmount),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Metode: ${_getRefundMethodText(refund.refundMethod)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Date and status
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.calendar,
                            size: 14,
                            color: Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat(
                              'dd MMM yyyy, HH:mm',
                            ).format(DateTime.parse(refund.refundDate)),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _getRefundStatusColor(
                          refund.status,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getRefundStatusText(refund.status),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getRefundStatusColor(refund.status),
                        ),
                      ),
                    ),
                  ],
                ),

                // Notes if available
                if (refund.notes != null && refund.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          LucideIcons.messageSquare,
                          size: 14,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            refund.notes!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF4B5563),
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

  String _getRefundMethodText(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Tunai';
      case 'transfer':
      case 'bank_transfer':
        return 'Transfer';
      case 'mixed':
        return 'Campuran';
      default:
        return method;
    }
  }

  Color _getRefundStatusColor(String status) {
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

  String _getRefundStatusText(String status) {
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

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: 5, // Show 5 shimmer cards
      itemBuilder: (context, index) {
        return _buildShimmerCard();
      },
    );
  }

  Widget _buildShimmerCard() {
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Shimmer.fromColors(
          baseColor: const Color(0xFFE5E7EB),
          highlightColor: const Color(0xFFF3F4F6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status badge shimmer
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Customer name shimmer
              Container(
                width: double.infinity,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              // Transaction number shimmer
              Container(
                width: 200,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 6),
              // Date shimmer
              Container(
                width: 150,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              // Amount row shimmer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 120,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 40,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 60,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
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
    );
  }

  Widget _buildHighlightedText(
    String text,
    String searchQuery,
    TextStyle style,
  ) {
    if (searchQuery.isEmpty ||
        !text.toLowerCase().contains(searchQuery.toLowerCase())) {
      return Text(text, style: style);
    }

    final index = text.toLowerCase().indexOf(searchQuery.toLowerCase());
    final before = text.substring(0, index);
    final match = text.substring(index, index + searchQuery.length);
    final after = text.substring(index + searchQuery.length);

    return RichText(
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: before),
          TextSpan(
            text: match,
            style: style.copyWith(
              backgroundColor: const Color(0xFFFEF3C7), // Yellow highlight
              color: const Color(0xFF92400E), // Darker text for contrast
            ),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }
}
