import 'package:flutter/material.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/routes/app_routes.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: AppIcons.sales,
                title: 'New Sale',
                subtitle: 'Start a new transaction',
                color: Colors.green,
                onTap: () => Navigator.pushNamed(context, AppRoutes.newSale),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                icon: AppIcons.add,
                title: 'Add Product',
                subtitle: 'Add new product',
                color: Colors.blue,
                onTap: () => Navigator.pushNamed(context, AppRoutes.addProduct),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: AppIcons.customers,
                title: 'Add Customer',
                subtitle: 'Register new customer',
                color: Colors.orange,
                onTap:
                    () => Navigator.pushNamed(context, AppRoutes.addCustomer),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                icon: AppIcons.chart,
                title: 'View Reports',
                subtitle: 'Sales analytics',
                color: Colors.purple,
                onTap: () => Navigator.pushNamed(context, AppRoutes.reports),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
