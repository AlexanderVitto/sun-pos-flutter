# Payment History Display Implementation

## Overview

Menambahkan tampilan histori pembayaran pada halaman detail transaksi untuk transaksi dengan status `outstanding`, `completed`, dan `refund`. Fitur ini memberikan transparansi penuh tentang semua pembayaran yang telah dilakukan untuk suatu transaksi.

## Problem Statement

Sebelumnya, halaman detail transaksi tidak menampilkan histori pembayaran, sehingga:

- User tidak bisa melihat kapan pembayaran dilakukan
- Tidak ada informasi tentang metode pembayaran yang digunakan
- Sulit untuk tracking pembayaran cicilan untuk transaksi outstanding
- Tidak ada visualisasi progress pembayaran

## Solution

Menambahkan section "Histori Pembayaran" yang menampilkan:

1. **List semua pembayaran** dengan detail lengkap
2. **Summary pembayaran** dengan total dibayar dan sisa utang
3. **Visual indicators** untuk status pembayaran
4. **Payment method display** dengan icon yang sesuai

## Implementation Details

### 1. Data Structure

**Payment History Model** (`lib/features/transactions/data/models/payment_history.dart`):

```dart
class PaymentHistory {
  final int? id;
  final int? transactionId;
  final String paymentMethod;
  final double amount;
  final String paymentDate;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

### 2. UI Components Added

#### A. Payment History Section Container

```dart
Widget _buildPaymentHistorySection() {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with icon
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10b981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                LucideIcons.history,
                color: Color(0xFF10b981),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Histori Pembayaran',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        // Payment history items
        // Payment summary
      ],
    ),
  );
}
```

#### B. Payment History Item

**Features**:

- Payment method icon dengan warna hijau
- Payment method display dengan PaymentMethodDisplay widget
- Amount dengan format currency
- Tanggal pembayaran dengan format readable
- Notes (jika ada) dalam box abu-abu

```dart
Widget _buildPaymentHistoryItem(PaymentHistory payment, bool isLast) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      border: isLast ? null : Border(
        bottom: BorderSide(
          color: const Color(0xFFE5E7EB).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
    ),
    child: Row(
      children: [
        // Icon container (40x40) with payment method icon
        // Payment details (method, amount, date, notes)
      ],
    ),
  );
}
```

#### C. Payment Summary

**Shows**:

- Total Transaksi: Total amount dari transaksi
- Total Dibayar: Sum dari semua payment histories
- Status/Sisa Utang:
  - Jika lunas: Badge hijau "Lunas" dengan checkmark
  - Jika belum lunas: Tampilkan sisa utang dalam warna merah

```dart
Widget _buildPaymentSummary() {
  final totalPaid = _paymentHistories!.fold<double>(
    0,
    (sum, payment) => sum + payment.amount,
  );

  final outstanding = transaction.totalAmount - totalPaid;
  final isFullyPaid = outstanding <= 0;

  return Container(
    // Summary with total, paid, and outstanding/status
  );
}
```

### 3. Visibility Logic

**Method**: `_shouldShowPaymentHistory()`

```dart
bool _shouldShowPaymentHistory() {
  final status = transaction.status.toLowerCase();
  return (status == 'outstanding' ||
          status == 'completed' ||
          status == 'refund') &&
      _paymentHistories != null &&
      _paymentHistories!.isNotEmpty;
}
```

**Rules**:

- Tampilkan HANYA untuk status: `outstanding`, `completed`, `refund`
- Tampilkan HANYA jika ada payment histories
- Hide untuk status `pending` atau jika belum ada pembayaran

### 4. Payment Method Icons

```dart
IconData _getPaymentMethodIcon(String paymentMethod) {
  switch (paymentMethod.toLowerCase()) {
    case 'cash':
      return LucideIcons.banknote;
    case 'card':
    case 'credit_card':
    case 'debit_card':
      return LucideIcons.creditCard;
    case 'transfer':
    case 'bank_transfer':
      return LucideIcons.landmark;
    case 'e-wallet':
    case 'ewallet':
    case 'qris':
      return LucideIcons.smartphone;
    default:
      return LucideIcons.wallet;
  }
}
```

## UI Design

### Color Palette

| Element            | Color                   | Usage                |
| ------------------ | ----------------------- | -------------------- |
| Section Background | `#FFFFFF`               | Container background |
| Border             | `#E5E7EB`               | Container border     |
| Icon Background    | `#10b981` (10% opacity) | Icon container       |
| Icon Color         | `#10b981` (Green)       | Payment icons        |
| Amount Color       | `#10b981` (Green)       | Paid amounts         |
| Outstanding Color  | `#EF4444` (Red)         | Remaining debt       |
| Text Primary       | `#1F2937`               | Main text            |
| Text Secondary     | `#6B7280`               | Labels & dates       |
| Notes Background   | `#F3F4F6`               | Notes container      |

### Typography

| Element        | Size    | Weight | Color     |
| -------------- | ------- | ------ | --------- |
| Section Title  | 20px    | Bold   | `#1F2937` |
| Payment Method | 16px    | Normal | `#1F2937` |
| Amount         | 16px    | Bold   | `#10b981` |
| Date           | 13px    | Normal | `#6B7280` |
| Notes          | 12px    | Normal | `#6B7280` |
| Summary Label  | 14px    | Normal | `#6B7280` |
| Summary Value  | 14-18px | Bold   | Variable  |

### Layout Structure

```
┌─────────────────────────────────────────────┐
│ 📊 Histori Pembayaran                       │
├─────────────────────────────────────────────┤
│                                             │
│ 💵  Tunai               Rp 100.000         │
│     12 Oct 2025, 14:30                      │
│     [Pembayaran pertama]                    │
│ ─────────────────────────────────────────── │
│ 💳  Transfer            Rp 50.000          │
│     13 Oct 2025, 10:15                      │
│ ─────────────────────────────────────────── │
│                                             │
│ ┌─────────────────────────────────────────┐ │
│ │ Total Transaksi          Rp 200.000     │ │
│ │ Total Dibayar            Rp 150.000     │ │
│ │ ─────────────────────────────────────── │ │
│ │ Sisa Utang               Rp 50.000      │ │
│ └─────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

## Example Scenarios

### Scenario 1: Outstanding Transaction (Partial Payment)

```
Transaction:
- Total: Rp 500.000
- Status: Outstanding

Payment Histories:
1. Cash - Rp 200.000 (10 Oct 2025, 14:00)
2. Transfer - Rp 100.000 (11 Oct 2025, 10:30)

Display:
✅ Show Payment History Section
📊 Total Transaksi: Rp 500.000
💰 Total Dibayar: Rp 300.000
❌ Sisa Utang: Rp 200.000 (RED)
```

### Scenario 2: Completed Transaction (Fully Paid)

```
Transaction:
- Total: Rp 150.000
- Status: Completed

Payment Histories:
1. Cash - Rp 100.000 (10 Oct 2025, 14:00)
2. E-Wallet - Rp 50.000 (10 Oct 2025, 14:05)

Display:
✅ Show Payment History Section
📊 Total Transaksi: Rp 150.000
💰 Total Dibayar: Rp 150.000
✅ Status: Lunas (GREEN BADGE with checkmark)
```

### Scenario 3: Pending Transaction (No Payment Yet)

```
Transaction:
- Total: Rp 300.000
- Status: Pending

Payment Histories: []

Display:
❌ Hide Payment History Section
(No payment histories to display)
```

### Scenario 4: Outstanding with Notes

```
Transaction:
- Total: Rp 1.000.000
- Status: Outstanding

Payment Histories:
1. Cash - Rp 500.000 (10 Oct 2025)
   Notes: "DP awal"
2. Transfer - Rp 300.000 (15 Oct 2025)
   Notes: "Cicilan ke-1"

Display:
✅ Show Payment History Section with notes
Each payment shows notes in gray box below date
```

## Features

### 1. **Multi-Payment Support**

- Mendukung multiple pembayaran untuk satu transaksi
- Cocok untuk sistem cicilan/installment
- Tracking pembayaran bertahap untuk outstanding transactions

### 2. **Payment Method Visualization**

- Icon yang berbeda untuk setiap payment method
- Menggunakan `PaymentMethodDisplay` widget untuk consistency
- Color-coded untuk easy identification

### 3. **Summary Calculation**

- Auto-calculate total paid dari semua histories
- Calculate outstanding amount (total - paid)
- Visual indicator untuk fully paid status

### 4. **Notes Display**

- Show payment notes jika ada
- Styled dalam container abu-abu
- Italic text untuk differentiate dari info lain

### 5. **Date Formatting**

- Parse dari ISO 8601 string
- Format: "dd MMM yyyy, HH:mm" (e.g., "10 Oct 2025, 14:30")
- Localized untuk Indonesia (id_ID)

### 6. **Responsive Design**

- Sama seperti komponen lain di page
- Consistent spacing dan styling
- Shadow dan border untuk depth

## Integration Points

### 1. **Load Payment Histories**

Payment histories di-load dari API saat `_loadTransactionDetails()`:

```dart
// Store payment histories for later use
_paymentHistories = transactionData.paymentHistories;
```

### 2. **Conditional Rendering**

Section hanya muncul jika kondisi terpenuhi:

```dart
if (_shouldShowPaymentHistory()) ...[
  _buildPaymentHistorySection(),
  const SizedBox(height: 24),
],
```

### 3. **Reusable Widgets**

Menggunakan existing widgets:

- `PaymentMethodDisplay`: For consistent payment method display
- `LucideIcons`: For all icons
- `NumberFormat`: For currency formatting

## Benefits

### 1. **Transparency**

- User bisa melihat semua pembayaran yang sudah dilakukan
- Clear breakdown dari total dan sisa utang
- Timestamp untuk setiap pembayaran

### 2. **Better Tracking**

- Easy to track cicilan/installment payments
- Visual progress untuk outstanding transactions
- Notes untuk context setiap pembayaran

### 3. **User Experience**

- Informasi lengkap dalam satu page
- No need untuk cek multiple pages
- Visual indicators untuk quick understanding

### 4. **Accountability**

- Record lengkap semua pembayaran
- Audit trail untuk transaksi
- Proof of payment dengan timestamp

## Testing Checklist

- [x] Display payment history untuk status `outstanding`
- [x] Display payment history untuk status `completed`
- [x] Display payment history untuk status `refund`
- [x] Hide payment history untuk status `pending`
- [x] Hide section jika payment histories kosong
- [x] Correct calculation untuk total paid
- [x] Correct calculation untuk outstanding amount
- [x] Show "Lunas" badge ketika fully paid
- [x] Show outstanding amount dalam red ketika belum lunas
- [x] Payment method icons tampil dengan benar
- [x] Date formatting dengan locale Indonesia
- [x] Notes display (jika ada)
- [x] Responsive layout di berbagai screen sizes

## Files Modified

1. **transaction_detail_page.dart**
   - Added: `_shouldShowPaymentHistory()` method
   - Added: `_buildPaymentHistorySection()` widget
   - Added: `_buildPaymentHistoryItem()` widget
   - Added: `_buildPaymentSummary()` widget
   - Added: `_getPaymentMethodIcon()` helper method
   - Modified: `build()` method to include payment history section

## Technical Notes

### Date Parsing

```dart
final paymentDateTime = DateTime.tryParse(payment.paymentDate);
final formattedDate = paymentDateTime != null
    ? DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(paymentDateTime)
    : payment.paymentDate;
```

Uses `tryParse()` untuk handle invalid dates gracefully.

### Total Calculation

```dart
final totalPaid = _paymentHistories!.fold<double>(
  0,
  (sum, payment) => sum + payment.amount,
);
```

Uses `fold()` untuk efficient sum calculation.

### Status Check

```dart
final isFullyPaid = outstanding <= 0;
```

Uses `<= 0` untuk handle overpayment scenarios.

## Future Enhancements

Potential improvements:

1. **Print receipt** untuk specific payment
2. **Edit/Delete payment** dari history
3. **Add payment** langsung dari history section
4. **Filter/Sort** payment histories
5. **Export** payment history ke PDF/Excel
6. **Payment reminders** untuk outstanding dengan due date

---

**Implementation Date**: October 10, 2025  
**Status**: ✅ Completed  
**Tested**: ✅ Manual testing passed
