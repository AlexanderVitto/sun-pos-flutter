import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/providers/auth_provider.dart';
import '../transactions/providers/transaction_list_provider.dart';
import '../sales/providers/pending_transaction_provider.dart';
import '../products/providers/product_provider.dart';
import '../customers/providers/customer_provider.dart';
import '../../core/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _loadingText = 'Checking authentication...';

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Tunggu sebentar untuk loading effect
    await Future.delayed(const Duration(seconds: 2));

    // Init auth provider untuk cek token
    await authProvider.init();

    if (!mounted) return;

    // Redirect berdasarkan status authentication
    if (authProvider.isAuthenticated) {
      // Ada token, load data terlebih dahulu
      await _loadAppData();

      if (!mounted) return;

      // Kemudian ke dashboard
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      // Tidak ada token, ke login
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  Future<void> _loadAppData() async {
    try {
      // Update loading text
      setState(() {
        _loadingText = 'Loading essential data...';
      });

      // Load products and customers in parallel for better performance
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      final customerProvider = Provider.of<CustomerProvider>(
        context,
        listen: false,
      );

      await Future.wait([
        productProvider.refreshProducts(),
        customerProvider.loadCustomers(refresh: true),
      ]);

      if (!mounted) return;

      // Update loading text
      setState(() {
        _loadingText = 'Loading transactions...';
      });

      // Load transaction-related data
      final transactionListProvider = Provider.of<TransactionListProvider>(
        context,
        listen: false,
      );
      final pendingTransactionProvider =
          Provider.of<PendingTransactionProvider>(context, listen: false);

      await Future.wait([
        transactionListProvider.refreshTransactions(),
        pendingTransactionProvider.loadPendingTransactions(),
      ]);

      if (!mounted) return;

      setState(() {
        _loadingText = 'Ready to go...';
      });

      // Small delay to show the "Ready" message
      await Future.delayed(const Duration(milliseconds: 500));

      debugPrint('All data loaded successfully after authentication');
      debugPrint('Products count: ${productProvider.products.length}');
      debugPrint('Customers count: ${customerProvider.customers.length}');
    } catch (e) {
      debugPrint('Error loading data after auth: $e');
      // Don't block navigation if data loading fails
      setState(() {
        _loadingText = 'Loading complete...';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[700],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo atau icon aplikasi
            const Icon(Icons.store, size: 80, color: Colors.white),
            const SizedBox(height: 24),

            // Nama aplikasi
            const Text(
              'Sun POS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            const Text(
              'Point of Sale System',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 40),

            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 16),

            Text(
              _loadingText,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
