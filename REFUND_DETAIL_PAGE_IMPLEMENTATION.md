# Implementasi Halaman Detail Refund

## Overview

Halaman detail refund menampilkan informasi lengkap tentang sebuah refund, termasuk informasi customer, transaksi original, item yang direfund, dan staff yang memproses refund.

## Implementasi

### 1. Model Detail Refund

**File**: `lib/features/refunds/data/models/refund_detail_response.dart`

Model lengkap untuk single refund detail:

- `RefundDetailResponse` - Response wrapper
- `RefundDetailData` - Data refund lengkap
- `RefundDetailUser` - User yang memproses refund dengan roles dan permissions
- `UserRole` - Role dan permission detail
- `RefundDetailItem` - Item detail dengan product variant info
- `ProductVariant` - Detail variant produk (stock, price, attributes)

**Perbedaan dengan RefundListResponse**:

- User memiliki data `roles` dan `permissions` yang lebih lengkap
- Detail items memiliki `productVariant` dengan informasi stock dan attributes
- Lebih detail untuk menampilkan informasi lengkap di halaman detail

### 2. Service API

**File**: `lib/features/refunds/data/services/refund_api_service.dart`

Method `getRefundById(int id)` sudah tersedia untuk fetch detail refund.

**Endpoint**: `GET {{base_url}}/api/v1/refunds/{refund_id}`

- Headers: Authorization Bearer Token
- Return: Map<String, dynamic>

### 3. Halaman Detail Refund

**File**: `lib/features/refunds/presentation/pages/refund_detail_page.dart`

Stateful widget untuk menampilkan detail refund dengan loading state.

#### Features:

**a. Header Section** (Gradient Red)

- Icon refund
- Refund number (besar dan bold)
- Status badge
- Tanggal refund
- Total refund amount (36px, bold, white)
- Breakdown: Cash & Transfer amount dalam card terpisah

**b. Info Cards Grid**

- **Customer Card**: Nama, phone
- **Store Card**: Nama toko, phone
- **Transaction Card** (full width):
  - Nomor transaksi original
  - Tanggal transaksi
  - Total amount
  - Status transaksi
- **User Card** (full width):
  - Nama staff yang memproses
  - Email staff
  - Role/jabatan

**c. Refund Details Section**

- Header "Item yang Direfund"
- List semua item yang direfund
- Untuk setiap item menampilkan:
  - Product image placeholder (icon package)
  - Nama produk
  - SKU
  - Quantity refunded
  - Unit price
  - Total refund amount (merah, bold)
  - Stock tersedia (jika ada product variant)

**d. Notes Section**

- Ditampilkan jika ada notes
- Background kuning muda
- Icon message square
- Text catatan

#### UI/UX Features:

1. **Pull to Refresh** - Refresh data refund
2. **Loading State** - CircularProgressIndicator saat loading
3. **Error State** - Pesan error dengan tombol retry
4. **Empty State** - Pesan jika data tidak ditemukan
5. **Print Button** (TODO) - Di AppBar untuk print refund

#### Color Scheme:

**Primary Colors**:

- Refund Red: `#EF4444` dan `#DC2626` (gradient)
- Accent Colors:
  - Customer: `#6366f1` (Indigo)
  - Store: `#8B5CF6` (Purple)
  - Transaction: `#10B981` (Green)
  - User: `#F59E0B` (Orange)

**Status Colors**:

- Pending: `#F59E0B` (Orange)
- Completed: `#10B981` (Green)
- Cancelled: `#EF4444` (Red)

### 4. Navigation

**File**: `lib/features/dashboard/presentation/widgets/transaction_tab_page.dart`

Update navigation di `_buildRefundCard()`:

```dart
onTap: () {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => RefundDetailPage(refundId: refund.id),
    ),
  );
},
```

**Import yang ditambahkan**:

```dart
import '../../../refunds/presentation/pages/refund_detail_page.dart';
```

## Struktur Tampilan

### Header (Gradient Red Card)

```
┌─────────────────────────────────────┐
│ 🔄  REFUND              [SELESAI]   │
│                                     │
│ RFD20251008P0NARF                   │
│ 📅 06 Oktober 2025, 00:00           │
│ ─────────────────────────────────   │
│ Total Refund                        │
│ Rp 100.000                          │
│                                     │
│ [💵 Tunai]      [💳 Transfer]       │
│ Rp 100.000      Rp 0                │
└─────────────────────────────────────┘
```

### Info Cards Grid

```
┌──────────────┬──────────────┐
│ 👤 Customer  │ 🏪 Store     │
│ Ahmad Rahman │ Downtown St. │
│ 083456...    │ +1 555...    │
└──────────────┴──────────────┘

┌─────────────────────────────┐
│ 🧾 Transaksi Original       │
│ ─────────────────────────   │
│ # Nomor: TRX20250929...     │
│ 📅 Tanggal: 29 Sep 2025     │
│ 💰 Total: Rp 100.000        │
│ ✅ Status: Selesai          │
└─────────────────────────────┘

┌─────────────────────────────┐
│ ⚙️ Diproses Oleh            │
│ ─────────────────────────   │
│ 👤 Nama: Staff User         │
│ ✉️ Email: staff@sun...      │
│ 🛡️ Role: Kepala Toko        │
└─────────────────────────────┘
```

### Items List

```
┌─────────────────────────────────────┐
│ 📦 Item yang Direfund               │
│ ─────────────────────────────────   │
│ [📦] 1.2' SS, GREEN FLASH...        │
│      SKU: IF CKMC003 (16)-ee6107   │
│      [1x] Rp 100.000        Rp 100K │
│                             ─────── │
│                             Stok: 66│
│ ─────────────────────────────────   │
│ 💬 Catatan                          │
│    Customer returned damaged prod...│
└─────────────────────────────────────┘
```

## API Response Example

```json
{
  "status": "success",
  "message": "Refund retrieved successfully",
  "data": {
    "id": 1,
    "refund_number": "RFD20251008P0NARF",
    "transaction_id": 33,
    "total_refund_amount": 100000,
    "refund_method": "cash",
    "cash_refund_amount": 100000,
    "transfer_refund_amount": 0,
    "status": "completed",
    "notes": "Customer returned damaged product",
    "refund_date": "2025-10-06T00:00:00.000000Z",
    "user": {
      "id": 2,
      "name": "Staff User",
      "email": "staff@sunfirework.com",
      "roles": [...]
    },
    "customer": {...},
    "store": {...},
    "transaction": {...},
    "details": [
      {
        "id": 1,
        "product_name": "1.2' SS, GREEN FLASH W/PURPLE BQ - 100/1",
        "product_sku": "IF CKMC003 (16)-ee6107",
        "unit_price": 100000,
        "quantity_refunded": 1,
        "total_refund_amount": 100000,
        "product_variant": {
          "stock": 66,
          "price": 100000,
          ...
        }
      }
    ]
  }
}
```

## Usage Flow

1. **User tap pada refund card** di transaction tab (filter: Refund)
2. **Navigate ke RefundDetailPage** dengan `refundId`
3. **Page load** - Show loading indicator
4. **Fetch data** dari API `/api/v1/refunds/{refund_id}`
5. **Parse response** menggunakan `RefundDetailResponse.fromJson()`
6. **Display data** di UI dengan section yang terorganisir
7. **User dapat**:
   - Melihat semua detail refund
   - Scroll untuk melihat semua items
   - Pull to refresh untuk reload data
   - Tap back untuk kembali ke list
   - (Future) Tap print untuk print receipt

## Error Handling

1. **Loading State**: CircularProgressIndicator di center
2. **Error State**:
   - Icon alert circle merah
   - Error message
   - Tombol "Coba Lagi" untuk retry
3. **Empty State**: Pesan "Data refund tidak ditemukan"
4. **Network Error**: Handled dengan try-catch, tampilkan error message

## Testing

### Test Cases:

1. ✅ Load detail refund dengan data lengkap
2. ✅ Load detail refund tanpa notes
3. ✅ Load detail refund dengan multiple items
4. ✅ Load detail refund dengan cash only
5. ✅ Load detail refund dengan transfer only
6. ✅ Load detail refund dengan mixed payment
7. ✅ Handle error 404 (refund not found)
8. ✅ Handle error 401 (unauthorized)
9. ✅ Pull to refresh functionality
10. ✅ Back navigation

### Manual Testing Steps:

1. Buka Dashboard → Transaksi
2. Klik chip "Refund"
3. Tap pada salah satu refund card
4. Verifikasi:
   - Loading indicator muncul
   - Data ditampilkan dengan benar
   - Semua section tampil (header, cards, items, notes)
   - Currency format benar
   - Date format benar
   - Pull to refresh bekerja
   - Back button bekerja

## Potential Enhancements

1. **Print Receipt** - Implement print refund receipt
2. **Share** - Share refund details via WhatsApp/Email
3. **Timeline** - Show refund timeline/history
4. **Related Transactions** - Link to related transactions
5. **Edit/Cancel** - Allow edit or cancel refund (with permission)
6. **Export PDF** - Generate PDF refund document
7. **Image Preview** - Show product images if available
8. **Stock History** - Show stock movement from refund

## File Structure

```
lib/
├── features/
│   └── refunds/
│       ├── data/
│       │   ├── models/
│       │   │   ├── refund_list_response.dart
│       │   │   └── refund_detail_response.dart (NEW)
│       │   └── services/
│       │       └── refund_api_service.dart (existing)
│       ├── providers/
│       │   └── refund_list_provider.dart
│       └── presentation/
│           └── pages/
│               └── refund_detail_page.dart (NEW)
└── features/
    └── dashboard/
        └── presentation/
            └── widgets/
                └── transaction_tab_page.dart (updated)
```

## Dependencies

Tidak ada dependency baru. Menggunakan:

- `lucide_icons` - Icons
- `intl` - Date & currency formatting
- `flutter/material.dart` - Material widgets

## Conclusion

Halaman detail refund telah selesai diimplementasikan dengan:

- ✅ Model data lengkap untuk detail refund
- ✅ UI yang menarik dan informatif dengan gradient header
- ✅ Breakdown pembayaran (cash & transfer)
- ✅ Info cards untuk customer, store, transaction, user
- ✅ List items yang direfund dengan detail
- ✅ Notes section jika ada catatan
- ✅ Error handling yang proper
- ✅ Pull to refresh
- ✅ Navigation dari list ke detail
- ✅ Responsive dan user-friendly

Fitur siap digunakan dan dapat di-extend untuk fitur tambahan seperti print, share, dan export.
