# Implementasi Fitur Diskon Per Item pada Order Confirmation

## Ringkasan

Fitur ini telah diubah dari diskon total harga menjadi **diskon per item** dengan menggunakan input persentase yang sama. Diskon akan diterapkan ke setiap item secara individual, memberikan fleksibilitas yang lebih besar dalam penetapan harga.

## Perubahan dari Diskon Total ke Diskon Per Item

### 🔄 **Concept Change**

#### Sebelum (Diskon Total)

```dart
// Diskon diterapkan ke total keseluruhan
double get discountAmount => subtotal * (_discountPercentage / 100);
double get updatedTotalAmount => subtotal - discountAmount;
```

#### Sesudah (Diskon Per Item)

```dart
// Diskon diterapkan ke setiap item individual
List<CartItem> get updatedCartItems => _cartItems.map((item) {
  final discountedPrice = item.product.price * (1 - (_discountPercentage / 100));
  return item.copyWith(
    product: item.product.copyWith(price: discountedPrice),
  );
}).toList();
```

### 🎯 **Key Benefits of Per-Item Discount**

1. **Individual Pricing Control**: Setiap item mendapat diskon yang sama secara persentase
2. **Accurate Item Pricing**: Harga per item yang sudah didiskon jelas terlihat
3. **Better Inventory Tracking**: Sistem inventory dapat track harga actual per item
4. **Consistent Discount Application**: Diskon diterapkan secara konsisten per item

## Technical Implementation

### 1. **Updated Data Structure**

```dart
// Original cart items (unchanged)
late List<CartItem> _cartItems;

// Updated cart items with discounted prices
List<CartItem> get updatedCartItems => _cartItems.map((item) {
  final discountedPrice = item.product.price * (1 - (_discountPercentage / 100));
  return item.copyWith(
    product: item.product.copyWith(price: discountedPrice),
  );
}).toList();
```

### 2. **Calculation Methods**

```dart
// Subtotal before discount
double get subtotal => _cartItems.fold(0.0, (sum, item) =>
  sum + (item.product.price * item.quantity));

// Subtotal after discount per item
double get subtotalAfterDiscount => updatedCartItems.fold(0.0, (sum, item) =>
  sum + (item.product.price * item.quantity));

// Total discount amount
double get discountAmount => subtotal - subtotalAfterDiscount;

// Final total (same as subtotalAfterDiscount)
double get updatedTotalAmount => subtotalAfterDiscount;
```

### 3. **UI Enhancements**

#### Product List Display

Setiap item menampilkan:

- **Original Price** (dengan strikethrough jika ada diskon)
- **Discounted Price** (harga final)
- **Discount Percentage Badge** (visual indicator)
- **Subtotal per Item** (quantity × discounted price)

#### Discount Card

- **Title**: "Diskon Per Item" (lebih spesifik)
- **Input Label**: "Diskon Per Item (%)" dengan helper text
- **Summary**: Menampilkan subtotal sebelum dan sesudah diskon

#### Bottom Total Display

- **Conditional Display**: Harga asli (coret) dan harga final
- **Discount Badge**: Menampilkan persentase diskon yang diterapkan

## Visual Implementation

### 1. **Product Item Display**

```
┌──────────────────────────────────────────────┐
│ [IMG] Product Name                           │
│ Qty: 2x  [Original: Rp 50,000] → Rp 45,000 │
│                     -10%                     │
│                              Subtotal: 90k   │
└──────────────────────────────────────────────┘
```

### 2. **Discount Card Layout**

```
┌─────────────────────────────────────┐
│ 🔴 Diskon Per Item                 │
│                                     │
│ [Input: 10%] → Total Hemat: 50k    │
│ ℹ️ Diskon diterapkan ke setiap item │
│                                     │
│ Subtotal (sebelum): Rp 500,000     │
│ Total setelah diskon: Rp 450,000   │
└─────────────────────────────────────┘
```

### 3. **Bottom Total Enhanced**

```
┌─────────────────────────────────────┐
│ Total Pesanan        Rp 500,000    │
│ 3 item              ────────────    │
│ Diskon 10% per item  Rp 450,000    │
└─────────────────────────────────────┘
```

## Backend Integration

### Updated Data Flow

```dart
// CartProvider receives items with discounted prices
cartProvider.clearCart();
for (final item in updatedCartItems) {
  // item.product.price already contains discounted price
  cartProvider.addItem(item.product, quantity: item.quantity);
}
```

### Transaction Data

- **Item Prices**: Backend menerima harga yang sudah didiskon per item
- **Discount Tracking**: Discount percentage tetap dikirim untuk audit trail
- **Accurate Totals**: Total amount sudah mencerminkan harga final

## Advantages Over Total Discount

### 1. **Granular Control**

- ✅ **Per-Item Pricing**: Setiap item memiliki harga final yang jelas
- ✅ **Consistent Application**: Diskon diterapkan merata ke semua item
- ✅ **Transparent Calculation**: Customer bisa lihat harga actual per item

### 2. **Business Benefits**

- ✅ **Inventory Accuracy**: Harga per item yang akurat untuk inventory tracking
- ✅ **Reporting Clarity**: Report menampilkan harga actual yang dibayar customer
- ✅ **Audit Trail**: Discount percentage tersimpan untuk keperluan audit

### 3. **User Experience**

- ✅ **Clear Display**: Harga asli dan harga diskon jelas terlihat
- ✅ **Real-time Feedback**: Perubahan diskon langsung terlihat per item
- ✅ **Professional Look**: Tampilan yang professional dengan price strikethrough

## Implementation Example

### Usage Scenario

```
1. Customer membeli 3 item:
   - Item A: Rp 100,000 x 1
   - Item B: Rp 50,000 x 2
   - Item C: Rp 25,000 x 1

2. Cashier memberikan diskon 10% per item:
   - Item A: Rp 90,000 x 1 = Rp 90,000
   - Item B: Rp 45,000 x 2 = Rp 90,000
   - Item C: Rp 22,500 x 1 = Rp 22,500

3. Total: Rp 202,500 (vs original Rp 225,000)
   Total hemat: Rp 22,500 (10% dari total)
```

## Migration Considerations

### Backward Compatibility

- ✅ **Same Input Method**: Menggunakan input field yang sama
- ✅ **Same UI Flow**: User experience tetap familiar
- ✅ **Same Validation**: Input validation 0-100% tetap sama

### Data Consistency

- ✅ **Price Accuracy**: Harga per item yang dikirim ke backend akurat
- ✅ **Total Calculation**: Total amount konsisten dengan sum of items
- ✅ **Discount Tracking**: Percentage diskon tetap tersimpan

---

**Status**: ✅ **UPGRADED & READY FOR PRODUCTION**

Fitur diskon telah berhasil diupgrade dari diskon total menjadi diskon per item dengan implementation yang lebih robust dan user-friendly! 🚀
