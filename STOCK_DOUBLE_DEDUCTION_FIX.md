# Fix: Stock Berkurang 2x Saat Menambahkan 1 Item ke Keranjang

## Problem Description

Ketika user menambahkan 1 item ke keranjang dari halaman detail produk, stok berkurang 2 (seharusnya hanya berkurang 1).

**Example:**

- Stok awal: 66
- User klik "+" 1x (tambah 1 item)
- User klik "Tambahkan ke Keranjang"
- **Bug**: Stok menjadi 64 ❌
- **Expected**: Stok menjadi 65 ✅

## Root Cause Analysis

### Issue 1: Double Processing dengan Draft Transaction

Di `ProductDetailViewModel.updateCartQuantity()`, saat menambah item ke cart, ada 2 tempat yang memproses draft transaction:

1. **Di `CartProvider.addItem()`** - Otomatis memanggil `_processDraftTransaction(context)` jika context tersedia
2. **Di `ProductDetailViewModel`** - Manual memanggil `_updateDraftTransactionOnServer(context)`

Ini menyebabkan draft transaction di-process 2x, yang mungkin menyebabkan stok berkurang 2x di backend.

### Issue 2: Variant Quantities Tidak Di-Clear dengan Benar

Setelah sukses update cart, `_variantQuantities` perlu di-clear dan di-reinitialize dari cart untuk mencegah penambahan berulang. Tapi sebelum fix, logic clear-nya tidak sempurna:

```dart
// BEFORE (Bug):
_variantQuantities.removeWhere((key, value) => value == 0);
// Hanya remove yang 0, tapi yang > 0 masih tersimpan!

// AFTER (Fixed):
_variantQuantities.clear();
// Clear semua, lalu reinitialize dari cart
```

### Issue 3: Tidak Ada Re-initialization Setelah Reload

Setelah `_reloadProductDetail()`, tidak ada panggilan `_initializeVariantQuantitiesFromCart()`, sehingga `_variantQuantities` tidak sinkron dengan state cart yang sebenarnya.

## Solution

### Fix 1: Prevent Automatic Draft Transaction Processing

Hapus parameter `context` dari panggilan `addItem()` dan `updateItemQuantity()` untuk mencegah automatic draft transaction processing:

```dart
// BEFORE:
_cartProvider!.addItem(product, quantity: quantity, context: context);
_cartProvider!.updateItemQuantity(existingItem.id, quantity);

// AFTER:
_cartProvider!.addItem(product, quantity: quantity); // No context
_cartProvider!.updateItemQuantity(existingItem.id, quantity); // No context
```

Kita tetap manual call `_updateDraftTransactionOnServer(context)` SETELAH semua update selesai, untuk memastikan hanya 1x processing.

### Fix 2: Properly Clear Variant Quantities

Clear semua `_variantQuantities` setelah sukses update cart:

```dart
// Clear variant quantities after successful update to prevent double-adding
_variantQuantities.clear();
print('🧹 ProductDetailViewModel: Cleared variant quantities after successful cart update');
```

### Fix 3: Reinitialize After Reload

Tambahkan `_initializeVariantQuantitiesFromCart()` di `_reloadProductDetail()`:

```dart
Future<void> _reloadProductDetail() async {
  try {
    final response = await _apiService.getProduct(_productId);

    if (response.status == 'success') {
      _productDetail = response.data;
      _initializeQuantityFromCart();

      // Reinitialize variant quantities from cart to show current cart state
      _initializeVariantQuantitiesFromCart(); // ✅ Added
    }

    notifyListeners();
  } catch (e) {
    print('❌ Error reloading product detail: ${e.toString()}');
  }
}
```

## Complete Flow (After Fix)

### Scenario 1: Pertama Kali Menambah Item

1. **Page dibuka, cart kosong**

   - `loadProductDetail()` → `_initializeVariantQuantitiesFromCart()`
   - `_variantQuantities = {}` (kosong)

2. **User klik + pada variant 123**

   - `increaseVariantQuantity(123)`
   - `_variantQuantities[123] = 1`

3. **User klik "Tambahkan ke Keranjang"**
   - `updateCartQuantity()` dipanggil
   - Item 123 tidak ada di cart
   - `_cartProvider.addItem(product, quantity: 1)` ← **No context, no auto draft processing**
   - Cart sekarang punya item 123 dengan quantity 1 ✅
   - `_updateDraftTransactionOnServer(context)` ← **Manual call, 1x saja**
   - `_variantQuantities.clear()` → `{}`
   - `_reloadProductDetail()` → `_initializeVariantQuantitiesFromCart()`
   - `_variantQuantities[123] = 1` (dari cart)

### Scenario 2: Update Quantity Item yang Sudah Ada

4. **User klik + lagi**

   - `increaseVariantQuantity(123)`
   - `currentQty = 1` (dari `_variantQuantities`)
   - `_variantQuantities[123] = 2`

5. **User klik "Tambahkan ke Keranjang"**
   - `updateCartQuantity()` dipanggil
   - Item 123 **ADA** di cart dengan quantity 1
   - `_cartProvider.updateItemQuantity(existingItem.id, 2)` ← **No context, no auto draft processing**
   - Cart di-update ke quantity 2 ✅
   - `_updateDraftTransactionOnServer(context)` ← **Manual call, 1x saja**
   - `_variantQuantities.clear()` → `{}`
   - `_reloadProductDetail()` → `_initializeVariantQuantitiesFromCart()`
   - `_variantQuantities[123] = 2` (dari cart)

## Files Modified

### 1. `product_detail_viewmodel.dart`

**Changes:**

- Removed `context` parameter from `addItem()` and `updateItemQuantity()` calls
- Changed `_variantQuantities.removeWhere()` to `_variantQuantities.clear()`
- Added `_initializeVariantQuantitiesFromCart()` call in `_reloadProductDetail()`

**Location:** `lib/features/products/presentation/viewmodels/product_detail_viewmodel.dart`

### 2. `cart_item.dart` (Enhancement - Not Related to Bug)

**Changes:**

- Added discount support (percentage & fixed amount)
- Added new getters for calculations
- Added helper methods

**Location:** `lib/data/models/cart_item.dart`

## Testing Checklist

- [x] Tambah 1 item baru ke cart → Stok berkurang 1 ✅
- [x] Tambah 1 item lagi (update existing) → Stok berkurang 1 lagi ✅
- [x] Variant quantities di-clear setelah update
- [x] Variant quantities di-reinitialize dari cart setelah reload
- [x] Draft transaction hanya di-process 1x
- [x] No duplicate cart items
- [x] Stock calculation correct

## Prevention

Untuk mencegah masalah serupa di masa depan:

1. **Consistent Draft Transaction Processing**: Pilih salah satu approach:

   - **Option A**: Automatic processing di CartProvider (pass context)
   - **Option B**: Manual processing di caller (don't pass context) ← **Current approach**

2. **Clear State After Update**: Selalu clear temporary state (`_variantQuantities`) setelah sukses update

3. **Reinitialize After Reload**: Selalu reinitialize state dari source of truth (cart) setelah reload

4. **Add Logging**: Gunakan print statements untuk debugging flow execution

## Verification

```dart
// Check logs for this flow:
🛒 CartProvider: Adding item ... x 1
➕ ProductDetailViewModel: Added variant ... to cart with quantity 1
📡 ProductDetailViewModel: Draft transaction updated on server
🧹 ProductDetailViewModel: Cleared variant quantities after successful cart update
🔄 ProductDetailViewModel: Reloading product detail data
✅ ProductDetailViewModel: Product detail reloaded successfully
```

Pastikan:

- `Adding item` hanya muncul 1x
- `Draft transaction updated` hanya muncul 1x
- `Cleared variant quantities` muncul setelah cart update
- `Product detail reloaded` muncul terakhir

---

**Date Fixed**: October 10, 2025
**Status**: ✅ RESOLVED
**Tested**: Manual testing passed
