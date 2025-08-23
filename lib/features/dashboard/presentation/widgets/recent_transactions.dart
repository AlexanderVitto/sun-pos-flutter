import 'package:flutter/material.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/utils/format_helper.dart';
import '../../../../data/models/sale.dart';

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    // Demo data - in real app this would come from a provider
    final transactions = _getDemoTransactions();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            TextButton.icon(
              onPressed: () {
                // Navigate to all transactions
              },
              icon: const Icon(AppIcons.forward),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children:
                transactions.map((transaction) {
                  return _TransactionTile(transaction: transaction);
                }).toList(),
          ),
        ),
      ],
    );
  }

  List<Sale> _getDemoTransactions() {
    return [
      Sale(
        id: '1',
        customerName: 'John Doe',
        items: [],
        tax: 0,
        discount: 0,
        paymentMethod: PaymentMethod.cash,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      Sale(
        id: '2',
        customerName: 'Jane Smith',
        items: [],
        tax: 0,
        discount: 0,
        paymentMethod: PaymentMethod.card,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Sale(
        id: '3',
        items: [],
        tax: 0,
        discount: 0,
        paymentMethod: PaymentMethod.transfer,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }
}

class _TransactionTile extends StatelessWidget {
  final Sale transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getPaymentMethodColor().withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getPaymentMethodIcon(),
          color: _getPaymentMethodColor(),
          size: 20,
        ),
      ),
      title: Text(
        transaction.customerName ?? 'Walk-in Customer',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(FormatHelper.formatDateTime(transaction.createdAt)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            FormatHelper.formatCurrency(transaction.total),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Completed',
              style: TextStyle(
                color: Colors.green[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        // Navigate to transaction detail
      },
    );
  }

  IconData _getPaymentMethodIcon() {
    switch (transaction.paymentMethod) {
      case PaymentMethod.cash:
        return AppIcons.cash;
      case PaymentMethod.card:
        return AppIcons.card;
      case PaymentMethod.transfer:
        return AppIcons.transfer;
    }
  }

  Color _getPaymentMethodColor() {
    switch (transaction.paymentMethod) {
      case PaymentMethod.cash:
        return Colors.green;
      case PaymentMethod.card:
        return Colors.blue;
      case PaymentMethod.transfer:
        return Colors.purple;
    }
  }
}
