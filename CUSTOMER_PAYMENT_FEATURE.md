# Customer Payment Feature - Multi-Transaction Payment Distribution

## Overview

Fitur pembayaran utang customer dengan distribusi otomatis ke multiple transaksi outstanding.

## Features Implemented

### 1. **FloatingActionButton (FAB) in Detail Page**

- **Location**: `customer_outstanding_detail_page.dart`
- **Behavior**:
  - Muncul hanya jika ada transaksi outstanding
  - Navigate ke halaman pembayaran
  - Auto-refresh data setelah pembayaran berhasil

### 2. **Customer Payment Page**

- **File**: `customer_payment_page.dart`
- **Components**:
  - Customer header dengan info customer
  - Outstanding summary (total utang + jumlah transaksi)
  - List transaksi yang akan dibayar (sorted by date ASC)
  - Payment form (metode pembayaran + nominal)
  - Bottom bar dengan tombol bayar

### 3. **Payment Distribution Logic**

#### Algorithm:

```dart
1. Load semua transaksi outstanding, sorted by transaction_date ASC
2. User input nominal pembayaran
3. Distribusi pembayaran:
   - Loop transaksi dari yang terlama
   - Bayar transaksi sampai outstanding_amount = 0
   - Jika pembayaran > outstanding_amount:
     * Set status = 'completed'
     * Lanjut ke transaksi berikutnya dengan sisa payment
   - Jika pembayaran < outstanding_amount:
     * Update payment partial
     * Status tetap 'outstanding'
     * Stop loop
```

#### Example:

```
Customer punya 3 transaksi:
- Transaksi A: Rp 100.000 (outstanding)
- Transaksi B: Rp 150.000 (outstanding)
- Transaksi C: Rp 200.000 (outstanding)
Total: Rp 450.000

User bayar Rp 250.000:
✅ Transaksi A: Lunas (status: completed)
✅ Transaksi B: Lunas (status: completed)
⏳ Transaksi C: Partial payment Rp 0 (sisa Rp 200.000, status: outstanding)

Result:
- 3 transaksi diupdate
- 2 transaksi lunas
```

### 4. **API Integration**

#### Endpoint Used:

```
PUT /api/v1/transactions/{id}/payments
```

#### Request Body:

```json
{
  "payments": [
    {
      "payment_method": "cash",
      "amount": 100000,
      "payment_date": "2025-12-08T16:00:00.000Z",
      "notes": "Pembayaran utang customer",
      "user_id": 1
    }
  ],
  "status": "completed" // or "outstanding"
}
```

### 5. **User Flow**

```
1. Dashboard → Pelanggan Berhutang (Bottom Nav)
2. Outstanding Customers List → Tap customer card
3. Customer Outstanding Detail → View transactions
4. Tap FAB "Bayar Utang" (floating button)
5. Customer Payment Page:
   - View total utang dan list transaksi
   - Pilih metode pembayaran
   - Input nominal (dengan thousand separator)
   - Opsional: tambah catatan
6. Tap "Proses Pembayaran"
7. Confirmation Dialog:
   - Tampilkan berapa transaksi akan diupdate
   - Tampilkan berapa transaksi akan lunas
8. Success Dialog:
   - Tampilkan hasil pembayaran
9. Auto-navigate back + refresh detail page
```

### 6. **Validation Rules**

- ✅ Nominal harus > 0
- ✅ Nominal tidak boleh melebihi total utang
- ✅ Payment method wajib dipilih
- ✅ Catatan opsional

### 7. **UI/UX Features**

- ✅ **Thousand separator** pada input nominal (format: 1.000.000)
- ✅ **Real-time validation** saat user mengetik
- ✅ **Loading state** dengan circular progress indicator
- ✅ **Confirmation dialog** sebelum submit
- ✅ **Success dialog** dengan detail hasil
- ✅ **Error handling** dengan snackbar
- ✅ **Auto-refresh** data setelah pembayaran
- ✅ **Disabled button** jika input invalid atau sedang processing

### 8. **Payment Methods**

Mendukung metode pembayaran dari `PaymentConstants`:

- Cash (Tunai)
- Transfer (Bank Transfer)
- Card (Kartu Debit/Kredit)
- E-Wallet (QRIS/E-Money)

## Technical Implementation

### State Management

```dart
- _formKey: Form validation
- _amountController: Input nominal
- _notesController: Input catatan
- _selectedPaymentMethod: Metode pembayaran terpilih
- _isProcessing: Loading state
- _isLoadingTransactions: Loading transaksi
- _transactions: List transaksi outstanding
- _totalOutstanding: Total utang customer
```

### Key Methods

#### 1. `_loadOutstandingTransactions()`

Load semua transaksi outstanding customer, sorted oldest first

#### 2. `_submitPayment()`

Process pembayaran dengan distribusi ke multiple transaksi:

- Validasi form
- Get user ID dari auth provider
- Show confirmation dialog
- Loop transaksi dan distribute payment
- Update setiap transaksi via API
- Show success dialog
- Navigate back dengan result = true

#### 3. `_showConfirmationDialog()`

Calculate preview:

- Berapa transaksi akan diupdate
- Berapa transaksi akan lunas
- Display detail pembayaran

#### 4. `_showSuccessDialog()`

Display hasil pembayaran:

- Jumlah transaksi yang diupdate
- Jumlah transaksi yang lunas

## Files Modified/Created

### Created:

- ✅ `/lib/features/customers/pages/customer_payment_page.dart`

### Modified:

- ✅ `/lib/features/customers/pages/customer_outstanding_detail_page.dart`
  - Added FAB
  - Added refresh callback
  - Import customer_payment_page.dart

## Testing Checklist

- [ ] Test payment untuk 1 transaksi (full payment)
- [ ] Test payment untuk multiple transaksi (full payment)
- [ ] Test payment partial (tidak cukup melunasi semua)
- [ ] Test validation (nominal = 0)
- [ ] Test validation (nominal > total utang)
- [ ] Test konfirmasi dialog cancel
- [ ] Test konfirmasi dialog confirm
- [ ] Test error handling (network error)
- [ ] Test auto-refresh setelah payment
- [ ] Test semua payment methods
- [ ] Test dengan/tanpa catatan

## Future Enhancements

1. **Print Receipt** setelah pembayaran berhasil
2. **Payment History** per customer
3. **Reminder** untuk customer dengan utang > X hari
4. **Partial Payment Strategy**:
   - Option: Bayar transaksi tertua dulu (current)
   - Option: Bayar transaksi terbesar dulu
   - Option: Pilih manual transaksi mana yang mau dibayar
5. **Bulk Payment** untuk multiple customers sekaligus
6. **Export** laporan pembayaran ke PDF/Excel

## Notes

- Payment distribution menggunakan strategi **oldest-first** (FIFO)
- API endpoint `updateTransactionPayment` hanya menerima array payment baru, tidak perlu merge dengan existing payments di client side
- Status transaksi otomatis berubah ke 'completed' jika outstanding_amount <= 0
- User ID didapat dari AuthProvider untuk tracking siapa yang melakukan pembayaran
