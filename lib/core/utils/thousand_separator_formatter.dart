import 'package:flutter/services.dart';

/// TextInputFormatter yang memformat angka dengan pemisah ribuan
/// Contoh: 1000000 -> 1.000.000
class ThousandSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Jika kosong, izinkan
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Hapus semua karakter non-digit
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Jika tidak ada digit, return empty
    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    // Format dengan pemisah ribuan (titik)
    String formatted = _formatWithThousandSeparator(digitsOnly);

    // Hitung posisi cursor yang baru
    int selectionIndex = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }

  /// Format string angka dengan pemisah ribuan
  String _formatWithThousandSeparator(String value) {
    if (value.isEmpty) return '';

    // Reverse string untuk memudahkan penambahan separator setiap 3 digit
    String reversed = value.split('').reversed.join('');

    // Tambahkan titik setiap 3 digit
    String formatted = '';
    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        formatted += '.';
      }
      formatted += reversed[i];
    }

    // Reverse kembali untuk mendapatkan hasil akhir
    return formatted.split('').reversed.join('');
  }

  /// Helper untuk parsing string yang sudah diformat ke double
  /// Contoh: "1.000.000" -> 1000000.0
  static double? parseFormatted(String text) {
    if (text.isEmpty) return null;

    // Hapus semua titik pemisah ribuan
    String digitsOnly = text.replaceAll('.', '');

    return double.tryParse(digitsOnly);
  }

  /// Helper untuk memformat double ke string dengan pemisah ribuan
  /// Contoh: 1000000.0 -> "1.000.000"
  static String format(double value) {
    // Bulatkan ke integer terlebih dahulu
    int intValue = value.round();

    // Convert ke string
    String valueStr = intValue.toString();

    // Format dengan pemisah ribuan
    String reversed = valueStr.split('').reversed.join('');
    String formatted = '';

    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        formatted += '.';
      }
      formatted += reversed[i];
    }

    return formatted.split('').reversed.join('');
  }
}
