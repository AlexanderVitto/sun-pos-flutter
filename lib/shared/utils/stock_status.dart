import 'package:flutter/material.dart';

/// Tingkat ketersediaan stok, dipakai untuk reminder visual yang konsisten
/// di seluruh aplikasi (kartu produk, kartu POS, detail produk, dialog varian).
enum StockLevel { out, low, safe }

/// Status stok turunan dari [stock] saat ini dan [minStock] (batas minimum).
///
/// Aturan:
/// - `stock <= 0`        => Habis (merah)
/// - `stock <= minStock` => Menipis (oranye)
/// - selain itu          => Aman (hijau)
class StockStatus {
  final StockLevel level;

  /// Label singkat siap tampil: `Habis` / `Menipis` / `Aman`.
  final String label;

  /// Warna indikator yang selaras dengan palet dashboard app.
  final Color color;

  const StockStatus._(this.level, this.label, this.color);

  factory StockStatus.of(int stock, int minStock) {
    if (stock <= 0) {
      return const StockStatus._(StockLevel.out, 'Habis', Color(0xFFef4444));
    }
    if (stock <= minStock) {
      return const StockStatus._(StockLevel.low, 'Menipis', Color(0xFFf59e0b));
    }
    return const StockStatus._(StockLevel.safe, 'Aman', Color(0xFF10b981));
  }

  bool get isOut => level == StockLevel.out;
  bool get isLow => level == StockLevel.low;
  bool get isSafe => level == StockLevel.safe;
}
