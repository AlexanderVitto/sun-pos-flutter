import 'package:flutter/material.dart';
import '../../../core/constants/payment_constants.dart';

class PaymentMethodSelector extends StatelessWidget {
  final String selectedPaymentMethod;
  final Function(String) onPaymentMethodChanged;
  final bool enabled;
  final EdgeInsets? padding;
  final Color? selectedColor;
  final Color? unselectedColor;

  const PaymentMethodSelector({
    super.key,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodChanged,
    this.enabled = true,
    this.padding,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          PaymentConstants.paymentMethods.entries.map((entry) {
            final String methodKey = entry.key;
            final String methodLabel = entry.value;
            final bool isSelected = selectedPaymentMethod == methodKey;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: enabled ? () => onPaymentMethodChanged(methodKey) : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: padding ?? const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? (selectedColor ?? Colors.teal.shade50)
                            : (unselectedColor ?? Colors.grey.shade50),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isSelected
                              ? (selectedColor?.withOpacity(0.7) ??
                                  Colors.teal.shade400)
                              : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getPaymentMethodIcon(methodKey),
                        color:
                            isSelected
                                ? (selectedColor ?? Colors.teal.shade600)
                                : Colors.grey.shade600,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          methodLabel,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color:
                                isSelected
                                    ? (selectedColor ?? Colors.teal.shade700)
                                    : Colors.black87,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: selectedColor ?? Colors.teal.shade600,
                          size: 22,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  IconData _getPaymentMethodIcon(String method) {
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

// Payment Method Display Widget (untuk menampilkan saja, tidak interactive)
class PaymentMethodDisplay extends StatelessWidget {
  final String paymentMethod;
  final double iconSize;
  final double fontSize;
  final Color? color;
  final String? additionalInfo;

  const PaymentMethodDisplay({
    super.key,
    required this.paymentMethod,
    this.iconSize = 20,
    this.fontSize = 14,
    this.color,
    this.additionalInfo,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = PaymentConstants.getPaymentMethodDisplayName(
      paymentMethod,
    );
    final displayText =
        additionalInfo != null ? '$displayName ($additionalInfo)' : displayName;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _getPaymentMethodIcon(paymentMethod),
          color: color ?? Colors.grey.shade600,
          size: iconSize,
        ),
        const SizedBox(width: 8),
        Text(
          displayText,
          style: TextStyle(
            fontSize: fontSize,
            color: color ?? Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  IconData _getPaymentMethodIcon(String method) {
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
