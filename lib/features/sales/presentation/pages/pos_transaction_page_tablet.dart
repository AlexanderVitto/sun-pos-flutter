import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../products/providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/pending_transaction_provider.dart';
import '../../../../data/models/product.dart';
import '../../../../data/models/cart_item.dart';
import 'payment_success_page.dart';
import 'pending_transaction_list_page.dart';
import '../../../transactions/data/services/transaction_api_service.dart';
import '../../../transactions/data/models/create_transaction_request.dart';
import '../../../transactions/data/models/transaction_detail.dart';
import '../widgets/customer_input_dialog.dart';
import '../../../customers/data/models/customer.dart';

class POSTransactionPage extends StatefulWidget {
  const POSTransactionPage({super.key});

  @override
  State<POSTransactionPage> createState() => _POSTransactionPageState();
}

class _POSTransactionPageState extends State<POSTransactionPage> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  CartProvider? _cartProvider;
  NavigatorState? _navigator;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get and cache the Navigator instance
    _navigator = Navigator.maybeOf(context);

    // Get and cache the CartProvider instance
    if (_cartProvider == null) {
      _cartProvider = Provider.of<CartProvider>(context, listen: false);
      print(
        '🛒 DEBUG: Cached CartProvider instance: ${_cartProvider.hashCode}',
      );

      // Listen to changes and force rebuild
      _cartProvider!.addListener(_onCartChanged);
    }
  }

  void _onCartChanged() {
    print('🛒 Cart listener triggered: ${_cartProvider!.items.length} items');
    if (mounted) {
      setState(() {}); // Force UI rebuild
    }
  }

  Future<void> _showCustomerDialog() async {
    final selectedCustomer = await showDialog<Customer?>(
      context: context,
      builder: (context) => const CustomerInputDialog(),
    );

    if (selectedCustomer != null && _cartProvider != null) {
      _cartProvider!.setCustomerName(selectedCustomer.name);
      _cartProvider!.setCustomerPhone(selectedCustomer.phone);
    }
  }

  @override
  void dispose() {
    // Remove listener to prevent memory leaks and access to deactivated widget
    _cartProvider?.removeListener(_onCartChanged);
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768; // Tablet if width >= 768px

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isTablet ? 'Transaksi POS - Tablet' : 'Transaksi POS',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          // Hide cart icon on tablet since cart is always visible
          if (!isTablet)
            Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart),
                      onPressed: () => _showCartBottomSheet(context),
                    ),
                    if (cartProvider.itemCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${cartProvider.itemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
      body: isTablet ? _buildTabletLayout() : _buildMobileLayout(),
    );
  }

  // Mobile layout (original design)
  Widget _buildMobileLayout() {
    return Scaffold(
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchAndFilter(),

          // Products Grid
          _buildProductsGrid(crossAxisCount: 2),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Tablet layout with side-by-side cart and products
  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Left side - Products (70% width)
        Expanded(
          flex: 7,
          child: Column(
            children: [
              // Search and Filter Section
              _buildSearchAndFilter(),

              // Products Grid with more columns for tablet
              _buildProductsGrid(crossAxisCount: 3),
            ],
          ),
        ),

        // Right side - Cart (30% width)
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Colors.grey[300]!)),
            ),
            child: _buildCartSidebar(),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Cari produk...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),

          // Category Filter
          SizedBox(
            height: 40,
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                final categories = ['Semua', ...productProvider.categories];
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = _selectedCategory == category;
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: Colors.blue[100],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid({required int crossAxisCount}) {
    return Expanded(
      child: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          final allProducts = productProvider.products;
          final filteredProducts =
              allProducts.where((product) {
                final matchesSearch = product.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
                final matchesCategory =
                    _selectedCategory == 'Semua' ||
                    product.category == _selectedCategory;
                return matchesSearch && matchesCategory;
              }).toList();

          if (filteredProducts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Tidak ada produk ditemukan',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              return _buildProductCard(product);
            },
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        if (cartProvider.items.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total (${cartProvider.itemCount} item)',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      'Rp ${_formatPrice(cartProvider.total)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => _processPayment(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'BAYAR',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Cart sidebar for tablet
  Widget _buildCartSidebar() {
    return AnimatedBuilder(
      animation: _cartProvider!,
      builder: (context, child) {
        print(
          '🛒 DEBUG: Cart sidebar rebuild - Provider: ${_cartProvider.hashCode}, Items: ${_cartProvider!.items.length}',
        );

        return Column(
          children: [
            // Cart Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.blue[600]),
              child: Row(
                children: [
                  const Icon(Icons.shopping_cart, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Keranjang (${_cartProvider!.itemCount})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_cartProvider!.items.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear_all, color: Colors.white),
                      onPressed: () {
                        _cartProvider!.clearCart();
                        _notesController
                            .clear(); // Clear notes when cart is cleared
                      },
                      tooltip: 'Kosongkan Keranjang',
                    ),
                ],
              ),
            ),

            // Cart Items
            Expanded(
              child:
                  _cartProvider!.items.isEmpty
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Keranjang kosong',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _cartProvider!.items.length,
                        itemBuilder: (context, index) {
                          final item = _cartProvider!.items[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp ${_formatPrice(item.product.price)}',
                                    style: TextStyle(
                                      color: Colors.green[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: const Icon(
                                                Icons.remove,
                                                size: 16,
                                              ),
                                              onPressed:
                                                  item.quantity > 1
                                                      ? () {
                                                        _cartProvider!
                                                            .updateItemQuantity(
                                                              item.id,
                                                              item.quantity - 1,
                                                            );
                                                      }
                                                      : () {
                                                        _cartProvider!
                                                            .removeItem(
                                                              item.id,
                                                            );
                                                      },
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            child: Text(
                                              '${item.quantity}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: const Icon(
                                                Icons.add,
                                                size: 16,
                                              ),
                                              onPressed:
                                                  item.quantity <
                                                          item.product.stock
                                                      ? () {
                                                        _cartProvider!
                                                            .updateItemQuantity(
                                                              item.id,
                                                              item.quantity + 1,
                                                            );
                                                      }
                                                      : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Rp ${_formatPrice(item.product.price * item.quantity)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),

            // Customer Information Section
            if (_cartProvider!.items.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Info Display or Button
                    if (_cartProvider!.customerName != null) ...[
                      // Selected Customer Display
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _cartProvider!.customerName!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (_cartProvider!.customerPhone != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      _cartProvider!.customerPhone!,
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _showCustomerDialog(),
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.green,
                                size: 18,
                              ),
                              tooltip: 'Ubah Pembeli',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _cartProvider!.setCustomerName(null);
                                _cartProvider!.setCustomerPhone(null);
                              },
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.red,
                                size: 18,
                              ),
                              tooltip: 'Hapus Pembeli',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Customer Input Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showCustomerDialog(),
                          icon: const Icon(Icons.person_add, size: 18),
                          label: const Text(
                            'Masukkan Pembeli',
                            style: TextStyle(fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: BorderSide(color: Colors.blue[300]!),
                            foregroundColor: Colors.blue[700],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Opsional - untuk receipt dan database customer',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Cart Total and Payment
            if (_cartProvider!.items.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total (${_cartProvider!.itemCount} item)',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rp ${_formatPrice(_cartProvider!.total)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _processPayment(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'BAYAR',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _addToCart(product),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image/Icon
                  Container(
                    width: double.infinity,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Icon(
                      _getProductIcon(product.category),
                      size: 40,
                      color: _getCategoryColor(product.category),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Product Name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(
                        product.category,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.category,
                      style: TextStyle(
                        fontSize: 10,
                        color: _getCategoryColor(product.category),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Price and Stock
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Rp ${_formatPrice(product.price)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[600],
                          ),
                        ),
                      ),
                      Text(
                        'Stok: ${product.stock}',
                        style: TextStyle(
                          fontSize: 10,
                          color:
                              product.stock < 10
                                  ? Colors.red
                                  : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed:
                          product.stock > 0 ? () => _addToCart(product) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_shopping_cart, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '+ Keranjang',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _addToCart(Product product) {
    print(
      '🛒 DEBUG: Adding ${product.name} to cart - Provider: ${_cartProvider.hashCode}',
    );

    // Use cached provider instance instead of Provider.of
    _cartProvider!.addItem(product);

    print(
      '🛒 DEBUG: After adding - Items count: ${_cartProvider!.items.length}',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} ditambahkan ke keranjang'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showCartBottomSheet(BuildContext context) {
    print(
      '🛒 DEBUG: _showCartBottomSheet CartProvider: ${_cartProvider.hashCode}, Items: ${_cartProvider!.items.length}',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    // Handle
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.shopping_cart),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _cartProvider!,
                              builder: (context, child) {
                                print(
                                  '🛒 DEBUG: Header rebuild - Items: ${_cartProvider!.items.length}',
                                );
                                return Text(
                                  'Keranjang (${_cartProvider!.itemCount})',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),

                    // Cart Items
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _cartProvider!,
                        builder: (context, child) {
                          print(
                            '🛒 DEBUG: Cart items rebuild - Provider: ${_cartProvider.hashCode}, Items: ${_cartProvider!.items.length}',
                          );

                          if (_cartProvider!.items.isEmpty) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Keranjang Belanja masih kosong',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _cartProvider!.items.length,
                            itemBuilder: (context, index) {
                              final item = _cartProvider!.items[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // Product Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.product.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Rp ${_formatPrice(item.product.price)}',
                                              style: TextStyle(
                                                color: Colors.green[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Quantity Controls
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove),
                                            onPressed:
                                                item.quantity > 1
                                                    ? () {
                                                      _cartProvider!
                                                          .updateItemQuantity(
                                                            item.id,
                                                            item.quantity - 1,
                                                          );
                                                    }
                                                    : () {
                                                      _cartProvider!.removeItem(
                                                        item.id,
                                                      );
                                                    },
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            child: Text(
                                              '${item.quantity}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add),
                                            onPressed:
                                                item.quantity <
                                                        item.product.stock
                                                    ? () {
                                                      _cartProvider!
                                                          .updateItemQuantity(
                                                            item.id,
                                                            item.quantity + 1,
                                                          );
                                                    }
                                                    : null,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // Total and Checkout
                    AnimatedBuilder(
                      animation: _cartProvider!,
                      builder: (context, child) {
                        if (_cartProvider!.items.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total (${_cartProvider!.itemCount} item)',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    'Rp ${_formatPrice(_cartProvider!.total)}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _processPayment(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[600],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'BAYAR',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  void _processPayment(BuildContext context) {
    if (_cartProvider!.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keranjang kosong!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog before processing payment
    _showPaymentConfirmationDialog(context);
  }

  void _showPaymentConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(Icons.payment, color: Colors.green),
              SizedBox(width: 8),
              Text('Konfirmasi Pembayaran'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Pembayaran:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // Items List
                  Container(
                    constraints: BoxConstraints(maxHeight: 200),
                    child: SingleChildScrollView(
                      child: Column(
                        children:
                            _cartProvider!.items.map((item) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.product.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            'Rp ${_formatPrice(item.product.price)}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        '${item.quantity}x',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Rp ${_formatPrice(item.subtotal)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.green[600],
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Payment Summary
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Item:',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '${_cartProvider!.itemCount}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Pembayaran:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Rp ${_formatPrice(_cartProvider!.total)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Apakah Anda yakin ingin melanjutkan pembayaran?',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  // Notes Input Field
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Catatan transaksi (opsional)...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
              child: const Text('Batal'),
            ),
            // Pesan button - creates order with status=payment
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _confirmOrder(context); // Process order (status=payment)
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Pesan'),
            ),
            const SizedBox(width: 8),
            // Bayar Sekarang button - creates transaction with status=completed
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _confirmPayment(context); // Process payment (status=completed)
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Bayar Sekarang'),
            ),
          ],
        );
      },
    );
  }

  void _confirmPayment(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Memproses transaksi...'),
            ],
          ),
        );
      },
    );

    try {
      // Create transaction request
      final transactionRequest = await _createTransactionRequest();
      if (!mounted) return;

      // Call API to create transaction
      final transactionService = TransactionApiService();
      final response = await transactionService.createTransaction(
        transactionRequest,
      );
      if (!mounted) return;

      // Close loading dialog using cached navigator
      if (mounted && _navigator != null && _navigator!.canPop()) {
        _navigator!.pop();
      }
      if (!mounted) return;

      if (response.success && response.data != null) {
        // Save cart data before clearing
        final cartItems = List<CartItem>.from(_cartProvider!.items);
        final totalAmount = _cartProvider!.total;

        // Delete pending transaction if it exists
        final pendingProvider = Provider.of<PendingTransactionProvider>(
          context,
          listen: false,
        );

        // Check if this is from a pending transaction by customer name
        final customerName = _cartProvider!.customerName;
        if (customerName != null && customerName.isNotEmpty) {
          // Find and delete pending transaction for this customer
          final pendingTransactions = pendingProvider.pendingTransactionsList;
          try {
            final matchingTransaction = pendingTransactions.firstWhere(
              (transaction) => transaction.customerName == customerName,
            );

            await pendingProvider.deletePendingTransaction(
              matchingTransaction.customerId,
            );
          } catch (e) {
            // No matching pending transaction found, continue normally
            debugPrint(
              'No pending transaction found for customer: $customerName',
            );
          }
        }

        // Clear cart after successful payment
        _cartProvider!.clearCart();
        _notesController.clear(); // Clear notes after successful transaction

        // Navigate to payment success page with transaction data
        if (mounted && _navigator != null) {
          _navigator!.pushReplacement(
            MaterialPageRoute(
              builder:
                  (context) => PaymentSuccessPage(
                    paymentMethod: response.data!.paymentMethod,
                    amountPaid: response.data!.paidAmount,
                    store: response.data!.store,
                    totalAmount: totalAmount,
                    transactionNumber: response.data!.transactionNumber,
                    cartItems: cartItems,
                    notes:
                        _notesController.text.trim().isEmpty
                            ? null
                            : _notesController.text.trim(),
                  ),
            ),
          );
        }

        // Show success message with transaction number
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Transaksi berhasil! No: ${response.data!.transactionNumber}',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Show error message
        if (mounted) {
          _showErrorDialog(
            context,
            'Gagal memproses transaksi: ${response.message}',
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      // Close loading dialog if still open using cached navigator
      if (mounted && _navigator != null && _navigator!.canPop()) {
        _navigator!.pop();
      }
      if (!mounted) return;

      // Show error dialog
      if (mounted) {
        _showErrorDialog(context, 'Terjadi kesalahan: ${e.toString()}');
      }
    }
  }

  void _confirmOrder(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Memproses pesanan...'),
            ],
          ),
        );
      },
    );

    try {
      // Create transaction request with status=pending
      final transactionRequest = await _createTransactionRequestWithStatus(
        'pending',
      );
      if (!mounted) return;

      // Call API to create transaction
      final transactionService = TransactionApiService();
      final response = await transactionService.createTransaction(
        transactionRequest,
      );
      if (!mounted) return;

      // Close loading dialog using cached navigator
      if (mounted && _navigator != null && _navigator!.canPop()) {
        _navigator!.pop();
      }
      if (!mounted) return;

      if (response.success && response.data != null) {
        // Delete pending transaction if it exists
        final pendingProvider = Provider.of<PendingTransactionProvider>(
          context,
          listen: false,
        );

        // Check if this is from a pending transaction by customer name
        final customerName = _cartProvider!.customerName;
        if (customerName != null && customerName.isNotEmpty) {
          // Find and delete pending transaction for this customer
          final pendingTransactions = pendingProvider.pendingTransactionsList;
          try {
            final matchingTransaction = pendingTransactions.firstWhere(
              (transaction) => transaction.customerName == customerName,
            );

            await pendingProvider.deletePendingTransaction(
              matchingTransaction.customerId,
            );
          } catch (e) {
            print('No pending transaction found for customer: $customerName');
          }
        }

        // Clear cart
        _cartProvider!.clearCart();
        _notesController.clear();

        // Navigate to dashboard
        if (mounted && _navigator != null) {
          _navigator!.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const PendingTransactionListPage(),
            ),
            (route) => false, // Remove all previous routes
          );
        }

        // Show success message with transaction number
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Pesanan berhasil dibuat! No: ${response.data!.transactionNumber}',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Show error message
        if (mounted) {
          _showErrorDialog(
            context,
            'Gagal memproses pesanan: ${response.message}',
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      // Close loading dialog if still open using cached navigator
      if (mounted && _navigator != null && _navigator!.canPop()) {
        _navigator!.pop();
      }
      if (!mounted) return;

      // Show error dialog
      if (mounted) {
        _showErrorDialog(context, 'Terjadi kesalahan: ${e.toString()}');
      }
    }
  }

  Future<CreateTransactionRequest> _createTransactionRequest() async {
    return _createTransactionRequestWithStatus('completed');
  }

  Future<CreateTransactionRequest> _createTransactionRequestWithStatus(
    String status,
  ) async {
    // Get current date in YYYY-MM-DD format
    final now = DateTime.now();
    final transactionDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Convert cart items to transaction details
    final details =
        _cartProvider!.items.map((cartItem) {
          return TransactionDetail(
            productId:
                int.tryParse(cartItem.product.id) ??
                1, // Convert string ID to int, default to 1 if conversion fails
            productVariantId:
                int.tryParse(cartItem.product.id) ??
                1, // Using same ID for variant, adjust as needed
            quantity: cartItem.quantity,
            unitPrice: cartItem.product.price,
          );
        }).toList();

    return CreateTransactionRequest(
      storeId: 1, // Default store ID, you can make this configurable
      paymentMethod: 'cash',
      paidAmount: _cartProvider!.total, // Assuming exact payment for now
      notes:
          _notesController.text.trim().isEmpty
              ? 'POS Transaction - ${_cartProvider!.items.length} items'
              : _notesController.text.trim(),
      transactionDate: transactionDate,
      details: details,
      customerName: _cartProvider!.customerName,
      customerPhone: _cartProvider!.customerPhone,
      status: status,
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('Error'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  IconData _getProductIcon(String category) {
    switch (category.toLowerCase()) {
      case 'single rows':
        return Icons.water_drop;
      case 'display cake':
        return Icons.cake;
      case 'snacks':
        return Icons.cookie;
      case 'beverages':
        return Icons.local_drink;
      case 'food':
        return Icons.restaurant;
      default:
        return Icons.shopping_bag;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'single rows':
        return Colors.blue;
      case 'display cake':
        return Colors.pink;
      case 'snacks':
        return Colors.orange;
      case 'beverages':
        return Colors.cyan;
      case 'food':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
