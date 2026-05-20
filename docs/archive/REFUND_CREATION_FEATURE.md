# Implementasi Fitur Refund Item

## 📋 Ringkasan

Fitur refund item memungkinkan pengguna untuk melakukan refund produk dari transaksi dengan status **completed** atau **outstanding**. Pengguna dapat memilih item yang akan di-refund, menentukan jumlah, metode refund (cash/transfer/mixed), dan menambahkan catatan.

## 🎯 Tujuan

1. Memberikan kemampuan refund item dari transaksi yang sudah selesai atau masih outstanding
2. Mendukung berbagai metode refund (cash, transfer, atau kombinasi keduanya)
3. Validasi jumlah refund agar sesuai dengan total item yang dipilih
4. Integrasi dengan API backend untuk menyimpan data refund

## 🔧 Perubahan yang Dilakukan

### 1. **Model Request Refund** (`create_refund_request.dart`)

```dart
class CreateRefundRequest {
  final int transactionId;
  final int storeId;
  final String refundMethod; // 'cash', 'transfer', 'cash_and_transfer'
  final double cashRefundAmount;
  final double transferRefundAmount;
  final String status;
  final String? notes;
  final String refundDate;
  final List<RefundDetailRequest> details;
}

class RefundDetailRequest {
  final int transactionDetailId;
  final int quantityRefunded;
}
```

**Fitur:**

- Mendefinisikan struktur request untuk POST /api/v1/refunds
- Mendukung 3 metode refund: cash, transfer, cash_and_transfer
- Menyertakan detail item yang di-refund dengan quantity masing-masing

### 2. **API Service** (`refund_api_service.dart`)

```dart
Future<Map<String, dynamic>> createRefund(
  Map<String, dynamic> requestBody,
) async {
  // POST request ke /api/v1/refunds
  // Dengan Authorization Bearer token
  // Debug logging untuk request dan response
}
```

**Fitur:**

- Method createRefund() untuk POST refund ke API
- Debug logging lengkap untuk tracking request/response
- Error handling untuk status code 401 dan lainnya

### 3. **Provider** (`refund_list_provider.dart`)

```dart
Future<void> createRefund(CreateRefundRequest request) async {
  // Submit refund ke API
  // Auto-refresh list setelah sukses
}
```

**Fitur:**

- Method createRefund() untuk submit refund
- Auto-refresh daftar refund setelah berhasil dibuat
- Debug logging untuk tracking proses

### 4. **Halaman Create Refund** (`create_refund_page.dart`)

**UI Components:**

1. **Transaction Info Card**

   - Menampilkan nomor invoice, tanggal, dan total transaksi

2. **Item Selection**

   - Checkbox untuk memilih item yang akan di-refund
   - Input quantity untuk setiap item
   - Validasi: quantity tidak boleh melebihi quantity transaksi

3. **Total Refund Display**

   - Real-time calculation berdasarkan item yang dipilih
   - Ditampilkan dalam card berwarna biru

4. **Refund Method Selection**

   - Dropdown: Cash, Transfer, atau Cash & Transfer
   - Auto-fill amount berdasarkan metode yang dipilih

5. **Amount Input**

   - Input cash amount (jika metode cash atau mixed)
   - Input transfer amount (jika metode transfer atau mixed)
   - Validasi: total harus sama dengan total refund

6. **Refund Date Picker**

   - Date picker untuk tanggal refund
   - Default: hari ini

7. **Notes (Optional)**

   - Textarea untuk catatan refund

8. **Submit Button**
   - Validasi semua input sebelum submit
   - Loading indicator saat proses
   - Success/error message setelah submit

**Validasi:**

- Minimal 1 item harus dipilih
- Quantity refund: min 1, max = quantity transaksi
- Total cash/transfer harus sesuai dengan total refund
- Untuk metode cash_and_transfer: cash + transfer = total refund

### 5. **Transaction Detail Page** (`transaction_detail_page.dart`)

**Perubahan:**

1. **Import baru:**

   ```dart
   import '../../../transactions/data/models/create_transaction_response.dart';
   import '../../../refunds/presentation/pages/create_refund_page.dart';
   ```

2. **State variable baru:**

   ```dart
   TransactionData? _transactionData; // Untuk pass ke CreateRefundPage
   ```

3. **Store transaction data:**

   ```dart
   // Di _loadTransactionDetails()
   _transactionData = transactionData;
   ```

4. **Action buttons untuk status COMPLETED:**

   - Tombol "Lihat Struk" (hijau)
   - Tombol "Refund Item" (outlined, orange) - BARU

5. **Action buttons untuk status OUTSTANDING:**

   - Tombol "Bayar Utang" (orange)
   - Tombol "Refund Item" (outlined, orange) - BARU

6. **Method \_navigateToRefund():**
   ```dart
   Future<void> _navigateToRefund() async {
     // Check if transaction data loaded
     // Navigate to CreateRefundPage
     // Reload transaction on success
     // Show success message
   }
   ```

## 📊 Flow Refund

```
1. User membuka Transaction Detail Page
   ↓
2. Untuk transaksi completed/outstanding → Tampil tombol "Refund Item"
   ↓
3. User klik "Refund Item"
   ↓
4. Navigate ke CreateRefundPage dengan data transaksi
   ↓
5. User pilih item yang akan di-refund
   ↓
6. User input quantity untuk setiap item
   ↓
7. System auto-calculate total refund
   ↓
8. User pilih metode refund (cash/transfer/mixed)
   ↓
9. System auto-fill amount sesuai metode
   ↓
10. User adjust amount jika perlu (untuk mixed method)
    ↓
11. User pilih tanggal refund
    ↓
12. User tambah catatan (optional)
    ↓
13. User klik "Submit Refund"
    ↓
14. System validasi semua input
    ↓
15. Jika valid → POST ke /api/v1/refunds
    ↓
16. Jika sukses:
    - Show success message
    - Navigate back ke Transaction Detail
    - Reload transaction data
    - Show info message "Silakan cek tab Refund"
    ↓
17. Jika gagal:
    - Show error message
    - User dapat retry
```

## 🔐 API Integration

### Endpoint

```
POST /api/v1/refunds
```

### Headers

```
Authorization: Bearer {token}
Content-Type: application/json
Accept: application/json
```

### Request Body

```json
{
  "transaction_id": 123,
  "store_id": 1,
  "refund_method": "cash", // atau "transfer" atau "cash_and_transfer"
  "cash_refund_amount": 50000,
  "transfer_refund_amount": 0,
  "status": "completed",
  "notes": "Refund karena barang rusak", // optional
  "refund_date": "2024-01-15",
  "details": [
    {
      "transaction_detail_id": 456,
      "quantity_refunded": 2
    }
  ]
}
```

### Response (Success)

```json
{
  "status": "success",
  "message": "Refund created successfully",
  "data": {
    "id": 789,
    "refund_number": "REF-20240115-001",
    ...
  }
}
```

## ✅ Validasi

### Form Validation

1. **Item Selection:**

   - Minimal 1 item harus dipilih
   - Show error jika tidak ada item dipilih

2. **Quantity Validation:**

   - Minimal: 1
   - Maksimal: quantity di transaksi
   - Show error inline di textfield

3. **Amount Validation:**

   - Metode Cash: cash amount = total refund
   - Metode Transfer: transfer amount = total refund
   - Metode Mixed: cash + transfer = total refund
   - Show snackbar error jika tidak sesuai

4. **Required Fields:**
   - Transaction ID
   - Store ID
   - Refund method
   - Refund date
   - Minimal 1 detail item

## 🎨 UI/UX Features

### Design

- **Color Scheme:**
  - Primary: Green (#4CAF50, shade 600) - konsisten dengan tema success/refund
  - AppBar: Green shade 600
  - Cards: White dengan border radius 12px
  - Selected items: Green shade 300 border (2px), Green shade 50 background
  - Buttons: Green shade 600 dengan icon
  - Input fields: Border radius 12px, green accent saat focus
- **Icons:**
  - Transaction info: `receipt_long` (white on green)
  - Total refund: `calculate` (white on green)
  - Payment method: `payment`
  - Cash amount: `attach_money`
  - Transfer amount: `account_balance`
  - Date: `calendar_today`
  - Notes: `note_add`
  - Submit: `check_circle_outline`
  - Checkbox: Custom container dengan `check` icon

### Card Styling

- **Transaction Info Card:**
  - Elevation: 2
  - Border radius: 12px
  - Padding: 16px
  - Icon container dengan green background
  - Divider untuk memisahkan info
- **Item Cards:**
  - Elevation: 1
  - Margin bottom: 12px
  - Border radius: 12px
  - Dynamic border: Green saat selected, grey saat unselected
  - Border width: 2px selected, 1px unselected
  - InkWell untuk tap effect
  - Custom checkbox dengan green background
- **Total Refund Card:**
  - Elevation: 2
  - Green shade 50 background
  - Green shade 200 border (2px)
  - Icon badge dengan green background
  - Large bold text untuk amount

### Form Inputs

- **Dropdown (Metode Refund):**
  - Filled background (white)
  - Border radius: 12px
  - Prefix icon (payment) dengan green color
  - Focus border: Green shade 600 (2px)
  - Dropdown arrow di suffix
- **Amount Fields:**
  - Filled background (white)
  - Border radius: 12px
  - Prefix icon berbeda per jenis (money/bank)
  - Font weight: 600 untuk value
  - Prefix "Rp " dengan bold styling
  - Focus border: Green shade 600 (2px)
- **Quantity Input:**
  - Background: Green shade 50
  - Border: Green shade 200
  - Width: 100px
  - Center aligned text
  - Bold font untuk value
  - Max indicator di kanan
- **Date Picker:**
  - InputDecorator dengan filled background
  - Calendar icon prefix
  - Dropdown arrow suffix
  - Format: "dd MMM yyyy"
  - Bold text untuk tanggal
- **Notes:**
  - Multi-line (3 rows)
  - Placeholder text dengan grey color
  - Prefix icon di top-aligned
  - Full border radius

### Responsive Features

- Auto-fill amount saat ganti metode refund
- Real-time total calculation saat pilih item
- Loading state pada submit button
- Success/error feedback dengan SnackBar
- Tap anywhere pada card untuk select/deselect
- Smooth border color transition

### Interactive Elements

- **Item Selection:**
  - Tap card untuk toggle selection
  - Visual feedback dengan border color change
  - Checkbox animation (green fill)
  - Auto-fill quantity = 1 saat dipilih
  - Collapse/expand quantity input
- **Quantity Control:**
  - Appears only when item selected
  - Green themed container
  - Max limit displayed
  - Real-time validation
  - Inline error messages

### User Experience

- Clear visual hierarchy dengan typography
- Consistent spacing (12-24px)
- Icon badges untuk visual context
- Color-coded states (selected/unselected)
- Informative labels dan hints
- Disabled state untuk submit button
- Loading indicator saat processing
- Success/error messages dengan context
- Auto-navigation setelah sukses

## 📁 File Structure

```
lib/features/refunds/
├── data/
│   ├── models/
│   │   └── create_refund_request.dart (BARU)
│   └── services/
│       └── refund_api_service.dart (UPDATED)
├── providers/
│   └── refund_list_provider.dart (UPDATED)
└── presentation/
    └── pages/
        └── create_refund_page.dart (BARU)

lib/features/dashboard/presentation/pages/
└── transaction_detail_page.dart (UPDATED)
```

## 🧪 Testing Manual

### Test Case 1: Refund dengan Cash

1. Buka transaksi completed
2. Klik "Refund Item"
3. Pilih 1 item, set quantity = 1
4. Pilih metode "Cash"
5. Verifikasi cash amount auto-filled
6. Submit
7. ✅ Refund berhasil dibuat

### Test Case 2: Refund dengan Transfer

1. Buka transaksi completed
2. Klik "Refund Item"
3. Pilih 2 item dengan quantity berbeda
4. Pilih metode "Transfer"
5. Verifikasi transfer amount auto-filled
6. Submit
7. ✅ Refund berhasil dibuat

### Test Case 3: Refund dengan Cash & Transfer

1. Buka transaksi outstanding
2. Klik "Refund Item"
3. Pilih item
4. Pilih metode "Cash & Transfer"
5. Input cash amount
6. Input transfer amount
7. Verifikasi total = cash + transfer
8. Submit
9. ✅ Refund berhasil dibuat

### Test Case 4: Validation Errors

1. Buka create refund page
2. Jangan pilih item → Submit
3. ✅ Error: "Pilih minimal 1 item"
4. Pilih item, set quantity > stock
5. ✅ Error: "Max {quantity}"
6. Set amount tidak sesuai total
7. ✅ Error: "Jumlah harus {total}"

## 🚀 Deployment Checklist

- [x] Model CreateRefundRequest dibuat
- [x] API service method createRefund() ditambahkan
- [x] Provider method createRefund() ditambahkan
- [x] CreateRefundPage UI dibuat
- [x] Transaction Detail Page updated dengan tombol refund
- [x] Navigation flow implemented
- [x] Validasi form implemented
- [x] Error handling implemented
- [x] Success feedback implemented
- [x] Debug logging added

## 📝 Notes

### Catatan Penting

1. **Transaction Data:** CreateRefundPage menerima `TransactionData` (bukan `TransactionDetailResponse`)
2. **Store ID:** Diambil dari `transaction.store.id`
3. **Auto-refresh:** List refund di-refresh otomatis setelah create
4. **Navigation:** Kembali ke transaction detail dengan result=true jika sukses

### Future Improvements

1. Tambah konfirmasi dialog sebelum submit
2. Tambah preview total refund sebelum submit
3. Support partial refund (refund sebagian dari quantity)
4. Tambah foto/bukti refund
5. Print struk refund
6. Email notifikasi ke customer

## 🔗 Related Files

- `REFUND_DETAIL_API_INTEGRATION.md` - Detail API integration
- `REFUND_TRANSACTION_MODEL_FIX.md` - Model fixes
- `PAYMENT_HISTORY_DISPLAY.md` - Payment history feature

---

**Dibuat:** 10 Oktober 2025  
**Status:** ✅ Completed
