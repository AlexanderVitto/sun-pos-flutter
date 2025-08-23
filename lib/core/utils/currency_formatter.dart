import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _idrFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String formatIDR(double amount) {
    return _idrFormatter.format(amount);
  }

  static String formatIDRCompact(double amount) {
    if (amount >= 1000000000) {
      return 'Rp ${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return 'Rp ${amount.toStringAsFixed(0)}';
    }
  }
}
