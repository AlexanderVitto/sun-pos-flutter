import 'package:intl/intl.dart';

class FormatHelper {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _timeFormat = DateFormat('HH:mm');
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  // Currency formatting
  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  // Date formatting
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  // Time formatting
  static String formatTime(DateTime time) {
    return _timeFormat.format(time);
  }

  // DateTime formatting
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  // Number formatting
  static String formatNumber(int number) {
    return NumberFormat('#,###').format(number);
  }

  // Percentage formatting
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  // Phone number formatting
  static String formatPhoneNumber(String phone) {
    if (phone.length >= 10) {
      return '${phone.substring(0, 4)}-${phone.substring(4, 8)}-${phone.substring(8)}';
    }
    return phone;
  }
}
