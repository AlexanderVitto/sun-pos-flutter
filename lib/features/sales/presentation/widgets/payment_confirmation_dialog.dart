import 'package:flutter/material.dart';
import '../../../../data/models/cart_item.dart';
import '../../../customers/data/models/customer.dart';
import 'customer_input_dialog.dart';

class PaymentConfirmationDialog extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalAmount;
  final int itemCount;
  final TextEditingController notesController;
  final Function(String customerName, String customerPhone) onConfirm;
  final VoidCallback onCancel;
  final String? initialCustomerName;
  final String? initialCustomerPhone;

  const PaymentConfirmationDialog({
    super.key,
    required this.cartItems,
    required this.totalAmount,
    required this.itemCount,
    required this.notesController,
    required this.onConfirm,
    required this.onCancel,
    this.initialCustomerName,
    this.initialCustomerPhone,
  });

  @override
  _PaymentConfirmationDialogState createState() =>
      _PaymentConfirmationDialogState();
}

class _PaymentConfirmationDialogState extends State<PaymentConfirmationDialog> {
  Customer? _selectedCustomer;

  @override
  void initState() {
    super.initState();
    // Create customer object if initial data exists
    if (widget.initialCustomerName?.isNotEmpty == true ||
        widget.initialCustomerPhone?.isNotEmpty == true) {
      _selectedCustomer = Customer(
        id: 0, // Temporary ID for display purposes
        name: widget.initialCustomerName ?? '',
        phone: widget.initialCustomerPhone ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  String get customerName => _selectedCustomer?.name ?? '';
  String get customerPhone => _selectedCustomer?.phone ?? '';

  void _showCustomerInputDialog() async {
    final result = await showDialog<Customer?>(
      context: context,
      builder:
          (BuildContext context) =>
              CustomerInputDialog(initialCustomer: _selectedCustomer),
    );

    if (result != null) {
      setState(() {
        _selectedCustomer = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.payment, color: Colors.green, size: 24),
          ),
          const SizedBox(width: 12),
          const Text(
            'Konfirmasi Pembayaran',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ringkasan Pesanan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: widget.cartItems.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = widget.cartItems[index];
                          return Row(
                            children: [
                              // Product image or placeholder
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child:
                                      item.product.imagePath?.isNotEmpty == true
                                          ? Image.network(
                                            item.product.imagePath!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Icon(
                                                      Icons.image_not_supported,
                                                      color:
                                                          Colors.grey.shade400,
                                                      size: 20,
                                                    ),
                                          )
                                          : Icon(
                                            Icons.shopping_bag_outlined,
                                            color: Colors.grey.shade400,
                                            size: 20,
                                          ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Product details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          '${item.quantity}x',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Rp ${item.product.price.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Subtotal
                              Text(
                                'Rp ${(item.product.price * item.quantity).toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(height: 1, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total (${widget.itemCount} item)',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Rp ${widget.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Customer Input Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Data Pembeli',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Customer display or button to select
                    if (_selectedCustomer != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Icon(
                                Icons.person,
                                color: Colors.blue.shade600,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedCustomer!.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (_selectedCustomer!.phone.isNotEmpty)
                                    Text(
                                      _selectedCustomer!.phone,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: _showCustomerInputDialog,
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    color: Colors.blue.shade600,
                                    size: 18,
                                  ),
                                  tooltip: 'Ubah Customer',
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedCustomer = null;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.red.shade400,
                                    size: 18,
                                  ),
                                  tooltip: 'Hapus Customer',
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _showCustomerInputDialog,
                          icon: Icon(
                            Icons.person_add_outlined,
                            color: Colors.blue.shade600,
                            size: 20,
                          ),
                          label: Text(
                            'Pilih atau Tambah Pembeli',
                            style: TextStyle(
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            side: BorderSide(color: Colors.blue.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Notes Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notes_outlined,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Catatan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: widget.notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Tambahkan catatan (opsional)',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue.shade400),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Batal',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            widget.onConfirm(customerName, customerPhone);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.payment, size: 18),
              SizedBox(width: 8),
              Text(
                'Konfirmasi Pembayaran',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
