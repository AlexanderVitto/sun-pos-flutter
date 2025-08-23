import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../providers/reports_provider.dart';
import '../../data/models/most_sold_product_model.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _selectedPeriod = 'Hari Ini';
  late ReportsProvider _reportsProvider;

  // Date ranges for different periods
  final Map<String, Map<String, String>> _dateRanges = {
    'Hari Ini': {
      'date_from': DateTime.now().toIso8601String().split('T')[0],
      'date_to': DateTime.now().toIso8601String().split('T')[0],
    },
    'Minggu Ini': {
      'date_from':
          DateTime.now()
              .subtract(const Duration(days: 7))
              .toIso8601String()
              .split('T')[0],
      'date_to': DateTime.now().toIso8601String().split('T')[0],
    },
    'Bulan Ini': {
      'date_from':
          DateTime(
            DateTime.now().year,
            DateTime.now().month,
            1,
          ).toIso8601String().split('T')[0],
      'date_to': DateTime.now().toIso8601String().split('T')[0],
    },
  };

  @override
  void initState() {
    super.initState();
    _reportsProvider = context.read<ReportsProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReports();
    });
  }

  void _loadReports() {
    final selectedRange = _dateRanges[_selectedPeriod]!;
    _reportsProvider.fetchTransactionWidgets(
      dateFrom: selectedRange['date_from']!,
      dateTo: selectedRange['date_to']!,
    );
    _reportsProvider.fetchMostSoldProducts(
      dateFrom: selectedRange['date_from']!,
      dateTo: selectedRange['date_to']!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header
            _buildModernHeader(context),

            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Period Selection
                        _buildPeriodSelector(),

                        const SizedBox(height: AppTheme.spacingXLarge),

                        // Summary Cards
                        _buildSummaryCards(),

                        const SizedBox(height: AppTheme.spacingXLarge),

                        // Top Products Section
                        _buildTopProductsSection(),

                        const SizedBox(height: AppTheme.spacingXLarge),

                        // Transaction Analysis
                        _buildTransactionAnalysis(),

                        const SizedBox(height: AppTheme.spacingXXLarge),
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

  Widget _buildModernHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: AppTheme.headerDecoration,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: const Icon(
                    LucideIcons.barChart3,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Laporan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Analisis performa penjualan',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Periode Laporan', style: AppTheme.headingSmall),
          const SizedBox(height: AppTheme.spacingMedium),
          Row(
            children:
                _dateRanges.keys.map((period) {
                  final isSelected = _selectedPeriod == period;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _onPeriodChanged(period),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.spacingMedium,
                              horizontal: AppTheme.spacingMedium,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppTheme.primaryIndigo
                                      : AppTheme.backgroundTertiary,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMedium,
                              ),
                            ),
                            child: Text(
                              period,
                              style: AppTheme.bodyMedium.copyWith(
                                color:
                                    isSelected
                                        ? Colors.white
                                        : AppTheme.textPrimary,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Consumer<ReportsProvider>(
      builder: (context, provider, child) {
        final widgets = provider.transactionWidgets;

        if (provider.isLoading) {
          return _buildLoadingSummaryCards();
        }

        if (widgets == null) {
          return _buildErrorSummaryCards();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ringkasan $_selectedPeriod', style: AppTheme.headingSmall),
            const SizedBox(height: AppTheme.spacingMedium),

            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Total Penjualan',
                    value: _formatCurrency(widgets.totalSales.toDouble()),
                    icon: LucideIcons.banknote,
                    color: AppTheme.primaryGreen,
                    subtitle: '${widgets.totalTransactions} transaksi',
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMedium),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Rata-rata',
                    value: _formatCurrency(widgets.averageTransactionAmount),
                    icon: LucideIcons.trendingUp,
                    color: AppTheme.primaryBlue,
                    subtitle: 'Per transaksi',
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingMedium),

            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Item Terjual',
                    value: widgets.itemsSold.toString(),
                    icon: LucideIcons.package,
                    color: AppTheme.primaryPurple,
                    subtitle: 'Total item',
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMedium),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Transaksi',
                    value: widgets.totalTransactions.toString(),
                    icon: LucideIcons.shoppingCart,
                    color: AppTheme.primaryAmber,
                    subtitle: 'Total transaksi',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Icon(
                LucideIcons.moreVertical,
                color: AppTheme.textTertiary,
                size: 16,
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingMedium),

          Text(title, style: AppTheme.bodySmall),

          const SizedBox(height: AppTheme.spacingXSmall),

          Text(value, style: AppTheme.headingMedium.copyWith(fontSize: 20)),

          const SizedBox(height: AppTheme.spacingXSmall),

          Text(subtitle, style: AppTheme.caption),
        ],
      ),
    );
  }

  Widget _buildLoadingSummaryCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ringkasan $_selectedPeriod', style: AppTheme.headingSmall),
        const SizedBox(height: AppTheme.spacingMedium),

        Row(
          children: [
            Expanded(child: _buildLoadingCard()),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(child: _buildLoadingCard()),
          ],
        ),

        const SizedBox(height: AppTheme.spacingMedium),

        Row(
          children: [
            Expanded(child: _buildLoadingCard()),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(child: _buildLoadingCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: AppTheme.cardDecoration,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircularProgressIndicator(strokeWidth: 2),
          SizedBox(height: AppTheme.spacingMedium),
          Text('Memuat...', style: AppTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildErrorSummaryCards() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Icon(LucideIcons.alertCircle, size: 48, color: Colors.red[400]),
          const SizedBox(height: AppTheme.spacingMedium),
          Text('Gagal memuat data', style: AppTheme.headingSmall),
          const SizedBox(height: AppTheme.spacingSmall),
          Text(
            'Terjadi kesalahan saat memuat ringkasan',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          ElevatedButton.icon(
            onPressed: _loadReports,
            style: AppTheme.primaryButtonStyle,
            icon: const Icon(LucideIcons.refreshCw, size: 18),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductsSection() {
    return Consumer<ReportsProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Produk Terlaris', style: AppTheme.headingSmall),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to detailed products report
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryIndigo,
                  ),
                  icon: const Icon(LucideIcons.arrowRight, size: 16),
                  label: const Text('Lihat Semua'),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingMedium),

            if (provider.isLoadingProducts)
              _buildLoadingProductsList()
            else if (provider.mostSoldProducts.isEmpty)
              _buildEmptyProductsList()
            else
              _buildProductsList(provider.mostSoldProducts),
          ],
        );
      },
    );
  }

  Widget _buildProductsList(List<MostSoldProductModel> products) {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        children:
            products.take(5).map((product) {
              return _buildProductItem(product);
            }).toList(),
      ),
    );
  }

  Widget _buildProductItem(MostSoldProductModel product) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: const Icon(
              LucideIcons.package,
              color: AppTheme.primaryBlue,
              size: 20,
            ),
          ),

          const SizedBox(width: AppTheme.spacingMedium),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Terjual ${product.totalSold} item',
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'SKU: ${product.productSku}',
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryGreen,
                ),
              ),
              Text('Product ID: ${product.productId}', style: AppTheme.caption),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingProductsList() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: AppTheme.cardDecoration,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEmptyProductsList() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Icon(LucideIcons.package, size: 48, color: AppTheme.textTertiary),
          const SizedBox(height: AppTheme.spacingMedium),
          Text('Belum ada data produk', style: AppTheme.headingSmall),
          const SizedBox(height: AppTheme.spacingSmall),
          Text(
            'Data produk terlaris akan muncul setelah ada transaksi',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionAnalysis() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Analisis Transaksi', style: AppTheme.headingSmall),

          const SizedBox(height: AppTheme.spacingMedium),

          Text(
            'Grafik penjualan dan tren akan ditampilkan di sini',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppTheme.spacingLarge),

          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.backgroundTertiary,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.barChart3,
                    size: 48,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  Text(
                    'Chart placeholder',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onPeriodChanged(String period) {
    setState(() {
      _selectedPeriod = period;
    });
    _loadReports();
  }

  Future<void> _handleRefresh() async {
    _loadReports();
    // Wait for loading to complete
    await Future.delayed(const Duration(seconds: 1));
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }
}
