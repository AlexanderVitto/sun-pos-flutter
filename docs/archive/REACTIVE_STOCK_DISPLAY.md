# Reactive Stock Display Implementation

## Perubahan yang Dilakukan

Menambahkan fitur reactive stock display pada list produk di POS, dimana stok yang ditampilkan adalah stok aktual dikurangi dengan quantity yang sudah ada di cart.

## 1. CartProvider Enhancement

**File**: `lib/features/sales/providers/cart_provider.dart`

### Method Baru yang Ditambahkan:

```dart
// Get quantity of product variant in cart by productVariantId
int getProductVariantQuantity(int? productVariantId) {
  if (productVariantId == null) return 0;

  try {
    final item = _items.firstWhere(
      (item) => item.product.productVariantId == productVariantId,
    );
    return item.quantity;
  } catch (e) {
    return 0;
  }
}

// Get remaining stock for a product variant (actual stock - quantity in cart)
int getRemainingStock(int actualStock, int? productVariantId) {
  final quantityInCart = getProductVariantQuantity(productVariantId);
  return actualStock - quantityInCart;
}
```

### Penjelasan Method:

#### `getProductVariantQuantity(int? productVariantId)`

- Mengambil quantity dari product variant yang ada di cart berdasarkan `productVariantId`
- Lebih akurat daripada `getProductQuantity()` yang berdasarkan `product.id`
- Return `0` jika product variant tidak ada di cart atau `productVariantId` null
- Menggunakan `firstWhere` untuk mencari item dengan productVariantId yang sesuai

#### `getRemainingStock(int actualStock, int? productVariantId)`

- Menghitung remaining stock = actual stock - quantity in cart
- Digunakan untuk menampilkan stok yang tersedia (belum masuk cart)
- Parameter:
  - `actualStock`: Stok aktual dari database/API
  - `productVariantId`: ID variant untuk mengecek quantity di cart
- Return: Stok yang tersisa setelah dikurangi quantity di cart

## 2. ProductCard Update

**File**: `lib/features/sales/presentation/widgets/product_card.dart`

### Before:

```dart
// Stock Info
Text(
  'Stok: ${widget.product.stock}',
  style: TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: widget.product.stock < 10
        ? const Color(0xFFef4444)
        : const Color(0xFF6b7280),
    letterSpacing: 0.1,
  ),
),
```

### After:

```dart
// Stock Info - Shows remaining stock (actual stock - quantity in cart)
Consumer<CartProvider>(
  builder: (context, cartProvider, child) {
    final remainingStock = cartProvider.getRemainingStock(
      widget.product.stock,
      widget.product.productVariantId,
    );

    return Text(
      'Stok: $remainingStock',
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: remainingStock < 10
            ? const Color(0xFFef4444)
            : const Color(0xFF6b7280),
        letterSpacing: 0.1,
      ),
    );
  },
),
```

### Perubahan:

1. **Reactive Display**: Menggunakan `Consumer<CartProvider>` untuk reactive updates
2. **Dynamic Calculation**: Menghitung `remainingStock` menggunakan method `getRemainingStock()`
3. **Color Logic Update**: Warning color (red) berdasarkan `remainingStock` bukan `product.stock`
4. **Real-time Update**: Stock akan otomatis update ketika ada perubahan di cart (add/remove/update quantity)

## 3. Cara Kerja

### Flow:

1. **User adds item dari ProductDetailPage**:

   ```
   ProductDetailPage -> CartProvider.addItem() -> notifyListeners()
   ```

2. **ProductCard mendeteksi perubahan**:

   ```
   Consumer<CartProvider> rebuild -> getRemainingStock() dipanggil ulang
   ```

3. **Stock dihitung ulang**:

   ```
   remainingStock = actualStock - quantityInCart
   ```

4. **UI Update**:
   ```
   Text widget menampilkan remainingStock yang baru
   ```

### Example:

```
Product: "Nasi Goreng"
- actualStock: 10
- productVariantId: 123

Scenario 1 - No items in cart:
- getProductVariantQuantity(123) = 0
- getRemainingStock(10, 123) = 10 - 0 = 10
- Display: "Stok: 10"

Scenario 2 - 3 items in cart:
- User adds 3x "Nasi Goreng" to cart
- getProductVariantQuantity(123) = 3
- getRemainingStock(10, 123) = 10 - 3 = 7
- Display: "Stok: 7"

Scenario 3 - All items in cart:
- User adds 10x "Nasi Goreng" to cart
- getProductVariantQuantity(123) = 10
- getRemainingStock(10, 123) = 10 - 10 = 0
- Display: "Stok: 0" (red color)
```

## 4. Keuntungan Implementasi Ini

### 1. **User Experience**

- User bisa langsung melihat stok yang tersisa
- Tidak perlu menghitung manual (stok - quantity di cart)
- Visual feedback langsung ketika menambah/kurangi item

### 2. **Prevent Overselling**

- Stok yang ditampilkan sudah memperhitungkan item di cart
- Mengurangi risiko user menambahkan lebih dari stok yang tersedia
- Warning color (red) muncul jika remaining stock < 10

### 3. **Real-time Sync**

- Stok di POS list otomatis update ketika ada perubahan di cart
- Tidak perlu refresh page atau reload data
- Konsisten di semua tempat (ProductDetailPage dan POS list)

### 4. **Accurate Calculation**

- Menggunakan `productVariantId` untuk akurasi tinggi
- Mendukung multiple variants dari product yang sama
- Method `getRemainingStock()` bisa digunakan di tempat lain

## 5. Testing Checklist

- [x] Add item dari ProductDetailPage, stock di POS list berkurang
- [x] Remove item dari cart, stock di POS list bertambah
- [x] Update quantity di cart, stock di POS list update accordingly
- [x] Multiple products dengan variant berbeda, stock calculation terpisah
- [x] Stock warning color (red) muncul ketika remaining stock < 10
- [x] Stock display 0 ketika semua item sudah di cart

## 6. Files Modified

1. `lib/features/sales/providers/cart_provider.dart`

   - Added: `getProductVariantQuantity()` method
   - Added: `getRemainingStock()` method

2. `lib/features/sales/presentation/widgets/product_card.dart`
   - Changed: Static stock display to reactive `Consumer<CartProvider>`
   - Updated: Stock calculation logic to use `getRemainingStock()`

## Technical Notes

- Method `getProductVariantQuantity()` menggunakan `productVariantId` lebih akurat daripada `product.id`
- `Consumer<CartProvider>` hanya rebuild widget stock, tidak rebuild seluruh ProductCard
- Method `getRemainingStock()` bisa reused di komponen lain yang perlu display remaining stock
- Warning color threshold (< 10) konsisten dengan logic sebelumnya
