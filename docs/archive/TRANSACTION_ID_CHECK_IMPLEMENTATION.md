# Transaction ID Check Implementation

## Overview

Implementasi logic untuk mengecek apakah transaction ID sudah ada sebelum membuat atau mengupdate transaction pada method `_confirmOrder` dan `_confirmPayment` di PaymentService.

## Changes Made

### 1. Enhanced `_confirmOrder` Method

**Before**: Selalu membuat transaction baru dengan `processPayment()`
**After**: Mengecek apakah sudah ada `draftTransactionId`, jika ada maka update, jika tidak ada maka create baru.

```dart
// Check if this is an existing draft transaction that needs update
if (cartProvider.hasExistingDraftTransaction) {
  debugPrint('🔄 Updating existing draft transaction to order status. ID: ${cartProvider.draftTransactionId}');

  // Use updateTransaction method for existing draft transactions
  transactionResponse = await transactionProvider.updateTransaction(
    transactionId: cartProvider.draftTransactionId!,
    cartItems: cartProvider.items,
    totalAmount: cartProvider.total,
    notes: notesController.text.trim(),
    paymentMethod: 'cash',
    customerName: cartProvider.customerName ?? 'Customer',
    customerPhone: cartProvider.customerPhone,
    status: 'pending', // Change status from draft to pending
    cashAmount: 0,
    transferAmount: 0,
  );
} else {
  debugPrint('✨ Creating new order transaction');

  // Process new order using processPayment method
  transactionResponse = await transactionProvider.processPayment(
    cartItems: cartProvider.items,
    totalAmount: cartProvider.total,
    notes: notesController.text.trim(),
    paymentMethod: 'cash',
    customerName: cartProvider.customerName ?? 'Customer',
    customerPhone: cartProvider.customerPhone,
    status: 'pending', // Status pending for orders
    cashAmount: 0,
    transferAmount: 0,
  );
}
```

### 2. Enhanced `_confirmPayment` Method

**Before**: Selalu membuat transaction baru dengan `processPayment()`
**After**: Mengecek apakah sudah ada `draftTransactionId`, jika ada maka update, jika tidak ada maka create baru.

```dart
// Check if this is an existing draft transaction that needs update
if (cartProvider.hasExistingDraftTransaction) {
  debugPrint('🔄 Updating existing draft transaction to completed status. ID: ${cartProvider.draftTransactionId}');

  // Use updateTransaction method for existing draft transactions
  transactionResponse = await transactionProvider.updateTransaction(
    transactionId: cartProvider.draftTransactionId!,
    cartItems: cartProvider.items,
    totalAmount: cartProvider.total,
    notes: notesController.text.trim(),
    paymentMethod: 'cash',
    customerName: cartProvider.customerName ?? 'Customer',
    customerPhone: cartProvider.customerPhone,
    status: 'completed', // Change status from draft to completed
    cashAmount: cashAmount,
    transferAmount: transferAmount,
  );
} else {
  debugPrint('✨ Creating new completed transaction');

  // Process payment using processPayment method
  transactionResponse = await transactionProvider.processPayment(
    cartItems: cartProvider.items,
    totalAmount: cartProvider.total,
    notes: notesController.text.trim(),
    paymentMethod: 'cash',
    customerName: cartProvider.customerName ?? 'Customer',
    customerPhone: cartProvider.customerPhone,
    status: 'completed', // Status completed for paid transactions
    cashAmount: cashAmount,
    transferAmount: transferAmount,
  );
}
```

## Logic Flow

### Draft → Order Flow

1. **User adds items to cart** → `processDraftTransaction()` creates/updates draft
2. **User confirms order** → `_confirmOrder()` checks if draft exists:
   - **If draft exists**: Update draft status from `draft` to `pending`
   - **If no draft**: Create new transaction with `pending` status
3. **Cart cleared** and user redirected to OrderSuccessPage

### Draft → Payment Flow

1. **User adds items to cart** → `processDraftTransaction()` creates/updates draft
2. **User confirms payment** → `_confirmPayment()` checks if draft exists:
   - **If draft exists**: Update draft status from `draft` to `completed`
   - **If no draft**: Create new transaction with `completed` status
3. **Cart cleared** and user redirected to PaymentSuccessPage

## Benefits

### 1. **Data Consistency**

- Prevents duplicate transactions
- Maintains transaction history and audit trail
- Single source of truth for each customer session

### 2. **Better User Experience**

- Seamless transition from draft to confirmed transaction
- Preserves customer data and notes across states
- Consistent transaction numbering

### 3. **Improved Performance**

- Reduces unnecessary API calls
- Reuses existing transaction data
- Optimized database operations

### 4. **Better Error Handling**

- Clear debug messages for troubleshooting
- Graceful handling of both create and update scenarios
- Consistent error reporting

## Debug Messages

The implementation includes comprehensive debug logging:

```dart
// For updates
debugPrint('🔄 Updating existing draft transaction to [status]. ID: ${cartProvider.draftTransactionId}');
debugPrint('✅ Draft transaction updated to [status] successfully');

// For new transactions
debugPrint('✨ Creating new [type] transaction');
debugPrint('✅ New [type] transaction created successfully');
```

## Status Transitions

| From Status | Action          | To Status   | Method Used           |
| ----------- | --------------- | ----------- | --------------------- |
| `null`      | Create Order    | `pending`   | `processPayment()`    |
| `draft`     | Confirm Order   | `pending`   | `updateTransaction()` |
| `null`      | Create Payment  | `completed` | `processPayment()`    |
| `draft`     | Confirm Payment | `completed` | `updateTransaction()` |

## Testing Scenarios

### Scenario 1: New Order (No Draft)

1. Add items to empty cart
2. Go directly to order confirmation
3. **Expected**: New transaction created with `pending` status

### Scenario 2: Draft → Order

1. Add items to cart (creates draft)
2. Add/remove more items (updates draft)
3. Confirm order
4. **Expected**: Draft transaction updated to `pending` status

### Scenario 3: New Payment (No Draft)

1. Add items to empty cart
2. Go directly to payment
3. **Expected**: New transaction created with `completed` status

### Scenario 4: Draft → Payment

1. Add items to cart (creates draft)
2. Add/remove more items (updates draft)
3. Confirm payment
4. **Expected**: Draft transaction updated to `completed` status

This implementation ensures consistent transaction management and provides a better user experience while maintaining data integrity across the POS application.
