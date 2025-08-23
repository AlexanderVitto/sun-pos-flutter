import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/cash_flow_provider.dart';
import '../widgets/cash_flow_card.dart';
import '../widgets/cash_flow_filter_dialog.dart';
import 'add_cash_flow_page.dart';

class CashFlowsPage extends StatefulWidget {
  const CashFlowsPage({super.key});

  @override
  State<CashFlowsPage> createState() => _CashFlowsPageState();
}

class _CashFlowsPageState extends State<CashFlowsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load cash flows when page is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CashFlowProvider>().loadCashFlows(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when near bottom
      context.read<CashFlowProvider>().loadMoreCashFlows();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Flows'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CashFlowProvider>().loadCashFlows(refresh: true);
            },
          ),
        ],
      ),
      body: Consumer<CashFlowProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Summary Cards
              _buildSummaryCards(provider),

              // Filter Info
              if (provider.selectedType != null ||
                  provider.selectedCategory != null ||
                  provider.dateFrom != null ||
                  provider.dateTo != null)
                _buildActiveFilters(provider),

              // Cash Flow List
              Expanded(child: _buildCashFlowList(provider)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddCashFlow(context),
        backgroundColor: Colors.blue.shade600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCards(CashFlowProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Masuk',
              provider.totalInAmount,
              Colors.green,
              Icons.arrow_upward,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              'Total Keluar',
              provider.totalOutAmount,
              Colors.red,
              Icons.arrow_downward,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              'Net Amount',
              provider.netAmount,
              provider.netAmount >= 0 ? Colors.green : Colors.red,
              provider.netAmount >= 0 ? Icons.trending_up : Icons.trending_down,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(CashFlowProvider provider) {
    final filters = <String>[];

    if (provider.selectedType != null) {
      filters.add('Type: ${provider.getFormattedType(provider.selectedType!)}');
    }
    if (provider.selectedCategory != null) {
      filters.add(
        'Category: ${provider.getFormattedCategory(provider.selectedCategory!)}',
      );
    }
    if (provider.dateFrom != null && provider.dateTo != null) {
      filters.add('Date: ${provider.dateFrom} - ${provider.dateTo}');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          Icon(Icons.filter_alt, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Active filters: ${filters.join(', ')}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => provider.clearFilters(),
            child: Text(
              'Clear',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashFlowList(CashFlowProvider provider) {
    if (provider.isLoading && provider.cashFlows.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Error loading cash flows',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage!,
              style: TextStyle(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.loadCashFlows(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.cashFlows.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No cash flows found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first cash flow entry',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadCashFlows(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: provider.cashFlows.length + (provider.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= provider.cashFlows.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final cashFlow = provider.cashFlows[index];
          return CashFlowCard(
            cashFlow: cashFlow,
            onTap: () => _showCashFlowDetails(context, cashFlow),
          );
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CashFlowFilterDialog(),
    );
  }

  void _navigateToAddCashFlow(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddCashFlowPage()),
    );

    if (result == true) {
      // Refresh the list if a cash flow was created
      if (mounted) {
        context.read<CashFlowProvider>().loadCashFlows(refresh: true);
      }
    }
  }

  void _showCashFlowDetails(BuildContext context, cashFlow) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(cashFlow.title),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Description', cashFlow.description),
                _buildDetailRow('Amount', cashFlow.formattedAmount),
                _buildDetailRow(
                  'Type',
                  cashFlow.type == 'in' ? 'Masuk' : 'Keluar',
                ),
                _buildDetailRow(
                  'Category',
                  context.read<CashFlowProvider>().getFormattedCategory(
                    cashFlow.category,
                  ),
                ),
                _buildDetailRow(
                  'Date',
                  DateFormat('dd MMM yyyy').format(cashFlow.transactionDate),
                ),
                if (cashFlow.notes != null && cashFlow.notes!.isNotEmpty)
                  _buildDetailRow('Notes', cashFlow.notes!),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}
