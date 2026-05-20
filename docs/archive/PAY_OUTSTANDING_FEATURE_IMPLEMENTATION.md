# Pay Outstanding Feature - Implementation Summary

## Overview

Fitur pembayaran utang yang memungkinkan user untuk melakukan pembayaran cicilan atau pelunasan transaksi yang berstatus "outstanding".

## Features Implemented

### 1. New Page: `PayOutstandingPage`

**Location**: `lib/features/transactions/presentation/pages/pay_outstanding_page.dart`

#### **UI Components**:

1. **Transaction Header**

   - Nomor transaksi
   - Status "Outstanding" dengan warna orange
   - Tanggal transaksi

2. **Outstanding Summary**

   - Total Transaksi
   - Sudah Dibayar
   - Sisa Utang (highlighted in red)

3. **Payment History** (if exists)

   - List riwayat pembayaran sebelumnya
   - Menampilkan metode, nominal, dan tanggal

4. **Payment Input Section**

   - Pilihan metode pembayaran (chips)
   - Input nominal pembayaran
   - Input catatan (optional)
   - Validasi: nominal tidak boleh > sisa utang

5. **Confirmation Dialog**
   - Menampilkan ringkasan pembayaran
   - Total yang akan dibayar
   - Sisa utang setelah pembayaran
   - Status: "LUNAS" jika pelunasan

#### **Key Features**:

```dart
class PayOutstandingPage extends StatefulWidget {
  final TransactionData transaction;

  // Features:
  // ✅ Auto-calculate outstanding amount
  // ✅ Payment method selection
  // ✅ Amount validation
  // ✅ Confirmation dialog
  // ✅ Auto status update to "completed" if fully paid
}
```

#### **Payment Logic**:

1. **Calculate Outstanding**:

   ```dart
   _totalPaid = paymentHistories.fold(0, (sum, p) => sum + p.amount);
   _outstandingAmount = totalAmount - _totalPaid;
   ```

2. **Validation**:

   ```dart
   - Amount > 0
   - Amount <= Outstanding Amount
   - Payment method selected
   ```

3. **Update Request**:
   ```dart
   {
     "payments": [
       ...existingPayments,
       newPayment
     ],
     "status": newOutstanding <= 0 ? "completed" : "outstanding"
   }
   ```

### 2. API Service Enhancement

**Location**: `lib/features/transactions/data/services/transaction_api_service.dart`

#### **New Method**: `updateTransactionPayment`

```dart
Future<CreateTransactionResponse> updateTransactionPayment(
  int transactionId,
  Map<String, dynamic> paymentData,
) async {
  // PUT /api/v1/transactions/{id}
  // Only updates payments array and status
}
```

**Request Body Structure**:

```json
{
  "payments": [
    {
      "payment_method": "cash",
      "amount": 50000,
      "payment_date": "2025-10-10T10:30:00",
      "notes": "Cicilan pertama",
      "user_id": 1
    }
  ],
  "status": "outstanding" // or "completed"
}
```

**Response Handling**:

- ✅ 200: Success - returns updated TransactionData
- ✅ 401: Unauthorized
- ✅ 404: Transaction not found
- ✅ 422: Validation error
- ✅ 400: Bad request
- ✅ 500+: Server error

### 3. Navigation Integration

**Location**: `lib/features/dashboard/presentation/pages/transaction_detail_page.dart`

#### **Changes Made**:

1. **Import Added**:

   ```dart
   import '../../../transactions/presentation/pages/pay_outstanding_page.dart';
   ```

2. **New Navigation Method**:

   ```dart
   Future<void> _navigateToPayOutstanding() async {
     final result = await Navigator.push<bool>(
       context,
       MaterialPageRoute(
         builder: (context) => PayOutstandingPage(transaction: _transactionData!),
       ),
     );

     if (result == true && mounted) {
       await _loadTransactionDetails(); // Reload data
       Navigator.of(context).pop(true); // Back to list
     }
   }
   ```

3. **Button Updated**:
   ```dart
   ElevatedButton.icon(
     onPressed: () => _navigateToPayOutstanding(), // Changed from dialog
     label: Text('Bayar Utang'),
   )
   ```

## User Flow

### **Complete Payment Flow**:

```
Transaction Detail (Outstanding)
         ↓
   Click "Bayar Utang"
         ↓
   PayOutstandingPage
         ↓
   Select Payment Method
         ↓
   Enter Amount
         ↓
   Add Notes (optional)
         ↓
   Click "Proses Pembayaran"
         ↓
   Confirmation Dialog
         ↓
   Confirm "Ya, Proses"
         ↓
   API Call: PUT /transactions/{id}
         ↓
   Success Response
         ↓
   Show Success Message
         ↓
   Reload Transaction Detail
         ↓
   Pop back to Transaction List
```

### **Status Update Logic**:

1. **Outstanding → Outstanding** (Partial Payment):

   - User bayar < sisa utang
   - Status tetap "outstanding"
   - Payment ditambahkan ke history

2. **Outstanding → Completed** (Full Payment):
   - User bayar = sisa utang
   - Status berubah ke "completed"
   - Transaction lunas

## Validation Rules

### **Amount Validation**:

```dart
✅ Must be filled (> 0)
✅ Cannot exceed outstanding amount
✅ Cannot be negative
✅ Must be numeric
```

### **Payment Method**:

```dart
✅ Must select one method
✅ Options: cash, card, bank_transfer, digital_wallet, credit
```

### **Notes**:

```dart
✅ Optional field
✅ Max length: No limit (defined by API)
```

## UI/UX Design

### **Color Scheme**:

- **Outstanding**: Orange (`#EA580C`, `#F97316`)
- **Success/Paid**: Green (`#10B981`)
- **Error/Outstanding Amount**: Red (`#EF4444`)
- **Info**: Blue (`#3B82F6`)
- **Border**: Gray (`#E5E7EB`)

### **Icons Used**:

- Alert Triangle: Outstanding status
- Wallet: Outstanding summary
- History: Payment history
- Banknote: Payment input
- Check Circle: Paid/Success
- Help Circle: Confirmation dialog

### **Responsive Design**:

- ✅ Full-width cards
- ✅ Scrollable content
- ✅ Fixed bottom button
- ✅ Safe area padding

## API Integration

### **Endpoint**:

```
PUT {{base_url}}/api/v1/transactions/{id}
```

### **Headers**:

```
Content-Type: application/json
Authorization: Bearer {token}
Accept: application/json
```

### **Request Body** (Example):

```json
{
  "payments": [
    {
      "payment_method": "cash",
      "amount": 100000,
      "payment_date": "2025-10-10T14:30:00.000Z",
      "notes": null,
      "user_id": 1
    },
    {
      "payment_method": "bank_transfer",
      "amount": 50000,
      "payment_date": "2025-10-10T15:45:00.000Z",
      "notes": "Cicilan kedua",
      "user_id": 1
    }
  ],
  "status": "outstanding"
}
```

### **Success Response** (200):

```json
{
  "success": true,
  "message": "Transaction updated successfully",
  "data": {
    "id": 123,
    "transaction_number": "TRX-2025-001",
    "total_amount": 250000,
    "outstanding_amount": 100000,
    "status": "outstanding",
    "payment_histories": [...]
  }
}
```

## Error Handling

### **Frontend Validation**:

```dart
✅ Empty amount
✅ Invalid amount (< 0)
✅ Amount exceeds outstanding
✅ No payment method selected
```

### **API Error Handling**:

```dart
✅ 401: Show "Unauthorized" message
✅ 404: Show "Transaction not found"
✅ 422: Show validation errors from API
✅ 400: Show bad request message
✅ 500+: Show "Server error, try again"
✅ Network error: Show "Connection error"
```

### **User Feedback**:

- ✅ Loading indicator during API call
- ✅ Success SnackBar with green background
- ✅ Error SnackBar with red background
- ✅ Disable button while processing
- ✅ Auto-navigate back on success

## Testing Checklist

### **Functional Tests**:

- [ ] Calculate outstanding amount correctly
- [ ] Display payment history properly
- [ ] Validate amount input (min/max)
- [ ] Payment method selection works
- [ ] Confirmation dialog shows correct info
- [ ] API call with correct payload
- [ ] Status updates to "completed" when lunas
- [ ] Status stays "outstanding" for partial payment
- [ ] Success message displays correctly
- [ ] Navigation back to list on success
- [ ] Error messages display correctly

### **Edge Cases**:

- [ ] No payment history (first payment)
- [ ] Multiple payment histories
- [ ] Exact outstanding amount (full payment)
- [ ] Amount > outstanding (validation)
- [ ] Empty notes field
- [ ] Network timeout
- [ ] API error responses
- [ ] Transaction not found

### **UI/UX Tests**:

- [ ] Responsive on different screen sizes
- [ ] Scrollable when content overflows
- [ ] Bottom button always visible
- [ ] Loading state during API call
- [ ] Disabled state when invalid input
- [ ] Keyboard dismisses properly
- [ ] Form validation messages clear

## Future Enhancements

### **Potential Improvements**:

1. **Multiple Payment Methods in One Transaction**

   - Allow cash + transfer in single payment
   - Similar to partial payment in payment_confirmation_page

2. **Payment Schedule**

   - Set reminder for next payment
   - Show payment due date

3. **Payment Receipt**

   - Generate receipt for each payment
   - Email/print payment proof

4. **Payment Analytics**

   - Show payment trend
   - Average payment time

5. **Quick Amount Buttons**
   - 25%, 50%, 75%, 100% of outstanding
   - Quick access to common amounts

## Related Files

### **Modified Files**:

1. `lib/features/transactions/presentation/pages/pay_outstanding_page.dart` (NEW)
2. `lib/features/transactions/data/services/transaction_api_service.dart` (UPDATED)
3. `lib/features/dashboard/presentation/pages/transaction_detail_page.dart` (UPDATED)

### **Dependencies**:

- `lib/features/transactions/data/models/create_transaction_response.dart`
- `lib/features/transactions/data/models/payment_history.dart`
- `lib/core/constants/payment_constants.dart`
- `lib/features/auth/providers/auth_provider.dart`

## Notes

- ✅ Payment hanya menambahkan ke array `payments`, tidak menghapus/edit yang lama
- ✅ Status auto-update berdasarkan kalkulasi outstanding amount
- ✅ Validasi amount di frontend untuk UX yang lebih baik
- ✅ Confirmation dialog untuk menghindari kesalahan input
- ✅ Auto-reload data setelah pembayaran berhasil
- ✅ Support untuk semua metode pembayaran dari PaymentConstants

---

**Implementation Date**: October 10, 2025
**Status**: ✅ Complete
**Version**: 1.0.0
