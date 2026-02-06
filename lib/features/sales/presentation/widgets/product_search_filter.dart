import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../products/providers/product_provider.dart';

class ProductSearchFilter extends StatelessWidget {
  final String searchQuery;
  final String selectedCategory;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategoryChanged;

  const ProductSearchFilter({
    super.key,
    required this.searchQuery,
    required this.selectedCategory,
    required this.onSearchChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                return TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari produk (min. 2 karakter)...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: productProvider.isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: onSearchChanged,
                );
              },
            ),
          ),

          // Category Filter
          SizedBox(
            height: 40,
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                final categories = productProvider.categories;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = selectedCategory == category;
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          onCategoryChanged(category);
                        },
                        backgroundColor: Colors.grey[100],
                        selectedColor: const Color(
                          0xFF6366f1,
                        ).withValues(alpha: 0.2),
                        checkmarkColor: const Color(0xFF6366f1),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? const Color(0xFF6366f1)
                              : Colors.grey[700],
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF6366f1)
                              : Colors.grey[300]!,
                          width: 1.5,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
