import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../../../core/constants/app_icons.dart';

class ProductSearchBar extends StatefulWidget {
  const ProductSearchBar({super.key});

  @override
  State<ProductSearchBar> createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends State<ProductSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    _controller.text = productProvider.searchQuery;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Search products...',
        prefixIcon: const Icon(AppIcons.search),
        suffixIcon:
            _controller.text.isNotEmpty
                ? IconButton(
                  icon: const Icon(AppIcons.close),
                  onPressed: () {
                    _controller.clear();
                    Provider.of<ProductProvider>(
                      context,
                      listen: false,
                    ).clearSearch();
                  },
                )
                : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      onChanged: (value) {
        Provider.of<ProductProvider>(
          context,
          listen: false,
        ).searchProducts(value);
        setState(() {});
      },
    );
  }
}
