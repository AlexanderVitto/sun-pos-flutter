import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _selectedPeriod = 'Hari Ini';

  // Dummy data for sales report
  final Map<String, Map<String, dynamic>> _salesData = {
    'Hari Ini': {
      'transactions': 45,
      'revenue': 2350000,
      'items_sold': 127,
      'avg_transaction': 52222,
    },
    'Minggu Ini': {
      'transactions': 312,
      'revenue': 16450000,
      'items_sold': 892,
      'avg_transaction': 52724,
    },
    'Bulan Ini': {
      'transactions': 1248,
      'revenue': 65230000,
      'items_sold': 3567,
      'avg_transaction': 52267,
    },
  };

  // Dummy data for 7 days chart
  final List<Map<String, dynamic>> _weeklyData = [
    {'day': 'Sen', 'sales': 1200000.0},
    {'day': 'Sel', 'sales': 1800000.0},
    {'day': 'Rab', 'sales': 2100000.0},
    {'day': 'Kam', 'sales': 1650000.0},
    {'day': 'Jum', 'sales': 2350000.0},
    {'day': 'Sab', 'sales': 2800000.0},
    {'day': 'Min', 'sales': 3200000.0},
  ];

  @override
  Widget build(BuildContext context) {
    final currentData = _salesData[_selectedPeriod]!;
    final maxSales = _weeklyData
        .map((e) => e['sales'] as double)
        .reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Laporan Penjualan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.download),
            onPressed: () => _exportReport(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            _buildPeriodSelector(),

            const SizedBox(height: 24),

            // Summary Cards
            _buildSummaryCards(currentData),

            const SizedBox(height: 24),

            // Sales Chart
            _buildSalesChart(maxSales),

            const SizedBox(height: 24),

            // Top Products
            _buildTopProducts(),

            const SizedBox(height: 24),

            // Recent Transactions
            _buildRecentTransactions(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.calendar, size: 20, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text(
                  'Periode Laporan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children:
                  _salesData.keys.map((period) {
                    final isSelected = _selectedPeriod == period;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(period),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedPeriod = period;
                              });
                            }
                          },
                          selectedColor: Colors.blue[100],
                          checkmarkColor: Colors.blue[600],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan Penjualan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildSummaryCard(
              title: 'Total Transaksi',
              value: '${data['transactions']}',
              icon: LucideIcons.shoppingCart,
              color: Colors.blue,
              subtitle: 'transaksi',
            ),
            _buildSummaryCard(
              title: 'Total Penjualan',
              value: 'Rp ${_formatPrice(data['revenue'].toDouble())}',
              icon: LucideIcons.banknote,
              color: Colors.green,
              subtitle: 'revenue',
            ),
            _buildSummaryCard(
              title: 'Item Terjual',
              value: '${data['items_sold']}',
              icon: LucideIcons.package,
              color: Colors.orange,
              subtitle: 'item',
            ),
            _buildSummaryCard(
              title: 'Rata-rata Transaksi',
              value: 'Rp ${_formatPrice(data['avg_transaction'].toDouble())}',
              icon: LucideIcons.trendingUp,
              color: Colors.purple,
              subtitle: 'per transaksi',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(LucideIcons.arrowUp, color: color, size: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),

            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart(double maxSales) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.barChart3, size: 20, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text(
                  'Penjualan 7 Hari Terakhir',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Simple Bar Chart
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    _weeklyData.map((data) {
                      final height = (data['sales'] / maxSales) * 150;
                      final isToday =
                          data['day'] == 'Jum'; // Assume today is Friday

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Sales amount
                          Text(
                            'Rp ${_formatPriceShort(data['sales'])}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Bar
                          Container(
                            width: 30,
                            height: height,
                            decoration: BoxDecoration(
                              color:
                                  isToday ? Colors.blue[600] : Colors.blue[200],
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Day label
                          Text(
                            data['day'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  isToday ? FontWeight.bold : FontWeight.normal,
                              color:
                                  isToday ? Colors.blue[600] : Colors.grey[600],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProducts() {
    final topProducts = [
      {'name': 'Nasi Gudeg', 'sold': 45, 'revenue': 675000},
      {'name': 'Es Teh Manis', 'sold': 67, 'revenue': 335000},
      {'name': 'Ayam Goreng', 'sold': 32, 'revenue': 640000},
      {'name': 'Soto Ayam', 'sold': 28, 'revenue': 420000},
      {'name': 'Kerupuk', 'sold': 89, 'revenue': 267000},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.trophy, size: 20, color: Colors.orange[600]),
                const SizedBox(width: 8),
                const Text(
                  'Produk Terlaris',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ...topProducts.asMap().entries.map((entry) {
              final index = entry.key;
              final product = entry.value;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color:
                            index == 0
                                ? const Color(0xFFFFD700)
                                : index == 1
                                ? Colors.grey[400]
                                : index == 2
                                ? Colors.orange[300]
                                : Colors.blue[100],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: index < 3 ? Colors.white : Colors.blue[600],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${product['sold']} terjual',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      'Rp ${_formatPrice((product['revenue'] as int).toDouble())}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final recentTransactions = [
      {
        'id': 'TRX001',
        'time': '15:30',
        'items': 3,
        'total': 45000,
        'method': 'Tunai',
      },
      {
        'id': 'TRX002',
        'time': '15:15',
        'items': 2,
        'total': 28000,
        'method': 'QRIS',
      },
      {
        'id': 'TRX003',
        'time': '14:45',
        'items': 5,
        'total': 72000,
        'method': 'Debit',
      },
      {
        'id': 'TRX004',
        'time': '14:20',
        'items': 1,
        'total': 15000,
        'method': 'Tunai',
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.clock, size: 20, color: Colors.green[600]),
                    const SizedBox(width: 8),
                    const Text(
                      'Transaksi Terbaru',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to detailed transactions
                  },
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ...recentTransactions.map((transaction) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        LucideIcons.receipt,
                        color: Colors.green[600],
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                transaction['id'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                transaction['time'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${transaction['items']} item • ${transaction['method']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Rp ${_formatPrice((transaction['total'] as int).toDouble())}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _exportReport(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Export Laporan'),
            content: const Text('Fitur export laporan akan segera tersedia.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  String _formatPriceShort(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    }
    return price.toStringAsFixed(0);
  }
}
