import 'package:flutter/services.dart';

/// Custom TextInputFormatter yang memungkinkan input angka desimal
/// dengan format Indonesia (koma sebagai pemisah desimal)
class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;
  final String decimalSeparator;

  DecimalTextInputFormatter({
    this.decimalRange = 2,
    this.decimalSeparator = ',',
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text;

    // Jika kosong, izinkan
    if (newText.isEmpty) {
      return newValue;
    }

    // Hanya izinkan angka dan satu pemisah desimal
    final RegExp regExp = RegExp(r'^\d*[,]?\d*$');
    if (!regExp.hasMatch(newText)) {
      return oldValue;
    }

    // Periksa apakah ada lebih dari satu pemisah desimal
    final List<String> parts = newText.split(decimalSeparator);
    if (parts.length > 2) {
      return oldValue;
    }

    // Jika ada pemisah desimal, batasi digit setelah pemisah
    if (parts.length == 2 && parts[1].length > decimalRange) {
      return oldValue;
    }

    return newValue;
  }

  /// Helper untuk mengkonversi string input ke double
  /// Contoh: "1000,50" -> 1000.50
  static double? parseDecimal(String text) {
    if (text.isEmpty) return null;

    // Ganti koma dengan titik untuk parsing
    final normalizedText = text.replaceAll(',', '.');
    return double.tryParse(normalizedText);
  }

  /// Helper untuk memformat double ke string dengan format Indonesia
  /// Contoh: 1000.50 -> "1000,50"
  static String formatDecimal(double value, {int decimalPlaces = 2}) {
    String formatted = value.toStringAsFixed(decimalPlaces);

    // Ganti titik dengan koma
    formatted = formatted.replaceAll('.', ',');

    // Hilangkan trailing zeros jika tidak diperlukan
    if (formatted.contains(',')) {
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      formatted = formatted.replaceAll(RegExp(r',$'), '');
    }

    return formatted;
  }

  /// Helper untuk memformat dengan pemisah ribuan dan desimal
  /// Contoh: 1234567.89 -> "1.234.567,89"
  static String formatCurrencyInput(double value, {int decimalPlaces = 2}) {
    // Format bagian bulat dengan pemisah ribuan
    final intPart = value.floor();
    final decimalPart = value - intPart;

    // Format bagian bulat dengan titik sebagai pemisah ribuan
    String intPartFormatted = intPart.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]}.',
    );

    // Jika tidak ada bagian desimal, return hanya bagian bulat
    if (decimalPart == 0 && decimalPlaces == 0) {
      return intPartFormatted;
    }

    // Format bagian desimal
    String decimalPartFormatted = (decimalPart * 100)
        .round()
        .toString()
        .padLeft(2, '0');
    if (decimalPlaces != 2) {
      double scaleFactor = 1;
      for (int i = 0; i < decimalPlaces; i++) {
        scaleFactor *= 10;
      }
      decimalPartFormatted = (decimalPart * scaleFactor)
          .round()
          .toString()
          .padLeft(decimalPlaces, '0');
    }

    // Hilangkan trailing zeros
    decimalPartFormatted = decimalPartFormatted.replaceAll(RegExp(r'0+$'), '');

    if (decimalPartFormatted.isEmpty) {
      return intPartFormatted;
    }

    return '$intPartFormatted,$decimalPartFormatted';
  }
}
