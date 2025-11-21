# Cash Amount Validation Fix

## 📋 Overview

Implementasi validasi untuk memastikan `cashAmount` yang dikirim ke server tidak melebihi total harga item pada saat pembayaran.

## 🎯 Problem Statement

Sebelumnya, pada saat `handleConfirmPayment`, cash amount yang dikirim ke server bisa melebihi total harga item. Ini terjadi karena:

- User bisa memasukkan nilai pembayaran yang lebih besar dari total (untuk kembalian)
- Tidak ada validasi yang membatasi nilai yang dikirim ke server
- Server hanya perlu menerima nilai transaksi sebenarnya, bukan jumlah uang yang dibayarkan customer

## ✅ Solution Implementation

### 1. Cash Payment Method

Untuk pembayaran dengan metode **cash**:

```dart
if (_selectedPaymentMethod == 'cash') {
  // Parse amount paid from input
  final amountPaid = DecimalTextInputFormatter.parseDecimal(
    _amountPaidController.text,
  ) ?? 0.0;

  // Cap cash amount to not exceed total
  cashAmount = amountPaid > calculatedTotal ? calculatedTotal : amountPaid;
  transferAmount = 0.0;
}
```

**Logic:**

- Parse nilai yang diinput user
- Jika `amountPaid` > `calculatedTotal`, gunakan `calculatedTotal` sebagai `cashAmount`
- Jika `amountPaid` ≤ `calculatedTotal`, gunakan `amountPaid` sebagai `cashAmount`
- Transfer amount selalu 0 untuk cash payment

**Contoh:**

- Total harga: Rp 100.000
- Customer bayar: Rp 150.000
- Cash amount ke server: Rp 100.000 ✅ (bukan Rp 150.000)

### 2. Bank Transfer - Partial Payment

Untuk pembayaran **bank transfer** dengan tipe **partial** (sebagian cash, sebagian transfer):

```dart
if (_bankTransferType == 'partial') {
  // Parse both cash and transfer amounts
  final cash = DecimalTextInputFormatter.parseDecimal(
    _cashAmountController.text,
  ) ?? 0.0;
  final transfer = DecimalTextInputFormatter.parseDecimal(
    _transferAmountController.text,
  ) ?? 0.0;

  // Cap total payment to not exceed total amount
  final totalPayment = cash + transfer;
  if (totalPayment > calculatedTotal) {
    // Proportionally reduce both amounts
    final ratio = calculatedTotal / totalPayment;
    cashAmount = cash * ratio;
    transferAmount = transfer * ratio;
  } else {
    cashAmount = cash;
    transferAmount = transfer;
  }
}
```

**Logic:**

- Hitung total pembayaran (`cash + transfer`)
- Jika total pembayaran > total harga:
  - Hitung ratio: `calculatedTotal / totalPayment`
  - Kurangi proporsional kedua nilai menggunakan ratio
- Jika total pembayaran ≤ total harga, gunakan nilai asli

**Contoh:**

- Total harga: Rp 100.000
- User input cash: Rp 70.000
- User input transfer: Rp 50.000
- Total payment: Rp 120.000 (melebihi total)
- Ratio: 100.000 / 120.000 = 0.833
- Cash amount ke server: Rp 58.310 (70.000 × 0.833) ✅
- Transfer amount ke server: Rp 41.650 (50.000 × 0.833) ✅
- Total ke server: Rp 99.960 ≈ Rp 100.000 ✅

### 3. Bank Transfer - Full Payment

Untuk pembayaran **bank transfer** dengan tipe **full**:

```dart
} else {
  // For full payment, transfer amount = total amount, cash = 0
  cashAmount = 0.0;
  transferAmount = calculatedTotal;
}
```

**Logic:**

- Cash amount = 0
- Transfer amount = total harga (menggunakan `calculatedTotal`)

## 🔧 Technical Changes

### Modified File

- **File:** `lib/features/sales/presentation/pages/payment_confirmation_page.dart`
- **Method:** `_handleConfirmPayment()`
- **Lines:** ~428-470 (payment amount calculation logic)

### Key Changes

1. ✅ Menghitung `calculatedTotal` terlebih dahulu menggunakan `_calculateTotalWithEditedPrices()`
2. ✅ Validasi cash payment: cap to calculated total
3. ✅ Validasi partial payment: proportional reduction jika melebihi total
4. ✅ Full transfer payment: menggunakan calculated total, bukan `widget.totalAmount`

## 📊 Before vs After

### Before ❌

```dart
if (_selectedPaymentMethod == 'cash') {
  cashAmount = DecimalTextInputFormatter.parseDecimal(
    _amountPaidController.text,
  );
  transferAmount = 0.0;
}
```

**Problem:** `cashAmount` bisa melebihi total harga

### After ✅

```dart
if (_selectedPaymentMethod == 'cash') {
  final amountPaid = DecimalTextInputFormatter.parseDecimal(
    _amountPaidController.text,
  ) ?? 0.0;

  cashAmount = amountPaid > calculatedTotal ? calculatedTotal : amountPaid;
  transferAmount = 0.0;
}
```

**Solution:** `cashAmount` di-cap tidak melebihi `calculatedTotal`

## 🧪 Testing Scenarios

### Cash Payment

1. **Scenario 1:** Amount paid < Total

   - Total: Rp 100.000
   - Paid: Rp 80.000
   - Expected: cashAmount = Rp 80.000 ✅

2. **Scenario 2:** Amount paid = Total

   - Total: Rp 100.000
   - Paid: Rp 100.000
   - Expected: cashAmount = Rp 100.000 ✅

3. **Scenario 3:** Amount paid > Total
   - Total: Rp 100.000
   - Paid: Rp 150.000
   - Expected: cashAmount = Rp 100.000 ✅ (capped)

### Partial Payment

4. **Scenario 4:** Total payment < Total

   - Total: Rp 100.000
   - Cash: Rp 40.000, Transfer: Rp 30.000
   - Expected: cashAmount = Rp 40.000, transferAmount = Rp 30.000 ✅

5. **Scenario 5:** Total payment = Total

   - Total: Rp 100.000
   - Cash: Rp 60.000, Transfer: Rp 40.000
   - Expected: cashAmount = Rp 60.000, transferAmount = Rp 40.000 ✅

6. **Scenario 6:** Total payment > Total
   - Total: Rp 100.000
   - Cash: Rp 70.000, Transfer: Rp 50.000
   - Expected: Proportional reduction applied ✅

### Full Transfer

7. **Scenario 7:** Full bank transfer
   - Total: Rp 100.000
   - Expected: cashAmount = Rp 0, transferAmount = Rp 100.000 ✅

## 🎯 Benefits

1. **Data Integrity:** Server hanya menerima nilai transaksi yang valid
2. **Accurate Reporting:** Laporan keuangan akurat karena jumlah pembayaran sesuai total
3. **Business Logic:** Memisahkan konsep "uang yang dibayarkan customer" vs "nilai transaksi"
4. **User Experience:** User tetap bisa input nilai lebih besar untuk kembalian, tapi backend menerima nilai yang benar
5. **Proportional Handling:** Partial payment yang melebihi total dikurangi secara proporsional untuk fairness

## 📝 Related Files

- `lib/features/sales/presentation/pages/payment_confirmation_page.dart` - Main implementation
- `lib/core/utils/decimal_text_input_formatter.dart` - Decimal parsing utility

## 🔗 Related Documentation

- `ENHANCED_PAYMENT_DIALOG_IMPLEMENTATION.md` - Payment dialog features
- `CUSTOMER_BASED_PRODUCT_PRICING.md` - Product pricing logic

---

**Implementation Date:** 2025-01-XX  
**Status:** ✅ Implemented & Tested  
**Impact:** High - Affects all payment processing
