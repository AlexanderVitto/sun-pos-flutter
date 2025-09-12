import 'package:flutter/material.dart';
import '../../core/constants/payment_constants.dart';
import '../../shared/widgets/payment_method_widgets.dart';

class PaymentMethodExampleUsage extends StatefulWidget {
  const PaymentMethodExampleUsage({super.key});

  @override
  _PaymentMethodExampleUsageState createState() =>
      _PaymentMethodExampleUsageState();
}

class _PaymentMethodExampleUsageState extends State<PaymentMethodExampleUsage> {
  String _selectedPaymentMethod = 'cash';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Method Examples')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Example 1: Using PaymentConstants directly
            const Text(
              'Example 1: Using PaymentConstants directly',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...PaymentConstants.paymentMethods.entries.map((entry) {
              return ListTile(
                leading: Icon(_getPaymentIcon(entry.key)),
                title: Text(entry.value),
                subtitle: Text('Key: ${entry.key}'),
                trailing:
                    _selectedPaymentMethod == entry.key
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = entry.key;
                  });
                },
              );
            }),

            const SizedBox(height: 32),

            // Example 2: Using PaymentMethodSelector widget
            const Text(
              'Example 2: Using PaymentMethodSelector Widget',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: PaymentMethodSelector(
                  selectedPaymentMethod: _selectedPaymentMethod,
                  onPaymentMethodChanged: (method) {
                    setState(() {
                      _selectedPaymentMethod = method;
                    });
                  },
                  selectedColor: Colors.blue,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Example 3: Using PaymentMethodDisplay widget
            const Text(
              'Example 3: Using PaymentMethodDisplay Widget',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    PaymentMethodDisplay(
                      paymentMethod: _selectedPaymentMethod,
                      iconSize: 24,
                      fontSize: 16,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selected: $_selectedPaymentMethod',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Example 4: Using utility methods
            const Text(
              'Example 4: Using Utility Methods',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('All payment methods:'),
                    Text(PaymentConstants.paymentMethodKeys.join(', ')),
                    const SizedBox(height: 8),
                    Text('Display names:'),
                    Text(PaymentConstants.paymentMethodDisplayNames.join(', ')),
                    const SizedBox(height: 8),
                    Text('Selected method display name:'),
                    Text(
                      PaymentConstants.getPaymentMethodDisplayName(
                        _selectedPaymentMethod,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Is valid payment method "test":'),
                    Text(
                      PaymentConstants.isValidPaymentMethod('test').toString(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Example 5: In transaction summary
            const Text(
              'Example 5: Transaction Summary Usage',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Payment Method:'),
                        PaymentMethodDisplay(
                          paymentMethod: _selectedPaymentMethod,
                          additionalInfo:
                              _selectedPaymentMethod == 'bank_transfer'
                                  ? 'Penuh'
                                  : null,
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount:'),
                        const Text(
                          'Rp 150,000',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentIcon(String method) {
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
}
