import 'package:flutter/material.dart';
import '../../../../data/models/product.dart';
import '../widgets/product_search_filter.dart';
import '../widgets/product_grid.dart';
import '../widgets/cart_sidebar.dart';
import '../view_models/pos_transaction_view_model.dart';

class TabletLayout extends StatelessWidget {
  final POSTransactionViewModel viewModel;
  final void Function(Product) onAddToCart;
  final VoidCallback onPaymentPressed;

  const TabletLayout({
    super.key,
    required this.viewModel,
    required this.onAddToCart,
    required this.onPaymentPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + kToolbarHeight + 24,
        left: 24,
        right: 24,
        bottom: 24,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366f1).withValues(alpha: 0.1),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: ProductSearchFilter(
                      searchQuery: viewModel.searchQuery,
                      selectedCategory: viewModel.selectedCategory,
                      onSearchChanged: viewModel.updateSearchQuery,
                      onCategoryChanged: viewModel.updateSelectedCategory,
                    ),
                  ),
                  Expanded(
                    child: ProductGrid(
                      crossAxisCount: 3,
                      searchQuery: viewModel.searchQuery,
                      selectedCategory: viewModel.selectedCategory,
                      onAddToCart: onAddToCart,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          SizedBox(
            width: 400,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8b5cf6).withValues(alpha: 0.1),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: CartSidebar(onPaymentPressed: onPaymentPressed),
            ),
          ),
        ],
      ),
    );
  }
}
