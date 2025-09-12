import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/themes/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/constants/app_strings.dart';
import 'core/utils/app_info_helper.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/products/providers/product_provider.dart';
import 'features/products/providers/api_product_provider.dart';
import 'features/products/presentation/viewmodels/product_detail_viewmodel.dart';
import 'features/products/data/services/product_api_service.dart';
import 'features/sales/providers/cart_provider.dart';
import 'features/sales/providers/transaction_provider.dart';
import 'features/sales/providers/pending_transaction_provider.dart';
import 'features/sales/presentation/view_models/pos_transaction_view_model.dart';
import 'features/transactions/providers/transaction_list_provider.dart';
import 'features/customers/providers/customer_provider.dart';
import 'features/cash_flows/providers/cash_flow_provider.dart';
import 'features/reports/providers/reports_provider.dart';
import 'features/dashboard/providers/store_provider.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Indonesian locale for date formatting
  try {
    await initializeDateFormatting('id_ID', null);
  } catch (e) {
    // Fallback to default locale if Indonesian locale fails
    debugPrint('Failed to initialize id_ID locale, using default: $e');
    await initializeDateFormatting('en_US', null);
  }

  // Initialize app and device information for HTTP headers
  try {
    await AppInfoHelper.initialize();
    debugPrint('App info initialized: ${AppInfoHelper.userAgent}');
  } catch (e) {
    debugPrint('Failed to initialize app info: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StoreProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ApiProductProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => PendingTransactionProvider()),
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (_) => CartProvider(),
          update: (_, authProvider, cartProvider) {
            // Auto-sync user data dari AuthProvider ke CartProvider
            if (cartProvider != null) {
              cartProvider.syncUserData(authProvider.user);
              return cartProvider;
            }

            // Fallback jika cartProvider null
            final newCartProvider = CartProvider();
            newCartProvider.initializeWithUser(authProvider.user);
            return newCartProvider;
          },
        ),
        ChangeNotifierProxyProvider<CartProvider, ProductDetailViewModel>(
          create:
              (_) => ProductDetailViewModel(
                productId: 0, // Default value, akan diupdate saat digunakan
                apiService: ProductApiService(),
              ),
          update: (_, cartProvider, viewModel) {
            // Sesuai dokumentasi: reuse instance dan update properties
            if (viewModel != null) {
              viewModel.updateCartProvider(cartProvider);
              return viewModel;
            }

            // Fallback jika viewModel null
            return ProductDetailViewModel(
              productId: 0,
              apiService: ProductApiService(),
            )..updateCartProvider(cartProvider);
          },
        ),
        ChangeNotifierProxyProvider3<
          CartProvider,
          TransactionProvider,
          PendingTransactionProvider,
          POSTransactionViewModel
        >(
          create: (_) => POSTransactionViewModel(),
          update: (
            _,
            cartProvider,
            transactionProvider,
            pendingTransactionProvider,
            viewModel,
          ) {
            // CartProvider sudah auto-sync dengan AuthProvider melalui proxy
            // Sesuai dokumentasi: reuse instance dan update properties
            if (viewModel != null) {
              viewModel.updateCartProvider(cartProvider);
              viewModel.updateTransactionProvider(transactionProvider);
              viewModel.updatePendingTransactionProvider(
                pendingTransactionProvider,
              );
              return viewModel;
            }

            // Fallback jika viewModel null (seharusnya tidak terjadi)
            return POSTransactionViewModel()
              ..updateCartProvider(cartProvider)
              ..updateTransactionProvider(transactionProvider)
              ..updatePendingTransactionProvider(pendingTransactionProvider);
          },
        ),
        ChangeNotifierProvider(create: (_) => TransactionListProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => CashFlowProvider()),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appTitle,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const SplashScreen(),
        onGenerateRoute: AppRouter.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// Widget AppWithUserSync sudah tidak diperlukan lagi
// karena sync dilakukan melalui ChangeNotifierProxyProvider
