import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/pending_transaction_provider.dart';
import '../../../../data/models/product.dart';
import '../../../products/presentation/pages/product_detail_page.dart';
import '../view_models/pos_transaction_view_model.dart';
import '../widgets/pos_app_bar.dart';
import '../widgets/mobile_layout.dart';
import '../widgets/tablet_layout.dart';
import '../widgets/bottom_navigation_bar_widget.dart';
import '../widgets/cart_bottom_sheet.dart';
import '../services/payment_service.dart';
import '../utils/pos_ui_helpers.dart';

class POSTransactionPage extends StatefulWidget {
  const POSTransactionPage({super.key});

  @override
  State<POSTransactionPage> createState() => _POSTransactionPageState();
}

class _POSTransactionPageState extends State<POSTransactionPage>
    with WidgetsBindingObserver {
  DateTime? _lastAutoSave;
  int _lastCartItemCount = 0;

  @override
  void initState() {
    super.initState();
    // Add observer to listen for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remove observer
    WidgetsBinding.instance.removeObserver(this);
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

    return Scaffold(
      appBar: POSAppBar(
        isTablet: isTablet,
        onCartPressed: () => _showCartBottomSheet(context),
      ),
      body: Container(
        color: const Color.fromARGB(255, 244, 244, 244),
        child:
            isTablet
                ? TabletLayout(
                  viewModel: viewModel,
                  onAddToCart: (product) => _addToCart(product, context),
                  onPaymentPressed: () => _processPayment(context),
                  onOrderPressed: () => _processOrder(context),
                )
                : MobileLayout(
                  viewModel: viewModel,
                  onAddToCart: (product) => _addToCart(product, context),
                  onProductTap:
                      (product) => _navigateToProductDetail(product, context),
                ),
      ),
      bottomNavigationBar:
          !isTablet
              ? BottomNavigationBarWidget(
                onPaymentPressed: () => _processPayment(context),
                onOrderPressed: () => _processOrder(context),
              )
              : null,
    );
  }

  void _addToCart(Product product, BuildContext context) {
    print('🛒 Adding product to cart: ${product.name}');
    final viewModel = Provider.of<POSTransactionViewModel>(
      context,
      listen: false,
    );
    final cartProvider = viewModel.cartProvider;

    if (cartProvider != null) {
      print('🛒 Using CartProvider instance: ${cartProvider.hashCode}');
      cartProvider.addItem(product);
      print('🛒 After adding - total items: ${cartProvider.items.length}');

      PosUIHelpers.showSuccessSnackbar(
        context,
        '${product.name} ditambahkan ke keranjang',
      );

      // Auto-save after adding item to cart (with throttling)
      if (onAutoSave != null) {
        // Use delayed save to avoid too frequent saves
        Future.delayed(const Duration(milliseconds: 500), () {
          onAutoSave!().catchError((e) {
            debugPrint('❌ Error auto-saving after add to cart: $e');
          });
        });
      }
    }
  }

  void _navigateToProductDetail(Product product, BuildContext context) {
    // Convert Product to int ID for ProductDetailPage
    final productId = int.tryParse(product.id) ?? 0;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(productId: productId),
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
      print('🛒 Opening bottom sheet - items: ${cartProvider.items.length}');

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) {
          // Pass cartProvider as value to ensure it's available in the modal
          return ChangeNotifierProvider<CartProvider>.value(
            value: cartProvider,
            child: CartBottomSheet(
              viewModel: viewModel,
              onPaymentPressed: () => _processPayment(context),
            ),
          );
        },
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
      _removePendingTransactionAfterPayment(context, cartProvider);

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
