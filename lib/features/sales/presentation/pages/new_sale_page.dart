import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../customers/presentation/widgets/customer_selection_card.dart';
import '../../providers/cart_provider.dart';
import '../../../../core/constants/app_strings.dart';

class NewSalePage extends StatelessWidget {
  const NewSalePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.newSale),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Selection Section
            const CustomerSelectionCard(),

            const SizedBox(height: 16),

            // Cart Summary Section
            Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.shopping_cart, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Cart Summary',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${cartProvider.itemCount} items',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (cartProvider.items.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Cart is empty',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Add products to continue',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            children: [
                              ...cartProvider.items.map(
                                (item) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(item.product.name),
                                  subtitle: Text('Qty: ${item.quantity}'),
                                  trailing: Text(
                                    '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              const Divider(),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '\$${cartProvider.total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Navigate to products page
                      Navigator.of(context).pushNamed('/products');
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Add Products'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.blue.shade300),
                      foregroundColor: Colors.blue,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Consumer<CartProvider>(
                    builder: (context, cartProvider, child) {
                      return ElevatedButton.icon(
                        onPressed: cartProvider.items.isEmpty
                            ? null
                            : () {
                                // Handle checkout
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Checkout functionality coming soon',
                                    ),
                                    backgroundColor: Colors.blue,
                                  ),
                                );
                              },
                        icon: const Icon(Icons.payment),
                        label: const Text('Checkout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
