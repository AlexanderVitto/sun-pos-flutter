import 'package:flutter/material.dart';
import '../../../../data/models/cart_item.dart';
import '../../../customers/data/models/customer.dart';
import '../../../transactions/data/models/store.dart';

class OrderConfirmationPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalAmount;
  final int itemCount;
  final TextEditingController notesController;
  final Function(
    String customerName,
    String customerPhone,
    List<CartItem> updatedCartItems,
    double updatedTotalAmount,
    double discountPercentage,
  )
  onConfirm;
  final Customer? selectedCustomer;
  final String? initialCustomerName;
  final String? initialCustomerPhone;
  final Store store;

  const OrderConfirmationPage({
    super.key,
    required this.cartItems,
    required this.totalAmount,
    required this.itemCount,
    required this.notesController,
    required this.onConfirm,
    required this.store,
    this.selectedCustomer,
    this.initialCustomerName,
    this.initialCustomerPhone,
  });

  @override
  _OrderConfirmationPageState createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  Customer? _selectedCustomer;
  bool _isProcessing = false;
  late List<CartItem> _cartItems;
  double _discountPercentage = 0.0;
  late TextEditingController _discountController;

  @override
  void initState() {
    super.initState();
    // Initialize cart items copy
    _cartItems = List.from(widget.cartItems);
    _discountController = TextEditingController(text: '0');

    // Prioritize pre-selected customer from cart
    if (widget.selectedCustomer != null) {
      _selectedCustomer = widget.selectedCustomer;
    } else if (widget.initialCustomerName?.isNotEmpty == true ||
        widget.initialCustomerPhone?.isNotEmpty == true) {
      // Fallback to initial data if no pre-selected customer
      _selectedCustomer = Customer(
        id: 0, // Temporary ID for display purposes
        name: widget.initialCustomerName ?? '',
        phone: widget.initialCustomerPhone ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  String get customerName => _selectedCustomer?.name ?? '';
  String get customerPhone => _selectedCustomer?.phone ?? '';

  List<CartItem> get updatedCartItems =>
      _cartItems.map((item) {
        // Apply discount percentage to each item's price
        final discountedPrice =
            item.product.price * (1 - (_discountPercentage / 100));
        return item.copyWith(
          product: item.product.copyWith(price: discountedPrice),
        );
      }).toList();

  double get subtotal => _cartItems.fold(
    0.0,
    (sum, item) => sum + (item.product.price * item.quantity),
  );

  double get subtotalAfterDiscount => updatedCartItems.fold(
    0.0,
    (sum, item) => sum + (item.product.price * item.quantity),
  );

  double get discountAmount => subtotal - subtotalAfterDiscount;
  double get updatedTotalAmount => subtotalAfterDiscount;

  void _recalculateTotal() {
    setState(() {
      // Total akan dihitung ulang melalui getter yang sudah ada
      // subtotal akan update otomatis karena _cartItems berubah
      // updatedTotalAmount akan update otomatis karena menggunakan subtotal dan discount
    });
  }

  void _updateDiscount() {
    setState(() {
      final discount = double.tryParse(_discountController.text) ?? 0.0;
      _discountPercentage = discount.clamp(0.0, 100.0);
      if (_discountPercentage != discount) {
        _discountController.text = _discountPercentage.toString();
      }
    });
  }

  void _showEditPriceModal(int index) {
    final item = _cartItems[index];
    final TextEditingController priceController = TextEditingController(
      text: item.product.price.toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'Edit Harga Item',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Product info
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              item.product.imagePath?.isNotEmpty == true
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item.product.imagePath!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey.shade400,
                                          ),
                                    ),
                                  )
                                  : Icon(
                                    Icons.shopping_bag,
                                    color: Colors.grey.shade400,
                                  ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Qty: ${item.quantity}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Price input
                    Text(
                      'Harga per Item',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.orange.shade600,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final newPrice = double.tryParse(
                                priceController.text,
                              );
                              if (newPrice != null && newPrice > 0) {
                                setState(() {
                                  _cartItems[index] = _cartItems[index]
                                      .copyWith(
                                        product: item.product.copyWith(
                                          price: newPrice,
                                        ),
                                      );
                                });
                                _recalculateTotal();
                                Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Harga harus berupa angka yang valid',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Simpan'),
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

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.help_outline,
                  color: Colors.orange.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Konfirmasi Pesanan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Apakah Anda yakin ingin membuat pesanan ini?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Item:',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          '${widget.itemCount} item',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Pembayaran:',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Rp ${updatedTotalAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pesanan akan disimpan dan menunggu pembayaran',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _handleConfirmOrder(); // Proceed with order
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Ya, Konfirmasi',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleConfirmOrder() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Pass the updated cart items and total to the callback
      widget.onConfirm(
        customerName,
        customerPhone,
        updatedCartItems,
        updatedTotalAmount,
        _discountPercentage,
      );
      // Navigation will be handled by the calling page
      // if (mounted) {
      //   Navigator.of(context).pop();
      // }
    } catch (e) {
      // Show error if needed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Konfirmasi Pesanan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade50, Colors.orange.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pesanan Menunggu Pembayaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pesanan akan disimpan dan menunggu pembayaran dari customer',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Order Summary Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade600,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.shopping_cart,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Detail Pesanan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Product List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _cartItems.length,
                      separatorBuilder:
                          (context, index) => const Divider(height: 20),
                      itemBuilder: (context, index) {
                        final item = _cartItems[index];
                        return Row(
                          children: [
                            // Product Image
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child:
                                    item.product.imagePath?.isNotEmpty == true
                                        ? Image.network(
                                          item.product.imagePath!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey.shade400,
                                                    size: 24,
                                                  ),
                                        )
                                        : Icon(
                                          Icons.shopping_bag,
                                          color: Colors.grey.shade400,
                                          size: 24,
                                        ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Product Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          border: Border.all(
                                            color: Colors.blue.shade200,
                                          ),
                                        ),
                                        child: Text(
                                          '${item.quantity}x',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue.shade700,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => _showEditPriceModal(index),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            border: Border.all(
                                              color: Colors.green.shade200,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (_discountPercentage >
                                                      0) ...[
                                                    Text(
                                                      'Rp ${item.product.price.toStringAsFixed(0)}',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade600,
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                  ],
                                                  Text(
                                                    'Rp ${updatedCartItems[index].product.price.toStringAsFixed(0)}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.green.shade700,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Icon(
                                                    Icons.edit,
                                                    size: 14,
                                                    color:
                                                        Colors.green.shade700,
                                                  ),
                                                ],
                                              ),
                                              if (_discountPercentage > 0)
                                                Text(
                                                  '-${_discountPercentage.toStringAsFixed(1)}%',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.red.shade600,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Subtotal
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.orange.shade200,
                                ),
                              ),
                              child: Text(
                                'Rp ${(updatedCartItems[index].product.price * item.quantity).toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Store Information Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade600,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.store,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Informasi Toko',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.business_outlined,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Nama: ${widget.store.name}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Alamat: ${widget.store.address}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Telepon: ${widget.store.phoneNumber}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Customer Information Card
            if (customerName.isNotEmpty || customerPhone.isNotEmpty)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Informasi Customer',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (customerName.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Nama: $customerName',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      if (customerName.isNotEmpty && customerPhone.isNotEmpty)
                        const SizedBox(height: 8),
                      if (customerPhone.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Telepon: $customerPhone',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // // Discount Card
            // Card(
            //   elevation: 2,
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Padding(
            //     padding: const EdgeInsets.all(20),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Row(
            //           children: [
            //             Container(
            //               padding: const EdgeInsets.all(8),
            //               decoration: BoxDecoration(
            //                 color: Colors.red.shade600,
            //                 borderRadius: BorderRadius.circular(8),
            //               ),
            //               child: const Icon(
            //                 Icons.percent,
            //                 color: Colors.white,
            //                 size: 20,
            //               ),
            //             ),
            //             const SizedBox(width: 12),
            //             const Text(
            //               'Diskon Per Item',
            //               style: TextStyle(
            //                 fontSize: 18,
            //                 fontWeight: FontWeight.bold,
            //                 color: Colors.black87,
            //               ),
            //             ),
            //           ],
            //         ),
            //         const SizedBox(height: 16),
            //         Row(
            //           children: [
            //             Expanded(
            //               child: TextField(
            //                 controller: _discountController,
            //                 keyboardType: TextInputType.number,
            //                 onChanged: (_) => _updateDiscount(),
            //                 decoration: InputDecoration(
            //                   labelText: 'Diskon Per Item (%)',
            //                   hintText: '0',
            //                   helperText:
            //                       'Diskon akan diterapkan ke setiap item',
            //                   suffixText: '%',
            //                   border: OutlineInputBorder(
            //                     borderRadius: BorderRadius.circular(8),
            //                   ),
            //                   focusedBorder: OutlineInputBorder(
            //                     borderRadius: BorderRadius.circular(8),
            //                     borderSide: BorderSide(
            //                       color: Colors.red.shade600,
            //                       width: 2,
            //                     ),
            //                   ),
            //                   contentPadding: const EdgeInsets.symmetric(
            //                     horizontal: 12,
            //                     vertical: 16,
            //                   ),
            //                 ),
            //               ),
            //             ),
            //             const SizedBox(width: 16),
            //             Container(
            //               padding: const EdgeInsets.all(16),
            //               decoration: BoxDecoration(
            //                 color: Colors.red.shade50,
            //                 borderRadius: BorderRadius.circular(8),
            //                 border: Border.all(color: Colors.red.shade200),
            //               ),
            //               child: Text(
            //                 'Rp ${discountAmount.toStringAsFixed(0)}',
            //                 style: TextStyle(
            //                   fontSize: 16,
            //                   fontWeight: FontWeight.bold,
            //                   color: Colors.red.shade700,
            //                 ),
            //               ),
            //             ),
            //           ],
            //         ),
            //         const SizedBox(height: 12),
            //         Container(
            //           width: double.infinity,
            //           padding: const EdgeInsets.all(12),
            //           decoration: BoxDecoration(
            //             color: Colors.grey.shade50,
            //             borderRadius: BorderRadius.circular(8),
            //             border: Border.all(color: Colors.grey.shade300),
            //           ),
            //           child: Column(
            //             children: [
            //               Row(
            //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                 children: [
            //                   Text(
            //                     'Subtotal (sebelum diskon):',
            //                     style: TextStyle(
            //                       fontSize: 14,
            //                       color: Colors.grey.shade700,
            //                     ),
            //                   ),
            //                   Text(
            //                     'Rp ${subtotal.toStringAsFixed(0)}',
            //                     style: TextStyle(
            //                       fontSize: 14,
            //                       fontWeight: FontWeight.w600,
            //                       color: Colors.grey.shade700,
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //               if (_discountPercentage > 0) ...[
            //                 const SizedBox(height: 8),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                   children: [
            //                     Text(
            //                       'Total setelah diskon:',
            //                       style: TextStyle(
            //                         fontSize: 14,
            //                         fontWeight: FontWeight.w600,
            //                         color: Colors.green.shade700,
            //                       ),
            //                     ),
            //                     Text(
            //                       'Rp ${subtotalAfterDiscount.toStringAsFixed(0)}',
            //                       style: TextStyle(
            //                         fontSize: 14,
            //                         fontWeight: FontWeight.bold,
            //                         color: Colors.green.shade700,
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //               ],
            //             ],
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            const SizedBox(height: 16),

            // Notes Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade600,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.note,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Catatan Pesanan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: widget.notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Tambahkan catatan pesanan (opsional)...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.indigo.shade600,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.all(16),
                        helperText:
                            'Catatan akan disertakan dalam receipt dan detail pesanan',
                        helperStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      style: const TextStyle(fontSize: 16),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 100), // Space for bottom bar
          ],
        ),
      ),

      // Bottom Bar with Total and Actions
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Total Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade600, Colors.orange.shade500],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Pesanan',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${widget.itemCount} item',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          if (_discountPercentage > 0)
                            Text(
                              'Diskon ${_discountPercentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (_discountPercentage > 0) ...[
                            Text(
                              'Rp ${subtotal.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.8),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            Text(
                              'Rp ${updatedTotalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ] else
                            Text(
                              'Rp ${updatedTotalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        onPressed:
                            _isProcessing
                                ? null
                                : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: Colors.grey.shade400,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cancel_outlined,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Batal',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Confirm Button
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed:
                            _isProcessing ? null : _showConfirmationDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            _isProcessing
                                ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Memproses...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                                : Text(
                                  'Konfirmasi Pesanan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
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
}
