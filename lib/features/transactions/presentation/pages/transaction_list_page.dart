import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/transaction_list_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../sales/presentation/pages/receipt_page.dart';
import '../../../../data/models/cart_item.dart';
import '../../../../data/models/product.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({Key? key}) : super(key: key);

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TransactionListProvider>(
        context,
        listen: false,
      );
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
      appBar: const CustomAppBar(
        title: 'Daftar Transaksi',
        showBackButton: true,
      ),
      body: Consumer<TransactionListProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildFilterSection(provider),
              Expanded(child: _buildTransactionsList(provider)),
              _buildPaginationInfo(provider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFiltersDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.filter_list, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterSection(TransactionListProvider provider) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nomor transaksi...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            provider.setSearch(null);
                            provider.refreshTransactions();
                          },
                          icon: const Icon(Icons.clear),
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onSubmitted: (value) {
                provider.setSearch(value.isEmpty ? null : value);
                provider.refreshTransactions();
              },
            ),
            const SizedBox(height: 12),
            // Quick filters
            Wrap(
              spacing: 8.0,
              children: [
                FilterChip(
                  label: const Text('Hari Ini'),
                  onSelected: (selected) {
                    if (selected) {
                      provider.applyTodayFilter();
                      provider.refreshTransactions();
                    }
                  },
                ),
                FilterChip(
                  label: const Text('Minggu Ini'),
                  onSelected: (selected) {
                    if (selected) {
                      provider.applyThisWeekFilter();
                      provider.refreshTransactions();
                    }
                  },
                ),
                FilterChip(
                  label: const Text('Bulan Ini'),
                  onSelected: (selected) {
                    if (selected) {
                      provider.applyCurrentMonthFilter();
                      provider.refreshTransactions();
                    }
                  },
                ),
                FilterChip(
                  label: const Text('Reset Filter'),
                  onSelected: (selected) {
                    if (selected) {
                      provider.clearFilters();
                      _searchController.clear();
                      provider.refreshTransactions();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(TransactionListProvider provider) {
    if (provider.isLoading && provider.transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Error: ${provider.errorMessage}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                provider.clearError();
                provider.refreshTransactions();
              },
              child: const Text('Coba Lagi'),
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
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Tidak ada transaksi ditemukan',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refreshTransactions,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        itemCount:
            provider.transactions.length + (provider.hasNextPage ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.transactions.length) {
            // Loading indicator for next page
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final transaction = provider.transactions[index];
          return _buildTransactionCard(transaction);
        },
      ),
    );
  }

  Widget _buildTransactionCard(transaction) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => _showTransactionDetails(transaction),
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      transaction.transactionNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(transaction.status),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      _getStatusText(transaction.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Date and time
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(transaction.createdAt),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Amount and payment method
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currencyFormat.format(transaction.totalAmount),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        '${transaction.detailsCount} item',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: _getPaymentMethodColor(
                            transaction.paymentMethod,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          _getPaymentMethodText(transaction.paymentMethod),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction.store.name,
                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),

              // Notes if available
              if (transaction.notes != null &&
                  transaction.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.note, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          transaction.notes!,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildPaginationInfo(TransactionListProvider provider) {
    if (provider.meta == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total: ${provider.totalTransactions} transaksi',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          Text(
            'Halaman ${provider.currentPage} dari ${provider.totalPages}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showFiltersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TransactionFiltersDialog(),
    );
  }

  void _showTransactionDetails(transaction) {
    showDialog(
      context: context,
      builder: (context) => TransactionDetailsDialog(transaction: transaction),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Selesai';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Batal';
      default:
        return status;
    }
  }

  Color _getPaymentMethodColor(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return Colors.green;
      case 'card':
        return Colors.blue;
      case 'transfer':
        return Colors.purple;
      case 'e-wallet':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getPaymentMethodText(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return 'Tunai';
      case 'card':
        return 'Kartu';
      case 'transfer':
        return 'Transfer';
      case 'e-wallet':
        return 'E-Wallet';
      default:
        return paymentMethod;
    }
  }
}

// Dialog for advanced filters
class TransactionFiltersDialog extends StatefulWidget {
  const TransactionFiltersDialog({Key? key}) : super(key: key);

  @override
  State<TransactionFiltersDialog> createState() =>
      _TransactionFiltersDialogState();
}

class _TransactionFiltersDialogState extends State<TransactionFiltersDialog> {
  late TransactionListProvider _provider;
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();
  DateTime? _dateFrom;
  DateTime? _dateTo;
  String? _selectedPaymentMethod;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<TransactionListProvider>(context, listen: false);

    // Initialize with current filter values
    _minAmountController.text = _provider.minAmount?.toString() ?? '';
    _maxAmountController.text = _provider.maxAmount?.toString() ?? '';

    if (_provider.dateFrom != null) {
      _dateFrom = DateTime.parse(_provider.dateFrom!);
    }
    if (_provider.dateTo != null) {
      _dateTo = DateTime.parse(_provider.dateTo!);
    }

    _selectedPaymentMethod = _provider.paymentMethod;
    _selectedStatus = _provider.status;
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Transaksi'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date range
              const Text(
                'Rentang Tanggal:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _selectDate(true),
                      child: Text(
                        _dateFrom != null
                            ? DateFormat('dd/MM/yyyy').format(_dateFrom!)
                            : 'Dari Tanggal',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _selectDate(false),
                      child: Text(
                        _dateTo != null
                            ? DateFormat('dd/MM/yyyy').format(_dateTo!)
                            : 'Sampai Tanggal',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Amount range
              const Text(
                'Rentang Jumlah:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minAmountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Jumlah Min',
                        prefixText: 'Rp ',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _maxAmountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Jumlah Max',
                        prefixText: 'Rp ',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Payment method
              const Text(
                'Metode Pembayaran:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                decoration: const InputDecoration(
                  hintText: 'Pilih metode pembayaran',
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Semua')),
                  DropdownMenuItem(value: 'cash', child: Text('Tunai')),
                  DropdownMenuItem(value: 'card', child: Text('Kartu')),
                  DropdownMenuItem(value: 'transfer', child: Text('Transfer')),
                  DropdownMenuItem(value: 'e-wallet', child: Text('E-Wallet')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Status
              const Text(
                'Status:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(hintText: 'Pilih status'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Semua')),
                  DropdownMenuItem(value: 'completed', child: Text('Selesai')),
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'cancelled', child: Text('Batal')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        TextButton(onPressed: _resetFilters, child: const Text('Reset')),
        ElevatedButton(onPressed: _applyFilters, child: const Text('Terapkan')),
      ],
    );
  }

  Future<void> _selectDate(bool isFromDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        if (isFromDate) {
          _dateFrom = date;
        } else {
          _dateTo = date;
        }
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _dateFrom = null;
      _dateTo = null;
      _minAmountController.clear();
      _maxAmountController.clear();
      _selectedPaymentMethod = null;
      _selectedStatus = null;
    });
  }

  void _applyFilters() {
    // Apply date range
    String? dateFromStr;
    String? dateToStr;

    if (_dateFrom != null) {
      dateFromStr =
          '${_dateFrom!.year}-${_dateFrom!.month.toString().padLeft(2, '0')}-${_dateFrom!.day.toString().padLeft(2, '0')}';
    }
    if (_dateTo != null) {
      dateToStr =
          '${_dateTo!.year}-${_dateTo!.month.toString().padLeft(2, '0')}-${_dateTo!.day.toString().padLeft(2, '0')}';
    }

    _provider.setDateRange(dateFromStr, dateToStr);

    // Apply amount range
    double? minAmount;
    double? maxAmount;

    if (_minAmountController.text.isNotEmpty) {
      minAmount = double.tryParse(_minAmountController.text);
    }
    if (_maxAmountController.text.isNotEmpty) {
      maxAmount = double.tryParse(_maxAmountController.text);
    }

    _provider.setAmountRange(minAmount, maxAmount);
    _provider.setPaymentMethod(_selectedPaymentMethod);
    _provider.setStatus(_selectedStatus);

    // Refresh data
    _provider.refreshTransactions();

    Navigator.of(context).pop();
  }
}

// Dialog for transaction details
class TransactionDetailsDialog extends StatelessWidget {
  final dynamic transaction;

  const TransactionDetailsDialog({Key? key, required this.transaction})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

    return AlertDialog(
      title: Text(transaction.transactionNumber),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                'Tanggal',
                dateFormat.format(transaction.createdAt),
              ),
              _buildDetailRow(
                'Total',
                currencyFormat.format(transaction.totalAmount),
              ),
              _buildDetailRow(
                'Dibayar',
                currencyFormat.format(transaction.paidAmount),
              ),
              _buildDetailRow(
                'Kembalian',
                currencyFormat.format(transaction.changeAmount),
              ),
              _buildDetailRow(
                'Metode Bayar',
                _getPaymentMethodText(transaction.paymentMethod),
              ),
              _buildDetailRow('Status', _getStatusText(transaction.status)),
              _buildDetailRow(
                'Jumlah Item',
                '${transaction.detailsCount} item',
              ),
              _buildDetailRow('Toko', transaction.store.name),
              _buildDetailRow('Kasir', transaction.user.name),
              if (transaction.customer != null)
                _buildDetailRow('Pelanggan', transaction.customer.name),
              if (transaction.notes != null && transaction.notes!.isNotEmpty)
                _buildDetailRow('Catatan', transaction.notes!),
            ],
          ),
        ),
      ),
      actions: [
        // Tombol Lihat Struk untuk transaksi completed
        if (transaction.status.toLowerCase() == 'completed')
          ElevatedButton.icon(
            onPressed: () => _navigateToReceipt(context, transaction),
            icon: const Icon(Icons.receipt_long),
            label: const Text('Lihat Struk'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
            ),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Tutup'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _navigateToReceipt(BuildContext context, transaction) {
    // Konversi data transaksi ke format CartItem untuk ReceiptPage
    List<CartItem> receiptItems = [];

    // Karena kita tidak memiliki detail item dari transaction list,
    // kita akan membuat placeholder CartItem berdasarkan total dan jumlah item
    if (transaction.detailsCount > 0) {
      double averagePrice = transaction.totalAmount / transaction.detailsCount;
      for (int i = 0; i < transaction.detailsCount; i++) {
        receiptItems.add(
          CartItem(
            id: i + 1,
            product: Product(
              id: i + 1,
              name: 'Item ${i + 1}',
              code: 'ITEM${i + 1}',
              description: 'Item transaksi',
              price: averagePrice,
              stock: 1,
              category: 'General',
            ),
            quantity: 1,
            addedAt: transaction.transactionDate,
          ),
        );
      }
    }
    Navigator.of(context).pop(); // Tutup dialog
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ReceiptPage(
              receiptId: transaction.transactionNumber,
              transactionDate: transaction.transactionDate,
              items: receiptItems,
              store: transaction.store,
              user: transaction.user,
              subtotal: transaction.totalAmount,
              discount: 0.0,
              total: transaction.totalAmount,
              paymentMethod: _getPaymentMethodText(transaction.paymentMethod),
              notes: transaction.notes,
              status: transaction.status,
              dueDate: transaction.outstandingReminderDate,
            ),
      ),
    );
  }

  String _getPaymentMethodText(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return 'Tunai';
      case 'card':
        return 'Kartu';
      case 'transfer':
        return 'Transfer';
      case 'e-wallet':
        return 'E-Wallet';
      default:
        return paymentMethod;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Selesai';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Batal';
      default:
        return status;
    }
  }
}
