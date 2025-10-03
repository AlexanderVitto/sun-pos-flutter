import 'package:flutter/material.dart';
import '../../../../data/models/cart_item.dart';
import '../../../customers/data/models/customer.dart';
import '../../../../core/constants/payment_constants.dart';

class PaymentConfirmationPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalAmount;
  final int itemCount;
  final TextEditingController notesController;
  final Function(
    String customerName,
    String customerPhone,
    String paymentMethod,
    double? cashAmount,
    double? transferAmount,
    String paymentStatus,
    String? outstandingReminderDate,
    List<CartItem> updatedCartItems,
    double updatedTotalAmount,
  )
  onConfirm;
  final Customer? selectedCustomer;
  final String? initialCustomerName;
  final String? initialCustomerPhone;

  const PaymentConfirmationPage({
    super.key,
    required this.cartItems,
    required this.totalAmount,
    required this.itemCount,
    required this.notesController,
    required this.onConfirm,
    this.selectedCustomer,
    this.initialCustomerName,
    this.initialCustomerPhone,
  });

  @override
  _PaymentConfirmationPageState createState() =>
      _PaymentConfirmationPageState();
}

class _PaymentConfirmationPageState extends State<PaymentConfirmationPage> {
  Customer? _selectedCustomer;
  bool _isProcessing = false;
  String _selectedPaymentMethod = 'cash'; // Default to cash
  String _bankTransferType = 'full'; // 'full' or 'partial'
  String _paymentStatus = 'lunas'; // 'lunas' or 'utang'
  DateTime? _outstandingDueDate; // Tanggal jatuh tempo untuk utang

  // Controllers for cash and transfer amounts
  final TextEditingController _cashAmountController = TextEditingController();
  final TextEditingController _transferAmountController =
      TextEditingController();

  // Controller for amount paid in cash payment method
  final TextEditingController _amountPaidController = TextEditingController();

  // Map to store edited prices per item (itemId -> editedPrice)
  Map<String, double> _editedPrices = {};

  @override
  void initState() {
    super.initState();
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

    // Add listeners for real-time calculation updates
    _cashAmountController.addListener(() {
      setState(() {});
    });
    _transferAmountController.addListener(() {
      setState(() {});
    });
    _amountPaidController.addListener(() {
      setState(() {});
    });
  }

  String get customerName => _selectedCustomer?.name ?? '';
  String get customerPhone => _selectedCustomer?.phone ?? '';

  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'cash':
        return Icons.money;
      case 'card':
        return Icons.credit_card;
      case 'bank_transfer':
        return Icons.account_balance;
      case 'digital_wallet':
        return Icons.wallet;
      case 'credit':
        return Icons.schedule;
      default:
        return Icons.payment;
    }
  }

  @override
  void dispose() {
    _cashAmountController.dispose();
    _transferAmountController.dispose();
    _amountPaidController.dispose();
    super.dispose();
  }

  bool get _isPaymentValid {
    // Check if due date is required for debt payment
    if (_paymentStatus == 'utang' && _outstandingDueDate == null) {
      return false;
    }

    // For cash payment, check if amount paid is filled and sufficient
    if (_selectedPaymentMethod == 'cash') {
      final amountPaid =
          double.tryParse(
            _amountPaidController.text.replaceAll(RegExp(r'[^0-9.]'), ''),
          ) ??
          0.0;
      return amountPaid > 0 && amountPaid >= _calculateTotalWithEditedPrices();
    }

    if (_selectedPaymentMethod != 'bank_transfer') return true;
    if (_bankTransferType == 'full') return true;

    // For partial payment, check if total payment is sufficient
    final cashAmount =
        double.tryParse(
          _cashAmountController.text.replaceAll(RegExp(r'[^0-9.]'), ''),
        ) ??
        0.0;
    final transferAmount =
        double.tryParse(
          _transferAmountController.text.replaceAll(RegExp(r'[^0-9.]'), ''),
        ) ??
        0.0;
    final totalPaid = cashAmount + transferAmount;

    return totalPaid >= _calculateTotalWithEditedPrices();
  }

  String _getPaymentDisplayText() {
    final baseMethod =
        PaymentConstants.paymentMethods[_selectedPaymentMethod] ?? '';
    if (_selectedPaymentMethod == 'bank_transfer') {
      final typeText = _bankTransferType == 'full' ? 'Penuh' : 'Sebagian';
      return '$baseMethod ($typeText)';
    }
    return baseMethod;
  }

  void _handleConfirmPayment() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Parse cash and transfer amounts based on payment method and type
      double? cashAmount;
      double? transferAmount;

      if (_selectedPaymentMethod == 'cash') {
        // For cash payment, use the amount paid from input field
        cashAmount = double.tryParse(
          _amountPaidController.text.replaceAll(RegExp(r'[^0-9.]'), ''),
        );
        transferAmount = 0.0;
      } else if (_selectedPaymentMethod == 'bank_transfer') {
        if (_bankTransferType == 'partial') {
          // For partial payment, get values from input fields
          cashAmount = double.tryParse(
            _cashAmountController.text.replaceAll(RegExp(r'[^0-9.]'), ''),
          );
          transferAmount = double.tryParse(
            _transferAmountController.text.replaceAll(RegExp(r'[^0-9.]'), ''),
          );
        } else {
          // For full payment, transfer amount = total amount, cash = 0
          cashAmount = 0.0;
          transferAmount = widget.totalAmount;
        }
      }

      // Format tanggal jatuh tempo untuk API
      String? outstandingReminderDateStr;
      if (_paymentStatus == 'utang' && _outstandingDueDate != null) {
        outstandingReminderDateStr =
            '${_outstandingDueDate!.year}-${_outstandingDueDate!.month.toString().padLeft(2, '0')}-${_outstandingDueDate!.day.toString().padLeft(2, '0')}';
      }

      // Create updated cart items with edited prices
      final updatedCartItems =
          widget.cartItems.map((item) {
            final editedPrice = _editedPrices[item.id];
            if (editedPrice != null && editedPrice != item.product.price) {
              // Create new product with updated price
              final updatedProduct = item.product.copyWith(price: editedPrice);
              return item.copyWith(product: updatedProduct);
            }
            return item;
          }).toList();

      // Calculate updated total amount
      final updatedTotalAmount = updatedCartItems.fold<double>(
        0.0,
        (sum, item) => sum + (item.product.price * item.quantity),
      );

      widget.onConfirm(
        customerName,
        customerPhone,
        _selectedPaymentMethod,
        cashAmount,
        transferAmount,
        _paymentStatus,
        outstandingReminderDateStr,
        updatedCartItems,
        updatedTotalAmount,
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
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Konfirmasi Pembayaran',
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
                          'Ringkasan Pesanan',
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
                      itemCount: widget.cartItems.length,
                      separatorBuilder:
                          (context, index) => const Divider(height: 20),
                      itemBuilder: (context, index) {
                        final item = widget.cartItems[index];
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
                                    // maxLines: 2,
                                    // overflow: TextOverflow.ellipsis,
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
                                      if (_editedPrices.containsKey(
                                        item.id,
                                      )) ...[
                                        Text(
                                          'Rp ${item.product.price.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade500,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Rp ${_getEffectivePrice(item).toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.blue.shade600,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ] else
                                        Text(
                                          'Rp ${item.product.price.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Subtotal
                            // Subtotal with Edit Button
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.green.shade200,
                                    ),
                                  ),
                                  child: Text(
                                    'Rp ${(_getEffectivePrice(item) * item.quantity).toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),

                                // const SizedBox(height: 4),
                                // InkWell(
                                //   onTap:
                                //       () => _showEditPriceDialog(
                                //         context,
                                //         item,
                                //         index,
                                //       ),
                                //   borderRadius: BorderRadius.circular(6),
                                //   child: Container(
                                //     padding: const EdgeInsets.symmetric(
                                //       horizontal: 8,
                                //       vertical: 4,
                                //     ),
                                //     decoration: BoxDecoration(
                                //       color: Colors.blue.shade50,
                                //       borderRadius: BorderRadius.circular(6),
                                //       border: Border.all(
                                //         color: Colors.blue.shade200,
                                //         width: 1,
                                //       ),
                                //     ),
                                //     child: Row(
                                //       mainAxisSize: MainAxisSize.min,
                                //       children: [
                                //         Icon(
                                //           Icons.edit,
                                //           size: 12,
                                //           color: Colors.blue.shade600,
                                //         ),
                                //         const SizedBox(width: 4),
                                //         Text(
                                //           'Edit Harga',
                                //           style: TextStyle(
                                //             fontSize: 10,
                                //             color: Colors.blue.shade600,
                                //             fontWeight: FontWeight.w500,
                                //           ),
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                                // ),
                              ],
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
                              color: Colors.orange.shade600,
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

            // Notes Input Card
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
                            Icons.note,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Catatan Transaksi',
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
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Tambahkan catatan transaksi (opsional)...',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.purple.shade400),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Payment Status Selection Card
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
                            color: Colors.blue.shade600,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.receipt_long,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Status Pembayaran',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Lunas Option
                    InkWell(
                      onTap: () {
                        setState(() {
                          _paymentStatus = 'lunas';
                          _outstandingDueDate =
                              null; // Clear due date when selecting lunas
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              _paymentStatus == 'lunas'
                                  ? Colors.green.shade50
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                _paymentStatus == 'lunas'
                                    ? Colors.green.shade400
                                    : Colors.grey.shade300,
                            width: _paymentStatus == 'lunas' ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color:
                                  _paymentStatus == 'lunas'
                                      ? Colors.green.shade600
                                      : Colors.grey.shade600,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lunas',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          _paymentStatus == 'lunas'
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                      color:
                                          _paymentStatus == 'lunas'
                                              ? Colors.green.shade700
                                              : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Pembayaran diselesaikan sekarang',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_paymentStatus == 'lunas')
                              Icon(
                                Icons.radio_button_checked,
                                color: Colors.green.shade600,
                                size: 22,
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Utang Option
                    InkWell(
                      onTap: () {
                        setState(() {
                          _paymentStatus = 'utang';
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              _paymentStatus == 'utang'
                                  ? Colors.orange.shade50
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                _paymentStatus == 'utang'
                                    ? Colors.orange.shade400
                                    : Colors.grey.shade300,
                            width: _paymentStatus == 'utang' ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              color:
                                  _paymentStatus == 'utang'
                                      ? Colors.orange.shade600
                                      : Colors.grey.shade600,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Utang',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          _paymentStatus == 'utang'
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                      color:
                                          _paymentStatus == 'utang'
                                              ? Colors.orange.shade700
                                              : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Pembayaran akan diselesaikan kemudian',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_paymentStatus == 'utang')
                              Icon(
                                Icons.radio_button_checked,
                                color: Colors.orange.shade600,
                                size: 22,
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Due Date Picker (show only when utang is selected)
                    if (_paymentStatus == 'utang') ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.orange.shade600,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Tanggal Jatuh Tempo',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () async {
                                final DateTime? pickedDate =
                                    await showDatePicker(
                                      context: context,
                                      initialDate:
                                          _outstandingDueDate ??
                                          DateTime.now().add(
                                            const Duration(days: 7),
                                          ),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(
                                        const Duration(days: 365),
                                      ),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: Colors.orange.shade600,
                                              onPrimary: Colors.white,
                                              surface: Colors.white,
                                              onSurface: Colors.black87,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                if (pickedDate != null) {
                                  setState(() {
                                    _outstandingDueDate = pickedDate;
                                  });
                                }
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.orange.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.date_range,
                                      color: Colors.orange.shade600,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _outstandingDueDate != null
                                            ? '${_outstandingDueDate!.day.toString().padLeft(2, '0')}/${_outstandingDueDate!.month.toString().padLeft(2, '0')}/${_outstandingDueDate!.year}'
                                            : 'Pilih tanggal jatuh tempo',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color:
                                              _outstandingDueDate != null
                                                  ? Colors.black87
                                                  : Colors.grey.shade600,
                                          fontWeight:
                                              _outstandingDueDate != null
                                                  ? FontWeight.w500
                                                  : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.orange.shade600,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_outstandingDueDate == null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Tanggal jatuh tempo wajib diisi untuk pembayaran utang',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Payment Method Selection Card
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
                            color: Colors.teal.shade600,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.payment,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Metode Pembayaran',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Payment Method Options
                    Column(
                      children:
                          PaymentConstants.paymentMethods.entries.map((entry) {
                            final String methodKey = entry.key;
                            final String methodLabel = entry.value;
                            final bool isSelected =
                                _selectedPaymentMethod == methodKey;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedPaymentMethod = methodKey;
                                    // Clear all input fields when changing payment method
                                    _amountPaidController.clear();
                                    _cashAmountController.clear();
                                    _transferAmountController.clear();
                                  });
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? Colors.teal.shade50
                                            : Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? Colors.teal.shade400
                                              : Colors.grey.shade300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getPaymentMethodIcon(methodKey),
                                        color:
                                            isSelected
                                                ? Colors.teal.shade600
                                                : Colors.grey.shade600,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          methodLabel,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight:
                                                isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.w500,
                                            color:
                                                isSelected
                                                    ? Colors.teal.shade700
                                                    : Colors.black87,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.teal.shade600,
                                          size: 22,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Bank Transfer Type Selection (only show when bank_transfer is selected)
            if (_selectedPaymentMethod == 'bank_transfer')
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
                              Icons.account_balance_wallet,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Jenis Pembayaran Transfer',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Full Payment Option
                      InkWell(
                        onTap: () {
                          setState(() {
                            _bankTransferType = 'full';
                            // Clear input fields when switching to full payment
                            _cashAmountController.clear();
                            _transferAmountController.clear();
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                _bankTransferType == 'full'
                                    ? Colors.indigo.shade50
                                    : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  _bankTransferType == 'full'
                                      ? Colors.indigo.shade400
                                      : Colors.grey.shade300,
                              width: _bankTransferType == 'full' ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.payment,
                                color:
                                    _bankTransferType == 'full'
                                        ? Colors.indigo.shade600
                                        : Colors.grey.shade600,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bayar Penuh',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            _bankTransferType == 'full'
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                        color:
                                            _bankTransferType == 'full'
                                                ? Colors.indigo.shade700
                                                : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Bayar seluruh jumlah via transfer bank',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_bankTransferType == 'full')
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.indigo.shade600,
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Partial Payment Option
                      InkWell(
                        onTap: () {
                          setState(() {
                            _bankTransferType = 'partial';
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                _bankTransferType == 'partial'
                                    ? Colors.indigo.shade50
                                    : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  _bankTransferType == 'partial'
                                      ? Colors.indigo.shade400
                                      : Colors.grey.shade300,
                              width: _bankTransferType == 'partial' ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.pie_chart,
                                color:
                                    _bankTransferType == 'partial'
                                        ? Colors.indigo.shade600
                                        : Colors.grey.shade600,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bayar Sebagian',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            _bankTransferType == 'partial'
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                        color:
                                            _bankTransferType == 'partial'
                                                ? Colors.indigo.shade700
                                                : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Kombinasi pembayaran tunai + transfer',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_bankTransferType == 'partial')
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.indigo.shade600,
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Cash Amount Input Card (only show for cash payment)
            if (_selectedPaymentMethod == 'cash')
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
                              Icons.money,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Jumlah Pembayaran Tunai',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Amount Paid Input
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.attach_money,
                                color: Colors.grey.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Jumlah Dibayar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const Text(
                                ' *',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _amountPaidController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Masukkan jumlah pembayaran',
                              prefixText: 'Rp ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.green.shade400,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Total calculation display
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total yang harus dibayar:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Rp ${_calculateTotalWithEditedPrices().toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Jumlah dibayar:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Builder(
                                  builder: (context) {
                                    final amountPaid =
                                        double.tryParse(
                                          _amountPaidController.text.replaceAll(
                                            RegExp(r'[^0-9.]'),
                                            '',
                                          ),
                                        ) ??
                                        0.0;

                                    final totalRequired =
                                        _calculateTotalWithEditedPrices();
                                    final isValid = amountPaid >= totalRequired;

                                    return Text(
                                      'Rp ${amountPaid.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isValid
                                                ? Colors.green.shade700
                                                : Colors.red.shade600,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Builder(
                              builder: (context) {
                                final amountPaid =
                                    double.tryParse(
                                      _amountPaidController.text.replaceAll(
                                        RegExp(r'[^0-9.]'),
                                        '',
                                      ),
                                    ) ??
                                    0.0;

                                final totalRequired =
                                    _calculateTotalWithEditedPrices();
                                final change = amountPaid - totalRequired;

                                if (amountPaid > totalRequired) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Kembalian:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        'Rp ${change.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade600,
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Payment Amount Details Card (only show for bank_transfer and partial payment)
            if (_selectedPaymentMethod == 'bank_transfer' &&
                _bankTransferType == 'partial')
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
                              color: Colors.blue.shade600,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.calculate,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Detail Pembayaran',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Cash Amount Input
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.money,
                                color: Colors.grey.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Jumlah Tunai',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _cashAmountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Masukkan jumlah tunai (opsional)',
                              prefixText: 'Rp ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.blue.shade400,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Transfer Amount Input
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.account_balance,
                                color: Colors.grey.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Jumlah Transfer',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _transferAmountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Masukkan jumlah transfer (opsional)',
                              prefixText: 'Rp ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.blue.shade400,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Total calculation display
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total yang harus dibayar:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Rp ${_calculateTotalWithEditedPrices().toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total pembayaran:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Builder(
                                  builder: (context) {
                                    final cashAmount =
                                        double.tryParse(
                                          _cashAmountController.text.replaceAll(
                                            RegExp(r'[^0-9.]'),
                                            '',
                                          ),
                                        ) ??
                                        0.0;
                                    final transferAmount =
                                        double.tryParse(
                                          _transferAmountController.text
                                              .replaceAll(
                                                RegExp(r'[^0-9.]'),
                                                '',
                                              ),
                                        ) ??
                                        0.0;
                                    final totalPaid =
                                        cashAmount + transferAmount;
                                    return Text(
                                      'Rp ${totalPaid.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            totalPaid >=
                                                    _calculateTotalWithEditedPrices()
                                                ? Colors.green.shade700
                                                : Colors.red.shade700,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
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
                      colors: [Colors.green.shade600, Colors.green.shade500],
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
                            'Total Pembayaran',
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
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                _getPaymentMethodIcon(_selectedPaymentMethod),
                                color: Colors.white.withValues(alpha: 0.9),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getPaymentDisplayText(),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        'Rp ${_calculateTotalWithEditedPrices().toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
                            (_isProcessing || !_isPaymentValid)
                                ? null
                                : _handleConfirmPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isPaymentValid
                                  ? Colors.green.shade600
                                  : Colors.grey.shade400,
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
                                : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle, size: 22),
                                    SizedBox(width: 8),
                                    Text(
                                      'Konfirmasi Pembayaran',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }

  // Calculate total amount with edited prices
  double _calculateTotalWithEditedPrices() {
    double total = 0.0;
    for (final item in widget.cartItems) {
      final editedPrice = _editedPrices[item.id] ?? item.product.price;
      total += editedPrice * item.quantity;
    }
    return total;
  }

  // Get effective price for an item (edited price or original price)
  double _getEffectivePrice(CartItem item) {
    return _editedPrices[item.id] ?? item.product.price;
  }

  // Show dialog to edit item price
  void _showEditPriceDialog(BuildContext context, CartItem item, int index) {
    final TextEditingController priceController = TextEditingController();
    final currentPrice = _getEffectivePrice(item);
    priceController.text = currentPrice.toStringAsFixed(0);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.edit, color: Colors.blue.shade600, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Edit Harga Item',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.shopping_bag,
                        color: Colors.grey,
                        size: 20,
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
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Jumlah: ${item.quantity}x',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Price input
              const Text(
                'Harga per Item',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  hintText: 'Masukkan harga baru',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue.shade400),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
                onChanged: (value) {
                  // Auto-format number as user types
                  if (value.isNotEmpty) {
                    final numValue = double.tryParse(
                      value.replaceAll(RegExp(r'[^0-9.]'), ''),
                    );
                    if (numValue != null) {
                      final formatted = numValue.toStringAsFixed(0);
                      if (formatted != value) {
                        priceController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(
                            offset: formatted.length,
                          ),
                        );
                      }
                    }
                  }
                },
              ),
              const SizedBox(height: 12),

              // Current vs new subtotal
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal saat ini:'),
                        Text(
                          'Rp ${(currentPrice * item.quantity).toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal baru:'),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: priceController,
                          builder: (context, value, child) {
                            final newPrice =
                                double.tryParse(
                                  value.text.replaceAll(RegExp(r'[^0-9.]'), ''),
                                ) ??
                                currentPrice;
                            return Text(
                              'Rp ${(newPrice * item.quantity).toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final newPrice = double.tryParse(
                  priceController.text.replaceAll(RegExp(r'[^0-9.]'), ''),
                );

                if (newPrice != null && newPrice >= 0) {
                  setState(() {
                    _editedPrices[item.id.toString()] = newPrice;
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Harga tidak valid'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}
