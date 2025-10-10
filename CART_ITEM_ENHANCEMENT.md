# CartItem Model Enhancement 🛒

## Overview

Enhanced CartItem model dengan fitur-fitur baru untuk mendukung discount, validation, dan integrasi yang lebih baik dengan Product dan TransactionDetail.

## New Features ✨

### 1. Discount Support

CartItem sekarang mendukung dua jenis diskon:

#### a. Percentage Discount

```dart
final item = CartItem(
  id: 1,
  product: product,
  quantity: 2,
  addedAt: DateTime.now(),
  discountPercentage: 10.0, // 10% discount
);
```

#### b. Fixed Amount Discount

```dart
final item = CartItem(
  id: 1,
  product: product,
  quantity: 2,
  addedAt: DateTime.now(),
  discountAmount: 5000.0, // Rp 5.000 discount per item
);
```

### 2. New Properties

| Property             | Type      | Description                    |
| -------------------- | --------- | ------------------------------ |
| `discountPercentage` | `double?` | Percentage discount (0-100)    |
| `discountAmount`     | `double?` | Fixed discount amount per item |
| `notes`              | `String?` | Item-specific notes            |

### 3. New Getters

#### Price & Discount Getters

```dart
// Original unit price
double unitPrice = item.unitPrice; // product.price

// Price after discount per unit
double discountedPrice = item.discountedUnitPrice;

// Total discount for all quantities
double discount = item.totalDiscount;

// Subtotal before discount
double beforeDiscount = item.subtotalBeforeDiscount;

// Final subtotal (after discount)
double finalPrice = item.subtotal;

// Check if has discount
bool hasDisc = item.hasDiscount;
```

#### Product Info Getters

```dart
// Get product variant ID (for transactions)
int variantId = item.productVariantId;

// Get product ID
int prodId = item.productId;
```

#### Stock Validation Getters

```dart
// Check if enough stock available
bool canAdd = item.hasEnoughStock;

// Get remaining stock after this cart item
int remaining = item.remainingStock;
```

### 4. New Helper Methods

#### Quick Copy Methods

```dart
// Update quantity
CartItem updated = item.withQuantity(5);

// Add discount
CartItem discounted = item.withDiscount(percentage: 15.0);
CartItem discounted2 = item.withDiscount(amount: 2000.0);

// Add notes
CartItem withNote = item.withNotes("Customer request");
```

#### Conversion Method

```dart
// Convert to TransactionDetail format for API
Map<String, dynamic> detail = item.toTransactionDetail();
// Result:
// {
//   'product_id': 1,
//   'product_variant_id': 123,
//   'quantity': 2,
//   'unit_price': 15000.0 // discounted price
// }
```

## Usage Examples

### Example 1: Basic Cart Item

```dart
final cartItem = CartItem(
  id: DateTime.now().millisecondsSinceEpoch,
  product: product,
  quantity: 2,
  addedAt: DateTime.now(),
);

print('Subtotal: ${cartItem.subtotal}'); // product.price * 2
```

### Example 2: Cart Item with Percentage Discount

```dart
final cartItem = CartItem(
  id: DateTime.now().millisecondsSinceEpoch,
  product: product, // price: 100,000
  quantity: 2,
  addedAt: DateTime.now(),
  discountPercentage: 20.0, // 20% off
);

print('Unit Price: ${cartItem.unitPrice}'); // 100,000
print('Discounted Unit Price: ${cartItem.discountedUnitPrice}'); // 80,000
print('Subtotal Before Discount: ${cartItem.subtotalBeforeDiscount}'); // 200,000
print('Total Discount: ${cartItem.totalDiscount}'); // 40,000
print('Final Subtotal: ${cartItem.subtotal}'); // 160,000
```

### Example 3: Cart Item with Fixed Amount Discount

```dart
final cartItem = CartItem(
  id: DateTime.now().millisecondsSinceEpoch,
  product: product, // price: 50,000
  quantity: 3,
  addedAt: DateTime.now(),
  discountAmount: 5000.0, // Rp 5.000 off per item
);

print('Unit Price: ${cartItem.unitPrice}'); // 50,000
print('Discounted Unit Price: ${cartItem.discountedUnitPrice}'); // 45,000
print('Total Discount: ${cartItem.totalDiscount}'); // 15,000
print('Final Subtotal: ${cartItem.subtotal}'); // 135,000
```

### Example 4: Cart Item with Notes

```dart
final cartItem = CartItem(
  id: DateTime.now().millisecondsSinceEpoch,
  product: product,
  quantity: 1,
  addedAt: DateTime.now(),
  notes: "Extra spicy, no onions",
);

print(cartItem.toString());
// CartItem(product: Nasi Goreng, quantity: 1, unitPrice: 25000.0, subtotal: 25000.0, notes: Extra spicy, no onions)
```

### Example 5: Stock Validation

```dart
final cartItem = CartItem(
  id: DateTime.now().millisecondsSinceEpoch,
  product: product, // stock: 10
  quantity: 8,
  addedAt: DateTime.now(),
);

if (cartItem.hasEnoughStock) {
  print('Stock available!');
  print('Remaining stock: ${cartItem.remainingStock}'); // 2
} else {
  print('Not enough stock!');
}
```

### Example 6: Converting to Transaction

```dart
final cartItem = CartItem(
  id: 1,
  product: product, // id: 5, productVariantId: 123, price: 50000
  quantity: 2,
  addedAt: DateTime.now(),
  discountPercentage: 10.0,
);

// Convert to transaction detail
final transactionDetail = cartItem.toTransactionDetail();
print(transactionDetail);
// {
//   'product_id': 5,
//   'product_variant_id': 123,
//   'quantity': 2,
//   'unit_price': 45000.0 // with 10% discount applied
// }
```

## Calculation Logic

### Discount Priority

Jika kedua jenis diskon diberikan, **discountAmount** akan diprioritaskan:

```dart
final item = CartItem(
  product: product, // price: 100,000
  quantity: 1,
  discountPercentage: 20.0,    // 20% = 20,000
  discountAmount: 15000.0,     // Rp 15,000
);

// Will use discountAmount (15,000), not percentage (20,000)
print(item.totalDiscount); // 15,000
```

### Formulas

#### Total Discount with Fixed Amount

```
totalDiscount = discountAmount × quantity
```

#### Total Discount with Percentage

```
totalDiscount = (unitPrice × quantity) × (discountPercentage / 100)
```

#### Discounted Unit Price with Fixed Amount

```
discountedUnitPrice = unitPrice - discountAmount
```

#### Discounted Unit Price with Percentage

```
discountedUnitPrice = unitPrice × (1 - discountPercentage / 100)
```

#### Final Subtotal

```
subtotal = subtotalBeforeDiscount - totalDiscount
subtotal = (unitPrice × quantity) - totalDiscount
```

## Enhanced JSON Format

### Output (toJson)

```json
{
  "id": 1234567890,
  "product": {
    "id": 5,
    "product_name": "Nasi Goreng",
    "unit_price": 25000.0,
    ...
  },
  "quantity": 2,
  "addedAt": "2025-10-10T10:30:00.000Z",
  "subtotal": 45000.0,
  "subtotalBeforeDiscount": 50000.0,
  "unitPrice": 25000.0,
  "discountedUnitPrice": 22500.0,
  "totalDiscount": 5000.0,
  "discountPercentage": 10.0,
  "notes": "Customer special request"
}
```

### Input (fromJson)

```dart
final item = CartItem.fromJson({
  "id": 1,
  "product": {...},
  "quantity": 2,
  "addedAt": "2025-10-10T10:30:00.000Z",
  "discountPercentage": 10.0,
  "notes": "Special order"
});
```

## Migration Guide

### Backward Compatibility ✅

Model ini **100% backward compatible** dengan kode yang sudah ada. Field baru bersifat opsional:

```dart
// Old code still works
final item = CartItem(
  id: 1,
  product: product,
  quantity: 2,
  addedAt: DateTime.now(),
);
// No changes needed!
```

### Updating Existing Code (Optional)

#### Before:

```dart
// Manual discount calculation
final subtotal = item.product.price * item.quantity;
final discount = subtotal * 0.1; // 10%
final total = subtotal - discount;
```

#### After:

```dart
// Automatic discount calculation
final item = CartItem(
  // ... existing fields
  discountPercentage: 10.0,
);
final total = item.subtotal; // Already includes discount
```

## Benefits 🎯

1. **✅ Cleaner Code**: Discount logic centralized in model
2. **✅ Type Safety**: All calculations with proper null safety
3. **✅ Reusability**: Helper methods for common operations
4. **✅ Validation**: Built-in stock validation
5. **✅ Better Integration**: Easy conversion to TransactionDetail
6. **✅ Flexibility**: Support for both percentage and fixed discounts
7. **✅ Debugging**: Enhanced toString() with all relevant info
8. **✅ Extensibility**: Easy to add more features in future

## Testing Checklist

- [x] Basic cart item creation
- [x] Cart item with percentage discount
- [x] Cart item with fixed amount discount
- [x] Stock validation
- [x] JSON serialization/deserialization
- [x] Transaction detail conversion
- [x] Copy methods (withQuantity, withDiscount, withNotes)
- [x] All getters return correct values
- [x] Backward compatibility with existing code

---

**Date**: October 10, 2025
**Status**: ✅ COMPLETE
**Version**: 2.0
