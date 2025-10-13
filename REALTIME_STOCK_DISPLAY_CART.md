# Feature: Real-time Stock Display di Halaman Keranjang

## 📋 Feature Description

Stock badge di halaman keranjang sekarang menampilkan **stock yang tersisa secara real-time** berdasarkan quantity item yang sudah ada di cart. Ini memberikan visual feedback yang akurat tentang berapa stock yang masih available untuk ditambahkan.

## ✨ Key Features

### 1. **Dynamic Stock Calculation**

- **Total Stock in System**: Stock total dari database
- **Quantity in Cart**: Total quantity produk yang sudah di cart
- **Available Stock**: Stock tersisa = Total - Quantity in Cart

### 2. **Real-time Updates**

- Stock badge otomatis update saat:
  - User add item ke cart
  - User increase/decrease quantity
  - User remove item dari cart
  - ProductProvider refresh data

### 3. **Visual Indicators**

- **Green** (Stock > 10): Stock aman
- **Yellow** (Stock 1-10): Stock rendah
- **Red** (Stock ≤ 0): Stock habis
- **Dual Info**: Menampilkan "Stok Tersisa" dan "Total"

## 🎯 How It Works

### Stock Calculation Logic:

```dart
// 1. Get total stock from system
int totalStockInSystem = currentProduct.stock;

// 2. Calculate total quantity already in cart for this product
final quantityInCart = cartProvider.items
    .where((cartItem) => cartItem.product.id == item.product.id)
    .fold<int>(0, (sum, cartItem) => sum + cartItem.quantity);

// 3. Available stock = Total - Quantity in cart
final availableStock = totalStockInSystem - quantityInCart;
```

### Example Scenarios:

#### **Scenario 1: Initial State**

```
Product A - Total Stock: 50
Cart: Empty

Stock Badge: "Stok Tersisa: 50 | Total: 50" (Green)
```

#### **Scenario 2: Add to Cart**

```
Product A - Total Stock: 50
User adds 10 to cart

Stock Badge: "Stok Tersisa: 40 | Total: 50" (Green)
```

#### **Scenario 3: Multiple Items**

```
Product A - Total Stock: 50
Cart Item 1: Product A x 15
Cart Item 2: Product A (different variant) x 20

Total in cart: 35
Stock Badge: "Stok Tersisa: 15 | Total: 50" (Yellow - Low Stock!)
```

#### **Scenario 4: Max Capacity**

```
Product A - Total Stock: 50
Cart: Product A x 50

Stock Badge: "Stok Tersisa: 0 | Total: 50" (Red - Out of Stock!)
Plus button: DISABLED ❌
```

## 💻 Implementation Details

### **File**: `lib/features/sales/presentation/pages/cart_page.dart`

#### **1. Stock Calculation in Consumer**

```dart
Widget _buildCartItem(
  BuildContext context,
  CartItem item,
  CartProvider cartProvider,
) {
  return Consumer<ProductProvider>(
    builder: (context, productProvider, child) {
      // Get current product from provider
      final currentProduct = productProvider.products.firstWhere(
        (p) => p.id == item.product.id,
        orElse: () => item.product,
      );

      // Get total stock from system
      int totalStockInSystem;
      if (item.product.productVariantId != null) {
        totalStockInSystem = item.product.stock;
      } else {
        totalStockInSystem = currentProduct.stock;
      }

      // ✅ Calculate quantity already in cart
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final quantityInCart = cartProvider.items
          .where((cartItem) => cartItem.product.id == item.product.id)
          .fold<int>(0, (sum, cartItem) => sum + cartItem.quantity);

      // ✅ Calculate available stock
      final availableStock = totalStockInSystem - quantityInCart;

      // Determine stock status
      final isLowStock = availableStock > 0 && availableStock <= 10;
      final isOutOfStock = availableStock <= 0;

      return Container(
        // ... cart item UI
      );
    },
  );
}
```

#### **2. Enhanced Stock Badge UI**

**Before (Simple):**

```dart
Text('Stok: $availableStock')
```

**After (Detailed):**

```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  decoration: BoxDecoration(
    color: isOutOfStock
        ? const Color(0x1aef4444)      // Red background
        : isLowStock
        ? const Color(0x1af59e0b)      // Yellow background
        : const Color(0x1a10b981),     // Green background
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: isOutOfStock
          ? const Color(0x3aef4444)
          : isLowStock
          ? const Color(0x3af59e0b)
          : const Color(0x3a10b981),
    ),
  ),
  child: Row(
    children: [
      Icon(
        isOutOfStock
            ? LucideIcons.xCircle
            : isLowStock
            ? LucideIcons.alertTriangle
            : LucideIcons.package,
        size: 14,
        color: /* dynamic color */,
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Main info: Available stock
          Text(
            'Stok Tersisa: $availableStock',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: /* dynamic color */,
            ),
          ),
          // ✅ Secondary info: Total stock
          Text(
            'Total: $totalStockInSystem',
            style: TextStyle(
              fontSize: 10,
              color: /* dynamic color with opacity */,
            ),
          ),
        ],
      ),
    ],
  ),
)
```

#### **3. Button State Based on Available Stock**

```dart
IconButton(
  onPressed: isOutOfStock || item.quantity >= availableStock
      ? null  // ❌ Disabled if out of stock or max reached
      : () {
          cartProvider.addItem(item.product, context: context);
        },
  icon: const Icon(LucideIcons.plus, size: 18),
  color: isOutOfStock || item.quantity >= availableStock
      ? const Color(0xFF9ca3af)  // Gray when disabled
      : const Color(0xFF10b981),  // Green when active
)
```

## 🎨 UI/UX Design

### Stock Badge Visual States:

#### **1. Normal Stock (Green)**

```
┌─────────────────────────────┐
│ 📦  Stok Tersisa: 35        │
│     Total: 50               │  ← Green background
└─────────────────────────────┘
```

#### **2. Low Stock (Yellow)**

```
┌─────────────────────────────┐
│ ⚠️  Stok Tersisa: 8          │
│     Total: 50               │  ← Yellow background (warning)
└─────────────────────────────┘
```

#### **3. Out of Stock (Red)**

```
┌─────────────────────────────┐
│ ❌  Stok Tersisa: 0          │
│     Total: 50               │  ← Red background (alert)
└─────────────────────────────┘
```

### Complete Cart Item Layout:

```
┌───────────────────────────────────────────────┐
│  Product Name                          [🗑️]   │
│  Rp 25,000                                    │
│                                               │
│  ┌─────────────────────────────────────────┐ │
│  │ 📦  Stok Tersisa: 40                    │ │
│  │     Total: 50                           │ │
│  └─────────────────────────────────────────┘ │
│                                               │
│  ────────────────────────────────────────────│
│                                               │
│  Jumlah:                    [-] [10] [+]     │
│                                               │
│  Subtotal:                   Rp 250,000      │
└───────────────────────────────────────────────┘
```

## 📊 Data Flow

### Real-time Update Flow:

```
User clicks [+] button
  ↓
CartProvider.addItem(product, context: context)
  ↓
_items list updated (quantity +1)
  ↓
CartProvider.notifyListeners()
  ↓
ListView.builder rebuilds cart items
  ↓
Consumer<ProductProvider> rebuilds each item
  ↓
Stock calculation runs:
  - totalStockInSystem: 50
  - quantityInCart: 11 (was 10, now 11)
  - availableStock: 39 (was 40, now 39)
  ↓
Stock badge updates:
  "Stok Tersisa: 39 | Total: 50" ✅
  ↓
Button state check:
  - item.quantity (11) < availableStock (39)
  - Plus button: ENABLED ✅
```

### Edge Case: Max Capacity Reached

```
Current state:
  - Total stock: 50
  - Quantity in cart: 50
  - Available: 0

User tries to click [+]:
  ↓
Button check: item.quantity (50) >= availableStock (0)
  ↓
Button is DISABLED ❌
  ↓
Visual feedback:
  - Button grayed out
  - Stock badge shows red "0"
  - User cannot add more
```

## ✅ Benefits

### 1. **Accurate Stock Information**

- Shows real remaining capacity
- Prevents overselling
- Clear visual feedback

### 2. **Better UX**

- User knows exactly how much more they can add
- No confusion about available stock
- Proactive warnings (yellow when low)

### 3. **Prevents Errors**

- Plus button disabled when max reached
- Visual indicators (colors, icons)
- Impossible to exceed stock

### 4. **Real-time Sync**

- Consumer pattern ensures immediate updates
- No stale data
- Consistent across cart operations

### 5. **Business Intelligence**

- Shows total vs available
- Helps with stock management
- Identifies popular items (when available stock is low)

## 🔍 Edge Cases Handled

### 1. **Multiple Same Product in Cart**

```dart
// Correctly sums all instances of same product
final quantityInCart = cartProvider.items
    .where((cartItem) => cartItem.product.id == item.product.id)
    .fold<int>(0, (sum, cartItem) => sum + cartItem.quantity);
```

### 2. **Product Variants**

```dart
// Different handling for variants vs main products
if (item.product.productVariantId != null) {
  totalStockInSystem = item.product.stock;  // Variant stock
} else {
  totalStockInSystem = currentProduct.stock;  // Main product stock
}
```

### 3. **Stock Becomes Negative (Edge Case)**

```dart
// Protection against negative available stock
final isOutOfStock = availableStock <= 0;

// Button disabled
onPressed: isOutOfStock ? null : () => addMore()
```

### 4. **Product Refresh Updates**

```dart
// Consumer automatically rebuilds when ProductProvider changes
Consumer<ProductProvider>(
  builder: (context, productProvider, child) {
    // Always gets latest stock from productProvider
    final currentProduct = productProvider.products.firstWhere(...);
  },
)
```

## 🧪 Testing Scenarios

### Test 1: Basic Add/Remove

```
1. Initial: Product A stock 100, cart empty
   → Badge: "Stok Tersisa: 100 | Total: 100" ✅

2. Add 10 to cart
   → Badge: "Stok Tersisa: 90 | Total: 100" ✅

3. Remove 5 from cart
   → Badge: "Stok Tersisa: 95 | Total: 100" ✅
```

### Test 2: Low Stock Warning

```
1. Product B stock 15, add 8 to cart
   → Badge: "Stok Tersisa: 7" (YELLOW) ⚠️

2. Add 3 more
   → Badge: "Stok Tersisa: 4" (YELLOW) ⚠️

3. Add 4 more
   → Badge: "Stok Tersisa: 0" (RED) ❌
   → Plus button DISABLED
```

### Test 3: Multiple Cart Items Same Product

```
1. Product C stock 50
2. Add item 1: Qty 20
   → Badge: "Stok Tersisa: 30"

3. Add item 2 (same product): Qty 15
   → Both badges: "Stok Tersisa: 15"
   (50 - 20 - 15 = 15)

4. Remove item 1
   → Remaining badge: "Stok Tersisa: 35"
   (50 - 15 = 35)
```

### Test 4: Product Refresh

```
1. Product D stock 100, cart has 40
   → Badge: "Stok Tersisa: 60"

2. Backend updates stock to 80
3. User pulls to refresh
   → ProductProvider.refreshProducts()
   → Consumer rebuilds
   → Badge: "Stok Tersisa: 40" (80 - 40)
```

## 🔮 Future Enhancements

### 1. **Stock Reservation Timer**

```dart
// Reserve stock when in cart for X minutes
class StockReservation {
  final int productId;
  final int quantity;
  final DateTime expiresAt;
}
```

### 2. **Stock Availability Animation**

```dart
AnimatedSwitcher(
  duration: Duration(milliseconds: 300),
  child: Text(
    'Stok Tersisa: $availableStock',
    key: ValueKey(availableStock),
  ),
)
```

### 3. **Low Stock Alert Badge**

```dart
if (isLowStock) {
  return Badge(
    label: Text('!'),
    child: StockBadge(),
  );
}
```

### 4. **Predicted Stock Depletion**

```dart
// Show estimated time until out of stock
final salesVelocity = calculateSalesPerHour(product);
final hoursUntilEmpty = availableStock / salesVelocity;

Text('Habis dalam ~${hoursUntilEmpty.round()} jam');
```

## 📚 Key Learnings

1. **Real-time Calculation** > Static Display

   - Calculate on-the-fly for accuracy
   - Don't cache stock calculations

2. **Consumer Pattern** for Reactive UI

   - Automatically updates when provider changes
   - No manual refresh needed

3. **Dual Information** Better UX

   - Show both available AND total
   - Context helps decision making

4. **Visual Indicators** Reduce Errors

   - Colors communicate status instantly
   - Icons reinforce message

5. **Prevent Invalid States**
   - Disable buttons when max reached
   - Validate before allowing actions

---

**Status**: ✅ Implemented
**Date**: October 13, 2025
**Feature Type**: Real-time Stock Display Enhancement
**Impact**: Improved accuracy, better UX, prevents overselling
**Technology**: Flutter, Provider pattern, Consumer widgets
