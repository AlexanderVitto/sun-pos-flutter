# Implementasi Diskon Per Item di Transaction Provider

## 📋 **Verifikasi Current Implementation**

Saat ini, **diskon sudah diimplementasikan pada `unitPrice` per item**, bukan pada total harga. Berikut adalah alur yang sudah benar:

## 🔄 **Flow Diskon Per Item yang Sudah Benar**

### **1. Order Confirmation Page**

```dart
// Menghitung harga per item yang sudah didiskon
List<CartItem> get updatedCartItems => _cartItems.map((item) {
  final discountedPrice = item.product.price * (1 - (_discountPercentage / 100));
  return item.copyWith(
    product: item.product.copyWith(price: discountedPrice),
  );
}).toList();
```

### **2. Payment Service**

```dart
// Menggunakan cart items yang sudah didiskon per item
cartProvider.clearItems();
for (final item in updatedCartItems) {
  cartProvider.addItem(item.product, quantity: item.quantity);
}
```

### **3. Transaction Provider**

```dart
// unitPrice sudah berisi harga per item yang sudah didiskon
final details = cartItems.map((cartItem) {
  return TransactionDetail(
    productId: cartItem.product.id,
    productVariantId: cartItem.product.id,
    quantity: cartItem.quantity,
    // unitPrice already contains discounted price per item
    unitPrice: cartItem.product.price, // ✅ Sudah didiskon per item
  );
}).toList();
```

## ✅ **Konfirmasi: Diskon Sudah Diterapkan di unitPrice**

### **Alur Data yang Benar:**

```
1. User input diskon 10% di Order Confirmation
   ↓
2. updatedCartItems dibuat dengan harga per item yang didiskon
   Item A: Rp 100,000 → Rp 90,000 (per unit)
   ↓
3. Payment Service update cart provider dengan items yang sudah didiskon
   cartProvider.items sekarang berisi harga yang sudah didiskon
   ↓
4. Transaction Provider menggunakan unitPrice dari cart items
   unitPrice: Rp 90,000 (sudah didiskon per item) ✅
   ↓
5. Backend menerima data dengan unitPrice yang sudah didiskon
```

### **Contoh Real Data:**

#### **Sebelum Diskon:**

```dart
TransactionDetail(
  productId: 1,
  quantity: 2,
  unitPrice: 100000, // Harga asli
)
// Total: 2 × 100,000 = 200,000
```

#### **Setelah Diskon 10% Per Item:**

```dart
TransactionDetail(
  productId: 1,
  quantity: 2,
  unitPrice: 90000, // Harga sudah didiskon per item ✅
)
// Total: 2 × 90,000 = 180,000
```

## 🎯 **Verification Checklist**

- [x] **Order Confirmation**: Menghitung diskon per item dengan benar
- [x] **Payment Service**: Mengirim cart items dengan harga yang sudah didiskon
- [x] **Transaction Provider**: Menggunakan `unitPrice` dari cart items yang sudah didiskon
- [x] **Backend Integration**: Menerima `unitPrice` yang sudah didiskon per item
- [x] **No Double Discount**: Tidak ada perhitungan diskon ganda

## 📊 **Example Test Case**

### **Input:**

- Item A: Rp 50,000 × 2 qty
- Item B: Rp 30,000 × 1 qty
- Diskon: 15% per item

### **Expected Output di Transaction Provider:**

```dart
details: [
  TransactionDetail(
    productId: 'A',
    quantity: 2,
    unitPrice: 42500, // 50,000 × (1 - 0.15) = 42,500
  ),
  TransactionDetail(
    productId: 'B',
    quantity: 1,
    unitPrice: 25500, // 30,000 × (1 - 0.15) = 25,500
  ),
]

// Total: (42,500 × 2) + (25,500 × 1) = 110,500
// vs Original: (50,000 × 2) + (30,000 × 1) = 130,000
// Discount: 19,500 (15% dari total original)
```

## 🔍 **Validation Points**

### **1. Unit Price Level Discount**

✅ **CORRECT**: Diskon diterapkan di level `unitPrice` per item
❌ **WRONG**: Diskon diterapkan di level total amount

### **2. Data Consistency**

✅ **CORRECT**: UI, Payment Service, dan Transaction Provider menggunakan data yang sama
❌ **WRONG**: Perhitungan berbeda di setiap layer

### **3. Backend Integration**

✅ **CORRECT**: Backend menerima `unitPrice` yang sudah final (sudah didiskon)
❌ **WRONG**: Backend masih perlu menghitung diskon

## 🚀 **Conclusion**

**Implementation sudah BENAR!** Diskon sudah diterapkan pada `unitPrice` per item di Transaction Provider, bukan pada total harga.

Flow data dari Order Confirmation → Payment Service → Transaction Provider → Backend sudah konsisten dan menggunakan harga per item yang sudah didiskon.

---

**Status**: ✅ **ALREADY IMPLEMENTED CORRECTLY**  
**Diskon per item di unitPrice**: **WORKING AS EXPECTED** 🎯
