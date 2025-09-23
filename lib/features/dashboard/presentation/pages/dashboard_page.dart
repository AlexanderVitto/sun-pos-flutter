import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../transactions/providers/transaction_list_provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/role_permissions.dart';
import '../../../products/providers/product_provider.dart';
// import '../../../products/presentation/pages/products_page_modern.dart'; // Hidden per user request
// import '../../../reports/presentation/pages/reports_page.dart'; // Hidden per user request
import '../../../profile/user_profile_page.dart';
import '../../../../core/events/transaction_events.dart';
import '../../../customers/pages/customer_list_page.dart';
// import '../../../cash_flows/presentation/pages/cash_flows_page.dart'; // Hidden per user request
// import '../../../cash_flows/presentation/pages/add_cash_flow_page.dart'; // Hidden per user request
import '../../../sales/presentation/pages/pending_transaction_list_page.dart';
import '../widgets/transaction_tab_page.dart';
import '../../providers/store_provider.dart';

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

  @override
  void initState() {
    super.initState();
    // Set initial index from widget parameter
    _selectedIndex = widget.initialIndex;

    // Initialize providers once to maintain state
    _productProvider = ProductProvider();

    _initializeStoreProvider();

    // Add observer for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    // Initialize StoreProvider and listen for AuthProvider changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToAuthProvider();
      _initializeProvidersData();
      _startAutoRefresh();
      _listenToTransactionEvents();
    });
  }

  void _initializeStoreProvider() {
    // Initialize store from user profile immediately
    final authProvider = context.read<AuthProvider>();
    final storeProvider = context.read<StoreProvider>();
    final user = authProvider.user;

    if (user != null &&
        user.stores.isNotEmpty &&
        !storeProvider.hasSelectedStore) {
      storeProvider.initializeWithStores(user.stores);
      debugPrint('🏪 StoreProvider initialized on dashboard load');
    } else {
      debugPrint('⏳ Waiting for AuthProvider to load user data...');
    }
  }

  void _listenToAuthProvider() {
    // Listen to AuthProvider changes to initialize store when user data is ready
    final authProvider = context.read<AuthProvider>();

    void authListener() {
      if (!mounted) return;

      final user = authProvider.user;
      final storeProvider = context.read<StoreProvider>();

      if (user != null &&
          user.stores.isNotEmpty &&
          !storeProvider.hasSelectedStore) {
        storeProvider.initializeWithStores(user.stores);
        debugPrint('🏪 StoreProvider initialized after AuthProvider update');
      }
    }

    authProvider.addListener(authListener);
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

  void _showStoreSelector(BuildContext context, List<dynamic> stores) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Consumer<StoreProvider>(
          builder: (context, storeProvider, child) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle indicator
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF6366f1,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            LucideIcons.store,
                            color: Color(0xFF6366f1),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Pilih Toko',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1f2937),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(LucideIcons.x),
                        ),
                      ],
                    ),
                  ),

                  // Store list
                  Container(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: stores.length,
                      itemBuilder: (context, index) {
                        final store = stores[index];
                        final isSelected =
                            storeProvider.selectedStore?.id == store.id;

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? const Color(
                                      0xFF6366f1,
                                    ).withValues(alpha: 0.1)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? const Color(
                                        0xFF6366f1,
                                      ).withValues(alpha: 0.3)
                                      : Colors.grey.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors:
                                      isSelected
                                          ? [
                                            const Color(0xFF6366f1),
                                            const Color(0xFF8b5cf6),
                                          ]
                                          : [
                                            Colors.grey[400]!,
                                            Colors.grey[300]!,
                                          ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                LucideIcons.store,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    store.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          isSelected
                                              ? const Color(0xFF6366f1)
                                              : const Color(0xFF1f2937),
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10b981),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Aktif',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (store.address.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    store.address,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color:
                                            store.isActive
                                                ? const Color(0xFF10b981)
                                                : const Color(0xFFef4444),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      store.isActive ? 'Aktif' : 'Tidak Aktif',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            store.isActive
                                                ? const Color(0xFF10b981)
                                                : const Color(0xFFef4444),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'ID: ${store.id}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            onTap:
                                isSelected
                                    ? null
                                    : () {
                                      // Set selected store using StoreProvider
                                      storeProvider.setSelectedStore(store);
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Berhasil beralih ke ${store.name}',
                                          ),
                                          backgroundColor: const Color(
                                            0xFF6366f1,
                                          ),
                                        ),
                                      );
                                    },
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
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
        // Navigate to login using Navigator instead of context across async gap
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
      pages.add(const TransactionTabPage());
    }
    if (RolePermissions.canAccessPOS(userRoles)) {
      pages.add(const PendingTransactionListPage());
    }
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

                    const SizedBox(height: 24),

                    // Store information card
                    _buildStoreInfoCard(),

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
                          final userName =
                              authProvider.user?.name ?? 'Pengguna';
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
                            final userName = authProvider.user?.name ?? 'P';
                            return Text(
                              userName.isNotEmpty
                                  ? userName[0].toUpperCase()
                                  : 'P',
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
              child: Column(
                children: [
                  // Date and system status row
                  Row(
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
                              DateFormat(
                                'EEEE, dd MMMM yyyy',
                                'id_ID',
                              ).format(DateTime.now()),
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

                  const SizedBox(height: 12),

                  // Store information row using StoreProvider
                  Consumer<StoreProvider>(
                    builder: (context, storeProvider, child) {
                      final currentStore = storeProvider.selectedStore;

                      if (currentStore == null) {
                        return const SizedBox.shrink();
                      }

                      return Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          final user = authProvider.user;
                          final storeCount = user?.stores.length ?? 0;

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    LucideIcons.store,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentStore.name,
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.95,
                                          ),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (currentStore.address.isNotEmpty)
                                        Text(
                                          currentStore.address,
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.7,
                                            ),
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                                if (storeCount > 1)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF10b981,
                                      ).withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap:
                                            () => _showStoreSelector(
                                              context,
                                              user?.stores ?? [],
                                            ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '1 dari $storeCount',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Icon(
                                                LucideIcons.chevronDown,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    },
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
                    title: 'Pendapatan',
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

                // Products Count
                Expanded(
                  child: _buildStatCard(
                    title: 'Produk',
                    value: _productProvider.products.length.toString(),
                    icon: LucideIcons.package,
                    color: const Color(0xFF8b5cf6), // Purple
                    subtitle: 'Total produk',
                  ),
                ),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.8),
            Colors.white.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.5),
            blurRadius: 0,
            offset: const Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with gradient background
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),

          const SizedBox(height: 15),

          // Value with modern typography
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1a1a1a),
              letterSpacing: -0.5,
              height: 1.0,
            ),
          ),

          const SizedBox(height: 4),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4a5568),
              letterSpacing: 0.2,
            ),
          ),

          const SizedBox(height: 2),

          // Subtitle with accent color
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreInfoCard() {
    return Consumer<StoreProvider>(
      builder: (context, storeProvider, child) {
        final currentStore = storeProvider.selectedStore;

        if (currentStore == null) {
          return const SizedBox.shrink();
        }

        return Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.user;
            final storeCount = user?.stores.length ?? 0;

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.9),
                    Colors.white.withValues(alpha: 0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366f1).withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF6366f1),
                              const Color(0xFF8b5cf6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF6366f1,
                              ).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.store,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Toko Aktif',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6b7280),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentStore.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1f2937),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (storeCount > 1)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF10b981),
                                const Color(0xFF059669),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF10b981,
                                ).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap:
                                  () => _showStoreSelector(
                                    context,
                                    user?.stores ?? [],
                                  ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '1 dari $storeCount toko',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      LucideIcons.chevronDown,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  if (currentStore.address.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf8fafc),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFe2e8f0),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.mapPin,
                            color: Color(0xFF6b7280),
                            size: 16,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              currentStore.address,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4b5563),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (currentStore.phoneNumber.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf8fafc),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFe2e8f0),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.phone,
                            color: Color(0xFF6b7280),
                            size: 16,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            currentStore.phoneNumber,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4b5563),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Store status indicator
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              currentStore.isActive
                                  ? const Color(0xFF10b981)
                                  : const Color(0xFFef4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        currentStore.isActive
                            ? 'Toko Aktif'
                            : 'Toko Tidak Aktif',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                              currentStore.isActive
                                  ? const Color(0xFF10b981)
                                  : const Color(0xFFef4444),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'ID: ${currentStore.id}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9ca3af),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
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
        'color': const Color(0xFF10b981),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PendingTransactionListPage(),
            ),
          );
        },
      });
    }

    // Customer management for all roles
    quickActions.add({
      'title': 'Kelola Pelanggan',
      'subtitle': 'Manajemen customer',
      'icon': LucideIcons.users,
      'color': const Color(0xFFf97316),
      'onTap': () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CustomerListPage()),
        );
      },
    });

    quickActions.add({
      'title': 'Pengaturan',
      'subtitle': 'Kelola akun & profil',
      'icon': LucideIcons.settings,
      'color': const Color(0xFFf59e0b),
      'onTap': () => setState(() => _selectedIndex = 3),
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

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children:
              quickActions.map((action) => _buildActionCard(action)).toList(),
        ),
      ],
    );
  }

  Widget _buildActionCard(Map<String, dynamic> action) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: action['color'].withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.6),
            blurRadius: 0,
            offset: const Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: action['onTap'],
          splashColor: action['color'].withValues(alpha: 0.1),
          highlightColor: action['color'].withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with glassmorphism effect
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        action['color'],
                        action['color'].withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: action['color'].withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(action['icon'], color: Colors.white, size: 26),
                ),

                const SizedBox(height: 16),

                // Title with modern typography
                Text(
                  action['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1a1a1a),
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 4),

                // Subtitle with accent color
                Text(
                  action['subtitle'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: action['color'].withValues(alpha: 0.7),
                    letterSpacing: 0.1,
                  ),
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
                  onPressed: () => setState(() => _selectedIndex = 1),
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
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.8),
                      Colors.white.withValues(alpha: 0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (recentTransactions.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.8),
                      Colors.white.withValues(alpha: 0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.grey[400]!, Colors.grey[300]!],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          LucideIcons.activity,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada transaksi hari ini',
                        style: TextStyle(
                          color: Color(0xFF4a5568),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.9),
                      Colors.white.withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366f1).withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
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
                  DateFormat('HH:mm').format(transaction.createdAt),
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
                '${transaction.detailsCount} barang',
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

  List<BottomNavigationBarItem> _getAvailableNavItems(List<String>? userRoles) {
    if (userRoles == null) return [];

    List<BottomNavigationBarItem> items = [];

    if (RolePermissions.canAccessDashboard(userRoles)) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(LucideIcons.layoutDashboard),
          label: 'Beranda',
        ),
      );
    }
    if (RolePermissions.canAccessPOS(userRoles)) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(LucideIcons.clock),
          label: 'Transaksi',
        ),
      );
    }
    if (RolePermissions.canAccessPOS(userRoles)) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(LucideIcons.clipboard),
          label: 'Pesan',
        ),
      );
    }
    if (RolePermissions.canAccessProfile(userRoles)) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(LucideIcons.user),
          label: 'Profil',
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
