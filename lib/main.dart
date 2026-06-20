import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/themes/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/constants/app_strings.dart';
import 'core/utils/app_info_helper.dart';
import 'core/network/connectivity_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/products/providers/product_provider.dart';
import 'features/products/providers/api_product_provider.dart';
import 'features/products/providers/product_snapshot_provider.dart';
import 'features/products/providers/low_stock_provider.dart';
import 'features/sales/providers/cart_provider.dart';
import 'features/sales/providers/transaction_provider.dart';
import 'features/sales/providers/pending_transaction_provider.dart';
import 'features/sales/presentation/view_models/pos_transaction_view_model.dart';
import 'features/transactions/providers/transaction_list_provider.dart';
import 'features/refunds/providers/refund_list_provider.dart';
import 'features/customers/providers/customer_provider.dart';
import 'features/cash_flows/providers/cash_flow_provider.dart';
import 'features/reports/providers/reports_provider.dart';
import 'features/dashboard/providers/store_provider.dart';
import 'features/splash/splash.dart';

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
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StoreProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ApiProductProvider()),
        ChangeNotifierProvider(create: (_) => LowStockProvider()),
        // Snapshot produk offline: auto-sync saat ganti toko & saat kembali
        // online. Membaca StoreProvider + ConnectivityProvider (didaftarkan
        // di atas) untuk menentukan kapan harus menarik data.
        ChangeNotifierProvider(
          create: (context) {
            final snapshot = ProductSnapshotProvider();
            final storeProvider = context.read<StoreProvider>();
            final connectivity = context.read<ConnectivityProvider>();

            void syncCurrentStore() {
              final storeId = storeProvider.selectedStore?.id;
              if (storeId == null) return;
              if (connectivity.isOnline) {
                snapshot.sync(storeId: storeId);
              } else {
                // Offline → cukup refresh metadata cache yang sudah ada.
                snapshot.refreshMeta(storeId);
              }
            }

            // Sync ulang setiap kali toko aktif berubah.
            storeProvider.addOnStoreChangedCallback(syncCurrentStore);

            // Saat koneksi kembali online, sync snapshot toko aktif.
            connectivity.addListener(() {
              if (connectivity.isOnline && !snapshot.isSyncing) {
                syncCurrentStore();
              }
            });

            // Sync awal bila toko sudah terpilih saat app dibuka.
            syncCurrentStore();
            return snapshot;
          },
        ),
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
        // ProductDetailViewModel removed from global providers
        // It should be created locally in ProductDetailPage to avoid StackOverflowError
        ChangeNotifierProxyProvider4<
          CartProvider,
          TransactionProvider,
          PendingTransactionProvider,
          ProductProvider,
          POSTransactionViewModel
        >(
          create: (_) => POSTransactionViewModel(),
          update:
              (
                _,
                cartProvider,
                transactionProvider,
                pendingTransactionProvider,
                productProvider,
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
                  viewModel.updateProductProvider(productProvider);
                  return viewModel;
                }

                // Fallback jika viewModel null (seharusnya tidak terjadi)
                return POSTransactionViewModel()
                  ..updateCartProvider(cartProvider)
                  ..updateTransactionProvider(transactionProvider)
                  ..updatePendingTransactionProvider(pendingTransactionProvider)
                  ..updateProductProvider(productProvider);
              },
        ),
        ChangeNotifierProxyProvider2<
          StoreProvider,
          AuthProvider,
          TransactionListProvider
        >(
          // Register store-change callback di create() saja agar tidak
          // terakumulasi setiap kali update() dipanggil oleh proxy.
          create: (context) {
            final storeProvider = context.read<StoreProvider>();
            final provider = TransactionListProvider(
              storeProvider: storeProvider,
              authProvider: context.read<AuthProvider>(),
            );
            storeProvider.addOnStoreChangedCallback(() {
              provider.loadTransactions(refresh: true);
            });
            return provider;
          },
          update: (_, storeProvider, authProvider, transactionListProvider) {
            if (transactionListProvider != null) {
              transactionListProvider.updateUserId(authProvider.user?.id);
              return transactionListProvider;
            }
            final newProvider = TransactionListProvider(
              storeProvider: storeProvider,
              authProvider: authProvider,
            );
            newProvider.updateUserId(authProvider.user?.id);
            storeProvider.addOnStoreChangedCallback(() {
              newProvider.loadTransactions(refresh: true);
            });
            return newProvider;
          },
        ),
        ChangeNotifierProxyProvider2<
          StoreProvider,
          AuthProvider,
          RefundListProvider
        >(
          create: (context) {
            final storeProvider = context.read<StoreProvider>();
            final provider = RefundListProvider(storeProvider: storeProvider);
            storeProvider.addOnStoreChangedCallback(() {
              provider.loadRefunds(refresh: true);
            });
            return provider;
          },
          update: (_, storeProvider, authProvider, refundListProvider) {
            if (refundListProvider != null) {
              refundListProvider.updateUserId(authProvider.user?.id);
              return refundListProvider;
            }
            final newProvider = RefundListProvider(
              storeProvider: storeProvider,
            );
            newProvider.updateUserId(authProvider.user?.id);
            storeProvider.addOnStoreChangedCallback(() {
              newProvider.loadRefunds(refresh: true);
            });
            return newProvider;
          },
        ),
        ChangeNotifierProxyProvider<StoreProvider, CustomerProvider>(
          // Daftarkan callback store-change di create() saja agar tidak
          // terakumulasi setiap kali update() dipanggil oleh proxy.
          create: (context) {
            final storeProvider = context.read<StoreProvider>();
            final provider = CustomerProvider();
            storeProvider.addOnStoreChangedCallback(() {
              // Toko global berubah → muat ulang grup pelanggan toko itu.
              provider.loadCustomerGroups();
            });
            return provider;
          },
          update: (_, __, customerProvider) => customerProvider!,
        ),
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
        navigatorObservers: [appRouteObserver],
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// Widget AppWithUserSync sudah tidak diperlukan lagi
// karena sync dilakukan melalui ChangeNotifierProxyProvider
