# Customer Product Pricing Integration

## 📋 Overview

Implementasi integrasi antara **Customer Selection** dan **Product Pricing** berdasarkan Customer Group ID. Ketika user memilih customer, sistem akan otomatis load produk dengan harga sesuai customer group yang dipilih.

## ✅ Implementasi

### File Modified: `customer_selection_page.dart`

#### 1. Import ProductProvider

```dart
import '../../../products/providers/product_provider.dart';
```

#### 2. Update Method `_selectCustomer()`

**SEBELUM:**

```dart
Future<void> _selectCustomer(ApiCustomer.Customer customer) async {
  final pendingProvider = Provider.of<PendingTransactionProvider>(
    context,
    listen: false,
  );
  final cartProvider = Provider.of<CartProvider>(context, listen: false);

  // ... existing code
}
```

**SESUDAH:**

```dart
Future<void> _selectCustomer(ApiCustomer.Customer customer) async {
  final pendingProvider = Provider.of<PendingTransactionProvider>(
    context,
    listen: false,
  );
  final cartProvider = Provider.of<CartProvider>(context, listen: false);
  final productProvider = Provider.of<ProductProvider>(
    context,
    listen: false,
  );

  // Set customer group ID to product provider for pricing
  if (customer.customerGroupId != null) {
    productProvider.setCustomerId(customer.customerGroupId!);
  }

  // ... existing code
}
```

## 🔄 Flow Diagram

```
User selects customer
        ↓
_selectCustomer() called
        ↓
Get ProductProvider instance
        ↓
Check customer.customerGroupId != null
        ↓
productProvider.setCustomerId(customer.customerGroupId!)
        ↓
ProductProvider updates internal state
        ↓
Products will be loaded with customer-specific pricing
        ↓
Navigate to POSTransactionPage
        ↓
POSTransactionPage displays products with correct pricing
```

## 💡 How It Works

### 1. Customer Selection

```dart
// User taps on a customer card
_selectCustomer(customer);
```

### 2. Set Customer Group ID

```dart
// Inside _selectCustomer()
final productProvider = Provider.of<ProductProvider>(
  context,
  listen: false,
);

if (customer.customerGroupId != null) {
  productProvider.setCustomerId(customer.customerGroupId!);
}
```

### 3. ProductProvider State Update

```dart
// In ProductProvider
void setCustomerId(int customerId) {
  _customerId = customerId;
  notifyListeners();
  // Will trigger product reload with new customer ID
}
```

### 4. Product API Call

```dart
// ProductApiService.getProducts() is called with customerId
GET /api/v1/products?customer_id={customerGroupId}

// Returns products with customer-specific pricing
{
  "data": [
    {
      "id": 1,
      "name": "Product A",
      "customer_info": {
        "customer_id": 2,
        "customer_group_name": "VIP Customer"
      },
      "variants": [
        {
          "customer_pricing": {
            "final_price": 85000,  // Discounted price
            "base_price": 100000,
            "price_source": "customer_group",
            "customer_group_name": "VIP Customer"
          }
        }
      ]
    }
  ]
}
```

## 🎯 Key Features

### ✅ Automatic Price Loading

- Customer group ID otomatis dikirim ke ProductProvider
- Products loaded dengan harga sesuai customer group
- Tidak perlu manual refresh atau reload

### ✅ Null Safety

```dart
if (customer.customerGroupId != null) {
  productProvider.setCustomerId(customer.customerGroupId!);
}
```

- Hanya set customer ID jika tidak null
- Prevents runtime errors

### ✅ State Management

- ProductProvider mengelola customer ID state
- Automatic product reload saat customer ID berubah
- POSTransactionPage akan display produk dengan harga yang benar

## 📊 Data Flow

```
Customer Selection Page
  ├─ Customer has customerGroupId: 2
  └─ User selects customer
      ↓
ProductProvider.setCustomerId(2)
  ├─ _customerId = 2
  ├─ notifyListeners()
  └─ Triggers product reload
      ↓
API Call: GET /api/v1/products?customer_id=2
  ├─ Returns products with VIP pricing
  └─ Products updated in ProductProvider
      ↓
Navigate to POSTransactionPage
  ├─ Listen to ProductProvider
  └─ Display products with customer-specific prices
```

## 🔍 Example Scenario

### Scenario: VIP Customer Shopping

1. **Customer Info:**

   - Name: "John Doe"
   - Customer Group: "VIP Customer" (ID: 2)
   - Discount: 15%

2. **User Action:**

   - Kasir selects "John Doe" dari customer list

3. **System Response:**

   ```dart
   _selectCustomer(john_doe_customer);
   // customer.customerGroupId = 2

   productProvider.setCustomerId(2);
   // ProductProvider now uses customer_id=2 for all API calls
   ```

4. **Product Pricing:**

   - Product A: Base price Rp 100.000 → Final price **Rp 85.000** (15% off)
   - Product B: Base price Rp 50.000 → Final price **Rp 42.500** (15% off)

5. **POS Display:**
   - Shows products with discounted prices
   - Customer gets VIP pricing automatically

## 🎨 UI/UX Impact

### Before Customer Selection

- Products may show default pricing or no pricing
- Customer group context not available

### After Customer Selection

- ✅ Products show customer-specific pricing
- ✅ Discounts automatically applied
- ✅ Price source indicated (customer_group)
- ✅ Customer group name displayed

## 🔗 Integration Points

### 1. CustomerSelectionPage

````dart
## 🔗 Integration Points

### 1. CustomerSelectionPage
```dart
// Sets customer group ID when customer selected
productProvider.setCustomerId(customer.customerGroupId!);
````

### 2. PendingTransactionListPage

```dart
// Sets customer group ID when resuming transaction
// For API transactions
if (detail.customer != null && detail.customer!.customerGroupId != null) {
  productProvider.setCustomerId(detail.customer!.customerGroupId!);
}

// For local transactions (backward compatibility)
if (apiCustomer.customerGroupId != null) {
  productProvider.setCustomerId(apiCustomer.customerGroupId!);
}
```

### 3. ProductProvider

````

### 2. ProductProvider

```dart
### 3. ProductProvider
```dart
// Manages customer ID state
int? _customerId;

void setCustomerId(int customerId) {
  _customerId = customerId;
  notifyListeners();
}
````

### 4. ProductApiService

````

### 3. ProductApiService

```dart
### 4. ProductApiService
```dart
// Uses customer ID in API calls
Future<List<Product>> getProducts({
  required int customerId,  // Now uses customer group ID
  // ...
})
````

### 5. POSTransactionPage

````

### 4. POSTransactionPage

```dart
// Automatically receives products with correct pricing
Consumer<ProductProvider>(
  builder: (context, productProvider, child) {
    // Products already have customer-specific pricing
    return ProductGrid(products: productProvider.products);
  },
)
````

## ✅ Testing Checklist

- [x] Customer with customerGroupId selected
- [x] ProductProvider.setCustomerId() called with correct ID
- [x] API called with customer_id parameter
- [x] Products returned with customer-specific pricing
- [x] POSTransactionPage displays correct prices
- [x] Null safety handled (customer without group ID)
- [x] Multiple customer selection (prices update correctly)
- [x] Pending transaction resume (prices preserved)
- [x] Resume API transaction (customer group ID set)
- [x] Resume local transaction (customer group ID set)

## 🚀 Benefits

### 1. **Seamless Integration**

- No manual intervention required
- Automatic price calculation

### 2. **Accurate Pricing**

- Always uses correct customer group
- No pricing errors

### 3. **Better UX**

- Instant price updates
- Clear price visibility
- Transparent discounts

### 4. **Business Logic**

- Enforces customer-based pricing rules
- Supports tiered customer groups
- Enables promotional pricing

## 📝 Notes

1. **Customer Group ID vs Customer ID:**

   - `customer.customerGroupId` → Used for product pricing
   - `customer.id` → Used for transaction/customer reference

2. **Pending Transactions:**

   - When resuming pending transaction, customer group ID is set
   - Products maintain their pricing from when transaction was created

3. **Fresh Transactions:**
   - New transaction gets latest pricing for customer group
   - Products loaded fresh from API

## 🔗 Related Files

- `lib/features/sales/presentation/pages/customer_selection_page.dart` (UPDATED)
- `lib/features/sales/presentation/pages/pending_transaction_list_page.dart` (UPDATED)
- `lib/features/products/providers/product_provider.dart` (Existing - uses setCustomerId)
- `lib/features/products/data/services/product_api_service.dart` (Existing - uses customerId)
- `lib/features/sales/presentation/pages/pos_transaction_page.dart` (Consumer of pricing)

## 📚 Related Documentation

- `CUSTOMER_BASED_PRODUCT_PRICING.md` - Product pricing models and API
- `ADD_CUSTOMER_PAGE_CONVERSION.md` - Customer creation with group selection
- `CUSTOMER_PRODUCT_PRICING_INTEGRATION.md` - This document
