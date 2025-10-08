# Implementasi Filter Transaksi Refund

## Overview

Fitur ini menambahkan kemampuan untuk melihat dan memfilter transaksi yang sudah direfund di halaman Dashboard Transaksi. Dengan menambahkan chip "Refund" di filter status transaksi, pengguna dapat dengan mudah melihat semua transaksi yang telah mengalami refund.

## Implementasi

### 1. Model Data Refund

**File**: `lib/features/refunds/data/models/refund_list_response.dart`

Model yang dibuat untuk menampung data dari API refund:

- `RefundListResponse` - Response wrapper utama
- `RefundData` - Data container dengan pagination
- `RefundItem` - Data detail refund
- `RefundUser`, `RefundStore`, `RefundCustomer` - Relasi data
- `RefundTransaction` - Data transaksi yang direfund
- `RefundDetail` - Detail item yang direfund
- `RefundLinks` dan `RefundMeta` - Pagination info

### 2. Service API Refund

**File**: `lib/features/refunds/data/services/refund_api_service.dart`

Service untuk komunikasi dengan backend API:

- **Endpoint**: `{{base_url}}/api/v1/refunds`
- **Method**: GET
- **Headers**: Authorization Bearer Token

**Fungsi Utama**:

- `getRefunds()` - Mengambil list refund dengan filter dan pagination
- `getRefundById(int id)` - Mengambil detail refund berdasarkan ID
- `getRefundsByTransactionId(int transactionId)` - Mengambil refund berdasarkan transaction ID

**Query Parameters yang Didukung**:

- `page` - Nomor halaman
- `per_page` - Jumlah item per halaman
- `search` - Pencarian
- `store_id` - Filter berdasarkan toko
- `user_id` - Filter berdasarkan user
- `customer_id` - Filter berdasarkan customer
- `date_from` - Filter tanggal mulai
- `date_to` - Filter tanggal akhir
- `status` - Filter status refund (pending, completed, cancelled)
- `refund_method` - Filter metode refund (cash, transfer, mixed)
- `min_amount` - Filter jumlah minimum
- `max_amount` - Filter jumlah maksimum
- `sort_by` - Field untuk sorting
- `sort_direction` - Arah sorting (asc/desc)

### 3. Provider State Management

**File**: `lib/features/refunds/providers/refund_list_provider.dart`

Provider untuk mengelola state data refund menggunakan ChangeNotifier:

**State Variables**:

- `_refunds` - List data refund
- `_isLoading` - Status loading
- `_errorMessage` - Pesan error
- `_meta` dan `_links` - Pagination metadata

**Fungsi Utama**:

- `loadRefunds()` - Load data refund dari API
- `loadNextPage()` - Load halaman berikutnya
- `setSearch()`, `setStatus()`, dll - Set filter
- `isTransactionRefunded(int transactionId)` - Check apakah transaksi sudah direfund
- `getRefundsByTransactionId(int transactionId)` - Ambil refund untuk transaksi tertentu

### 4. UI Implementation

**File**: `lib/features/dashboard/presentation/widgets/transaction_tab_page.dart`

**Perubahan UI**:

#### a. Tambahan Import

```dart
import '../../../refunds/providers/refund_list_provider.dart';
```

#### b. Inisialisasi Data

Di `initState()`, ditambahkan loading data refund:

```dart
final refundProvider = Provider.of<RefundListProvider>(context, listen: false);
refundProvider.loadRefunds(refresh: true);
```

#### c. Chip Filter Refund

Ditambahkan chip "Refund" di antara filter status:

```dart
_buildStatusChip('refund', 'Refund', provider),
```

#### d. Handling Filter Refund

Di method `_buildStatusChip()`, ditambahkan handling khusus untuk filter refund:

```dart
if (value == 'refund') {
  final refundProvider = Provider.of<RefundListProvider>(context, listen: false);
  refundProvider.loadRefunds(refresh: true);
} else {
  provider.setStatus(value);
  provider.loadTransactions(refresh: true);
}
```

#### e. Display Refund List

Method `_buildTransactionsList()` dimodifikasi untuk show refund list ketika filter aktif:

```dart
if (_selectedStatus == 'refund') {
  return Consumer<RefundListProvider>(
    builder: (context, refundProvider, child) {
      return _buildRefundsList(refundProvider);
    },
  );
}
```

#### f. Refund Card UI

Method `_buildRefundCard()` menampilkan:

- Refund number dan badge
- Nomor transaksi terkait
- Informasi customer
- Total refund amount dengan styling khusus (warna merah)
- Metode refund (Cash/Transfer/Mixed)
- Tanggal refund
- Status refund
- Notes (jika ada)

**Styling Khusus untuk Refund**:

- Badge warna merah untuk indikator refund
- Gradient merah untuk container total refund
- Icon `LucideIcons.arrowLeftRight` untuk badge refund

### 5. Provider Registration

**File**: `lib/main.dart`

Ditambahkan RefundListProvider ke dalam MultiProvider:

```dart
import 'features/refunds/providers/refund_list_provider.dart';

// Di dalam providers:
ChangeNotifierProvider(create: (_) => RefundListProvider()),
```

## Fitur Lengkap

### 1. Filter Chip "Refund"

- Chip baru di antara filter status transaksi
- Styling konsisten dengan chip lainnya
- Active state dengan warna ungu/indigo

### 2. Refund List View

Menampilkan list transaksi yang sudah direfund dengan informasi:

- Nomor refund
- Nomor transaksi original
- Nama customer
- Nomor telepon customer
- Total amount yang direfund
- Metode refund
- Tanggal refund
- Status refund
- Notes/catatan refund

### 3. Empty State

Handling untuk kondisi:

- Loading state dengan indicator
- Error state dengan tombol retry
- Empty state dengan pesan yang sesuai

### 4. Pagination

- Infinite scroll untuk load more data
- Pull to refresh
- Loading indicator saat load more

### 5. Navigation

Tap pada refund card akan navigate ke halaman detail transaksi (jika data transaksi tersedia)

## Status Color Coding

### Refund Status

- **Pending**: Orange (`#F59E0B`)
- **Completed**: Green (`#10B981`)
- **Cancelled**: Red (`#EF4444`)

### Refund Method Display

- `cash` → "Tunai"
- `transfer` / `bank_transfer` → "Transfer"
- `mixed` → "Campuran"

## Error Handling

Service menangani berbagai HTTP status codes:

- **200**: Success
- **401**: Unauthorized - Token tidak valid
- **403**: Forbidden - Tidak punya permission
- **404**: Not found
- **Other**: Error dengan detail message

## Testing

Untuk testing fitur ini:

1. **Pastikan ada data refund** di backend
2. **Buka halaman Dashboard** → Tab Transaksi
3. **Klik chip "Refund"**
4. **Verifikasi**:
   - Loading indicator muncul
   - Data refund ditampilkan dengan benar
   - Card refund memiliki styling yang tepat
   - Pagination bekerja dengan scroll
   - Pull to refresh bekerja
   - Navigation ke detail transaksi bekerja

## Potential Enhancements

1. **Search** - Tambahkan search untuk refund
2. **Filter tambahan** - Filter berdasarkan metode refund, customer, dll
3. **Detail Page** - Halaman detail khusus untuk refund
4. **Export** - Export data refund ke PDF/Excel
5. **Statistics** - Tampilkan statistik refund di dashboard
6. **Notifications** - Notifikasi untuk refund baru

## Dependencies

Tidak ada dependency baru yang ditambahkan. Menggunakan:

- `provider` - State management
- `http` - HTTP requests
- `lucide_icons` - Icons
- `intl` - Formatting (currency, date)

## File Structure

```
lib/
├── features/
│   └── refunds/
│       ├── data/
│       │   ├── models/
│       │   │   └── refund_list_response.dart
│       │   └── services/
│       │       └── refund_api_service.dart
│       └── providers/
│           └── refund_list_provider.dart
├── features/
│   └── dashboard/
│       └── presentation/
│           └── widgets/
│               └── transaction_tab_page.dart (updated)
└── main.dart (updated)
```

## API Response Example

```json
{
  "status": "success",
  "message": "Refunds retrieved successfully",
  "data": {
    "data": [
      {
        "id": 1,
        "refund_number": "RFD20251008P0NARF",
        "transaction_id": 33,
        "customer_id": 3,
        "total_refund_amount": 100000,
        "refund_method": "cash",
        "status": "completed",
        "refund_date": "2025-10-06T00:00:00.000000Z",
        ...
      }
    ],
    "meta": {
      "current_page": 1,
      "total": 1,
      ...
    }
  }
}
```

## Conclusion

Implementasi filter refund telah selesai dengan lengkap, mencakup:

- ✅ Model data yang sesuai dengan API response
- ✅ Service untuk komunikasi dengan API
- ✅ Provider untuk state management
- ✅ UI yang konsisten dengan design sistem yang ada
- ✅ Error handling yang proper
- ✅ Pagination dan infinite scroll
- ✅ Empty state dan loading state
- ✅ Integration dengan existing transaction system

Fitur ini siap digunakan dan dapat dengan mudah di-extend untuk fitur tambahan di masa depan.
