# Customer-Based Product Pricing Integration

## 📋 Overview

Implementasi fitur customer-specific pricing untuk produk. Sekarang API `/api/v1/products` memerlukan `customer_id` sebagai parameter wajib, dan response-nya mencakup informasi harga khusus untuk customer tersebut berdasarkan customer group.

## 🔄 API Changes

### Endpoint Update

**Before:**

```
GET /api/v1/products?per_page=100&active_only=true
```

**After:**

```
GET /api/v1/products?customer_id=1&per_page=100&active_only=true
```

### Request Parameters

| Parameter        | Type      | Required   | Description                                |
| ---------------- | --------- | ---------- | ------------------------------------------ |
| `customer_id`    | `int`     | **YES** ✅ | Customer ID untuk mendapatkan harga khusus |
| `per_page`       | `int`     | No         | Jumlah item per halaman (default: 15)      |
| `page`           | `int`     | No         | Nomor halaman (default: 1)                 |
| `search`         | `string`  | No         | Pencarian produk                           |
| `category_id`    | `int`     | No         | Filter berdasarkan kategori                |
| `unit_id`        | `int`     | No         | Filter berdasarkan unit                    |
| `active_only`    | `boolean` | No         | Filter produk aktif (default: true)        |
| `sort_by`        | `string`  | No         | Field untuk sorting                        |
| `sort_direction` | `string`  | No         | Arah sorting (asc/desc)                    |

## 📦 Response Structure

### New Fields in Product Response

#### 1. Variant Level - `customer_pricing`

```json
{
  "final_price": 10000000,
  "base_price": 10000000,
  "price_source": "base",
  "price_difference": 0,
  "price_difference_percentage": 0,
  "has_customer_pricing": false,
  "customer_group_name": null
}
```

#### 2. Variant Level - `formatted_prices`

```json
{
  "final_price": "Rp 10.000.000",
  "base_price": "Rp 10.000.000",
  "price_difference": "Rp 0 (0%)"
}
```

#### 3. Product Level - `customer_info`

```json
{
  "customer_id": 1,
  "customer_name": "Budi Santoso",
  "customer_group_name": null,
  "has_customer_pricing": false
}
```

### Example Full Response

```json
{
  "status": "success",
  "message": "Products retrieved successfully",
  "data": {
    "data": [
      {
        "id": 231,
        "name": "1.2' SS, GREEN FLASH TAIL W/PURPLE FLOWER BQ",
        "sku": "IF CKMC003 (15)",
        "description": "Product in Single Shots category",
        "min_stock": 1,
        "image": null,
        "is_active": true,
        "category": { "id": 7, "name": "Single Shots", ... },
        "unit": { "id": 1, "name": "Pack", ... },
        "variants": [
          {
            "id": 243,
            "name": "100/1",
            "sku": "IF CKMC003 (15)-ee6107",
            "price": 10000000,
            "cost_price": 6000000,
            "stock": -1,
            "attributes": { "Packing": "100/1" },
            "customer_pricing": {
              "final_price": 10000000,
              "base_price": 10000000,
              "price_source": "base",
              "has_customer_pricing": false
            },
            "formatted_prices": {
              "final_price": "Rp 10.000.000",
              "base_price": "Rp 10.000.000",
              "price_difference": "Rp 0 (0%)"
            }
          }
        ],
        "customer_info": {
          "customer_id": 1,
          "customer_name": "Budi Santoso",
          "customer_group_name": null,
          "has_customer_pricing": false
        }
      }
    ],
    "meta": { "current_page": 1, "total": 353, ... }
  }
}
```

## 🏗️ Model Changes

### 1. New Models Created

#### `CustomerPricing` Model

```dart
class CustomerPricing {
  final double finalPrice;           // Harga final untuk customer
  final double basePrice;             // Harga dasar produk
  final String priceSource;           // Sumber harga: 'base' atau 'customer_group'
  final double priceDifference;       // Selisih harga
  final double priceDifferencePercentage; // Persentase selisih
  final bool hasCustomerPricing;     // Apakah ada harga khusus
  final String? customerGroupName;    // Nama customer group
}
```

#### `FormattedPrices` Model

```dart
class FormattedPrices {
  final String finalPrice;        // "Rp 10.000.000"
  final String basePrice;          // "Rp 10.000.000"
  final String priceDifference;    // "Rp 0 (0%)"
}
```

#### `CustomerInfo` Model

```dart
class CustomerInfo {
  final int customerId;
  final String customerName;
  final String? customerGroupName;
  final bool hasCustomerPricing;
}
```

### 2. Updated Models

#### `ProductVariant` Model

**New fields:**

```dart
class ProductVariant {
  // ... existing fields
  final CustomerPricing? customerPricing;  // ✨ NEW
  final FormattedPrices? formattedPrices;  // ✨ NEW

  // New helper getters
  double get finalPrice;              // Returns customer price or base price
  bool get hasCustomerPricing;        // Check if has special pricing
  String get formattedFinalPrice;     // Get formatted price string
}
```

#### `Product` Model

**New field:**

```dart
class Product {
  // ... existing fields
  final CustomerInfo? customerInfo;    // ✨ NEW

  // New helper getter
  bool get hasCustomerPricing;         // Check if has special pricing
}
```

## 🔧 Service Changes

### ProductApiService

#### Updated Method Signature

```dart
Future<ProductResponse> getProducts({
  int page = 1,
  int perPage = 15,
  required int customerId,  // ✨ NOW REQUIRED
  String? search,
  int? categoryId,
  int? unitId,
  bool activeOnly = true,
  String? sortBy,
  String? sortDirection,
})
```

#### All Helper Methods Updated

```dart
// Search products
Future<ProductResponse> searchProducts(
  String query, {
  required int customerId,  // ✨ NOW REQUIRED
  // ... other params
})

// Get by category
Future<ProductResponse> getProductsByCategory(
  int categoryId, {
  required int customerId,  // ✨ NOW REQUIRED
  // ... other params
})

// Get by unit
Future<ProductResponse> getProductsByUnit(
  int unitId, {
  required int customerId,  // ✨ NOW REQUIRED
  // ... other params
})

// Get active products
Future<ProductResponse> getActiveProducts({
  required int customerId,  // ✨ NOW REQUIRED
  // ... other params
})

// Get all products
Future<ProductResponse> getAllProducts({
  required int customerId,  // ✨ NOW REQUIRED
  // ... other params
})
```

## 🎯 Provider Changes

### ProductProvider

#### New Properties

```dart
class ProductProvider extends ChangeNotifier {
  int? _customerId;  // Customer ID for pricing

  int? get customerId => _customerId;
}
```

#### New Methods

```dart
/// Set customer ID and reload products
void setCustomerId(int? customerId) {
  if (_customerId != customerId) {
    _customerId = customerId;
    if (customerId != null) {
      _loadProductsFromApi();
    } else {
      _products.clear();
      notifyListeners();
    }
  }
}
```

#### Updated Behavior

- **Before:** Products loaded automatically on initialization
- **After:** Products loaded ONLY after customer ID is set
- Products cleared when customer ID is null

### ApiProductProvider

#### New Properties & Methods

```dart
class ApiProductProvider extends ChangeNotifier {
  int? _customerId;  // Customer ID for pricing

  int? get customerId => _customerId;

  /// Set customer ID and reload products
  void setCustomerId(int? customerId) { ... }
}
```

## 📝 Usage Guide

### 1. Basic Usage - Load Products for Customer

```dart
// Get product provider
final productProvider = Provider.of<ProductProvider>(context, listen: false);

// Set customer ID (this triggers product load)
productProvider.setCustomerId(1);

// Products will now have customer-specific pricing
final products = productProvider.products;
```

### 2. Access Customer Pricing

```dart
// Get product
final product = productProvider.products.first;

// Access customer info
final customerInfo = product.customerInfo;
print('Customer: ${customerInfo?.customerName}');
print('Has special pricing: ${product.hasCustomerPricing}');

// Access variant pricing
final variant = product.variants.first;
final finalPrice = variant.finalPrice;  // Customer price if available
final basePrice = variant.price;         // Original price
final hasDiscount = variant.hasCustomerPricing;

// Access formatted prices
final formattedPrice = variant.formattedFinalPrice; // "Rp 10.000.000"

// Access detailed pricing info
if (variant.customerPricing != null) {
  final pricing = variant.customerPricing!;
  print('Final Price: ${pricing.finalPrice}');
  print('Base Price: ${pricing.basePrice}');
  print('Difference: ${pricing.priceDifference}');
  print('Percentage: ${pricing.priceDifferencePercentage}%');
  print('Group: ${pricing.customerGroupName}');
}
```

### 3. Display Price in UI

```dart
// Show final price (customer-specific or base)
Text(
  variant.formattedFinalPrice,
  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
)

// Show price difference if has customer pricing
if (variant.hasCustomerPricing && variant.customerPricing != null) {
  Text(
    'Save ${variant.customerPricing!.priceDifference}',
    style: TextStyle(color: Colors.green),
  )
}

// Show original price with strikethrough if discounted
if (variant.hasCustomerPricing) {
  Text(
    variant.formattedPrices?.basePrice ?? '',
    style: TextStyle(
      decoration: TextDecoration.lineThrough,
      color: Colors.grey,
    ),
  )
}
```

### 4. Integration with Cart

```dart
// When adding to cart, use final price
final product = productProvider.products.first;
final variant = product.variants.first;

cartProvider.addItem(
  Product(
    // ... other fields
    price: variant.finalPrice,  // Use customer price
  ),
);
```

### 5. Clear Customer (Logout/Switch Customer)

```dart
// Clear customer ID
productProvider.setCustomerId(null);

// Products will be cleared
// On next customer selection, call setCustomerId again
```

## 🔄 Migration Guide

### For Existing Code

#### 1. Update Provider Calls

**Before:**

```dart
// Products loaded automatically
final productProvider = ProductProvider();
```

**After:**

```dart
// Set customer ID first
final productProvider = ProductProvider();
productProvider.setCustomerId(customerIdFromCart or CustomerSelection);
```

#### 2. Update API Service Calls

**Before:**

```dart
await productApiService.getProducts(
  perPage: 100,
  activeOnly: true,
);
```

**After:**

```dart
await productApiService.getProducts(
  customerId: 1,  // ✨ REQUIRED
  perPage: 100,
  activeOnly: true,
);
```

#### 3. Access Pricing

**Before:**

```dart
final price = variant.price;  // Always base price
```

**After:**

```dart
final price = variant.finalPrice;  // Customer price if available, else base
// OR for explicit base price:
final basePrice = variant.price;
```

## 🎨 UI Implementation Examples

### Product Card with Customer Pricing

```dart
class ProductCard extends StatelessWidget {
  final Product product;

  Widget build(BuildContext context) {
    final variant = product.variants.first;

    return Card(
      child: Column(
        children: [
          Text(product.name),

          // Show customer info
          if (product.customerInfo != null)
            Text('For: ${product.customerInfo!.customerName}'),

          // Show price with discount indication
          Row(
            children: [
              Text(
                variant.formattedFinalPrice,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: variant.hasCustomerPricing
                    ? Colors.green
                    : Colors.black,
                ),
              ),

              // Show original price if discounted
              if (variant.hasCustomerPricing)
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    variant.formattedPrices!.basePrice,
                    style: TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),

          // Show discount badge
          if (variant.hasCustomerPricing &&
              variant.customerPricing != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Save ${variant.customerPricing!.priceDifferencePercentage}%',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
```

## 📊 Data Flow

```
┌─────────────────┐
│ Customer Select │
└────────┬────────┘
         │
         ▼
┌─────────────────────────┐
│ setCustomerId(1)        │
└────────┬────────────────┘
         │
         ▼
┌───────────────────────────────────┐
│ GET /products?customer_id=1       │
└────────┬──────────────────────────┘
         │
         ▼
┌───────────────────────────────────────┐
│ Response with customer_pricing         │
│ - final_price (customer-specific)      │
│ - base_price (original)                │
│ - customer_info                        │
└────────┬──────────────────────────────┘
         │
         ▼
┌────────────────────────────┐
│ ProductProvider.products   │
│ - Products with pricing    │
└────────┬───────────────────┘
         │
         ▼
┌──────────────────┐
│ UI Display       │
│ - Show prices    │
│ - Show discounts │
└──────────────────┘
```

## ✅ Testing Checklist

- [ ] Products load after setCustomerId() called
- [ ] Products cleared when customerId set to null
- [ ] Customer pricing displayed correctly
- [ ] Formatted prices shown properly
- [ ] Discount percentage calculated correctly
- [ ] Original price shown with strikethrough when discounted
- [ ] Cart uses customer-specific prices
- [ ] Customer info displayed in product details
- [ ] Price source indicator works (base vs customer_group)
- [ ] Multiple customers can have different prices for same product
- [ ] Error handling when customer_id missing
- [ ] Pagination works with customer_id parameter

## 🐛 Common Issues & Solutions

### Issue: Products not loading

**Solution:** Ensure customer ID is set before loading

```dart
productProvider.setCustomerId(customerId);
```

### Issue: Wrong prices displayed

**Solution:** Use `variant.finalPrice` instead of `variant.price`

```dart
// ✅ Correct
final price = variant.finalPrice;

// ❌ Wrong (always base price)
final price = variant.price;
```

### Issue: API error "customer_id required"

**Solution:** Check that all API calls include customerId parameter

```dart
await apiService.getProducts(
  customerId: 1,  // Don't forget!
  // ... other params
);
```

## 📁 Files Modified

### New Files

- `lib/features/products/data/models/customer_pricing.dart`
- `lib/features/products/data/models/formatted_prices.dart`
- `lib/features/products/data/models/customer_info.dart`

### Modified Files

- `lib/features/products/data/models/product_variant.dart`
- `lib/features/products/data/models/product.dart`
- `lib/features/products/data/services/product_api_service.dart`
- `lib/features/products/providers/product_provider.dart`
- `lib/features/products/providers/api_product_provider.dart`

## 🚀 Next Steps

1. **Integrate with Customer Selection Page**

   - Pass selected customer ID to ProductProvider
   - Load products after customer selected

2. **Update Cart Integration**

   - Ensure cart uses customer-specific prices
   - Display customer info in cart

3. **Update Transaction Flow**

   - Save customer_id with transactions
   - Display pricing details in transaction history

4. **Add Price History**
   - Track price changes for customers
   - Show price trends

---

**🎉 Customer-Based Pricing Integration Complete!**

Products now display accurate customer-specific pricing based on customer groups, with full support for discounts, formatted prices, and customer information.
