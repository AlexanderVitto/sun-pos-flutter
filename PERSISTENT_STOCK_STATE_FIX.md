# Fix: Persistent Stock State Across Cart Page Navigation

## 🐛 Problem

Stock calculation tidak persist ketika keluar dari `CartPage` dan kembali lagi:

- `_initialQuantities` dan `_hasUserAction` di-reset karena widget state disposed
- Stock kembali menampilkan nilai awal, bukan nilai yang sudah diubah
- User kehilangan tracking perubahan yang sudah dibuat

**Contoh Issue:**

```
1. User buka CartPage → Stock: 50 | 50
2. User add 5 items → Stock: 45 | 50 ✅
3. User keluar dari CartPage
4. User kembali ke CartPage → Stock: 50 | 50 ❌ (reset!)
```

## ✅ Solution

Pindahkan state tracking dari `CartPage` widget ke `CartProvider` (global state):

### **Before** (Widget State - Tidak Persist):

```dart
// ❌ Di _CartPageState - disposed saat widget destroyed
bool _hasUserAction = false;
Map<int, int> _initialQuantities = {};
```

### **After** (Provider State - Persist):

```dart
// ✅ Di CartProvider - persist selama app lifecycle
Map<int, int> _initialQuantities = {};
bool _hasUserAction = false;

// Getters
Map<int, int> get initialQuantities => Map.unmodifiable(_initialQuantities);
bool get hasUserAction => _hasUserAction;
```

## 🔧 Implementation

### 1. **CartProvider** - Add State Management

#### **State Variables**

```dart
class CartProvider extends ChangeNotifier {
  // ... existing fields
  Map<int, int> _initialQuantities = {}; // ✅ Store initial quantities per product ID
  bool _hasUserAction = false; // ✅ Track if user has made any cart action

  // Getters
  Map<int, int> get initialQuantities => Map.unmodifiable(_initialQuantities);
  bool get hasUserAction => _hasUserAction;

  // ...
}
```

#### **Capture Initial Quantities**

```dart
// ✅ Capture initial quantities for stock calculation
void captureInitialQuantities() {
  _initialQuantities.clear();
  for (var item in _items) {
    _initialQuantities[item.product.id] = item.quantity;
  }
  _hasUserAction = false; // Reset user action flag
  debugPrint('📊 Captured initial quantities: $_initialQuantities');
}
```

#### **Mark User Action**

```dart
// ✅ Mark that user has performed an action
void markUserAction() {
  if (!_hasUserAction) {
    _hasUserAction = true;
    notifyListeners();
    debugPrint('✋ User action marked');
  }
}
```

#### **Clear State on Cart Clear**

```dart
void clearCart() {
  _items.clear();
  _selectedCustomer = null;
  _discountAmount = 0.0;
  _customerName = null;
  _customerPhone = null;
  _draftTransactionId = null;
  _initialQuantities.clear(); // ✅ Clear initial quantities
  _hasUserAction = false; // ✅ Reset user action flag
  _clearError();
  notifyListeners();
}

void clearItems() {
  _items.clear();
  _initialQuantities.clear(); // ✅ Clear initial quantities when clearing items
  _hasUserAction = false; // ✅ Reset user action flag
  notifyListeners();
}
```

#### **Mark Action on All Cart Operations**

```dart
// In addItem()
debugPrint('🛒 Current items after add: ${_items.length}');
markUserAction(); // ✅ Mark that user has taken action
_clearError();
notifyListeners();

// In updateItemQuantity()
_items[index] = item.copyWith(quantity: newQuantity);
markUserAction(); // ✅ Mark that user has taken action
_clearError();
notifyListeners();

// In decreaseQuantity()
_items[index] = item.copyWith(quantity: newQuantity);
debugPrint('✅ Updated item at index $index to quantity: $newQuantity');
markUserAction(); // ✅ Mark that user has taken action
notifyListeners();

// In decreaseQuantityByProductId()
_items[index] = item.copyWith(quantity: newQuantity);
markUserAction(); // ✅ Mark that user has taken action
notifyListeners();
```

### 2. **CartPage** - Use Provider State

#### **Remove Local State**

```dart
class _CartPageState extends State<CartPage> {
  // ❌ REMOVED:
  // bool _hasUserAction = false;
  // Map<int, int> _initialQuantities = {};

  @override
  void initState() {
    super.initState();
    // ...
  }
}
```

#### **Capture Initial Quantities on Page Open**

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    productProvider.refreshProducts();

    // ✅ Capture initial quantities in CartProvider if not already captured
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    if (cartProvider.initialQuantities.isEmpty && cartProvider.items.isNotEmpty) {
      cartProvider.captureInitialQuantities();
    }
  });
}
```

#### **Use Provider State in Stock Calculation**

```dart
Widget _buildCartItem(...) {
  return Consumer<ProductProvider>(
    builder: (context, productProvider, child) {
      // ...

      // ✅ Get initial quantity from CartProvider
      final initialQuantity = cartProvider.initialQuantities[item.product.id] ?? 0;

      // Calculate delta (change in quantity)
      final deltaQuantity = quantityInCart - initialQuantity;

      // ✅ Available stock calculation using CartProvider flag
      final availableStock = cartProvider.hasUserAction
          ? totalStockInSystem - deltaQuantity
          : totalStockInSystem;

      // ...
    },
  );
}
```

#### **Mark User Action via Provider**

```dart
// ❌ BEFORE (local state):
setState(() {
  _hasUserAction = true;
});

// ✅ AFTER (provider):
cartProvider.markUserAction();
```

**Examples:**

```dart
// Decrease button
onPressed: () {
  debugPrint('🔽 Decreasing quantity...');
  cartProvider.markUserAction(); // ✅
  cartProvider.decreaseQuantity(item.id, context: context);
}

// Increase button
onPressed: () {
  debugPrint('🔼 Increasing quantity...');
  cartProvider.markUserAction(); // ✅
  cartProvider.addItem(item.product, context: context);
}

// Manual quantity update
void _updateQuantity(...) {
  // ... validation
  cartProvider.markUserAction(); // ✅
  cartProvider.updateItemQuantity(item.id, quantity, context: context);
}
```

## 🎯 How It Works

### Scenario: Navigate Away and Return

```
Session Start:
  - Cart has: Product A x 10 (from previous session)
  - CartProvider._initialQuantities: {} (empty)
  - CartProvider._hasUserAction: false

Step 1: User opens CartPage (first time)
  - captureInitialQuantities() called
  - CartProvider._initialQuantities: {productA_id: 10}
  - CartProvider._hasUserAction: false
  - Display: "Stock: 50 | Total: 50" ✅

Step 2: User adds 5 items
  - markUserAction() called
  - CartProvider._hasUserAction: true ✅
  - Quantity: 10 → 15
  - Delta: 15 - 10 = 5
  - Display: "Stock: 45 | Total: 50" ✅

Step 3: User navigates away (CartPage disposed)
  - Widget state destroyed
  - ✅ BUT CartProvider state preserved:
    - _initialQuantities: {productA_id: 10}
    - _hasUserAction: true

Step 4: User returns to CartPage (recreated)
  - Widget recreated (fresh _CartPageState)
  - In initState: Check if initialQuantities already exists
  - CartProvider._initialQuantities: {productA_id: 10} ✅ (still there!)
  - CartProvider._hasUserAction: true ✅ (still true!)
  - Skip captureInitialQuantities() (already has data)
  - Display: "Stock: 45 | Total: 50" ✅ (preserved!)
```

### When to Recapture

```dart
if (cartProvider.initialQuantities.isEmpty && cartProvider.items.isNotEmpty) {
  cartProvider.captureInitialQuantities();
}
```

**Recapture when:**

- `initialQuantities` is empty AND
- Cart has items

**Don't recapture when:**

- `initialQuantities` already has data (user returning)
- Cart is empty (no items to track)

## ✨ Benefits

### 1. **State Persistence**

- Initial quantities preserved across navigation
- User action flag maintained
- Stock calculation consistent

### 2. **Better UX**

- No confusion from reset values
- Stock display stays accurate
- Seamless navigation experience

### 3. **Proper State Management**

- Global state in Provider (persist)
- Local state in Widget (UI only)
- Clear separation of concerns

### 4. **Accurate Tracking**

- Delta calculation preserved
- Multi-session cart handled correctly
- No double-counting of existing items

## 🧪 Test Cases

### Test 1: Navigate Away and Return

```
1. Open CartPage with existing items
2. Add some items
3. Navigate away (back to product list)
4. Return to CartPage

Expected:
  ✅ Stock display same as before leaving
  ✅ Initial quantities preserved
  ✅ User action flag preserved
```

### Test 2: Clear Cart

```
1. Add items to cart
2. Navigate away and return (state preserved)
3. Clear entire cart
4. Add new items

Expected:
  ✅ Initial quantities cleared
  ✅ User action flag reset to false
  ✅ New items start fresh
```

### Test 3: Multiple Products

```
1. Add Product A x 10
2. Capture initial: {A: 10}
3. Add Product B x 5
4. Navigate away and return
5. Increase Product A by 3

Expected:
  ✅ Product A initial: 10 (preserved)
  ✅ Product B initial: 5 (captured on first open)
  ✅ Product A delta: 3
  ✅ Stock calculations accurate
```

## 📝 Key Takeaways

1. **Widget state is temporary** - Disposed saat widget destroyed
2. **Provider state is persistent** - Survive across navigation
3. **Capture once, use everywhere** - No need to recapture on every visit
4. **Clear on logical boundaries** - Clear cart → clear state
5. **Mark actions in provider** - Consistent state updates

## 🚀 Result

Stock state sekarang **persistent across navigation**:

- ✅ Initial quantities preserved
- ✅ User action flag maintained
- ✅ Stock calculation accurate
- ✅ No reset on page revisit
- ✅ Seamless user experience
