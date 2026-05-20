# Cart Page Implementation - Perubahan dari Bottom Sheet ke Full Page

## 📋 Ringkasan Perubahan

Implementasi ini mengubah tampilan keranjang belanja dari **Bottom Sheet** menjadi **Full Page** dengan fitur real-time stock update.

## ✅ Fitur yang Diimplementasikan

### 1. **Cart Page (Halaman Keranjang Penuh)**

- ✅ Mengubah dari modal bottom sheet ke halaman penuh
- ✅ UI yang lebih luas dan user-friendly
- ✅ AppBar dengan tombol back dan clear cart
- ✅ Tampilan detail item yang lebih lengkap

### 2. **Real-time Stock Update**

- ✅ Stok produk otomatis refresh saat halaman cart dibuka
- ✅ Stok update otomatis ketika quantity berubah (tambah/kurang/hapus)
- ✅ Badge stok dengan indikator warna:
  - 🟢 **Hijau**: Stok aman (> 10)
  - 🟡 **Kuning**: Stok rendah (1-10)
  - 🔴 **Merah**: Stok habis (0)

### 3. **Input Manual Quantity**

- ✅ Klik pada angka quantity untuk input manual
- ✅ Dialog input dengan validasi stok
- ✅ Auto-validate terhadap stok tersedia
- ✅ Peringatan jika melebihi stok

### 4. **Fitur Tambahan**

- ✅ Tombol hapus item individual
- ✅ Tombol kosongkan keranjang
- ✅ Konfirmasi dialog sebelum hapus
- ✅ Empty state yang informatif
- ✅ Loading dan error handling

## 📁 File yang Dibuat/Diubah

### File Baru:

1. **`lib/features/sales/presentation/pages/cart_page.dart`**
   - Halaman cart penuh menggantikan bottom sheet
   - Real-time stock monitoring
   - Input quantity manual
   - Remove item functionality

### File Dimodifikasi:

1. **`lib/features/sales/presentation/pages/pos_transaction_page.dart`**

   - Import `cart_page.dart` menggantikan `cart_bottom_sheet.dart`
   - Mengubah `showModalBottomSheet` menjadi `Navigator.push`
   - Navigasi ke CartPage

2. **`lib/features/products/presentation/widgets/variants_section.dart`**
   - Sudah ada fitur input manual quantity (dari request sebelumnya)

## 🎨 Desain UI

### Cart Page Layout:

```
┌─────────────────────────────────┐
│ ← Keranjang (3)    [Kosongkan] │ AppBar
├─────────────────────────────────┤
│                                 │
│  ┌───────────────────────────┐ │
│  │ Product Name              │ │
│  │ Rp 15.000                 │ │
│  │ [Stok: 50] 🟢            │ │ Cart Item Card
│  │                           │ │
│  │ Jumlah: [−] 5 [+]        │ │
│  │ Subtotal: Rp 75.000      │ │
│  └───────────────────────────┘ │
│                                 │
├─────────────────────────────────┤
│ Total (3 item): Rp 225.000     │
│ [PROSES PEMBAYARAN]            │ Footer
└─────────────────────────────────┘
```

## 🔄 Flow Real-time Stock Update

### Saat Cart Page Dibuka:

1. `initState()` memanggil `_refreshProducts()`
2. `ProductProvider.refreshProducts()` dipanggil
3. Data produk terbaru diambil dari API
4. Stock badge di setiap item cart terupdate

### Saat Quantity Berubah:

1. User klik tombol (+), (-), atau input manual
2. `CartProvider.updateItemQuantity()` / `addItem()` / `decreaseQuantity()`
3. `_refreshProducts()` dipanggil otomatis
4. Stock terupdate di UI
5. Tombol (+) disabled jika quantity >= stock

### Diagram Flow:

```
User Action (Change Qty)
        ↓
CartProvider Update
        ↓
_refreshProducts()
        ↓
ProductProvider.refreshProducts()
        ↓
API Call (Get Latest Products)
        ↓
UI Update (Stock Badge)
```

## 🚀 Cara Penggunaan

### Membuka Cart Page:

```dart
// Di POS Transaction Page
void _showCartBottomSheet(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CartPage(
        viewModel: viewModel,
        onPaymentPressed: () => _processPayment(context),
      ),
    ),
  );
}
```

### Refresh Products Otomatis:

```dart
void _refreshProducts() {
  final productProvider = Provider.of<ProductProvider>(
    context,
    listen: false,
  );
  productProvider.refreshProducts();
}
```

### Stock Indicator Logic:

```dart
final isLowStock = availableStock > 0 && availableStock <= 10;
final isOutOfStock = availableStock <= 0;

// Badge Color:
// - Red (0xFFef4444): Out of stock
// - Yellow (0xFFf59e0b): Low stock
// - Green (0xFF10b981): Available
```

## 📊 Perbandingan: Before vs After

### Before (Bottom Sheet):

- ❌ Ruang terbatas (70% screen)
- ❌ Tidak bisa scroll dengan nyaman
- ❌ Stock tidak terupdate real-time
- ❌ Sulit edit quantity besar

### After (Full Page):

- ✅ Full screen, lebih leluasa
- ✅ Scroll smooth & comfortable
- ✅ Real-time stock update
- ✅ Input manual untuk quantity besar
- ✅ Stock badge dengan visual indicator
- ✅ Better UX untuk delete items

## 🎯 Keuntungan Implementasi

### 1. **User Experience**

- Lebih mudah melihat dan mengelola cart
- Stock information selalu up-to-date
- Prevent overselling (quantity > stock)

### 2. **Business Logic**

- Real-time inventory tracking
- Accurate stock display
- Prevent order failures due to stock issues

### 3. **Developer Experience**

- Clean separation of concerns
- Reusable ProductProvider.refreshProducts()
- Easy to maintain and extend

## 🔧 Methods yang Digunakan

### CartProvider:

```dart
void updateItemQuantity(int itemId, int quantity, {BuildContext? context})
void addItem(Product product, {int quantity = 1, BuildContext? context})
void decreaseQuantity(int itemId, {BuildContext? context})
void removeItem(int itemId, {BuildContext? context})
void clearCart()
```

### ProductProvider:

```dart
Future<void> refreshProducts() async
List<Product> get products
```

## ⚠️ Catatan Penting

1. **Stock Validation**:

   - Tombol (+) otomatis disabled jika quantity >= stock
   - Input manual divalidasi terhadap stock tersedia
   - Error message jika melebihi stock

2. **Auto Refresh**:

   - Products di-refresh saat cart page dibuka
   - Products di-refresh setiap kali quantity berubah
   - Ensures data consistency

3. **Performance**:
   - Refresh dilakukan secara asynchronous
   - UI tetap responsive selama refresh
   - Error handling untuk network issues

## 🧪 Testing Checklist

- [x] Cart page terbuka dengan benar
- [x] Stock badge menampilkan jumlah yang benar
- [x] Stock color indicator sesuai (green/yellow/red)
- [x] Tombol (+) disabled ketika quantity = stock
- [x] Input manual quantity berfungsi
- [x] Validasi stock di input manual
- [x] Hapus item berfungsi
- [x] Kosongkan cart berfungsi
- [x] Stock update setelah perubahan quantity
- [x] Navigasi back ke POS page
- [x] Process payment berfungsi

## 📝 Contoh Penggunaan

### 1. Buka Cart Page:

```dart
// User klik icon cart di AppBar
_showCartBottomSheet(context);
```

### 2. Update Quantity dengan Input Manual:

```dart
// User klik pada angka quantity
GestureDetector(
  onTap: () => _showQuantityInputDialog(...),
  child: Text('${item.quantity}'),
)
```

### 3. Monitor Stock Real-time:

```dart
Consumer<ProductProvider>(
  builder: (context, productProvider, child) {
    final availableStock = getCurrentStock(item);
    return StockBadge(stock: availableStock);
  },
)
```

## 🎨 Customization

### Mengubah Threshold Stock Rendah:

```dart
// Di cart_page.dart, line ~247
final isLowStock = availableStock > 0 && availableStock <= 10;
// Ubah 10 ke nilai lain sesuai kebutuhan
```

### Mengubah Warna Stock Badge:

```dart
// Red: 0xFFef4444 (Out of stock)
// Yellow: 0xFFf59e0b (Low stock)
// Green: 0xFF10b981 (Available)
```

## 🔮 Future Enhancements

1. **Pull to Refresh**: Tambah gesture pull-to-refresh di cart page
2. **Auto Refresh Interval**: Refresh products setiap X detik
3. **Stock Change Animation**: Animasi saat stock berubah
4. **Batch Update**: Update multiple items sekaligus
5. **Stock Reservation**: Reserve stock saat item di cart

## 📞 Support

Jika ada pertanyaan atau issue:

1. Check console logs untuk debugging
2. Pastikan ProductProvider tersedia di context
3. Verify API response untuk stock data
4. Check network connectivity

---

**Status**: ✅ Implemented & Tested
**Date**: October 13, 2025
**Version**: 1.0.0
