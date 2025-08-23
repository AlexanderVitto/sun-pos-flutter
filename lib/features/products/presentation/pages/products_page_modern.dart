import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/api_product_provider.dart';
import 'product_detail_page.dart';
import '../../../../core/theme/app_theme.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  void initState() {
    super.initState();
    // Initialize products after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ApiProductProvider>(context, listen: false);
      if (provider.apiProducts.isEmpty && !provider.isLoading) {
        provider.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header
            _buildModernHeader(context),

            // Content
            Expanded(
              child: Consumer<ApiProductProvider>(
                builder: (context, productProvider, child) {
                  if (productProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (productProvider.errorMessage != null) {
                    return _buildErrorState(context, productProvider);
                  }

                  return _buildProductsContent(productProvider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: AppTheme.headerDecoration,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: const Icon(
                    LucideIcons.package,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kelola Produk',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Manajemen produk toko',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ApiProductProvider productProvider,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: AppTheme.cardDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                child: Icon(
                  LucideIcons.alertCircle,
                  size: 48,
                  color: Colors.red[400],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Terjadi Kesalahan',
                style: AppTheme.headingSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                productProvider.errorMessage!,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => productProvider.refreshProducts(),
                style: AppTheme.primaryButtonStyle,
                icon: const Icon(LucideIcons.refreshCw, size: 18),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsContent(ApiProductProvider productProvider) {
    return Column(
      children: [
        // Custom search filter similar to ProductSearchFilter
        _buildProductSearchFilter(productProvider),

        // Product count and actions
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingLarge,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Icon(
                  LucideIcons.package,
                  size: 16,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${productProvider.apiProducts.length} dari ${productProvider.totalProducts} produk',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const Spacer(),
              if (productProvider.searchQuery.isNotEmpty ||
                  productProvider.selectedCategoryId != null)
                TextButton.icon(
                  onPressed: () => productProvider.clearFilters(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryIndigo,
                  ),
                  icon: const Icon(LucideIcons.x, size: 16),
                  label: const Text('Hapus Filter'),
                ),
            ],
          ),
        ),

        const SizedBox(height: AppTheme.spacingMedium),

        // Products grid
        Expanded(
          child:
              productProvider.apiProducts.isEmpty
                  ? _buildEmptyState(productProvider)
                  : _buildProductsList(productProvider),
        ),
      ],
    );
  }

  Widget _buildProductSearchFilter(ApiProductProvider productProvider) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(LucideIcons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => productProvider.searchProducts(value),
            ),
          ),

          // Category Filter
          SizedBox(
            height: 40,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: productProvider.categories.length,
              itemBuilder: (context, index) {
                final category = productProvider.categories[index];
                final isSelected = productProvider.selectedCategory == category;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      productProvider.filterByCategoryName(category);
                    },
                    backgroundColor: Colors.grey[100],
                    selectedColor: const Color(
                      0xFF6366f1,
                    ).withValues(alpha: 0.2),
                    checkmarkColor: const Color(0xFF6366f1),
                    labelStyle: TextStyle(
                      color:
                          isSelected
                              ? const Color(0xFF6366f1)
                              : Colors.grey[700],
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color:
                          isSelected
                              ? const Color(0xFF6366f1)
                              : Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ApiProductProvider productProvider) {
    final bool isFiltered =
        productProvider.searchQuery.isNotEmpty ||
        productProvider.selectedCategoryId != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: AppTheme.cardDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.textTertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                child: Icon(
                  isFiltered ? LucideIcons.search : LucideIcons.package,
                  size: 48,
                  color: AppTheme.textTertiary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isFiltered ? 'Produk Tidak Ditemukan' : 'Belum Ada Produk',
                style: AppTheme.headingSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isFiltered
                    ? 'Coba ubah kata kunci pencarian atau filter'
                    : 'Belum ada produk yang tersedia',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsList(ApiProductProvider productProvider) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200 &&
            !productProvider.isLoading &&
            productProvider.hasNextPage) {
          productProvider.loadMoreProducts();
        }
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: AppTheme.spacingMedium,
            mainAxisSpacing: AppTheme.spacingMedium,
          ),
          itemCount:
              productProvider.apiProducts.length +
              (productProvider.isLoading && productProvider.hasNextPage
                  ? 1
                  : 0),
          itemBuilder: (context, index) {
            if (index == productProvider.apiProducts.length) {
              return const Center(child: CircularProgressIndicator());
            }

            final product = productProvider.apiProducts[index];
            return _buildModernProductCard(product, context);
          },
        ),
      ),
    );
  }

  Widget _buildModernProductCard(dynamic product, BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToProductDetail(product, context),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: const Icon(
                    LucideIcons.package,
                    color: AppTheme.primaryBlue,
                    size: 20,
                  ),
                ),

                const SizedBox(height: AppTheme.spacingMedium),

                // Product Name
                Text(
                  product.name,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: AppTheme.spacingXSmall),

                // SKU
                Text(
                  'SKU: ${product.sku}',
                  style: AppTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),

                const Spacer(),

                // Status and Category
                Row(
                  children: [
                    // Category
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSmall,
                          ),
                        ),
                        child: Text(
                          product.category.name,
                          style: AppTheme.caption.copyWith(
                            color: AppTheme.primaryPurple,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            product.isActive
                                ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusSmall,
                        ),
                      ),
                      child: Text(
                        product.isActive ? 'Aktif' : 'Tidak Aktif',
                        style: AppTheme.caption.copyWith(
                          color:
                              product.isActive
                                  ? AppTheme.primaryGreen
                                  : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToProductDetail(dynamic product, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(productId: product.id),
      ),
    );
  }
}
