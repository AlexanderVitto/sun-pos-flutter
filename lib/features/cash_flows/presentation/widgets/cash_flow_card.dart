import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/cash_flow.dart';

class CashFlowCard extends StatelessWidget {
  final CashFlow cashFlow;
  final VoidCallback? onTap;

  const CashFlowCard({super.key, required this.cashFlow, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isIncoming = cashFlow.type == 'in';
    final color = isIncoming ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with title and amount
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cashFlow.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cashFlow.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isIncoming
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: color,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            cashFlow.formattedAmount,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isIncoming ? 'MASUK' : 'KELUAR',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Bottom row with category, date, and notes indicator
              Row(
                children: [
                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(cashFlow.category),
                          size: 12,
                          color: Colors.blue.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getCategoryName(cashFlow.category),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Date
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat(
                          'dd MMM yyyy',
                        ).format(cashFlow.transactionDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),

                  // Notes indicator
                  if (cashFlow.notes != null && cashFlow.notes!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.note, size: 12, color: Colors.grey.shade500),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'sales':
        return Icons.point_of_sale;
      case 'expense':
        return Icons.shopping_cart;
      case 'transfer':
        return Icons.swap_horiz;
      case 'investment':
        return Icons.trending_up;
      case 'loan':
        return Icons.account_balance;
      default:
        return Icons.more_horiz;
    }
  }

  String _getCategoryName(String category) {
    switch (category.toLowerCase()) {
      case 'sales':
        return 'Penjualan';
      case 'expense':
        return 'Pengeluaran';
      case 'transfer':
        return 'Transfer';
      case 'investment':
        return 'Investasi';
      case 'loan':
        return 'Pinjaman';
      default:
        return 'Lainnya';
    }
  }
}
