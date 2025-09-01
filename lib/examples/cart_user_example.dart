// Contoh implementasi penggunaan User data dalam CartProvider

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../../auth/providers/auth_provider.dart';

class CartUserExample extends StatefulWidget {
  @override
  _CartUserExampleState createState() => _CartUserExampleState();
}

class _CartUserExampleState extends State<CartUserExample> {
  @override
  void initState() {
    super.initState();

    // Initialize cart dengan user data saat widget dibuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCartWithUser();
    });
  }

  void _initializeCartWithUser() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // Set user data dari AuthProvider ke CartProvider
    if (authProvider.isAuthenticated && authProvider.user != null) {
      cartProvider.setCurrentUser(authProvider.user);
      print('User ${authProvider.user!.name} berhasil di-set ke cart');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cart dengan User Info')),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          return Column(
            children: [
              // User Info Card
              Card(
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Cashier',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),

                      if (cartProvider.hasUser) ...[
                        Text('Nama: ${cartProvider.userName}'),
                        Text('Email: ${cartProvider.userEmail}'),
                        Text('Role: ${cartProvider.userRole}'),
                        Text('ID: ${cartProvider.userId}'),
                      ] else ...[
                        Text('User belum login'),
                      ],
                    ],
                  ),
                ),
              ),

              // Cart Info
              Card(
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Cart',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),

                      Text('Total Items: ${cartProvider.itemCount}'),
                      Text(
                        'Total Amount: \$${cartProvider.total.toStringAsFixed(2)}',
                      ),

                      if (cartProvider.customerName != null)
                        Text('Customer: ${cartProvider.customerName}'),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed:
                          cartProvider.hasUser
                              ? () {
                                // Contoh action yang memerlukan user
                                _processWithUserValidation();
                              }
                              : null,
                      child: Text('Process Transaction'),
                    ),

                    SizedBox(height: 8),

                    ElevatedButton(
                      onPressed: () {
                        cartProvider.clearUser();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('User data cleared')),
                        );
                      },
                      child: Text('Clear User'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _processWithUserValidation() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (!cartProvider.hasUser) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User harus login untuk melakukan transaksi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Process transaksi dengan user data
    print('Processing transaction by: ${cartProvider.userName}');
    print('User ID: ${cartProvider.userId}');
    print('User Role: ${cartProvider.userRole}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaksi diproses oleh ${cartProvider.userName}'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
