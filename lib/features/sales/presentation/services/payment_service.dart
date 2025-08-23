import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../../../data/models/cart_item.dart';
import '../../../transactions/data/models/store.dart';
import '../utils/pos_ui_helpers.dart';
import '../widgets/payment_confirmation_dialog.dart';
import '../pages/payment_success_page.dart';

class PaymentService {
  static void processPayment(
    BuildContext context,
    CartProvider cartProvider,
    TextEditingController notesController,
  ) {
    if (cartProvider.items.isEmpty) {
      PosUIHelpers.showErrorSnackbar(context, 'Keranjang masih kosong');
      return;
    }

    _showPaymentConfirmationDialog(context, cartProvider, notesController);
  }

  static void _showPaymentConfirmationDialog(
    BuildContext context,
    CartProvider cartProvider,
    TextEditingController notesController,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => PaymentConfirmationDialog(
            cartItems: cartProvider.items,
            totalAmount: cartProvider.total,
            itemCount: cartProvider.itemCount,
            notesController: notesController,
            initialCustomerName: cartProvider.customerName,
            initialCustomerPhone: cartProvider.customerPhone,
            onConfirm:
                (customerName, customerPhone) => _confirmPayment(
                  context,
                  cartProvider,
                  customerName,
                  customerPhone,
                  notesController,
                ),
            onCancel: () => Navigator.of(context).pop(),
          ),
    );
  }

  static void _confirmPayment(
    BuildContext context,
    CartProvider cartProvider,
    String customerName,
    String customerPhone,
    TextEditingController notesController,
  ) async {
    try {
      // Set customer information in cart provider
      if (customerName.isNotEmpty) {
        cartProvider.setCustomerName(customerName);
      }
      if (customerPhone.isNotEmpty) {
        cartProvider.setCustomerPhone(customerPhone);
      }

      // Get transaction provider
      final transactionProvider = Provider.of<TransactionProvider>(
        context,
        listen: false,
      );

      // Process payment using the correct method
      final transactionResponse = await transactionProvider.processPayment(
        cartItems: cartProvider.items,
        totalAmount: cartProvider.total,
        notes: notesController.text.trim(),
        paymentMethod: 'cash',
        customerName: cartProvider.customerName ?? 'Customer',
        customerPhone: cartProvider.customerPhone,
        status: 'pending',
      );

      if (transactionResponse != null) {
        // Store cart items before clearing for receipt
        final cartItems = List<CartItem>.from(cartProvider.items);
        final totalAmount = cartProvider.total;

        // Clear cart
        cartProvider.clearCart();
        notesController.clear();

        // Create mock store data
        final store = Store(
          id: 1,
          name: 'Sun POS Store',
          address: 'Jl. Contoh No. 123, Jakarta',
          phoneNumber: '021-12345678',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Navigate to success page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) => PaymentSuccessPage(
                  paymentMethod: 'cash',
                  amountPaid: totalAmount,
                  totalAmount: totalAmount,
                  transactionNumber:
                      transactionResponse.data?.transactionNumber,
                  store: store,
                  cartItems: cartItems,
                  notes: notesController.text.trim(),
                ),
          ),
        );

        PosUIHelpers.showSuccessSnackbar(
          context,
          'Transaksi berhasil disimpan',
        );
      } else {
        _handlePaymentError(
          context,
          transactionProvider.errorMessage ??
              'Gagal membuat transaksi. Silakan coba lagi.',
        );
      }
    } catch (e) {
      _handlePaymentError(context, 'Terjadi kesalahan: ${e.toString()}');
    }
  }

  static void _handlePaymentError(BuildContext context, String message) {
    PosUIHelpers.showErrorSnackbar(context, message);
  }
}
