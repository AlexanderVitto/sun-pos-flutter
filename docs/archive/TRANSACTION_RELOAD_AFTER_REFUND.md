# Transaction Reload After Refund - Implementation Summary

## Overview

Menambahkan fitur reload otomatis data transaksi setelah proses refund berhasil, sehingga UI akan ter-update dengan data terbaru (returned_qty, remaining_qty, dan tombol refund).

## Changes Made

### File: `lib/features/dashboard/presentation/pages/transaction_detail_page.dart`

#### **Updated Method**: `_navigateToRefund()`

**Before**:

```dart
final result = await Navigator.push<bool>(
  context,
  MaterialPageRoute(
    builder: (context) => CreateRefundPage(transaction: _transactionData!),
  ),
);

// Reload transaction if refund was created successfully
if (result == true && mounted) {
  await _loadTransactionDetails();
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Silakan cek tab Refund untuk melihat data refund'),
      backgroundColor: Colors.green,
    ),
  );
}
```

**After**:

```dart
final result = await Navigator.push<bool>(
  context,
  MaterialPageRoute(
    builder: (context) => CreateRefundPage(transaction: _transactionData!),
  ),
);

// Reload transaction if refund was created successfully
if (result == true && mounted) {
  // Show loading indicator
  setState(() {
    _isLoadingItems = true;
  });

  // Force reload transaction details
  await _loadTransactionDetails();

  // Show success message
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(LucideIcons.checkCircle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text('Refund berhasil! Data transaksi diperbarui'),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
```

## Implementation Details

### **1. Loading State**

```dart
setState(() {
  _isLoadingItems = true;
});
```

- Menampilkan loading indicator saat reload
- User mendapat feedback visual bahwa data sedang diperbarui

### **2. Force Reload**

```dart
await _loadTransactionDetails();
```

- Memanggil API `GET /transactions/{id}` untuk mendapat data terbaru
- Update semua state variables:
  - `_transactionData` - Full transaction data
  - `_transactionItems` - List of items dengan returned_qty & remaining_qty terbaru
  - `_paymentHistories` - Payment histories
  - `_cartItems` - Cart items for refund

### **3. UI Auto-Update**

Setelah reload, UI akan otomatis update karena:

```dart
// Tombol refund akan hilang jika tidak ada refundable items
if (_transactionData != null && _transactionData!.hasRefundableItems) {
  // Show refund button
}

// Item detail akan menampilkan badge returned_qty & remaining_qty terbaru
if (item.returnedQty > 0) {
  // Show returned badge
}
```

### **4. Success Message**

```dart
SnackBar(
  content: Row(
    children: [
      Icon(LucideIcons.checkCircle, color: Colors.white),
      SizedBox(width: 8),
      Expanded(
        child: Text('Refund berhasil! Data transaksi diperbarui'),
      ),
    ],
  ),
  backgroundColor: Colors.green,
  behavior: SnackBarBehavior.floating,
)
```

- User mendapat konfirmasi bahwa refund berhasil
- Pesan lebih informatif dibanding sebelumnya

## User Flow

### **Complete Refund Flow**:

```
Transaction Detail Page
         ↓
   Click "Refund Item"
         ↓
   CreateRefundPage
         ↓
   Select items & quantities
         ↓
   Submit Refund
         ↓
   API Call: POST /refunds
         ↓
   Success → return true
         ↓
   Back to Transaction Detail
         ↓
   Show Loading Indicator ⏳
         ↓
   API Call: GET /transactions/{id} 🔄
         ↓
   Update State Variables
         ↓
   Rebuild UI ✨
         ↓
   Show Success Message ✅
```

## What Gets Updated After Reload

### **1. Transaction Items**:

```dart
_transactionItems = updated items with:
  - returnedQty: Increased by refund quantity
  - remainingQty: Decreased by refund quantity
```

### **2. Transaction Data**:

```dart
_transactionData = updated with:
  - hasRefundableItems: Recalculated
  - details: Updated returnedQty & remainingQty
  - paymentHistories: Latest payment data
```

### **3. UI Components**:

- ✅ **Item Badges**: "Refund: Nx" and "Sisa: Nx" updated
- ✅ **Refund Button**: Hidden if no more refundable items
- ✅ **Item List**: Shows latest quantities
- ✅ **Transaction Status**: May change if affected

## Example Scenario

### **Before Refund**:

```
Item: Product A
Quantity: 10x
Returned: 0x
Remaining: 10x
→ Refund button: VISIBLE ✓
```

### **After Refund (5 items)**:

```
Item: Product A
Quantity: 10x
Returned: 5x ← UPDATED
Remaining: 5x ← UPDATED
→ Refund button: VISIBLE ✓ (still can refund 5 more)
```

### **After Full Refund (10 items total)**:

```
Item: Product A
Quantity: 10x
Returned: 10x ← UPDATED
Remaining: 0x ← UPDATED
→ Refund button: HIDDEN ✗ (no more items to refund)
```

## Benefits

1. ✅ **Real-time Data**: User langsung melihat perubahan setelah refund
2. ✅ **Accurate UI**: Badge dan tombol sesuai dengan data terbaru
3. ✅ **Better UX**: Loading indicator memberi feedback visual
4. ✅ **Prevent Errors**: Tombol refund otomatis hilang jika sudah tidak ada item yang bisa direfund
5. ✅ **Consistency**: Data di detail page selalu sinkron dengan backend

## Edge Cases Handled

### **1. No Mounted Context**:

```dart
if (mounted) {
  ScaffoldMessenger.of(context).showSnackBar(...);
}
```

- Cek mounted sebelum show snackbar
- Prevent error jika widget sudah disposed

### **2. Null Transaction Data**:

```dart
if (_transactionData == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Data transaksi belum dimuat'),
      backgroundColor: Colors.red,
    ),
  );
  return;
}
```

- Guard clause untuk prevent null error

### **3. API Error During Reload**:

```dart
try {
  setState(() {
    _isLoadingItems = true;
    _errorMessage = null;
  });

  final response = await _apiService.getTransaction(widget.transaction.id);
  // ... process response

} catch (e) {
  setState(() {
    _isLoadingItems = false;
    _errorMessage = e.toString().replaceAll('Exception: ', '');
  });
}
```

- Error handling sudah ada di `_loadTransactionDetails()`
- User akan melihat error message jika reload gagal

## Testing Checklist

- [ ] Refund item partially → Data updated correctly
- [ ] Refund item fully → Refund button hidden
- [ ] Refund multiple items → All items updated
- [ ] Reload shows loading indicator
- [ ] Success message displays correctly
- [ ] Badge "Refund" shows correct quantity
- [ ] Badge "Sisa" shows correct remaining quantity
- [ ] Tombol refund muncul/hilang sesuai remaining_qty
- [ ] Error handling jika API reload gagal
- [ ] No mounted error after navigation

## Related Files

### **Modified**:

- `lib/features/dashboard/presentation/pages/transaction_detail_page.dart`

### **Dependencies**:

- `lib/features/refunds/presentation/pages/create_refund_page.dart` - Returns boolean result
- `lib/features/transactions/data/services/transaction_api_service.dart` - getTransaction API
- `lib/features/transactions/data/models/create_transaction_response.dart` - hasRefundableItems getter

## Notes

- ✅ Reload hanya dilakukan jika refund berhasil (`result == true`)
- ✅ Loading state ditampilkan saat reload untuk UX yang lebih baik
- ✅ Success message lebih informatif
- ✅ UI otomatis ter-update karena setState dan rebuild
- ✅ Tombol refund conditional based on `hasRefundableItems`

---

**Implementation Date**: October 10, 2025
**Status**: ✅ Complete
**Version**: 1.0.1
