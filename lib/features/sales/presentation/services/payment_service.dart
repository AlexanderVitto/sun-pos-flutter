import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/pending_transaction_provider.dart';
import '../../../../data/models/cart_item.dart';
import '../../../../data/models/customer.dart' as CartCustomer;
import '../../../customers/data/models/customer.dart' as DialogCustomer;
import '../../../transactions/data/models/store.dart';
import '../utils/pos_ui_helpers.dart';
import '../pages/payment_confirmation_page.dart';
import '../pages/order_confirmation_page.dart';
import '../pages/payment_success_page.dart';
import '../pages/order_success_page.dart';

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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => PaymentConfirmationPage(
              cartItems: cartProvider.items,
              totalAmount: cartProvider.total,
              itemCount: cartProvider.itemCount,
              notesController: notesController,
              selectedCustomer: _convertCustomer(
                cartProvider.selectedCustomer,
              ), // Convert and pass selected customer
              initialCustomerName: cartProvider.customerName,
              initialCustomerPhone: cartProvider.customerPhone,
              onConfirm: (customerName, customerPhone) {
                // Check if context is still valid before operations
                if (context.mounted) {
                  _confirmPayment(
                    context,
                    cartProvider,
                    customerName,
                    customerPhone,
                    notesController,
                  );
                }
              },
            ),
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
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder:
                  (context) => PaymentSuccessPage(
                    paymentMethod: 'cash',
                    amountPaid: totalAmount,
                    totalAmount: totalAmount,
                    transactionNumber:
                        transactionResponse.data?.transactionNumber,
                    store: transactionResponse.data?.store ?? store,
                    cartItems: cartItems,
                    notes: notesController.text.trim(),
                  ),
            ),
          );
        }

        if (context.mounted) {
          PosUIHelpers.showSuccessSnackbar(
            context,
            'Transaksi berhasil disimpan',
          );
        }
      } else {
        if (context.mounted) {
          _handlePaymentError(
            context,
            transactionProvider.errorMessage ??
                'Gagal membuat transaksi. Silakan coba lagi.',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        _handlePaymentError(context, 'Terjadi kesalahan: ${e.toString()}');
      }
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
    // Get store information - you may need to adjust this based on your Store model location
    final store = Store(
      id: 1,
      name: "SunPos Store",
      address: "Jl. Contoh No. 123",
      phoneNumber: "021-12345678",
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => OrderConfirmationPage(
              cartItems: cartProvider.items,
              totalAmount: cartProvider.total,
              itemCount: cartProvider.itemCount,
              notesController: notesController,
              selectedCustomer: _convertCustomer(
                cartProvider.selectedCustomer,
              ), // Convert and pass selected customer
              initialCustomerName: cartProvider.customerName,
              initialCustomerPhone: cartProvider.customerPhone,
              store: store,
              onConfirm: (customerName, customerPhone) {
                // Check if context is still valid before operations
                if (context.mounted) {
                  _confirmOrder(
                    context,
                    cartProvider,
                    customerName,
                    customerPhone,
                    notesController,
                  );
                }
              },
            ),
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

      // Process order using the correct method (status = pending payment)
      final transactionResponse = await transactionProvider.processPayment(
        cartItems: cartProvider.items,
        totalAmount: cartProvider.total,
        notes: notesController.text.trim(),
        paymentMethod: 'cash',
        customerName: cartProvider.customerName ?? 'Customer',
        customerPhone: cartProvider.customerPhone,
        status: 'pending', // Change status to pending for orders
      );

      if (transactionResponse != null) {
        // Prepare data for OrderSuccessPage
        final store = Store(
          id: 1,
          name: 'Sun POS',
          address: 'Alamat Toko',
          phoneNumber: '123-456-7890',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Get transaction number from response
        final transactionNumber =
            transactionResponse.data?.transactionNumber ??
            'ORD${DateTime.now().millisecondsSinceEpoch}';

        // Store cart items before clearing
        final cartItemsCopy = List<CartItem>.from(cartProvider.items);
        final totalAmount = cartProvider.total;
        final itemCount = cartProvider.itemCount;
        final notes = notesController.text.trim();

        // Clear cart
        cartProvider.clearCart();
        notesController.clear();

        // Navigate to OrderSuccessPage
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder:
                  (context) => OrderSuccessPage(
                    customerName:
                        customerName.isNotEmpty ? customerName : 'Customer',
                    customerPhone: customerPhone,
                    totalAmount: totalAmount,
                    transactionNumber: transactionNumber,
                    store: transactionResponse.data?.store ?? store,
                    cartItems: cartItemsCopy,
                    notes: notes,
                    itemCount: itemCount,
                  ),
            ),
          );
        }
      } else {
        if (context.mounted) {
          _handlePaymentError(
            context,
            transactionProvider.errorMessage ??
                'Gagal membuat pesanan. Silakan coba lagi.',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        _handlePaymentError(context, 'Terjadi kesalahan: ${e.toString()}');
      }
    }
  }
}
