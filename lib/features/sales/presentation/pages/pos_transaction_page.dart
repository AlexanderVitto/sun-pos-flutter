import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_router.dart';
import '../../providers/cart_provider.dart';
import '../../providers/pending_transaction_provider.dart';
import '../../../dashboard/providers/store_provider.dart';
import '../../../products/providers/product_provider.dart';
import '../../../transactions/providers/transaction_list_provider.dart';
import '../../../../data/models/product.dart';
import '../../../products/presentation/pages/product_detail_page.dart';
import '../view_models/pos_transaction_view_model.dart';
import '../widgets/pos_app_bar.dart';
import '../widgets/mobile_layout.dart';
import '../widgets/tablet_layout.dart';
import '../widgets/bottom_navigation_bar_widget.dart';
import 'cart_page.dart';
import '../services/payment_service.dart';
import '../utils/pos_ui_helpers.dart';

class POSTransactionPage extends StatefulWidget {
  const POSTransactionPage({super.key});

  @override
  State<POSTransactionPage> createState() => _POSTransactionPageState();
}

class _POSTransactionPageState extends State<POSTransactionPage>
    with WidgetsBindingObserver, RouteAware {
  DateTime? _lastAutoSave;
  int _lastCartItemCount = 0;

  // Periodic product refresh: how often to pull fresh products in the
  // background, and the minimum gap between any two refreshes (regardless of
  // trigger) to avoid storms when multiple triggers fire close together.
  static const Duration _productRefreshInterval = Duration(seconds: 30);
  static const Duration _productRefreshThrottle = Duration(seconds: 10);
  Timer? _productRefreshTimer;
  DateTime? _lastProductRefresh;

  @override
  void initState() {
    super.initState();
    // Add observer to listen for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    // Start periodic background refresh of products so kasir keeps getting
    // the latest server data without manual action.
    _productRefreshTimer = Timer.periodic(_productRefreshInterval, (_) {
      _refreshProductsIfIdle(reason: 'periodic');
    });

    // Debug: Check initial cart state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _debugCartState();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes so we get notified when this page becomes
    // visible again after a pushed page is popped (e.g. returning from Cart).
    final route = ModalRoute.of(context);
    if (route is ModalRoute<void>) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    // Remove observer
    WidgetsBinding.instance.removeObserver(this);
    appRouteObserver.unsubscribe(this);
    _productRefreshTimer?.cancel();
    // Save transaction before disposing
    _saveCurrentTransaction();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Save transaction when app goes to background or is paused
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _saveCurrentTransaction();
    }

    // Refresh products when the app returns to the foreground — handles the
    // common case of switching away for a while and coming back.
    if (state == AppLifecycleState.resumed) {
      _refreshProductsIfIdle(reason: 'app-resume');
    }
  }

  @override
  void didPopNext() {
    // Called when the user returns to POS after popping a pushed page
    // (e.g. closing Cart or a detail page). Server data may have changed
    // while they were away.
    _refreshProductsIfIdle(reason: 'route-popnext');
  }

  /// Refresh products if no other product load is in flight and the throttle
  /// window has elapsed. User-initiated pull-to-refresh bypasses this and is
  /// handled directly by `RefreshIndicator` in `ProductGrid`.
  void _refreshProductsIfIdle({required String reason}) {
    if (!mounted) return;
    final now = DateTime.now();
    if (_lastProductRefresh != null &&
        now.difference(_lastProductRefresh!) < _productRefreshThrottle) {
      return;
    }
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    if (productProvider.isLoading || productProvider.isSearching) {
      // Don't clobber an in-flight search/filter result.
      return;
    }
    _lastProductRefresh = now;
    debugPrint('🔄 POS: refreshing products ($reason)');
    productProvider.refreshProducts();
  }

  /// Debug method to check cart state
  void _debugCartState() {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      debugPrint('🛒 POSTransactionPage - Cart State Check:');
      debugPrint('🛒 Items count: ${cartProvider.items.length}');
      debugPrint(
        '🛒 Selected customer: ${cartProvider.selectedCustomer?.name}',
      );
      debugPrint('🛒 Total amount: ${cartProvider.total}');

      if (cartProvider.items.isNotEmpty) {
        debugPrint('🛒 Cart items:');
        for (var item in cartProvider.items) {
          debugPrint('   - ${item.product.name} x ${item.quantity}');
        }
      }
    } catch (e) {
      debugPrint('❌ Error debugging cart state: $e');
    }
  }

  /// Save current transaction if there are items in cart and customer selected
  /// with smart caching to avoid unnecessary saves
  Future<void> _saveCurrentTransaction() async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      // Smart save: Only save if cart has changes and minimum time has passed
      final now = DateTime.now();
      final hasMinTimeElapsed =
          _lastAutoSave == null ||
          now.difference(_lastAutoSave!).inSeconds >= 5; // 5 seconds throttle

      final currentItemCount = cartProvider.items.length;
      final hasCartChanged = currentItemCount != _lastCartItemCount;

      if (!hasMinTimeElapsed && !hasCartChanged) {
        return; // Skip save if no significant changes
      }

      final pendingProvider = Provider.of<PendingTransactionProvider>(
        context,
        listen: false,
      );

      // Only save if cart has items and customer is selected
      if (cartProvider.isNotEmpty && cartProvider.selectedCustomer != null) {
        final customer = cartProvider.selectedCustomer!;

        await pendingProvider.savePendingTransaction(
          customerId: customer.id.toString(),
          customerName: customer.name,
          customerPhone: customer.phone,
          cartItems: cartProvider.items,
          notes: null, // Can be enhanced to include notes from view model
        );

        _lastAutoSave = now;
        _lastCartItemCount = currentItemCount;

        debugPrint(
          '✅ Auto-saved pending transaction for customer: ${customer.name} (${cartProvider.items.length} items)',
        );
      } else if (cartProvider.isEmpty &&
          cartProvider.selectedCustomer != null) {
        // If cart is empty but customer is selected, remove any existing pending transaction
        final customer = cartProvider.selectedCustomer!;
        final customerId = customer.id.toString();

        final existingTransaction = pendingProvider.getPendingTransaction(
          customerId,
        );
        if (existingTransaction != null) {
          await pendingProvider.deletePendingTransaction(customerId);
          debugPrint(
            '🗑️ Removed empty pending transaction for customer: ${customer.name}',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error auto-saving transaction: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          // Save transaction when back button is pressed
          await _saveCurrentTransaction();
        }
      },
      child: Consumer<POSTransactionViewModel>(
        builder: (context, viewModel, child) {
          return _POSTransactionView(
            viewModel: viewModel,
            onAutoSave: _saveCurrentTransaction,
          );
        },
      ),
    );
  }
}

class _POSTransactionView extends StatelessWidget {
  final POSTransactionViewModel viewModel;
  final Future<void> Function()? onAutoSave;

  const _POSTransactionView({required this.viewModel, this.onAutoSave});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;

    // Debug: Check viewModel and cartProvider state
    debugPrint('🛒 _POSTransactionView building...');
    debugPrint(
      '🛒 ViewModel cartProvider: ${viewModel.cartProvider?.hashCode}',
    );
    debugPrint('🛒 Cart items: ${viewModel.cartProvider?.items.length ?? 0}');
    debugPrint(
      '🛒 Selected customer: ${viewModel.cartProvider?.selectedCustomer?.name ?? 'None'}',
    );

    return Scaffold(
      appBar: POSAppBar(
        isTablet: isTablet,
        onCartPressed: () => _showCartBottomSheet(context),
      ),
      body: Container(
        color: const Color.fromARGB(255, 244, 244, 244),
        child: isTablet
            ? TabletLayout(
                viewModel: viewModel,
                onAddToCart: (product, quantity) =>
                    _addToCart(product, quantity, context),
                onPaymentPressed: () => _processPayment(context),
                onOrderPressed: () => _processOrder(context),
              )
            : MobileLayout(
                viewModel: viewModel,
                onAddToCart: (product, quantity) =>
                    _addToCart(product, quantity, context),
                onProductTap: (product) => _handleProductTap(product, context),
              ),
      ),
      bottomNavigationBar: !isTablet
          ? BottomNavigationBarWidget(
              onPaymentPressed: () => _processPayment(context),
              onOrderPressed: () => _processOrder(context),
            )
          : null,
    );
  }

  void _addToCart(Product product, int quantity, BuildContext context) {
    debugPrint('🛒 Adding product to cart: ${product.name} x$quantity');
    final viewModel = Provider.of<POSTransactionViewModel>(
      context,
      listen: false,
    );
    final cartProvider = viewModel.cartProvider;

    if (cartProvider != null) {
      debugPrint('🛒 Using CartProvider instance: ${cartProvider.hashCode}');
      debugPrint(
        '🛒 Before adding - total items: ${cartProvider.items.length}',
      );

      cartProvider.addItem(product, quantity: quantity, context: context);

      debugPrint('🛒 After adding - total items: ${cartProvider.items.length}');

      PosUIHelpers.showSuccessSnackbar(
        context,
        '${product.name} x$quantity ditambahkan ke keranjang',
      );

      // Load transactions after adding item to cart
      _loadTransactionsAfterCartUpdate(context);

      // Auto-save after adding item to cart (with throttling)
      if (onAutoSave != null) {
        // Use delayed save to avoid too frequent saves
        Future.delayed(const Duration(milliseconds: 500), () {
          onAutoSave!().catchError((e) {
            debugPrint('❌ Error auto-saving after add to cart: $e');
          });
        });
      }
    } else {
      debugPrint('❌ CartProvider is null!');
    }
  }

  /// Load transactions after cart is updated to keep data fresh
  void _loadTransactionsAfterCartUpdate(BuildContext context) {
    try {
      // Load pending transactions
      final pendingProvider = Provider.of<PendingTransactionProvider>(
        context,
        listen: false,
      );
      final storeId = context.read<StoreProvider>().selectedStore?.id;
      pendingProvider.loadPendingTransactions(storeId: storeId);

      // Load transaction list if provider is available
      try {
        final transactionListProvider = Provider.of<TransactionListProvider>(
          context,
          listen: false,
        );
        transactionListProvider.refreshTransactions();

        debugPrint('✅ Transaction lists refreshed after cart update');
      } catch (e) {
        // TransactionListProvider might not be available in current scope
        debugPrint('ℹ️ TransactionListProvider not available in current scope');
      }
    } catch (e) {
      debugPrint('❌ Error loading transactions after cart update: $e');
    }
  }

  void _handleProductTap(Product product, BuildContext context) async {
    debugPrint('🔍 Product tapped: ${product.name}');

    // Navigate to product detail page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(productId: product.id),
      ),
    );
  }

  void _showCartBottomSheet(BuildContext context) {
    final viewModel = Provider.of<POSTransactionViewModel>(
      context,
      listen: false,
    );
    final cartProvider = viewModel.cartProvider;

    if (cartProvider != null) {
      debugPrint('🛒 Opening cart page - items: ${cartProvider.items.length}');

      // Navigate to cart page instead of showing bottom sheet
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider<CartProvider>.value(
            value: cartProvider,
            child: CartPage(
              viewModel: viewModel,
              onPaymentPressed: () => _processPayment(context),
            ),
          ),
        ),
      );
    }
  }

  void _processPayment(BuildContext context) {
    final viewModel = Provider.of<POSTransactionViewModel>(
      context,
      listen: false,
    );
    final cartProvider = viewModel.cartProvider;

    if (cartProvider != null) {
      // Remove pending transaction after successful payment
      _removePendingTransactionAfterPayment(context, cartProvider);

      PaymentService.processPayment(
        context: context,
        cartProvider: cartProvider,
        notesController: viewModel.notesController,
      );
    }
  }

  void _processOrder(BuildContext context) {
    final viewModel = Provider.of<POSTransactionViewModel>(
      context,
      listen: false,
    );
    final cartProvider = viewModel.cartProvider;

    if (cartProvider != null) {
      // Remove pending transaction after successful order
      // _removePendingTransactionAfterPayment(context, cartProvider);

      PaymentService.processOrder(
        context: context,
        cartProvider: cartProvider,
        notesController: viewModel.notesController,
      );
    }
  }

  /// Remove pending transaction after payment is completed
  Future<void> _removePendingTransactionAfterPayment(
    BuildContext context,
    CartProvider cartProvider,
  ) async {
    try {
      if (cartProvider.selectedCustomer != null) {
        final customerId = cartProvider.selectedCustomer!.id.toString();
        final pendingProvider = Provider.of<PendingTransactionProvider>(
          context,
          listen: false,
        );

        // Check if there's a pending transaction for this customer
        final existingTransaction = pendingProvider.getPendingTransaction(
          customerId,
        );
        if (existingTransaction != null) {
          await pendingProvider.deletePendingTransaction(customerId);
          debugPrint(
            '✅ Removed pending transaction after payment for customer: ${cartProvider.selectedCustomer!.name}',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error removing pending transaction after payment: $e');
    }
  }
}
