import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../transactions/providers/transaction_list_provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/role_permissions.dart';
import '../../../sales/presentation/pages/pos_transaction_page.dart';
import '../../../products/providers/product_provider.dart';
import '../../../sales/providers/cart_provider.dart';
// import '../../../products/presentation/pages/products_page_modern.dart'; // Hidden per user request
// import '../../../reports/presentation/pages/reports_page.dart'; // Hidden per user request
import '../../../profile/user_profile_page.dart';
import '../../../../core/events/transaction_events.dart';

class DashboardPage extends StatefulWidget {
  final int initialIndex;

  const DashboardPage({super.key, this.initialIndex = 0});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with WidgetsBindingObserver {
  late int _selectedIndex;
  Timer? _refreshTimer;
  StreamSubscription<TransactionEvent>? _transactionEventSubscription;

  // Persistent providers that maintain state across page switches
  late final ProductProvider _productProvider;
  late final CartProvider _cartProvider;

  @override
  void initState() {
    super.initState();
    // Set initial index from widget parameter
    _selectedIndex = widget.initialIndex;

    // Initialize providers once to maintain state
    _productProvider = ProductProvider();
    _cartProvider = CartProvider();

    // Add observer for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    // Ensure products are loaded (fallback to dummy if needed)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProvidersData();
      _startAutoRefresh();
      _listenToTransactionEvents();
    });
  }

  void _listenToTransactionEvents() {
    // Listen to transaction events for real-time updates
    _transactionEventSubscription = TransactionEvents.instance.stream.listen((
      event,
    ) {
      if (mounted && _selectedIndex == 0 && event is TransactionCreatedEvent) {
        // Refresh transaction list when a new transaction is created
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final transactionProvider = context.read<TransactionListProvider>();
          transactionProvider.loadTransactions(refresh: true);
        });
      }
    });
  }

  void _startAutoRefresh() {
    // Refresh transaction data every 30 seconds when on dashboard
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && _selectedIndex == 0) {
        final transactionProvider = context.read<TransactionListProvider>();
        transactionProvider.loadTransactions(refresh: true);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh when app comes back to foreground
    if (state == AppLifecycleState.resumed && mounted && _selectedIndex == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final transactionProvider = context.read<TransactionListProvider>();
        transactionProvider.loadTransactions(refresh: true);
      });
    }
  }

  void _initializeProvidersData() async {
    // Wait a bit for ProductProvider to finish loading from API
    await Future.delayed(const Duration(milliseconds: 1000));

    // If products still empty, force load dummy products
    if (_productProvider.products.isEmpty) {
      debugPrint('Loading dummy products as fallback...');
      // _productProvider.loadDummyProducts(); // Method may not exist
    }

    debugPrint(
      'Dashboard initialized with ${_productProvider.products.length} products',
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _transactionEventSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 17) {
      return 'Selamat Siang';
    } else {
      return 'Selamat Malam';
    }
  }

  String _formatDateSafely(DateTime date, String pattern) {
    try {
      return DateFormat(pattern, 'id_ID').format(date);
    } catch (e) {
      // Fallback to English if Indonesian locale is not available
      debugPrint('Date formatting error with id_ID locale, using fallback: $e');
      return DateFormat(pattern, 'en_US').format(date);
    }
  }

  String _formatTimeSafely(DateTime date, String pattern) {
    try {
      return DateFormat(pattern).format(date);
    } catch (e) {
      debugPrint('Time formatting error: $e');
      return date.toString().substring(11, 16); // HH:mm format as fallback
    }
  }

  void _handleLogout(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Ya, Keluar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await authProvider.logout();
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        });
      }
    }
  }

  List<Widget> _getAvailablePages(List<String>? userRoles) {
    if (userRoles == null) return [];

    List<Widget> pages = [];

    if (RolePermissions.canAccessDashboard(userRoles)) {
      pages.add(_buildDashboardContent());
    }
    if (RolePermissions.canAccessPOS(userRoles)) {
      pages.add(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: _productProvider),
            ChangeNotifierProvider.value(value: _cartProvider),
          ],
          child: const POSTransactionPage(),
        ),
      );
    }
    // Products page hidden per user request
    // if (RolePermissions.canAccessProducts(userRoles)) {
    //   pages.add(const ProductsPage());
    // }
    // Reports page hidden per user request
    // if (RolePermissions.canAccessReports(userRoles)) {
    //   pages.add(const ReportsPage());
    // }
    if (RolePermissions.canAccessProfile(userRoles)) {
      pages.add(const UserProfilePage());
    }

    return pages;
  }

  Widget _buildDashboardContent() {
    final greeting = _getGreeting();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refreshDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modern Header
              _buildModernHeader(context, greeting),

              // Content with padding
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick stats with modern design
                    _buildModernQuickStats(),

                    const SizedBox(height: 32),

                    // Quick actions with modern design
                    _buildModernQuickActions(context),

                    const SizedBox(height: 32),

                    // Recent activity with modern design
                    _buildModernRecentActivity(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshDashboardData() async {
    final transactionProvider = context.read<TransactionListProvider>();
    await transactionProvider.loadTransactions(refresh: true);
  }

  Widget _buildModernHeader(BuildContext context, String greeting) {
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
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top section with profile and settings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Greeting and user info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          final userName = authProvider.user?.name ?? 'User';
                          return Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Profile avatar and logout
                Row(
                  children: [
                    // Profile avatar
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            final userName = authProvider.user?.name ?? 'U';
                            return Text(
                              userName.isNotEmpty
                                  ? userName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Logout button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _handleLogout(context),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              LucideIcons.logOut,
                              color: Colors.white.withValues(alpha: 0.9),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Date and status info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.calendar,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDateSafely(
                            DateTime.now(),
                            'EEEE, dd MMMM yyyy',
                          ),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Sistem aktif dan berjalan dengan baik',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10b981), // Green
                      shape: BoxShape.circle,
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

  Widget _buildModernQuickStats() {
    return Consumer<TransactionListProvider>(
      builder: (context, transactionProvider, child) {
        final transactions = transactionProvider.transactions;
        final totalTransactions = transactions.length;
        final totalRevenue = transactions.fold<double>(
          0,
          (sum, transaction) => sum + transaction.totalAmount,
        );
        final avgTransaction =
            totalTransactions > 0 ? totalRevenue / totalTransactions : 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Hari Ini',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1f2937),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                // Total Transactions
                Expanded(
                  child: _buildStatCard(
                    title: 'Transaksi',
                    value: totalTransactions.toString(),
                    icon: LucideIcons.shoppingCart,
                    color: const Color(0xFF3b82f6), // Blue
                    subtitle: 'Total hari ini',
                  ),
                ),
                const SizedBox(width: 16),

                // Total Revenue
                Expanded(
                  child: _buildStatCard(
                    title: 'Revenue',
                    value: 'Rp ${_formatPrice(totalRevenue)}',
                    icon: LucideIcons.banknote,
                    color: const Color(0xFF10b981), // Green
                    subtitle: 'Total penjualan',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                // Average Transaction
                Expanded(
                  child: _buildStatCard(
                    title: 'Rata-rata',
                    value: 'Rp ${_formatPrice(avgTransaction.toDouble())}',
                    icon: LucideIcons.trendingUp,
                    color: const Color(0xFFf59e0b), // Amber
                    subtitle: 'Per transaksi',
                  ),
                ),
                const SizedBox(width: 16),

                // Products Count hidden per user request
                // Expanded(
                //   child: _buildStatCard(
                //     title: 'Produk',
                //     value: _productProvider.products.length.toString(),
                //     icon: LucideIcons.package,
                //     color: const Color(0xFF8b5cf6), // Purple
                //     subtitle: 'Total produk',
                //   ),
                // ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1), width: 1),
      ),
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
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Icon(
                LucideIcons.trendingUp,
                color: Colors.grey.withValues(alpha: 0.4),
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1f2937),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildModernQuickActions(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final userRoles = authProvider.user?.roleNames ?? [];

    final quickActions = <Map<String, dynamic>>[];

    if (RolePermissions.canAccessPOS(userRoles)) {
      quickActions.add({
        'title': 'Transaksi Baru',
        'subtitle': 'Buat penjualan baru',
        'icon': LucideIcons.plus,
        'color': const Color(0xFF3b82f6),
        'onTap':
            () => setState(
              () =>
                  _selectedIndex =
                      userRoles.contains('owner') ||
                              userRoles.contains('manager')
                          ? 1
                          : 0,
            ),
      });

      // Quick scan action for POS
      quickActions.add({
        'title': 'Scan Barcode',
        'subtitle': 'Scan produk cepat',
        'icon': LucideIcons.scan,
        'color': const Color(0xFF22c55e),
        'onTap': () {
          // Navigate to barcode scanner
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fitur scan barcode akan segera hadir'),
            ),
          );
        },
      });
    }

    // Products quick actions hidden per user request
    // if (RolePermissions.canAccessProducts(userRoles)) {
    //   quickActions.add({
    //     'title': 'Kelola Produk',
    //     'subtitle': 'Tambah & edit produk',
    //     'icon': LucideIcons.package,
    //     'color': const Color(0xFF8b5cf6),
    //     'onTap': () => setState(() => _selectedIndex = 2),
    //   });

    //   // Add quick action for adding new product directly
    //   quickActions.add({
    //     'title': 'Tambah Produk',
    //     'subtitle': 'Tambah produk baru',
    //     'icon': LucideIcons.plus,
    //     'color': const Color(0xFF3b82f6),
    //     'onTap': () {
    //       // Navigate to add product page
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(content: Text('Navigasi ke halaman tambah produk')),
    //       );
    //     },
    //   });
    // }

    // Cash Flow actions hidden per user request
    // Cash Flow action for owners/managers
    // if (userRoles.contains('owner') || userRoles.contains('manager')) {
    //   quickActions.add({
    //     'title': 'Kas & Keuangan',
    //     'subtitle': 'Kelola arus kas',
    //     'icon': LucideIcons.wallet,
    //     'color': const Color(0xFFef4444),
    //     'onTap':
    //         () => setState(
    //           () => _selectedIndex = 5,
    //         ), // Assuming cash flow is at index 5
    //   });

    //   // Cash Flows list - view all cash flow transactions
    //   quickActions.add({
    //     'title': 'Cash Flows',
    //     'subtitle': 'Daftar arus kas',
    //     'icon': LucideIcons.trendingUp,
    //     'color': const Color(0xFF8b5cf6),
    //     'onTap': () {
    //       // Navigate to cash flows list page
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(
    //           content: Text('Navigasi ke halaman daftar cash flows'),
    //         ),
    //       );
    //     },
    //   });

    //   // Add Cash Flow - add new cash in/out entry
    //   quickActions.add({
    //     'title': 'Tambah Cash Flow',
    //     'subtitle': 'Input kas masuk/keluar',
    //     'icon': LucideIcons.plusCircle,
    //     'color': const Color(0xFF059669),
    //     'onTap': () {
    //       // Navigate to add cash flow page
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(
    //           content: Text('Navigasi ke halaman tambah cash flow'),
    //         ),
    //       );
    //     },
    //   });
    // }

    // Reports quick actions hidden per user request
    // if (RolePermissions.canAccessReports(userRoles)) {
    //   quickActions.add({
    //     'title': 'Laporan',
    //     'subtitle': 'Lihat performa toko',
    //     'icon': LucideIcons.barChart3,
    //     'color': const Color(0xFF10b981),
    //     'onTap': () => setState(() => _selectedIndex = 3),
    //   });

    //   // Print Reports - for printing various reports
    //   quickActions.add({
    //     'title': 'Cetak Laporan',
    //     'subtitle': 'Export & print report',
    //     'icon': LucideIcons.printer,
    //     'color': const Color(0xFF6366f1),
    //     'onTap': () {
    //       // Navigate to print reports page
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(content: Text('Navigasi ke halaman cetak laporan')),
    //       );
    //     },
    //   });
    // }

    // Always available actions
    quickActions.add({
      'title': 'Daftar Transaksi',
      'subtitle': 'Lihat semua transaksi',
      'icon': LucideIcons.list,
      'color': const Color(0xFF06b6d4),
      'onTap': () => setState(() => _selectedIndex = 3),
    });

    // Customer management for all roles
    quickActions.add({
      'title': 'Kelola Pelanggan',
      'subtitle': 'Manajemen customer',
      'icon': LucideIcons.users,
      'color': const Color(0xFFf97316),
      'onTap': () {
        // Navigate to customer management page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigasi ke halaman kelola pelanggan')),
        );
      },
    });

    // Add customer quick action (like in old QuickActions widget)
    quickActions.add({
      'title': 'Tambah Customer',
      'subtitle': 'Daftar customer baru',
      'icon': LucideIcons.userPlus,
      'color': const Color(0xFF14b8a6),
      'onTap': () {
        // Navigate to add customer page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigasi ke halaman tambah customer')),
        );
      },
    });

    quickActions.add({
      'title': 'Pengaturan',
      'subtitle': 'Kelola akun & profil',
      'icon': LucideIcons.settings,
      'color': const Color(0xFFf59e0b),
      'onTap': () => setState(() => _selectedIndex = 4),
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aksi Cepat',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1f2937),
          ),
        ),
        const SizedBox(height: 16),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: quickActions.length,
          itemBuilder:
              (context, index) => _buildActionCard(quickActions[index]),
        ),
      ],
    );
  }

  Widget _buildActionCard(Map<String, dynamic> action) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: action['onTap'],
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: action['color'].withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(action['icon'], color: action['color'], size: 24),
                ),
                const SizedBox(height: 12),

                Text(
                  action['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1f2937),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                Text(
                  action['subtitle'],
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernRecentActivity() {
    return Consumer<TransactionListProvider>(
      builder: (context, transactionProvider, child) {
        final recentTransactions =
            transactionProvider.transactions.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Aktivitas Terbaru',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1f2937),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _selectedIndex = 3),
                  icon: const Icon(LucideIcons.arrowRight, size: 16),
                  label: const Text('Lihat Semua'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF6366f1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (transactionProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (recentTransactions.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        LucideIcons.activity,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada transaksi hari ini',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  children:
                      recentTransactions
                          .map(
                            (transaction) => _buildTransactionItem(transaction),
                          )
                          .toList(),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem(dynamic transaction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10b981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              LucideIcons.shoppingCart,
              color: Color(0xFF10b981),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transaksi #${transaction.transactionNumber}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1f2937),
                  ),
                ),
                Text(
                  _formatTimeSafely(transaction.createdAt, 'HH:mm'),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rp ${_formatPrice(transaction.totalAmount)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10b981),
                ),
              ),
              Text(
                '${transaction.detailsCount} item',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
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

  // Bottom Navigation and other methods remain the same...
  List<BottomNavigationBarItem> _getAvailableNavItems(List<String>? userRoles) {
    if (userRoles == null) return [];

    List<BottomNavigationBarItem> items = [];

    if (RolePermissions.canAccessDashboard(userRoles)) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(LucideIcons.layoutDashboard),
          label: 'Dashboard',
        ),
      );
    }
    if (RolePermissions.canAccessPOS(userRoles)) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(LucideIcons.shoppingCart),
          label: 'POS',
        ),
      );
    }
    // Products and Reports navigation items hidden per user request
    // if (RolePermissions.canAccessProducts(userRoles)) {
    //   items.add(
    //     const BottomNavigationBarItem(
    //       icon: Icon(LucideIcons.package),
    //       label: 'Products',
    //     ),
    //   );
    // }
    // if (RolePermissions.canAccessReports(userRoles)) {
    //   items.add(
    //     const BottomNavigationBarItem(
    //       icon: Icon(LucideIcons.barChart3),
    //       label: 'Reports',
    //     ),
    //   );
    // }
    if (RolePermissions.canAccessProfile(userRoles)) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(LucideIcons.user),
          label: 'Profile',
        ),
      );
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userRoles = user.roleNames;
        final availablePages = _getAvailablePages(userRoles);
        final availableNavItems = _getAvailableNavItems(userRoles);

        // Ensure selectedIndex doesn't exceed available pages
        if (_selectedIndex >= availablePages.length) {
          _selectedIndex = 0;
        }

        // For kasir, if they can't access dashboard, default to POS
        if (!RolePermissions.canAccessDashboard(userRoles) &&
            _selectedIndex == 0) {
          _selectedIndex = RolePermissions.canAccessPOS(userRoles) ? 0 : 0;
        }

        return Scaffold(
          backgroundColor: const Color(0xFFf8fafc),
          body:
              availablePages.isNotEmpty
                  ? availablePages[_selectedIndex]
                  : const Center(child: Text('No accessible features')),
          bottomNavigationBar:
              availableNavItems.isNotEmpty
                  ? Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: BottomNavigationBar(
                      type: BottomNavigationBarType.fixed,
                      currentIndex: _selectedIndex,
                      onTap: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });

                        // Refresh transaction data when returning to dashboard
                        if (index == 0) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            final transactionProvider =
                                context.read<TransactionListProvider>();
                            transactionProvider.loadTransactions(refresh: true);
                          });
                        }
                      },
                      selectedItemColor: const Color(0xFF6366f1),
                      unselectedItemColor: Colors.grey[400],
                      backgroundColor: Colors.white,
                      elevation: 0,
                      selectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      items: availableNavItems,
                    ),
                  )
                  : null,
        );
      },
    );
  }
}
