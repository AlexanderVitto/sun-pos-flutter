import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/product_detail_viewmodel.dart';
import '../widgets/product_detail_app_bar.dart';
import '../widgets/product_info_card.dart';
import '../widgets/variants_section.dart';
import '../widgets/category_unit_info.dart';
import '../widgets/quantity_controls.dart';
import '../widgets/add_to_cart_section.dart';
import '../widgets/product_detail_state_views.dart';
import '../utils/product_detail_helpers.dart';

class ProductDetailPage extends StatelessWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductDetailViewModel>(
      builder: (context, viewModel, child) {
        // Update product ID jika berbeda
        if (viewModel.productId != productId) {
          // Panggil update di frame berikutnya untuk menghindari setState during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            viewModel.updateProductId(productId);
          });
        }

        return _ProductDetailView(viewModel: viewModel, productId: productId);
      },
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
          QuantityControls(viewModel: viewModel),
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
