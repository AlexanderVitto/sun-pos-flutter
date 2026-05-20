# Customer Outstanding Detail Feature

## Overview

Fitur untuk menampilkan detail transaksi outstanding dari setiap pelanggan yang memiliki hutang. Halaman ini menampilkan daftar transaksi beserta status pembayaran, jumlah hutang, dan informasi penting lainnya.

## Implementation Date

December 8, 2025

## Features Implemented

### 1. **API Integration**

- ✅ Updated `TransactionApiService` to support `customerId` parameter
- ✅ Endpoint: `GET /api/v1/transactions?status=outstanding&customer_id={id}`
- ✅ Pagination support with infinite scroll
- ✅ Pull-to-refresh functionality

### 2. **Customer Outstanding Detail Page**

- ✅ **Customer Header Card** - Displays customer information with gradient design
  - Customer name and phone
  - Total outstanding amount
  - Total transaction amount
  - Transaction count
- ✅ **Transaction List** - Shows all outstanding transactions
  - Transaction number
  - Transaction date and time
  - Item count
  - Total amount and outstanding amount
  - Payment progress bar with percentage
  - Fully paid indicator (LUNAS badge)
  - Outstanding reminder date
  - Transaction notes (if available)

### 3. **Navigation**

- ✅ Tap on customer card in Outstanding Customers Page
- ✅ Navigate to Customer Outstanding Detail Page
- ✅ Smooth transition with Material page route

## Files Modified

### 1. `/lib/features/transactions/data/services/transaction_api_service.dart`

**Changes:**

- Added `customerId` parameter to `getTransactions()` method
- Allows filtering transactions by specific customer

```dart
Future<TransactionListResponse> getTransactions({
  int page = 1,
  int perPage = 10,
  String? search,
  int? storeId,
  int? userId,
  int? customerId,  // ← NEW PARAMETER
  String? dateFrom,
  String? dateTo,
  double? minAmount,
  double? maxAmount,
  String? sortBy,
  String? sortDirection,
  String? paymentMethod,
  String? status,
})
```

## Files Created

### 1. `/lib/features/customers/pages/customer_outstanding_detail_page.dart`

**Purpose:** Display detailed list of outstanding transactions for a specific customer

**Key Components:**

- `CustomerOutstandingDetailPage` - Main stateful widget
- `_buildCustomerHeader()` - Customer info card with statistics
- `_buildTransactionsList()` - List of transactions with infinite scroll
- `_buildTransactionCard()` - Individual transaction card with payment details

**Features:**

- Pull-to-refresh
- Infinite scroll pagination
- Loading states
- Empty state handling
- Error handling with retry
- Payment progress visualization
- Fully paid indicator
- Reminder date display
- Transaction notes display

### 2. `/lib/features/customers/pages/outstanding_customers_page.dart`

**Changes:**

- Added import for `CustomerOutstandingDetailPage`
- Updated `onTap` handler in `_buildCustomerCard()` to navigate to detail page

## UI Design

### Customer Header Card

- Gradient background (Indigo to Purple)
- Customer avatar with initial
- Customer name and phone
- Three statistics columns:
  1. Total Hutang (Outstanding Amount)
  2. Total Transaksi (Total Transaction Amount)
  3. Jumlah (Transaction Count)

### Transaction Card

- Gradient white background with border
- Status icon (Red alert for outstanding, Green check for fully paid)
- Transaction number and date
- Item count
- Amount details (Total vs Outstanding)
- Payment progress bar with percentage
- Color-coded progress (Green ≥50%, Orange <50%)
- LUNAS badge for fully paid transactions
- Reminder date with bell icon
- Notes section with file icon

## API Response Structure

### Endpoint

```
GET /api/v1/transactions?status=outstanding&customer_id=3
```

### Response Fields Used

```json
{
  "id": 110,
  "transaction_number": "TRX20251128JL1JWD",
  "date": "2025-11-28 03:28:19",
  "total_amount": 20000000,
  "total_paid": 0,
  "change_amount": 0,
  "outstanding_amount": 20000000,
  "is_fully_paid": false,
  "status": "outstanding",
  "notes": null,
  "transaction_date": "2025-11-28T11:29:24.000000Z",
  "outstanding_reminder_date": "2025-11-28T00:00:00.000000Z",
  "details_count": 2
}
```

## User Experience Flow

1. User opens "Pelanggan Berhutang" page
2. User sees list of customers with outstanding debts
3. User taps on a customer card
4. Navigation to Customer Outstanding Detail Page
5. User sees:
   - Customer summary at top
   - List of outstanding transactions below
6. User can:
   - Pull to refresh data
   - Scroll down to load more transactions
   - Tap transaction card (ready for future implementation)

## Visual Elements

### Colors Used

- **Primary Gradient:** Indigo (#6366f1) to Purple (#8b5cf6)
- **Outstanding:** Red (#ef4444) gradient
- **Fully Paid:** Green (#10b981) gradient
- **Warning (Reminder):** Amber (#f59e0b)
- **Background:** Slate (#f8fafc)

### Icons Used (Lucide Icons)

- `alertCircle` - Outstanding transactions
- `checkCircle` - Fully paid transactions
- `phone` - Phone number
- `shoppingCart` - Transaction count
- `receipt` - Total transaction
- `calendar` - Date
- `package` - Item count
- `bell` - Reminder
- `fileText` - Notes

## Benefits

1. **Detailed View** - Complete transaction history per customer
2. **Payment Tracking** - Visual progress of payment status
3. **Quick Overview** - Summary statistics at top
4. **Status Clarity** - Clear indication of fully paid vs outstanding
5. **Reminder System** - Display upcoming payment reminders
6. **Contextual Info** - Show transaction notes when available
7. **Smooth UX** - Infinite scroll with pull-to-refresh

## Future Enhancements

Potential features to add:

- [ ] Filter transactions by date range
- [ ] Sort by amount or date
- [ ] Export transaction list
- [ ] Payment action from detail page
- [ ] WhatsApp reminder directly from card
- [ ] Transaction detail view on tap
- [ ] Print transaction receipt

## Technical Notes

- Uses existing `TransactionApiService` to avoid code redundancy
- Leverages `TransactionListResponse` model (already implemented)
- Maintains consistency with existing transaction list UI patterns
- Implements infinite scroll for large transaction lists
- Proper error handling and loading states
- Responsive design with proper spacing and shadows

## Testing Checklist

- [x] Customer header displays correct information
- [x] Transaction list loads successfully
- [x] Pagination works correctly
- [x] Pull-to-refresh updates data
- [x] Empty state shown when no transactions
- [x] Error state with retry button
- [x] Fully paid indicator shows correctly
- [x] Payment progress bar accurate
- [x] Reminder date displays properly
- [x] Notes section shows when available
- [x] Navigation from customer list works
- [x] No code redundancy (reuses existing services)

## Code Quality

- ✅ No compilation errors
- ✅ No unused imports
- ✅ Proper null safety
- ✅ Consistent naming conventions
- ✅ Reusable code patterns
- ✅ Clean separation of concerns
- ✅ Proper error handling
- ✅ Efficient pagination
