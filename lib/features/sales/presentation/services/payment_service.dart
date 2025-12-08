import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/pending_transaction_provider.dart';
import '../../../../data/models/cart_item.dart';
import '../../../../data/models/customer.dart' as CartCustomer;
import '../../../customers/data/models/customer.dart' as DialogCustomer;
import '../../../transactions/data/models/store.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../dashboard/providers/store_provider.dart';
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
      address: cartCustomer.address,
      updatedAt: cartCustomer.updatedAt,
    );
  }

  // Get storeId from selected store in StoreProvider, fallback to user profile
  static int _getStoreIdFromUser(BuildContext context) {
    try {
      // First try to get selected store from StoreProvider
      final storeProvider = Provider.of<StoreProvider>(context, listen: false);
      final selectedStoreId = storeProvider.getSelectedStoreId();

      // StoreProvider has a default fallback value, so use it directly
      return selectedStoreId;
    } catch (e) {
      debugPrint('Error getting storeId from StoreProvider: $e');

      // Fallback to first store from user profile
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final user = authProvider.user;

        if (user != null && user.stores.isNotEmpty) {
          return user.stores.first.id;
        }
      } catch (e2) {
        debugPrint('Error getting storeId from user profile: $e2');
      }
    }

    // Default fallback storeId
    return 1;
  }

  // Get store information from StoreProvider, fallback to user profile
  static Store _getStoreFromUser(BuildContext context) {
    try {
      // First try to get selected store from StoreProvider
      final storeProvider = Provider.of<StoreProvider>(context, listen: false);
      final selectedStore = storeProvider.selectedStore;

      if (selectedStore != null) {
        return Store(
          id: selectedStore.id,
          name: selectedStore.name,
          address: selectedStore.address,
          phoneNumber: selectedStore.phoneNumber,
          isActive: selectedStore.isActive,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('Error getting store from StoreProvider: $e');
    }

    // Fallback to first store from user profile
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user != null && user.stores.isNotEmpty) {
        final userStore = user.stores.first;
        return Store(
          id: userStore.id,
          name: userStore.name,
          address: userStore.address,
          phoneNumber: userStore.phoneNumber,
          isActive: userStore.isActive,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('Error getting store from user profile: $e');
    }

    // Default fallback store
    return Store(
      id: 1,
      name: 'Sun POS Store',
      address: 'Jl. Contoh No. 123, Jakarta',
      phoneNumber: '021-12345678',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static Future<void> processPayment({
    required BuildContext context,
    required CartProvider cartProvider,
    required TextEditingController notesController,
    double? cashAmount,
    double transferAmount = 0,
  }) async {
    if (cartProvider.items.isEmpty) {
      PosUIHelpers.showErrorSnackbar(context, 'Keranjang masih kosong');
      return;
    }

    _showPaymentConfirmationDialog(
      context,
      cartProvider,
      notesController,
      cashAmount,
      transferAmount,
    );
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

  // Process draft transaction when adding items to cart
  static Future<void> processDraftTransaction({
    required BuildContext context,
    required CartProvider cartProvider,
  }) async {
    if (cartProvider.items.isEmpty) {
      return; // No items to process
    }

    try {
      // Get transaction provider
      final transactionProvider = Provider.of<TransactionProvider>(
        context,
        listen: false,
      );

      // Check if this is an existing draft transaction that needs update
      if (cartProvider.hasExistingDraftTransaction) {
        debugPrint(
          '🔄 Updating existing draft transaction ID: ${cartProvider.draftTransactionId}',
        );

        // Use the new updateTransaction method
        await transactionProvider.updateTransaction(
          transactionId: cartProvider.draftTransactionId!,
          cartItems: cartProvider.items,
          totalAmount: cartProvider.total,
          notes: '',
          paymentMethod: 'cash',
          storeId: _getStoreIdFromUser(context),
          customerName: cartProvider.selectedCustomer?.name ?? 'Customer',
          customerPhone: cartProvider.selectedCustomer?.phone,
          status: 'draft', // Draft status for cart items
          cashAmount: 0, // No cash amount for draft
          transferAmount: 0, // Default transfer amount for draft
          outstandingReminderDate: null, // No reminder date for draft
        );

        debugPrint('✅ Draft transaction updated successfully');
      } else {
        debugPrint('✨ Creating new draft transaction');

        // Process new draft transaction
        final response = await transactionProvider.processPayment(
          cartItems: cartProvider.items,
          totalAmount: cartProvider.total,
          notes: '',
          paymentMethod: 'cash',
          storeId: _getStoreIdFromUser(context),
          customerName: cartProvider.selectedCustomer?.name ?? 'Customer',
          customerPhone: cartProvider.selectedCustomer?.phone,
          status: 'draft', // Draft status for cart items
          cashAmount: 0, // No cash amount for draft
          transferAmount: 0, // Default transfer amount for draft
          outstandingReminderDate: null, // No reminder date for draft
        );

        // Store draft transaction ID for future updates
        if (response != null && response.data != null) {
          // Use a separate method call to update the cart provider
          _updateCartProviderWithTransactionId(context, response.data!.id);
          debugPrint(
            '✅ New draft transaction created with ID: ${response.data!.id}',
          );
        }
      }
    } catch (e) {
      // Silent failure for draft transactions to not interrupt user experience
      debugPrint('Failed to process draft transaction: ${e.toString()}');
    }
  }

  // Helper method to update cart provider with transaction ID
  static void _updateCartProviderWithTransactionId(
    BuildContext context,
    int transactionId,
  ) {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.setDraftTransactionId(transactionId);
    } catch (e) {
      debugPrint('Failed to update cart provider with transaction ID: $e');
    }
  }

  static void _showPaymentConfirmationDialog(
    BuildContext context,
    CartProvider cartProvider,
    TextEditingController notesController,
    double? cashAmount,
    double transferAmount,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentConfirmationPage(
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
              (
                customerName,
                customerPhone,
                paymentMethod,
                cashAmount,
                transferAmount,
                paymentStatus,
                outstandingReminderDate,
                updatedCartItems,
                updatedTotalAmount,
              ) {
                // Check if context is still valid before operations
                if (context.mounted) {
                  _confirmPayment(
                    context,
                    cartProvider,
                    customerName,
                    customerPhone,
                    paymentMethod,
                    notesController,
                    cashAmount,
                    transferAmount,
                    paymentStatus,
                    outstandingReminderDate,
                    updatedCartItems,
                    updatedTotalAmount,
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
    String paymentMethod,
    TextEditingController notesController,
    double? cashAmount,
    double? transferAmount,
    String paymentStatus,
    String? outstandingReminderDate,
    List<CartItem> updatedCartItems,
    double updatedTotalAmount,
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

      dynamic transactionResponse;

      // Check if this is an existing draft transaction that needs update
      if (cartProvider.hasExistingDraftTransaction) {
        debugPrint(
          '🔄 Updating existing draft transaction to completed status. ID: ${cartProvider.draftTransactionId}',
        );

        // Use updateTransaction method for existing draft transactions
        transactionResponse = await transactionProvider.updateTransaction(
          transactionId: cartProvider.draftTransactionId!,
          cartItems: updatedCartItems,
          totalAmount: updatedTotalAmount,
          notes: notesController.text.trim(),
          paymentMethod: paymentMethod,
          storeId: _getStoreIdFromUser(context),
          customerName: cartProvider.customerName ?? 'Customer',
          customerPhone: cartProvider.customerPhone,
          status: paymentStatus == 'utang' ? 'outstanding' : 'pending',
          cashAmount: cashAmount ?? 0,
          transferAmount: transferAmount ?? 0.0,
          outstandingReminderDate: outstandingReminderDate,
        );

        debugPrint('✅ Draft transaction updated to pending successfully');
      } else {
        debugPrint('✨ Creating new completed transaction');

        // Process payment using the correct method
        transactionResponse = await transactionProvider.processPayment(
          cartItems: updatedCartItems,
          totalAmount: updatedTotalAmount,
          notes: notesController.text.trim(),
          paymentMethod: paymentMethod,
          storeId: _getStoreIdFromUser(context),
          customerName: cartProvider.customerName ?? 'Customer',
          customerPhone: cartProvider.customerPhone,
          status: paymentStatus == 'utang' ? 'outstanding' : 'pending',
          cashAmount: cashAmount,
          transferAmount: transferAmount ?? 0.0,
          outstandingReminderDate: outstandingReminderDate,
        );

        debugPrint('✅ New pending transaction created successfully');
      }

      if (transactionResponse != null) {
        // Store cart items before clearing for receipt
        final cartItems = List<CartItem>.from(updatedCartItems);
        final totalAmount = updatedTotalAmount;

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

        // Get store information from user profile
        final store = _getStoreFromUser(context);

        // Navigate to success page
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PaymentSuccessPage(
                paymentMethod: 'cash',
                amountPaid: totalAmount,
                totalAmount: totalAmount,
                transactionNumber: transactionResponse.data?.transactionNumber,
                store: transactionResponse.data?.store ?? store,
                cartItems: cartItems,
                notes: notesController.text.trim(),
                user: Provider.of<AuthProvider>(context, listen: false).user,
                status: 'completed', // Cash transactions are completed
                dueDate: null, // No due date for completed transactions
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

  // Complete transaction with payment details (similar to TransactionDetailPage.completeTransaction)
  static Future<void> completeTransaction(
    BuildContext context,
    CartProvider cartProvider,
    TextEditingController notesController, {
    required String customerName,
    required String customerPhone,
    required String paymentMethod,
    required double? cashAmount,
    required double? transferAmount,
    required String paymentStatus,
    required String? outstandingReminderDate,
    required List<CartItem> updatedCartItems,
    required double updatedTotalAmount,
  }) async {
    // Cache all provider and navigator references BEFORE any async operations
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );
    final pendingProvider = Provider.of<PendingTransactionProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final storeId = _getStoreIdFromUser(context);
    final store = _getStoreFromUser(context);
    final notesText = notesController.text.trim();

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
              Text('Memproses pembayaran...'),
            ],
          ),
        );
      },
    );

    try {
      // Set customer information in cart provider
      if (customerName.isNotEmpty) {
        cartProvider.setCustomerName(customerName);
      }
      if (customerPhone.isNotEmpty) {
        cartProvider.setCustomerPhone(customerPhone);
      }

      dynamic transactionResponse;

      // Check if this is an existing draft transaction that needs update
      if (cartProvider.hasExistingDraftTransaction) {
        debugPrint(
          '🔄 Updating existing draft transaction to completed status. ID: ${cartProvider.draftTransactionId}',
        );

        // Use updateTransaction method for existing draft transactions
        transactionResponse = await transactionProvider.updateTransaction(
          transactionId: cartProvider.draftTransactionId!,
          cartItems: updatedCartItems,
          totalAmount: updatedTotalAmount,
          notes: notesText,
          paymentMethod: paymentMethod,
          storeId: storeId,
          customerName: customerName.isNotEmpty ? customerName : 'Customer',
          customerPhone: customerPhone.isNotEmpty ? customerPhone : null,
          status: paymentStatus == 'utang' ? 'outstanding' : 'completed',
          cashAmount: cashAmount ?? 0,
          transferAmount: transferAmount ?? 0.0,
          outstandingReminderDate: outstandingReminderDate,
        );

        debugPrint('✅ Draft transaction updated to completed successfully');
      } else {
        debugPrint('✨ Creating new completed transaction');

        // Process payment using the correct method
        transactionResponse = await transactionProvider.processPayment(
          cartItems: updatedCartItems,
          totalAmount: updatedTotalAmount,
          notes: notesText,
          paymentMethod: paymentMethod,
          storeId: storeId,
          customerName: customerName.isNotEmpty ? customerName : 'Customer',
          customerPhone: customerPhone.isNotEmpty ? customerPhone : null,
          status: paymentStatus == 'utang' ? 'outstanding' : 'completed',
          cashAmount: cashAmount,
          transferAmount: transferAmount ?? 0.0,
          outstandingReminderDate: outstandingReminderDate,
        );

        debugPrint('✅ New completed transaction created successfully');
      }

      // Close loading dialog using cached navigator
      if (navigator.canPop()) {
        navigator.pop();
      }

      // Check if update was successful
      if (transactionResponse != null) {
        // Store cart items before clearing for receipt
        final cartItems = List<CartItem>.from(updatedCartItems);
        final totalAmount = updatedTotalAmount;

        // Check if this is from a pending transaction by customer name
        if (customerName.isNotEmpty) {
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

        // Navigate to success page (use cached navigator, don't check context.mounted)
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (context) => PaymentSuccessPage(
              paymentMethod: paymentMethod,
              amountPaid: totalAmount,
              totalAmount: totalAmount,
              transactionNumber: transactionResponse.data?.transactionNumber,
              store: transactionResponse.data?.store ?? store,
              cartItems: cartItems,
              notes: notesText,
              user: authProvider.user,
              status: paymentStatus == 'utang' ? 'outstanding' : 'completed',
              dueDate: outstandingReminderDate != null
                  ? DateTime.tryParse(outstandingReminderDate)
                  : null,
            ),
          ),
        );

        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil diselesaikan'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              transactionProvider.errorMessage ??
                  'Gagal menyelesaikan transaksi. Silakan coba lagi.',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open using cached navigator
      if (navigator.canPop()) {
        navigator.pop();
      }

      // Show error message
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      );
    }
  }

  static void _showOrderConfirmationDialog(
    BuildContext context,
    CartProvider cartProvider,
    TextEditingController notesController,
  ) {
    // Get store information from user profile
    final store = _getStoreFromUser(context);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderConfirmationPage(
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
          // Callback untuk toggle OFF (order/pending)
          onConfirmOrder:
              (
                customerName,
                customerPhone,
                updatedCartItems,
                updatedTotalAmount,
                discountPercentage,
              ) {
                // Check if context is still valid before operations
                if (context.mounted) {
                  _confirmOrder(
                    context,
                    cartProvider,
                    customerName,
                    customerPhone,
                    notesController,
                    updatedCartItems,
                    updatedTotalAmount,
                    discountPercentage,
                  );
                }
              },
          // Callback untuk toggle ON (payment/direct)
          onConfirmPayment:
              (
                customerName,
                customerPhone,
                paymentMethod,
                cashAmount,
                transferAmount,
                paymentStatus,
                outstandingReminderDate,
                updatedCartItems,
                updatedTotalAmount,
              ) {
                // Check if context is still valid before operations
                if (context.mounted) {
                  completeTransaction(
                    context,
                    cartProvider,
                    notesController,
                    customerName: customerName,
                    customerPhone: customerPhone,
                    paymentMethod: paymentMethod,
                    cashAmount: cashAmount,
                    transferAmount: transferAmount,
                    paymentStatus: paymentStatus,
                    outstandingReminderDate: outstandingReminderDate,
                    updatedCartItems: updatedCartItems,
                    updatedTotalAmount: updatedTotalAmount,
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
    List<CartItem> updatedCartItems,
    double updatedTotalAmount,
    double discountPercentage,
  ) async {
    try {
      // Set customer information in cart provider
      if (customerName.isNotEmpty) {
        cartProvider.setCustomerName(customerName);
      }
      if (customerPhone.isNotEmpty) {
        cartProvider.setCustomerPhone(customerPhone);
      }

      // Update cart provider with modified items and total
      // This ensures the backend receives the correct updated prices
      cartProvider.clearItems();
      for (final item in updatedCartItems) {
        cartProvider.addItem(item.product, quantity: item.quantity);
      }

      // Since updatedCartItems already have discounted prices per item,
      // we don't need to set discount amount separately.
      // The cart provider will automatically calculate the correct total
      // from the already discounted item prices.

      // Get transaction provider
      final transactionProvider = Provider.of<TransactionProvider>(
        context,
        listen: false,
      );

      dynamic transactionResponse;

      // Check if this is an existing draft transaction that needs update
      if (cartProvider.hasExistingDraftTransaction) {
        debugPrint(
          '🔄 Updating existing draft transaction to order status. ID: ${cartProvider.draftTransactionId}',
        );

        // Use updateTransaction method for existing draft transactions
        transactionResponse = await transactionProvider.updateTransaction(
          transactionId: cartProvider.draftTransactionId!,
          cartItems: updatedCartItems,
          totalAmount: updatedTotalAmount,
          notes: notesController.text.trim(),
          paymentMethod: 'cash',
          storeId: _getStoreIdFromUser(context),
          customerName: cartProvider.customerName ?? 'Customer',
          customerPhone: cartProvider.customerPhone,
          status: 'pending', // Change status from draft to pending
          cashAmount: 0, // Orders don't have cash amount since they're pending
          transferAmount: 0, // Default transfer amount for orders
          outstandingReminderDate: null, // No reminder date for orders
        );

        debugPrint('✅ Draft transaction updated to order successfully');
      } else {
        debugPrint('✨ Creating new order transaction');

        // Process new order using the correct method (status = pending payment)
        transactionResponse = await transactionProvider.processPayment(
          cartItems: updatedCartItems,
          totalAmount: updatedTotalAmount,
          notes: notesController.text.trim(),
          paymentMethod: 'cash',
          storeId: _getStoreIdFromUser(context),
          customerName: cartProvider.customerName ?? 'Customer',
          customerPhone: cartProvider.customerPhone,
          status: 'pending', // Change status to pending for orders
          cashAmount: 0, // Orders don't have cash amount since they're pending
          transferAmount: 0, // Default transfer amount for orders
          outstandingReminderDate: null, // No reminder date for orders
        );

        debugPrint('✅ New order transaction created successfully');
      }

      if (transactionResponse != null) {
        // Get store information from user profile
        final store = _getStoreFromUser(context);

        // Get transaction number from response
        final transactionNumber =
            transactionResponse.data?.transactionNumber ??
            'ORD${DateTime.now().millisecondsSinceEpoch}';

        // Store cart items before clearing
        final cartItemsCopy = List<CartItem>.from(updatedCartItems);
        final totalAmount = updatedTotalAmount;
        final itemCount = updatedCartItems.fold(
          0,
          (sum, item) => sum + item.quantity,
        );
        final notes = notesController.text.trim();

        // Clear cart and reset draft transaction
        cartProvider.clearCart();
        notesController.clear();

        // Navigate to OrderSuccessPage
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => OrderSuccessPage(
                customerName: customerName.isNotEmpty
                    ? customerName
                    : 'Customer',
                customerPhone: customerPhone,
                totalAmount: totalAmount,
                transactionNumber: transactionNumber,
                store: transactionResponse.data?.store ?? store,
                cartItems: cartItemsCopy,
                notes: notes,
                itemCount: itemCount,
                status: 'pending', // Orders are typically pending
                dueDate: null, // Orders don't have due dates by default
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
