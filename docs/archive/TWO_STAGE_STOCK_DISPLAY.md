# Feature: Delta-Based Stock Display di Cart Page

## 📋 Feature Description

Stock badge di halaman keranjang menggunakan **delta-based calculation**:

1. **Stage 1 (Initial)**: Saat pertama buka cart page → Menampilkan total stock dari system
2. **Stage 2 (After Action)**: Setelah user melakukan action → Menampilkan stock dikurangi **delta (perubahan quantity)**

Delta = Quantity sekarang - Quantity awal saat page dibuka

Ini memberikan stock yang akurat berdasarkan **perubahan** yang user buat, bukan total quantity di cart.

## ✨ How It Works

### Stage 1: Initial Display (Before Any Action)

```dart
// When cart page first opens
bool _hasUserAction = false;
Map<int, int> _initialQuantities = {};  // Store initial quantity per product

// In initState - capture initial quantities
for (var item in cartProvider.items) {
  _initialQuantities[item.product.id] = item.quantity;
}

// Stock calculation (delta = 0 initially)
final deltaQuantity = quantityInCart - initialQuantity;  // 10 - 10 = 0
final availableStock = _hasUserAction
    ? totalStockInSystem - deltaQuantity  // After action
    : totalStockInSystem;                 // Before action (initial)

// Result: Show total stock from system
```

**Display:**

```
Product A - Total Stock: 50
Cart: Product A x 10 (existing items from before)

Stock Badge: "Stok Tersisa: 50 | Total: 50"
(Shows full stock - delta is 0 because no change yet)
```

### Stage 2: After User Action

```dart
// User clicks [+] to add 3 more
setState(() {
  _hasUserAction = true; // Flag set to true
});

// Stock calculation with delta
final initialQuantity = 10;           // Quantity saat page dibuka
final quantityInCart = 13;            // Quantity sekarang (10 + 3)
final deltaQuantity = 13 - 10 = 3;    // Perubahan dari initial

final availableStock = totalStockInSystem - deltaQuantity;  // 50 - 3 = 47

// Result: Show stock dikurangi DELTA (bukan total quantity)
```

**Display:**

```
After user adds 3 more:

Stock Badge: "Stok Tersisa: 47 | Total: 50"
(50 - 3 = 47, dikurangi DELTA dari initial, bukan dikurangi total 13)
```

## 🎯 User Flow

### Scenario: Open Cart with Existing Items (Delta-Based)

```
Initial State:
  - Cart already has: Product A x 10 (quantity dari sebelumnya)
  - Total stock in system: 50
  - Initial quantities map: {productId: 10}

Step 1: User opens cart page
  - _hasUserAction: false
  - quantityInCart: 10
  - initialQuantity: 10 (from map)
  - deltaQuantity: 10 - 10 = 0

  Stock Badge: "Stok Tersisa: 50 | Total: 50" ✅
  (Showing original stock - delta is 0)

Step 2: User clicks [+] 3 times (add 3 items)
  - _hasUserAction: true ✅
  - quantityInCart: 13
  - initialQuantity: 10 (tetap dari map)
  - deltaQuantity: 13 - 10 = 3 ✅
  - Recalculation: 50 - 3 = 47

  Stock Badge: "Stok Tersisa: 47 | Total: 50" ✅
  (Dikurangi DELTA = 3, bukan total quantity 13)

Step 3: User clicks [-] 2 times (remove 2 items)
  - _hasUserAction: already true
  - quantityInCart: 11
  - initialQuantity: 10 (tetap dari map)
  - deltaQuantity: 11 - 10 = 1 ✅
  - Recalculation: 50 - 1 = 49

  Stock Badge: "Stok Tersisa: 49 | Total: 50" ✅
  (Dikurangi DELTA = 1, karena net change dari initial cuma +1)

Step 4: User manually updates quantity to 15 via dialog
  - _hasUserAction: true ✅
  - quantityInCart: 15
  - initialQuantity: 10 (tetap dari map)
  - deltaQuantity: 15 - 10 = 5 ✅
  - Recalculation: 50 - 5 = 45

  Stock Badge: "Stok Tersisa: 45 | Total: 50" ✅
  (Dikurangi DELTA = 5 dari initial)
```

## 💻 Implementation Details

### **File**: `lib/features/sales/presentation/pages/cart_page.dart`

#### **1. Add State Variables**

```dart
class _CartPageState extends State<CartPage> {
  bool _hasUserAction = false;              // ✅ Track if user has made any cart action
  Map<int, int> _initialQuantities = {};    // ✅ Store initial quantity per product

  @override
  void initState() {
    super.initState();

    // Capture initial quantities for all cart items
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(context, listen: false);

      // ✅ Save initial quantity for each product
      for (var item in cartProvider.items) {
        _initialQuantities[item.product.id] = item.quantity;
      }

      // Refresh products when cart page opens
      productProvider.refreshProducts();
    });
  }
  // ...
}
```

#### **2. Delta-Based Stock Calculation**

```dart
Widget _buildCartItem(...) {
  return Consumer<ProductProvider>(
    builder: (context, productProvider, child) {
      // Get total stock from system
      int totalStockInSystem = currentProduct.stock;

      // Calculate total quantity in cart for this product
      final quantityInCart = cartProvider.items
          .where((cartItem) => cartItem.product.id == item.product.id)
          .fold<int>(0, (sum, cartItem) => sum + cartItem.quantity);

      // ✅ Get initial quantity from map (quantity saat page dibuka)
      final initialQuantity = _initialQuantities[item.product.id] ?? 0;

      // ✅ Calculate delta (perubahan dari initial)
      final deltaQuantity = quantityInCart - initialQuantity;

      // ✅ Delta-based calculation
      final availableStock = _hasUserAction
          ? totalStockInSystem - deltaQuantity  // Stage 2: Dikurangi DELTA
          : totalStockInSystem;                 // Stage 1: Full stock

      // Determine stock status
      final isLowStock = availableStock > 0 && availableStock <= 10;
      final isOutOfStock = availableStock <= 0;

      return Container(
        // ... cart item UI
      );
```

#### **3. Set Flag on Decrease Action**

```dart
IconButton(
  onPressed: () {
    debugPrint('🔽 Decreasing quantity...');

    setState(() {
      _hasUserAction = true; // ✅ Mark action taken
    });

    cartProvider.decreaseQuantity(
      item.id,
      context: context,
    );
  },
  icon: const Icon(LucideIcons.minus),
)
```

#### **4. Set Flag on Increase Action**

```dart
IconButton(
  onPressed: () {
    debugPrint('🔼 Increasing quantity...');

    setState(() {
      _hasUserAction = true; // ✅ Mark action taken
    });

    cartProvider.addItem(
      item.product,
      context: context,
    );
  },
  icon: const Icon(LucideIcons.plus),
)
```

#### **5. Set Flag on Manual Update**

```dart
void _updateQuantity(...) {
  final quantity = int.tryParse(value);
  // ... validation

  setState(() {
    _hasUserAction = true; // ✅ Mark action taken
  });

  cartProvider.updateItemQuantity(item.id, quantity, context: context);
  PosUIHelpers.showSuccessSnackbar(context, 'Jumlah berhasil diperbarui');
}
```

## 📊 Visual Comparison

### Before Delta-Based (Old):

```
Cart opens with Product A x 10 (from previous session)
Total stock: 50

Stock Badge: "Stok Tersisa: 40 | Total: 50"
(Immediately deducted by total quantity 10)

❌ Problem: User tidak tahu stock asli berapa
❌ Problem: Quantity 10 mungkin sudah di-add sebelumnya, tapi dikurangi lagi
```

### After Delta-Based (Current):

```
Stage 1 - Cart opens with Product A x 10 (from previous session)
Total stock: 50
Initial quantity saved: 10

Stock Badge: "Stok Tersisa: 50 | Total: 50"
(Shows original stock - delta is 0)

✅ User dapat melihat stock asli
✅ Tidak dikurangi quantity existing

---

Stage 2 - User adds 5 more (quantity becomes 15)
Delta: 15 - 10 = 5

Stock Badge: "Stok Tersisa: 45 | Total: 50"
(Dikurangi DELTA = 5, bukan total 15)

✅ User dapat melihat efek dari action mereka
✅ Stock dikurangi hanya perubahan yang user buat di session ini
```

## 🎯 Benefits

### 1. **Better Initial Context**

- User lihat stock asli dulu
- Tidak bingung dengan angka yang sudah dikurangi
- Know total capacity

### 2. **Accurate Session Tracking**

- Stock dikurangi hanya perubahan di session ini
- Tidak double-count quantity existing
- Delta-based calculation more accurate

### 3. **Clear Action Feedback**

- Stage 1: Informasi awal
- Stage 2: Feedback dari actions
- User understand impact

### 4. **Multi-Session Friendly**

- Cart dengan existing items handled correctly
- Tidak dikurangi stock untuk items yang sudah ada
- Only deduct changes user makes

## 🧪 Test Scenarios

### Test 1: Fresh Cart Open (With Existing Items)

```
Setup:
1. Cart already has Product A x 10 (from previous session)
2. System stock: 50
3. Open cart page

Expected:
  _initialQuantities[productId]: 10 ✅
  _hasUserAction: false
  quantityInCart: 10
  deltaQuantity: 10 - 10 = 0
  availableStock: 50 (full stock, delta is 0)
  Badge: "Stok Tersisa: 50 | Total: 50" ✅
```

### Test 2: First Action - Add Item

```
1. Initial badge: "50 | 50"
2. Click [+] button 3 times
3. Quantity: 10 → 13

Expected:
  _hasUserAction: true ✅
  quantityInCart: 13
  initialQuantity: 10 (from map)
  deltaQuantity: 13 - 10 = 3 ✅
  availableStock: 50 - 3 = 47
  Badge: "Stok Tersisa: 47 | Total: 50" ✅
```

### Test 3: Decrease Below Initial

```
1. Current quantity: 13
2. Click [-] button 5 times
3. Quantity: 13 → 8

Expected:
  _hasUserAction: true
  quantityInCart: 8
  initialQuantity: 10 (tetap dari map)
  deltaQuantity: 8 - 10 = -2 ✅ (negative delta!)
  availableStock: 50 - (-2) = 52 ✅
  Badge: "Stok Tersisa: 52 | Total: 50"

Note: Stock bisa melebihi total karena user mengurangi dari initial!
```

### Test 3: First Increase

```
1. Initial badge: "20 | 20"
2. Click [+] button
3. Quantity: 5 → 6

Expected:
  _hasUserAction: true ✅
  availableStock: 20 - 6 = 14
  Badge: "Stok Tersisa: 14 | Total: 20" ✅
```

### Test 4: Manual Update

```
1. Initial badge: "20 | 20"
2. Click on quantity → dialog opens
3. Input: 10
4. Save

Expected:
  _hasUserAction: true ✅
  availableStock: 20 - 10 = 10
  Badge: "Stok Tersisa: 10 | Total: 20" ✅
```

### Test 5: Multiple Actions

```
1. Initial: "20 | 20" (_hasUserAction: false)
2. Click [+]: "19 | 20" (_hasUserAction: true)
3. Click [+]: "18 | 20" (_hasUserAction: true)
4. Click [-]: "19 | 20" (_hasUserAction: true)

Expected:
  Flag stays true after first action ✅
  Subsequent actions use deducted calculation ✅
```

## 🔄 State Flow

```
Cart Page Opens
  ↓
_hasUserAction = false
  ↓
availableStock = totalStockInSystem
  ↓
Display: "Stok Tersisa: 50 | Total: 50"
  ↓
User clicks [+] or [-] or updates manually
  ↓
setState(() { _hasUserAction = true })
  ↓
Widget rebuilds
  ↓
availableStock = totalStockInSystem - quantityInCart
  ↓
Display: "Stok Tersisa: 40 | Total: 50"
  ↓
All subsequent actions use deducted calculation
```

## 💡 Why This Approach?

### Problem Solved:

**Before**: User melihat stock yang sudah dikurangi quantity di cart sejak awal

- Confusing: "Kenapa stock 40 padahal di system 50?"
- User tidak tahu stock asli berapa

**After**: User melihat progression yang natural

1. Pertama: Stock asli dari system (50)
2. Setelah action: Stock tersisa setelah dikurangi cart (40)

### User Mental Model:

```
Stage 1: "Ini stock yang ada di system"
   ↓
Stage 2: "Ini stock tersisa setelah saya pakai"
```

## 🔮 Alternative Approaches Considered

### Approach 1: Always Deduct (Rejected)

```dart
availableStock = totalStockInSystem - quantityInCart;
```

❌ User tidak dapat context stock asli

### Approach 2: Show Both Values Side-by-side (Complex)

```dart
Text('Stock: $totalStockInSystem | Tersisa: $remaining');
```

❌ Terlalu banyak informasi, membingungkan

### Approach 3: Two-Stage Display (Selected) ✅

```dart
availableStock = _hasUserAction
    ? totalStockInSystem - quantityInCart
    : totalStockInSystem;
```

✅ Progressive disclosure
✅ Clear mental model
✅ User-friendly

## 📚 Key Learnings

1. **Progressive Disclosure** lebih baik daripada show semua info sekaligus
2. **User Action Tracking** dengan state flag simple tapi effective
3. **Context Matters**: Stock asli vs stock tersisa punya makna berbeda
4. **setState()** trigger rebuild untuk update visual
5. **Two-stage approach** mirrors user mental model

## 🎓 Best Practices Applied

1. **Clear State Management**

   ```dart
   bool _hasUserAction = false; // Single source of truth
   ```

2. **Consistent Flag Setting**

   ```dart
   setState(() {
     _hasUserAction = true; // Set on every action
   });
   ```

3. **Conditional Logic**

   ```dart
   final availableStock = _hasUserAction
       ? calculated
       : original;
   ```

4. **User-Centric Design**
   - Show what user needs when they need it
   - Don't overwhelm with calculations upfront

---

**Status**: ✅ Implemented
**Date**: October 13, 2025
**Feature Type**: UX Enhancement - Two-Stage Stock Display
**Impact**: Better user understanding, clearer context
**Technology**: Flutter StatefulWidget, setState, conditional rendering
