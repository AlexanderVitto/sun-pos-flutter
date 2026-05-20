# Outstanding Display Amount Change - Implementation Summary

## Overview

Mengubah tampilan informasi pada transaksi dengan status "outstanding" dari menampilkan tanggal jatuh tempo menjadi menampilkan jumlah utang yang belum dibayarkan.

## Changes Made

### File: `lib/features/dashboard/presentation/widgets/transaction_tab_page.dart`

#### 1. Updated Transaction Card Display Logic

**Location**: Method `_buildTransactionCard` (line ~685-692)

**Before**:

```dart
// Outstanding reminder date section (only for outstanding transactions)
if (transaction.status.toLowerCase() == 'outstanding' &&
    transaction.outstandingReminderDate != null) ...[
  _buildOutstandingReminder(transaction),
  const SizedBox(height: 12),
],
```

**After**:

```dart
// Outstanding amount section (only for outstanding transactions)
if (transaction.status.toLowerCase() == 'outstanding') ...[
  _buildOutstandingAmount(transaction),
  const SizedBox(height: 12),
],
```

**Changes**:

- ✅ Removed condition check for `outstandingReminderDate != null`
- ✅ Now displays outstanding amount for ALL outstanding transactions
- ✅ Replaced `_buildOutstandingReminder` with `_buildOutstandingAmount`

#### 2. New Method: `_buildOutstandingAmount`

**Location**: Added after `_buildTransactionCard` method (line ~752)

```dart
Widget _buildOutstandingAmount(TransactionListItem transaction) {
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
        width: 1,
      ),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            LucideIcons.alertCircle,
            size: 16,
            color: Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jumlah Utang',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                currencyFormat.format(transaction.outstandingAmount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'BELUM DIBAYAR',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B5CF6),
            ),
          ),
        ),
      ],
    ),
  );
}
```

**Features**:

- ✅ Purple theme (`Color(0xFF8B5CF6)`) matching outstanding status
- ✅ Alert circle icon to indicate unpaid debt
- ✅ Large, bold display of outstanding amount
- ✅ "BELUM DIBAYAR" badge for quick visual identification
- ✅ Currency formatting with Indonesian Rupiah format
- ✅ Clean and modern card design with rounded corners

#### 3. Removed Method: `_buildOutstandingReminder`

**Removed**: The entire method that displayed due date information with countdown timers

**Reason**: Replaced with simpler outstanding amount display

## UI/UX Changes

### Before:

- Showed complex countdown information (overdue, due today, due tomorrow, future date)
- Different colors based on urgency (red for overdue, orange for today, yellow for tomorrow, blue for future)
- Required `outstandingReminderDate` to be set
- Showed detailed time information (hours left, days left, etc.)

### After:

- Shows clear, simple outstanding amount in purple card
- Single consistent design for all outstanding transactions
- Always visible when status is "outstanding"
- Focused on the financial amount rather than time
- "BELUM DIBAYAR" badge for quick recognition

## Visual Design

### Card Design:

```
┌─────────────────────────────────────────────────────────┐
│  [🔔]  Jumlah Utang            [BELUM DIBAYAR]          │
│        Rp 150.000                                        │
└─────────────────────────────────────────────────────────┘
```

### Color Scheme:

- **Background**: Purple with 10% opacity (`#8B5CF6` with alpha 0.1)
- **Border**: Purple with 30% opacity
- **Icon Background**: Purple with 20% opacity
- **Text**: Solid purple (`#8B5CF6`)
- **Badge Background**: Purple with 10% opacity

## Data Source

The outstanding amount is retrieved from:

```dart
transaction.outstandingAmount
```

This field is part of the `TransactionListItem` model from:

- `lib/features/transactions/data/models/transaction_list_response.dart`

## Benefits

1. **Clarity**: Users immediately see how much money is owed
2. **Simplicity**: Removed complex time-based logic
3. **Consistency**: Same display for all outstanding transactions
4. **Financial Focus**: Emphasizes the monetary aspect rather than time urgency
5. **Better UX**: Less mental load - just show the amount that needs to be paid

## Testing Checklist

- [ ] Outstanding transactions display the purple card with amount
- [ ] Amount is formatted correctly in Indonesian Rupiah
- [ ] "BELUM DIBAYAR" badge is visible
- [ ] Card appears for ALL outstanding transactions
- [ ] Card does NOT appear for pending/completed/refund transactions
- [ ] Amount matches the actual outstanding amount from API
- [ ] UI is responsive and looks good on different screen sizes

## Related Files

- `lib/features/transactions/data/models/transaction_list_response.dart` - Contains `outstandingAmount` field
- `lib/features/dashboard/presentation/widgets/transaction_tab_page.dart` - Main implementation file

## Notes

- The old `_buildOutstandingReminder` method with due date logic has been completely removed
- The change focuses on financial information rather than time-based reminders
- The purple color theme matches the "Outstanding" status badge color
- Currency formatting uses `NumberFormat.currency` with Indonesian locale

---

**Implementation Date**: October 10, 2025
**Status**: ✅ Complete
