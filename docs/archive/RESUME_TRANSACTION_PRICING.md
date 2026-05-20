# Resume Transaction with Customer Pricing

## 📋 Overview

Update pada **Pending Transaction List Page** untuk memastikan customer group ID di-set saat resume transaction, sehingga produk dimuat dengan harga yang sesuai dengan customer group.

## ✅ Implementasi

### File Modified: `pending_transaction_list_page.dart`

#### Method `_resumeTransaction()`

**Penambahan Logic untuk Set Customer Group ID:**

### 1. API Transaction Resume

```dart
// Handle API transaction - need to get detail first
final detail = await pendingProvider.getPendingTransactionDetail(
  transaction.id,
);

// ... existing code ...

// Set customer from API customer format
if (detail.customer != null) {
  cartProvider.setCustomerFromApi(detail.customer!);

  // ✅ NEW: Set customer group ID to product provider for pricing
  if (detail.customer!.customerGroupId != null) {
    productProvider.setCustomerId(detail.customer!.customerGroupId!);
    debugPrint(
      '💰 Setting customer group ID for pricing: ${detail.customer!.customerGroupId}',
    );
  }
}
```

### 2. Local Transaction Resume (Backward Compatibility)

```dart
// Handle local transaction (backward compatibility)
final apiCustomer = transaction.customer;
cartProvider.setCustomerFromApi(apiCustomer);

// ✅ NEW: Set customer group ID to product provider for pricing
if (apiCustomer.customerGroupId != null) {
  productProvider.setCustomerId(apiCustomer.customerGroupId!);
  debugPrint(
    '💰 Setting customer group ID for pricing: ${apiCustomer.customerGroupId}',
  );
}
```

## 🔄 Complete Flow

```
User taps "Lanjutkan" on pending transaction
        ↓
_resumeTransaction() called
        ↓
Get transaction detail (API) or local data
        ↓
Clear current cart
        ↓
Set draft transaction ID (if API transaction)
        ↓
Load cart items from transaction details
        ↓
Set customer to cart provider
        ↓
✅ Set customer group ID to product provider
        ↓
productProvider.setCustomerId(customerGroupId)
        ↓
ProductProvider updates state
        ↓
Products reload with customer-specific pricing
        ↓
Navigate to POSTransactionPage
        ↓
POSTransactionPage displays products with correct prices
```

## 💡 Key Benefits

### 1. **Price Consistency**

- Resumed transaction menggunakan pricing yang sama
- Customer group discount tetap diterapkan
- Tidak ada perubahan harga saat resume

### 2. **Automatic Pricing**

- Tidak perlu manual set pricing
- ProductProvider otomatis reload products
- Harga sesuai customer group

### 3. **Backward Compatible**

- Mendukung API transactions (new)
- Mendukung local transactions (old)
- Smooth migration path

## 📊 Before vs After

### SEBELUM (Without Customer Group ID):

```
Resume Transaction
  ↓
Load cart items
  ↓
Set customer
  ↓
Navigate to POS
  ↓
❌ Products show default pricing
❌ Customer discount not applied
❌ Wrong prices displayed
```

### SESUDAH (With Customer Group ID):

```
Resume Transaction
  ↓
Load cart items
  ↓
Set customer
  ↓
✅ Set customer group ID
  ↓
Navigate to POS
  ↓
✅ Products show customer-specific pricing
✅ Customer discount applied
✅ Correct prices displayed
```

## 🎯 Example Scenario

### Scenario: Resume VIP Customer Transaction

1. **Initial Transaction:**

   - Customer: "John Doe" (VIP Customer, Group ID: 2, 15% discount)
   - Added Product A: Rp 85.000 (discounted from Rp 100.000)
   - Transaction saved as pending

2. **Later - Resume Transaction:**

   ```dart
   _resumeTransaction(transaction);
   // transaction.customer.customerGroupId = 2
   ```

3. **System Actions:**

   ```dart
   // Load transaction detail
   final detail = await pendingProvider.getPendingTransactionDetail(id);

   // Set customer
   cartProvider.setCustomerFromApi(detail.customer!);

   // ✅ Set customer group ID for pricing
   productProvider.setCustomerId(2); // VIP group ID
   ```

4. **Result:**
   - Navigate to POS page
   - Products loaded with VIP pricing
   - Product A shows Rp 85.000 (15% off) ✅
   - Customer can continue shopping with correct prices

## 🔍 Debug Logging

Added debug prints to track customer group ID setting:

```dart
debugPrint(
  '💰 Setting customer group ID for pricing: ${detail.customer!.customerGroupId}',
);
```

This helps verify that:

- Customer group ID is correctly extracted
- ProductProvider receives the correct ID
- Pricing logic is triggered

## ⚙️ Technical Details

### API Transaction Flow:

```dart
if (transaction is PendingTransactionItem) {
  // 1. Get transaction detail from API
  final detail = await pendingProvider.getPendingTransactionDetail(
    transaction.id,
  );

  // 2. Set draft transaction ID
  cartProvider.setDraftTransactionId(transaction.id);

  // 3. Load cart items
  for (final item in detail.details) {
    // Find product and add to cart
  }

  // 4. Set customer
  if (detail.customer != null) {
    cartProvider.setCustomerFromApi(detail.customer!);

    // 5. ✅ Set customer group ID
    if (detail.customer!.customerGroupId != null) {
      productProvider.setCustomerId(detail.customer!.customerGroupId!);
    }
  }
}
```

### Local Transaction Flow:

```dart
else if (transaction is PendingTransaction) {
  // 1. Load cart items from local data
  for (final item in transaction.cartItems) {
    cartProvider.addItem(item.product, quantity: item.quantity);
  }

  // 2. Set customer
  final apiCustomer = transaction.customer;
  cartProvider.setCustomerFromApi(apiCustomer);

  // 3. ✅ Set customer group ID
  if (apiCustomer.customerGroupId != null) {
    productProvider.setCustomerId(apiCustomer.customerGroupId!);
  }
}
```

## 🛡️ Null Safety

Both implementations include null safety checks:

```dart
// API Transaction
if (detail.customer != null) {
  if (detail.customer!.customerGroupId != null) {
    productProvider.setCustomerId(detail.customer!.customerGroupId!);
  }
}

// Local Transaction
if (apiCustomer.customerGroupId != null) {
  productProvider.setCustomerId(apiCustomer.customerGroupId!);
}
```

This prevents errors when:

- Customer is null
- Customer group ID is null
- Customer doesn't have a group

## 📱 User Experience

### User Action Flow:

1. User goes to "Transaksi Pending" page
2. User sees list of pending transactions
3. User taps "Lanjutkan" on a transaction
4. System:
   - Loads transaction details
   - Sets customer
   - **Sets customer group ID for pricing** ✅
   - Navigates to POS page
5. User sees:
   - All cart items restored
   - Customer information displayed
   - **Products with correct customer group pricing** ✅
6. User can:
   - Continue shopping with correct prices
   - Add more items at correct pricing
   - Complete transaction

## 🎨 UI Impact

### POS Page Display:

```
┌────────────────────────────────┐
│ Customer: John Doe (VIP)       │ ← Customer info
│ Group: VIP Customer (15% off)  │ ← Group info
├────────────────────────────────┤
│                                │
│ Products:                      │
│ ┌──────────────────────────┐   │
│ │ Product A                │   │
│ │ Rp 85.000 (15% off) ✅   │   │ ← Correct VIP price
│ │ Base: Rp 100.000         │   │
│ └──────────────────────────┘   │
│                                │
│ ┌──────────────────────────┐   │
│ │ Product B                │   │
│ │ Rp 42.500 (15% off) ✅   │   │ ← Correct VIP price
│ │ Base: Rp 50.000          │   │
│ └──────────────────────────┘   │
└────────────────────────────────┘
```

## ✅ Testing Checklist

- [x] Resume API transaction with customer group
- [x] Customer group ID set correctly
- [x] ProductProvider receives customer group ID
- [x] Products reload with correct pricing
- [x] POS page displays correct prices
- [x] Resume local transaction with customer group
- [x] Null safety (customer without group)
- [x] Debug logging shows correct IDs
- [x] Can add more items with correct pricing
- [x] Can complete transaction successfully

## 🚀 Impact

### Before Implementation:

- ❌ Resume transaction → Wrong prices
- ❌ Manual price adjustment needed
- ❌ Customer discount not applied
- ❌ Inconsistent pricing experience

### After Implementation:

- ✅ Resume transaction → Correct prices
- ✅ Automatic pricing based on customer group
- ✅ Customer discount applied
- ✅ Consistent pricing experience

## 📝 Notes

1. **Transaction Types:**

   - API Transaction (PendingTransactionItem): From server
   - Local Transaction (PendingTransaction): From local storage

2. **Customer Group ID:**

   - Always comes from customer object
   - Used for product pricing API calls
   - Ensures correct discount application

3. **Product Reload:**

   - ProductProvider automatically reloads when customer ID changes
   - New products fetched with correct pricing
   - Existing cart items maintain their prices

4. **Debug Logging:**
   - Use 💰 emoji for pricing-related logs
   - Helps track customer group ID flow
   - Easy to search in logs

## 🔗 Related Documentation

- `CUSTOMER_PRODUCT_PRICING_INTEGRATION.md` - Overall pricing integration
- `CUSTOMER_BASED_PRODUCT_PRICING.md` - Product pricing models and API
- `ADD_CUSTOMER_PAGE_CONVERSION.md` - Customer creation with group selection

## 🔗 Related Files

- `lib/features/sales/presentation/pages/pending_transaction_list_page.dart` (UPDATED)
- `lib/features/products/providers/product_provider.dart` (Uses setCustomerId)
- `lib/features/sales/providers/cart_provider.dart` (Customer management)
- `lib/features/sales/presentation/pages/pos_transaction_page.dart` (Displays pricing)
