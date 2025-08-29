import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sun_pos/features/dashboard/presentation/pages/dashboard_page.dart';
import '../../providers/cart_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/pending_transaction_provider.dart';
import '../../../../data/models/cart_item.dart';
import '../../../../data/models/customer.dart' as CartCustomer;
import '../../../customers/data/models/customer.dart' as DialogCustomer;
import '../../../transactions/data/models/store.dart';
import '../utils/pos_ui_helpers.dart';
import '../widgets/payment_confirmation_dialog.dart';
import '../widgets/order_confirmation_dialog.dart';
import '../pages/payment_success_page.dart';

class PaymentService {
  // Convert CartCustomer to DialogCustomer
  static DialogCustomer.Customer? _convertCustomer(
    CartCustomer.Customer? cartCustomer,
  ) {
    if (cartCustomer == null) return null;

    return DialogCustomer.Customer(
      id: int.tryParse(cartCustomer.id) ?? 0,
      name: cartCustomer.name,
      phone: cartCustomer.phone,
      createdAt: cartCustomer.createdAt,
      updatedAt: cartCustomer.updatedAt,
    );
  }

  static Future<void> processPayment({
    required BuildContext context,
    required CartProvider cartProvider,
    required TextEditingController notesController,
  }) async {
    if (cartProvider.items.isEmpty) {
      PosUIHelpers.showErrorSnackbar(context, 'Keranjang masih kosong');
      return;
    }

    _showPaymentConfirmationDialog(context, cartProvider, notesController);
  }

  static Future<void> processOrder({
    required BuildContext context,
    required CartProvider cartProvider,
    required TextEditingController notesController,
  }) async {
    if (cartProvider.items.isEmpty) {
      PosUIHelpers.showErrorSnackbar(context, 'Keranjang masih kosong');
      return;
    }

    _showOrderConfirmationDialog(context, cartProvider, notesController);
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
            selectedCustomer: _convertCustomer(
              cartProvider.selectedCustomer,
            ), // Convert and pass selected customer
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
        status: 'completed', // Change status to completed for paid transactions
      );

      if (transactionResponse != null) {
        // Store cart items before clearing for receipt
        final cartItems = List<CartItem>.from(cartProvider.items);
        final totalAmount = cartProvider.total;

        // Delete pending transaction if it exists
        final pendingProvider = Provider.of<PendingTransactionProvider>(
          context,
          listen: false,
        );

        // Check if this is from a pending transaction by customer name
        final customerName = cartProvider.customerName;
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

  static void _showOrderConfirmationDialog(
    BuildContext context,
    CartProvider cartProvider,
    TextEditingController notesController,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => OrderConfirmationDialog(
            cartItems: cartProvider.items,
            totalAmount: cartProvider.total,
            itemCount: cartProvider.itemCount,
            notesController: notesController,
            selectedCustomer: _convertCustomer(
              cartProvider.selectedCustomer,
            ), // Convert and pass selected customer
            initialCustomerName: cartProvider.customerName,
            initialCustomerPhone: cartProvider.customerPhone,
            onConfirm:
                (customerName, customerPhone) => _confirmOrder(
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

  static void _confirmOrder(
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

      // Process order with status=pending
      final transactionResponse = await transactionProvider.processPayment(
        cartItems: cartProvider.items,
        totalAmount: cartProvider.total,
        notes: notesController.text.trim(),
        paymentMethod: 'cash',
        customerName: cartProvider.customerName ?? 'Customer',
        customerPhone: cartProvider.customerPhone,
        status: 'pending', // Set status to pending for orders
      );

      if (transactionResponse != null) {
        // Delete pending transaction if it exists
        final pendingProvider = Provider.of<PendingTransactionProvider>(
          context,
          listen: false,
        );

        // Check if this is from a pending transaction by customer name
        final customerName = cartProvider.customerName;
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

        // Clear cart
        cartProvider.clearCart();
        notesController.clear();

        // Navigate back to dashboard
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const DashboardPage(initialIndex: 2),
          ),
          (route) => false, // Remove all previous routes
        );

        PosUIHelpers.showSuccessSnackbar(
          context,
          'Pesanan berhasil dibuat! No: ${transactionResponse.data?.transactionNumber}',
        );
      } else {
        _handlePaymentError(
          context,
          transactionProvider.errorMessage ??
              'Gagal membuat pesanan. Silakan coba lagi.',
        );
      }
    } catch (e) {
      _handlePaymentError(context, 'Terjadi kesalahan: ${e.toString()}');
    }
  }
}
