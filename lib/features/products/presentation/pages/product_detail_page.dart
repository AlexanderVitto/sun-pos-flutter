import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/product_detail_viewmodel.dart';
import '../../data/services/product_api_service.dart';
import '../../providers/product_provider.dart';
import '../../../sales/providers/cart_provider.dart';
import '../widgets/product_detail_app_bar.dart';
import '../widgets/product_info_card.dart';
import '../widgets/variants_section.dart';
import '../widgets/category_unit_info.dart';
import '../widgets/add_to_cart_section.dart';
import '../widgets/product_detail_state_views.dart';
import '../utils/product_detail_helpers.dart';

class ProductDetailPage extends StatelessWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    // Get ProductProvider from context
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    // Create ProductDetailViewModel locally with ChangeNotifierProxyProvider
    // This avoids the StackOverflowError caused by global provider
    return ChangeNotifierProxyProvider<CartProvider, ProductDetailViewModel>(
      create: (_) {
        final viewModel = ProductDetailViewModel(
          productId: productId,
          apiService: ProductApiService(),
        );
        // Inject ProductProvider
        viewModel.updateProductProvider(productProvider);
        return viewModel;
      },
      update: (_, cartProvider, viewModel) {
        // Reuse instance and update CartProvider reference
        if (viewModel != null) {
          viewModel.updateCartProvider(cartProvider);
          viewModel.updateProductProvider(productProvider);

          // Update productId if different
          if (viewModel.productId != productId) {
            viewModel.updateProductId(productId);
          }

          return viewModel;
        }

        // Fallback if viewModel is null
        return ProductDetailViewModel(
            productId: productId,
            apiService: ProductApiService(),
          )
          ..updateCartProvider(cartProvider)
          ..updateProductProvider(productProvider);
      },
      child: Consumer<ProductDetailViewModel>(
        builder: (context, viewModel, child) {
          return _ProductDetailView(viewModel: viewModel, productId: productId);
        },
      ),
    );
  }
}

class _ProductDetailView extends StatelessWidget {
  final ProductDetailViewModel viewModel;
  final int productId;

  const _ProductDetailView({required this.viewModel, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: ProductDetailAppBar(viewModel: viewModel),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (viewModel.isLoading) {
      return const LoadingView();
    }

    if (viewModel.errorMessage != null) {
      return ErrorView(
        errorMessage: viewModel.errorMessage!,
        onRetry: viewModel.loadProductDetail,
      );
    }

    if (viewModel.productDetail == null) {
      return const EmptyView();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductInfoCard(productDetail: viewModel.productDetail!),
          VariantsSection(viewModel: viewModel),
          CategoryAndUnitInfo(productDetail: viewModel.productDetail!),
          AddToCartSection(
            viewModel: viewModel,
            onAddToCart: () => _handleAddToCart(context),
          ),
          const SizedBox(height: 20), // Bottom padding
        ],
      ),
    );
  }

  Future<void> _handleAddToCart(BuildContext context) async {
    ProductDetailHelpers.handleAddToCart(context, viewModel);
  }
}
