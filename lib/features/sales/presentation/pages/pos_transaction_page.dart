import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
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

class POSTransactionPage extends StatelessWidget {
  const POSTransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<POSTransactionViewModel>(
      builder: (context, viewModel, child) {
        return _POSTransactionView(viewModel: viewModel);
      },
    );
  }
}

class _POSTransactionView extends StatelessWidget {
  final POSTransactionViewModel viewModel;

  const _POSTransactionView({required this.viewModel});

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
      PaymentService.processPayment(
        context,
        cartProvider,
        viewModel.notesController,
      );
    }
  }
}
