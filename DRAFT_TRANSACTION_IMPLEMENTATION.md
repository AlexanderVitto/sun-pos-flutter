# Draft Transaction Implementation

## Overview

Implementasi fitur draft transaction yang otomatis mengirim data item ke server setiap kali item ditambahkan, diperbarui, atau dihapus dari cart dengan status "draft".

## Changes Made

### 1. PaymentService Enhancement

- **Added**: `processDraftTransaction()` method untuk menangani transaksi draft
- **Purpose**: Mengirim data cart ke server dengan status "draft" tanpa mengganggu user experience
- **Error Handling**: Silent failure untuk tidak mengganggu UX

```dart
// Process draft transaction when adding items to cart
static Future<void> processDraftTransaction({
  required BuildContext context,
  required CartProvider cartProvider,
}) async {
  if (cartProvider.items.isEmpty) {
    return; // No items to process
  }

  try {
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

    await transactionProvider.processPayment(
      cartItems: cartProvider.items,
      totalAmount: cartProvider.total,
      notes: 'Draft Transaction - Cart Update',
      paymentMethod: 'cash',
      customerName: cartProvider.customerName ?? 'Customer',
      customerPhone: cartProvider.customerPhone,
      status: 'draft', // Draft status for cart items
      cashAmount: null, // No cash amount for draft
    );
  } catch (e) {
    debugPrint('Failed to process draft transaction: ${e.toString()}');
  }
}
```

### 2. CartProvider Enhancement

- **Added**: BuildContext parameter ke semua cart operations
- **Added**: `_processDraftTransaction()` internal method
- **Updated Methods**:
  - `addItem()` - Now triggers draft transaction
  - `updateItemQuantity()` - Now triggers draft transaction
  - `increaseQuantity()` - Now triggers draft transaction
  - `decreaseQuantity()` - Now triggers draft transaction
  - `removeItem()` - Now triggers draft transaction

```dart
// Example: Adding item with draft transaction
void addItem(Product product, {int quantity = 1, BuildContext? context}) {
  // ... existing logic ...

  // Process draft transaction when context is available
  if (context != null) {
    _processDraftTransaction(context);
  }
}

// Internal method to handle draft transaction
void _processDraftTransaction(BuildContext context) async {
  try {
    await PaymentService.processDraftTransaction(
      context: context,
      cartProvider: this,
    );
  } catch (e) {
    debugPrint('Failed to process draft transaction: ${e.toString()}');
  }
}
```

### 3. UI Components Updated

Updated calling code to pass BuildContext:

**POS Transaction Page**:

```dart
cartProvider.addItem(product, context: context);
```

**Product Grid**:

```dart
cartProvider.addItem(product, context: context);
```

**Cart Bottom Sheet**:

```dart
cartProvider.addItem(item.product, context: context);
```

**POS Transaction ViewModel**:

```dart
void addToCart(Product product, {int quantity = 1, BuildContext? context}) {
  _cartProvider.addItem(product, quantity: quantity, context: context);
}
```

## API Request Format

When draft transaction is processed, it sends request with:

```json
{
  "store_id": 1,
  "payment_method": "cash",
  "paid_amount": 0.0,
  "notes": "Draft Transaction - Cart Update",
  "transaction_date": "2025-09-01T10:30:00.000Z",
  "details": [
    {
      "product_id": "123",
      "quantity": 2,
      "unit_price": 15000.0,
      "subtotal": 30000.0
    }
  ],
  "customer_name": "Customer",
  "customer_phone": null,
  "status": "draft",
  "cash_amount": null
}
```

## How It Works

1. **User adds item to cart** → `cartProvider.addItem()` called with context
2. **Cart updated** → Item added/updated in cart
3. **Draft transaction triggered** → `_processDraftTransaction()` called
4. **API request sent** → `processPayment()` with status="draft"
5. **Silent handling** → Success/failure doesn't affect UX

## Benefits

1. **Real-time sync**: Cart data always synced with server
2. **Non-intrusive**: Draft operations don't show error messages to user
3. **Backward compatible**: Context parameter is optional
4. **Consistent**: All cart operations now support draft transactions
5. **Error resilient**: Network failures don't break cart functionality

## Usage Examples

### Adding Item with Draft Transaction

```dart
// With context (triggers draft transaction)
cartProvider.addItem(product, context: context);

// Without context (no draft transaction)
cartProvider.addItem(product);
```

### Updating Quantity with Draft Transaction

```dart
// With context (triggers draft transaction)
cartProvider.updateItemQuantity(itemId, 5, context: context);

// Without context (no draft transaction)
cartProvider.updateItemQuantity(itemId, 5);
```

### Through ViewModel

```dart
viewModel.addToCart(product, quantity: 2, context: context);
```

## Notes

- Draft transactions use status="draft"
- No cash amount is sent for draft transactions
- Errors are logged but don't interrupt user experience
- Compatible with existing code (context parameter is optional)
- All cart operations (add/update/remove) now support draft sync
