# Summary: Delta-Based Stock Display dengan Persistent State

## 📋 Overview

Implementasi **delta-based stock calculation** dengan **persistent state management** untuk menampilkan stock yang akurat di halaman keranjang, bahkan setelah navigasi.

## 🎯 Features Implemented

### 1. **Delta-Based Stock Calculation**

Stock dihitung berdasarkan **perubahan (delta)** dari quantity awal:

```
Delta = Quantity sekarang - Quantity awal
Available Stock = Total Stock - Delta
```

**Advantages:**

- ✅ Tidak double-count existing items
- ✅ Hanya deduct perubahan yang user buat di session ini
- ✅ Lebih akurat untuk multi-session cart

### 2. **Two-Stage Display**

Stock ditampilkan dalam 2 tahap:

- **Stage 1 (Initial)**: Show total stock from system
- **Stage 2 (After Action)**: Show total stock minus delta

### 3. **Persistent State**

State disimpan di `CartProvider` (bukan widget state):

- ✅ Survive across navigation
- ✅ No reset on page revisit
- ✅ Consistent calculation

## 🔧 Technical Implementation

### **File Changes:**

#### 1. **lib/features/sales/providers/cart_provider.dart**

**Added State Variables:**

```dart
Map<int, int> _initialQuantities = {}; // Store initial quantities per product ID
bool _hasUserAction = false;           // Track if user has made any cart action

// Getters
Map<int, int> get initialQuantities => Map.unmodifiable(_initialQuantities);
bool get hasUserAction => _hasUserAction;
```

**Added Methods:**

```dart
// Capture initial quantities for stock calculation
void captureInitialQuantities() {
  _initialQuantities.clear();
  for (var item in _items) {
    _initialQuantities[item.product.id] = item.quantity;
  }
  _hasUserAction = false;
}

// Mark that user has performed an action
void markUserAction() {
  if (!_hasUserAction) {
    _hasUserAction = true;
    notifyListeners();
  }
}
```

**Updated Methods:**

- `clearCart()` - Clear initial quantities and reset flag
- `clearItems()` - Clear initial quantities and reset flag
- `addItem()` - Mark user action
- `updateItemQuantity()` - Mark user action
- `decreaseQuantity()` - Mark user action
- `decreaseQuantityByProductId()` - Mark user action

#### 2. **lib/features/sales/presentation/pages/cart_page.dart**

**Removed Local State:**

```dart
// ❌ REMOVED:
// bool _hasUserAction = false;
// Map<int, int> _initialQuantities = {};
```

**Updated initState:**

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    productProvider.refreshProducts();

    // Capture initial quantities if not already captured
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    if (cartProvider.initialQuantities.isEmpty && cartProvider.items.isNotEmpty) {
      cartProvider.captureInitialQuantities();
    }
  });
}
```

**Updated Stock Calculation:**

```dart
// Get initial quantity from CartProvider
final initialQuantity = cartProvider.initialQuantities[item.product.id] ?? 0;

// Calculate delta (change in quantity)
final deltaQuantity = quantityInCart - initialQuantity;

// Available stock calculation using CartProvider flag
final availableStock = cartProvider.hasUserAction
    ? totalStockInSystem - deltaQuantity
    : totalStockInSystem;
```

**Updated Action Handlers:**

```dart
// Decrease button
onPressed: () {
  cartProvider.markUserAction();
  cartProvider.decreaseQuantity(item.id, context: context);
}

// Increase button
onPressed: () {
  cartProvider.markUserAction();
  cartProvider.addItem(item.product, context: context);
}

// Manual quantity update
void _updateQuantity(...) {
  cartProvider.markUserAction();
  cartProvider.updateItemQuantity(item.id, quantity, context: context);
}
```

## 📊 How It Works

### Example Flow:

```
Initial State:
  Cart: Product A x 10 (from previous session)
  Total Stock: 50
  Provider._initialQuantities: {}
  Provider._hasUserAction: false

Step 1: Open CartPage (first time)
  → captureInitialQuantities()
  → Provider._initialQuantities: {productA_id: 10}
  → Display: "Stock: 50 | Total: 50"

Step 2: User adds 5 items
  → markUserAction()
  → Provider._hasUserAction: true
  → Quantity: 10 → 15
  → Delta: 15 - 10 = 5
  → Display: "Stock: 45 | Total: 50" ✅

Step 3: User navigates away
  → Widget disposed
  → Provider state preserved ✅

Step 4: User returns to CartPage
  → Widget recreated
  → Check: Provider._initialQuantities NOT empty
  → Skip recapture
  → Provider._hasUserAction: still true
  → Display: "Stock: 45 | Total: 50" ✅ (preserved!)
```

## ✨ Key Features

### 1. **Delta Calculation**

```
Example 1 - Add Items:
  Initial: 10, Current: 15
  Delta: 15 - 10 = 5
  Stock: 50 - 5 = 45 ✅

Example 2 - Remove Items:
  Initial: 10, Current: 8
  Delta: 8 - 10 = -2
  Stock: 50 - (-2) = 52 ✅ (can exceed total!)
```

### 2. **State Persistence**

- State in `CartProvider` (global)
- Survives widget disposal
- No recapture on revisit

### 3. **Smart Recapture**

```dart
if (cartProvider.initialQuantities.isEmpty && cartProvider.items.isNotEmpty) {
  cartProvider.captureInitialQuantities();
}
```

Only capture when:

- No initial data yet
- Cart has items

### 4. **Clear on Boundaries**

```dart
clearCart() → Clear all state
clearItems() → Clear all state
```

## 📝 Documentation Files

1. **TWO_STAGE_STOCK_DISPLAY.md** - Delta-based calculation explanation
2. **PERSISTENT_STOCK_STATE_FIX.md** - Persistent state implementation
3. **CART_STOCK_REALTIME_UPDATE_FIX.md** - Consumer pattern for updates
4. **DEBOUNCED_PRODUCT_REFRESH_FIX.md** - Debounced refresh strategy

## 🧪 Test Scenarios

### ✅ Scenario 1: Navigate Away and Return

```
1. Open cart → Stock: 50 | 50
2. Add 5 items → Stock: 45 | 50
3. Navigate away
4. Return to cart → Stock: 45 | 50 ✅ (preserved!)
```

### ✅ Scenario 2: Multiple Products

```
1. Product A x 10, Product B x 5
2. Add 3 to Product A
3. Navigate away and return
4. Product A stock reflects +3 delta ✅
5. Product B stock unchanged ✅
```

### ✅ Scenario 3: Clear Cart

```
1. Cart with items and state
2. Clear cart
3. State reset ✅
4. Add new items → Fresh start ✅
```

## 🎯 Benefits

### For Users:

- ✅ Consistent stock display
- ✅ No confusion from reset values
- ✅ Accurate stock tracking
- ✅ Seamless navigation

### For Developers:

- ✅ Clean state management
- ✅ Predictable behavior
- ✅ Easy to maintain
- ✅ Well documented

## 🚀 Result

**Problem Solved:**

- ❌ Stock reset saat navigasi → ✅ Persistent state
- ❌ Double-count existing items → ✅ Delta-based calculation
- ❌ Confusing initial display → ✅ Two-stage display
- ❌ Widget state unreliable → ✅ Provider state management

**Stock Display Sekarang:**

1. **Accurate** - Delta-based calculation
2. **Persistent** - State in Provider
3. **Consistent** - No reset on navigation
4. **User-friendly** - Clear two-stage display
