import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';

class CategoryFilterChips extends StatelessWidget {
  const CategoryFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final categories = productProvider.categories;

        return SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category == productProvider.selectedCategory;

              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 0 : 8,
                  right: index == categories.length - 1 ? 0 : 0,
                ),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    productProvider.filterByCategory(category);
                  },
                  backgroundColor: Colors.white,
                  selectedColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.2),
                  checkmarkColor: Theme.of(context).primaryColor,
                  labelStyle: TextStyle(
                    color:
                        isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[700],
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color:
                        isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300]!,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
