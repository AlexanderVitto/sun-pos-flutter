# Sales Reports Feature

Fitur laporan penjualan untuk aplikasi POS yang menampilkan analisis data penjualan dengan grafik dan statistik.

## Overview

Halaman laporan penjualan menyediakan dashboard lengkap untuk monitoring performa bisnis dengan data dummy yang realistis.

## Features

### 📊 1. Summary Cards (Ringkasan Penjualan)

- **Total Transaksi**: Jumlah transaksi dalam periode terpilih
- **Total Penjualan**: Revenue/pendapatan total
- **Item Terjual**: Jumlah total item yang terjual
- **Rata-rata Transaksi**: Nilai rata-rata per transaksi

### 📅 2. Period Selector (Filter Periode)

- **Hari Ini**: Data penjualan hari ini
- **Minggu Ini**: Data penjualan 7 hari terakhir
- **Bulan Ini**: Data penjualan 30 hari terakhir

### 📈 3. Sales Chart (Grafik Penjualan)

- Bar chart 7 hari terakhir
- Tampilan responsif dengan highlight hari ini
- Format currency yang user-friendly (K untuk ribu, M untuk juta)

### 🏆 4. Top Products (Produk Terlaris)

- Ranking 5 produk terlaris
- Menampilkan jumlah terjual dan revenue
- Visual ranking dengan warna medali (emas, perak, perunggu)

### 🕒 5. Recent Transactions (Transaksi Terbaru)

- Daftar 4 transaksi terkini
- Informasi ID, waktu, jumlah item, total, dan metode bayar
- Link "Lihat Semua" untuk detail lengkap

### 📤 6. Export Function

- Tombol export di app bar
- Dialog placeholder untuk fitur export masa depan

## File Structure

```
lib/features/reports/presentation/pages/
└── reports_page.dart           # Main sales report page
```

## Data Structure

### Sales Data (Dummy)

```dart
final Map<String, Map<String, dynamic>> _salesData = {
  'Hari Ini': {
    'transactions': 45,
    'revenue': 2350000,
    'items_sold': 127,
    'avg_transaction': 52222,
  },
  'Minggu Ini': {
    'transactions': 312,
    'revenue': 16450000,
    'items_sold': 892,
    'avg_transaction': 52724,
  },
  'Bulan Ini': {
    'transactions': 1248,
    'revenue': 65230000,
    'items_sold': 3567,
    'avg_transaction': 52267,
  },
};
```

### Weekly Chart Data

```dart
final List<Map<String, dynamic>> _weeklyData = [
  {'day': 'Sen', 'sales': 1200000.0},
  {'day': 'Sel', 'sales': 1800000.0},
  {'day': 'Rab', 'sales': 2100000.0},
  {'day': 'Kam', 'sales': 1650000.0},
  {'day': 'Jum', 'sales': 2350000.0},
  {'day': 'Sab', 'sales': 2800000.0},
  {'day': 'Min', 'sales': 3200000.0},
];
```

## UI Components

### 1. Period Selector

- Card dengan FilterChip untuk setiap periode
- State management dengan `setState()` untuk switching
- Visual feedback dengan warna dan checkmark

### 2. Summary Cards Grid

- GridView 2x2 layout
- Setiap card dengan icon, title, value, dan subtitle
- Color coding untuk setiap metric:
  - Biru: Total Transaksi
  - Hijau: Total Penjualan
  - Orange: Item Terjual
  - Ungu: Rata-rata Transaksi

### 3. Bar Chart

- Custom widget menggunakan Container
- Responsive height berdasarkan data maksimum
- Highlight untuk hari ini dengan warna berbeda
- Label dengan abbreviated format (K/M)

### 4. Top Products List

- Ranking visual dengan numbered circles
- Medal colors untuk top 3 (gold, silver, bronze)
- Product name, sold count, dan revenue

### 5. Recent Transactions

- Card list dengan transaction details
- Icon receipt dengan background colored
- Time, items count, payment method, dan total

## Styling

### Colors

- Primary: Blue[600] for app bar and accents
- Success: Green for revenue dan positive metrics
- Warning: Orange for items dan alerts
- Info: Purple untuk averages
- Medal: Gold (#FFD700), Silver (Grey[400]), Bronze (Orange[300])

### Typography

- Headers: FontWeight.bold dengan size 16-18
- Values: FontWeight.bold untuk emphasis
- Subtitles: Grey[600] dengan size 12
- Labels: Grey[500] untuk minor info

### Layout

- Padding: 16px consistent
- Card elevation: 2 untuk subtle shadow
- BorderRadius: 4-8px untuk modern look
- Spacing: 8-24px untuk visual hierarchy

## Functions

### Currency Formatting

```dart
String _formatPrice(double price) {
  return price.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]}.',
  );
}

String _formatPriceShort(double price) {
  if (price >= 1000000) {
    return '${(price / 1000000).toStringAsFixed(1)}M';
  } else if (price >= 1000) {
    return '${(price / 1000).toStringAsFixed(0)}K';
  }
  return price.toStringAsFixed(0);
}
```

## Demo Usage

1. **Run Demo**: `flutter run lib/reports_demo.dart`
2. **Navigate**: Klik "Lihat Laporan Penjualan"
3. **Test Filters**: Switch antara periode (Hari Ini, Minggu Ini, Bulan Ini)
4. **View Charts**: Lihat bar chart 7 hari dengan data berbeda
5. **Explore Sections**: Scroll untuk lihat top products dan recent transactions
6. **Try Export**: Klik icon download di app bar

## Integration Points

### With Main App

- Import di `app_router.dart` sudah ada
- Route `/reports` mengarah ke ReportsPage
- Navigation dari dashboard ke reports

### With Dashboard

- Summary cards dapat di-sync dengan dashboard stats
- Quick navigation dari dashboard reports card

### Future Enhancements

- Real data integration dengan database/API
- Date range picker untuk custom periode
- Export ke PDF/Excel
- Email reports
- Print functionality
- Drill-down ke detail transactions
- Comparison dengan periode sebelumnya
- Goals and targets tracking

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  lucide_icons: ^0.257.0 # For modern icons
```

## Screenshots & Features Demo

✅ **Period Filtering**: Switch data berdasarkan periode
✅ **Responsive Charts**: Bar chart yang menyesuaikan data
✅ **Top Products Ranking**: Visual ranking dengan medal colors  
✅ **Real-time Updates**: State management yang responsive
✅ **Currency Formatting**: Format Rupiah yang proper
✅ **Material Design**: Consistent dengan app theme
✅ **Export Ready**: Infrastructure untuk export features

Laporan penjualan ini memberikan insight yang comprehensive untuk monitoring performa bisnis POS dengan interface yang user-friendly dan data visualization yang jelas.
