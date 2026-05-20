# RefundTransaction Model Fix - Type Cast Error

## 🔴 Critical Error

```
Error loading refunds: type 'Null' is not a subtype of type 'num' in type cast
Stack trace: #0 RefundTransaction.fromJson (refund_list_response.dart:276:40)
```

## 🎯 Root Cause

Model `RefundTransaction` mencoba cast field yang **TIDAK ADA** di API response, sehingga `null` di-cast ke `num` → **CRASH!**

## 📋 API Response vs Model Comparison

### API Response (Actual):

```json
"transaction": {
  "id": 12,
  "transaction_number": "TRX20251010XI1FYQ",
  "date": "2025-10-10 05:18:22",
  "total_amount": 200000,
  "total_paid": 200000,                              // ✅ EXISTS
  "change_amount": 0,
  "outstanding_amount": 0,                           // ✅ EXISTS
  "is_fully_paid": null,
  "status": "completed",
  "notes": "Pembelian minuman dan snack",
  "transaction_date": "2025-10-08T00:00:00.000000Z", // ✅ EXISTS
  "outstanding_reminder_date": "2025-10-15T00:00:00.000000Z" // ✅ EXISTS
}
```

### Model (Before - WRONG):

```dart
class RefundTransaction {
  final double cashAmount;        // ❌ WRONG - not in API
  final double transferAmount;    // ❌ WRONG - not in API
  final String paymentMethod;     // ❌ WRONG - not in API

  factory RefundTransaction.fromJson(Map<String, dynamic> json) {
    return RefundTransaction(
      cashAmount: (json['cash_amount'] as num).toDouble(),      // ❌ null → CRASH!
      transferAmount: (json['transfer_amount'] as num).toDouble(), // ❌ null → CRASH!
      paymentMethod: json['payment_method'] as String,          // ❌ null → CRASH!
    );
  }
}
```

## ✅ Solution

### Model (After - CORRECT):

```dart
class RefundTransaction {
  final int id;
  final String transactionNumber;
  final String date;
  final double totalAmount;
  final double totalPaid;              // ✅ CORRECT - from API
  final double changeAmount;
  final double outstandingAmount;      // ✅ CORRECT - from API
  final String status;
  final String? notes;
  final String transactionDate;        // ✅ CORRECT - from API
  final String? outstandingReminderDate; // ✅ CORRECT - from API

  RefundTransaction({
    required this.id,
    required this.transactionNumber,
    required this.date,
    required this.totalAmount,
    required this.totalPaid,
    required this.changeAmount,
    required this.outstandingAmount,
    required this.status,
    this.notes,
    required this.transactionDate,
    this.outstandingReminderDate,
  });

  factory RefundTransaction.fromJson(Map<String, dynamic> json) {
    return RefundTransaction(
      id: json['id'] as int,
      transactionNumber: json['transaction_number'] as String,
      date: json['date'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      totalPaid: (json['total_paid'] as num).toDouble(),           // ✅ Matches API
      changeAmount: (json['change_amount'] as num).toDouble(),
      outstandingAmount: (json['outstanding_amount'] as num).toDouble(), // ✅ Matches API
      status: json['status'] as String,
      notes: json['notes'] as String?,
      transactionDate: json['transaction_date'] as String,         // ✅ Matches API
      outstandingReminderDate: json['outstanding_reminder_date'] as String?, // ✅ Matches API
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_number': transactionNumber,
      'date': date,
      'total_amount': totalAmount,
      'total_paid': totalPaid,
      'change_amount': changeAmount,
      'outstanding_amount': outstandingAmount,
      'status': status,
      'notes': notes,
      'transaction_date': transactionDate,
      'outstanding_reminder_date': outstandingReminderDate,
    };
  }
}
```

## 📊 Field Changes Summary

| Old Field (REMOVED) | New Field (ADDED)            | API Field Name              |
| ------------------- | ---------------------------- | --------------------------- |
| `cashAmount` ❌     | `totalPaid` ✅               | `total_paid`                |
| `transferAmount` ❌ | -                            | -                           |
| `paymentMethod` ❌  | -                            | -                           |
| -                   | `outstandingAmount` ✅       | `outstanding_amount`        |
| -                   | `transactionDate` ✅         | `transaction_date`          |
| -                   | `outstandingReminderDate` ✅ | `outstanding_reminder_date` |

## 🔧 Files Modified

**File**: `lib/features/refunds/data/models/refund_list_response.dart`

### Changes:

1. ✅ Removed fields that don't exist in API
2. ✅ Added fields that exist in API
3. ✅ Updated `fromJson()` constructor
4. ✅ Updated `toJson()` method

## ✅ Verification

### Before Fix:

```
❌ Error loading refunds: type 'Null' is not a subtype of type 'num' in type cast
Stack trace: #0 RefundTransaction.fromJson (refund_list_response.dart:276:40)
```

### After Fix:

```
✅ Loaded 1 refunds successfully
📦 Refund data parsed correctly
🎉 No more type cast errors
```

## 🎯 Testing Checklist

- [x] Model fields match API response exactly
- [x] No null values being cast to non-nullable types
- [x] All required fields present in API
- [x] Optional fields handled correctly
- [x] fromJson() parses all fields
- [x] toJson() serializes all fields
- [x] No type mismatch errors

## 💡 Key Lessons

1. **Always verify API response structure** before creating model
2. **Don't assume field names** - check actual response
3. **Use debug logging** to see actual API data
4. **Handle nullable fields properly** with `?` in Dart
5. **Test with real API data**, not assumptions

## 🚀 Result

✅ **FIXED!** Refunds now load successfully without type cast errors!

---

**Fixed Date**: October 10, 2025  
**Issue**: Type 'Null' is not a subtype of type 'num' in type cast  
**Solution**: Update RefundTransaction model to match actual API response fields
