import 'package:flutter/material.dart';
import '../../../../data/models/product.dart';
import '../widgets/product_search_filter.dart';
import '../widgets/product_grid.dart';
import '../view_models/pos_transaction_view_model.dart';

class MobileLayout extends StatelessWidget {
  final POSTransactionViewModel viewModel;
  final void Function(Product, int) onAddToCart; // Updated to include quantity
  final void Function(Product) onProductTap;

  const MobileLayout({
    super.key,
    required this.viewModel,
    required this.onAddToCart,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProductSearchFilter(
          searchQuery: viewModel.searchQuery,
          selectedCategory: viewModel.selectedCategory,
          onSearchChanged: viewModel.updateSearchQuery,
          onCategoryChanged: viewModel.updateSelectedCategory,
        ),
        Expanded(
          child: ProductGrid(
            crossAxisCount: 2,
            searchQuery: viewModel.searchQuery,
            selectedCategory: viewModel.selectedCategory,
            onAddToCart: onAddToCart,
            onProductTap: onProductTap,
          ),
        ),
      ],
    );
  }
}
