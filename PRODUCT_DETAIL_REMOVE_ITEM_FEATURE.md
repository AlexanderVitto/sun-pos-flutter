# Fitur Hapus Item dari Cart di Halaman Detail Produk

## Deskripsi

Implementasi fitur untuk menghapus item dari keranjang belanja dengan mengatur quantity menjadi 0 di halaman detail produk.

## Tanggal

5 Oktober 2025

## Fitur yang Diimplementasikan

### 1. Hapus Item dengan Quantity = 0

Pengguna sekarang dapat menghapus item dari cart dengan cara:

- Mengatur quantity variant menjadi 0 menggunakan tombol minus (-)
- Mengetik 0 langsung di input field quantity
- Setelah klik "Simpan Perubahan", item akan dihapus dari cart

### 2. Visual Feedback

- **Tombol berubah dinamis**:

  - Jika ada item dengan quantity > 0: "Simpan Perubahan" dengan icon ➕
  - Jika hanya ada item dengan quantity = 0: "Hapus dari Keranjang" dengan icon 🗑️
  - Jika tidak ada perubahan: "Pilih Varian" (disabled)

- **Notifikasi visual**:
  - Info hijau: Menampilkan jumlah varian yang akan ditambahkan/diupdate
  - Alert merah: Menampilkan jumlah item yang akan dihapus dari keranjang

## File yang Dimodifikasi

### 1. `product_detail_viewmodel.dart`

#### a. Method `setVariantQuantity`

**Sebelum:**

```dart
if (validQuantity == 0) {
  _variantQuantities.remove(variantId);
} else {
  _variantQuantities[variantId] = validQuantity;
}
```

**Sesudah:**

```dart
// Allow 0 to mark item for removal from cart
// Store the quantity (including 0) to track removal intent
_variantQuantities[variantId] = validQuantity;
```

**Alasan:** Menyimpan quantity = 0 untuk tracking item mana yang perlu dihapus dari cart.

#### b. Method `updateCartQuantity`

**Penambahan logic untuk menghapus item:**

```dart
// First, check for items to remove (quantity = 0)
final itemsToRemove = <int>[];
for (final entry in _variantQuantities.entries) {
  final variantId = entry.key;
  final quantity = entry.value;

  if (quantity == 0) {
    // Check if this variant exists in cart
    final existingItem = _cartProvider!.items.firstWhere(
      (item) => item.product.productVariantId == variantId,
      orElse: () => _cartProvider!.items.first,
    );

    if (existingItem.product.productVariantId == variantId) {
      // Mark for removal
      itemsToRemove.add(existingItem.id);
      print(
        '🗑️ ProductDetailViewModel: Marking variant $variantId for removal (quantity = 0)',
      );
    }
  }
}

// Remove items with quantity = 0
for (final itemId in itemsToRemove) {
  _cartProvider!.removeItem(itemId);
  print('🗑️ ProductDetailViewModel: Removed item $itemId from cart');
}
```

**Cleanup setelah update berhasil:**

```dart
// Clean up variant quantities - remove entries with 0 after successful update
_variantQuantities.removeWhere((key, value) => value == 0);
```

### 2. `add_to_cart_section.dart`

#### a. Tracking Item untuk Dihapus

```dart
// Check for items with quantity = 0 (marked for removal)
final itemsToRemove = viewModel.variantQuantities.entries
    .where((entry) => entry.value == 0)
    .length;
final hasChanges = hasSelection || itemsToRemove > 0;
```

#### b. Tombol Dinamis

```dart
child: ElevatedButton(
  onPressed: hasChanges ? onAddToCart : null,
  child: Row(
    children: [
      Icon(
        hasSelection
            ? LucideIcons.plus
            : (itemsToRemove > 0
                ? LucideIcons.trash2
                : LucideIcons.packageX),
      ),
      Text(
        hasSelection
            ? 'Simpan Perubahan'
            : (itemsToRemove > 0
                ? 'Hapus dari Keranjang'
                : 'Pilih Varian'),
      ),
    ],
  ),
),
```

#### c. Notifikasi Visual

```dart
// Info untuk item yang akan dihapus
if (itemsToRemove > 0 && !hasSelection)
  Container(
    decoration: BoxDecoration(
      color: const Color(0xFFFEF2F2),
      border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
    ),
    child: Row(
      children: [
        const Icon(LucideIcons.alertCircle, color: Color(0xFFEF4444)),
        Text(
          '$itemsToRemove item akan dihapus dari keranjang',
          style: const TextStyle(color: Color(0xFFEF4444)),
        ),
      ],
    ),
  ),
```

## Alur Kerja (User Flow)

1. **User membuka halaman detail produk**

   - ViewModel load product detail
   - Initialize variant quantities dari cart (jika sudah ada di cart)

2. **User mengatur quantity variant menjadi 0**

   - Klik tombol minus (-) hingga quantity = 0, atau
   - Ketik 0 langsung di input field
   - `setVariantQuantity` dipanggil dan menyimpan quantity = 0

3. **UI menampilkan feedback**

   - Tombol berubah menjadi "Hapus dari Keranjang"
   - Alert merah muncul: "X item akan dihapus dari keranjang"

4. **User klik tombol "Hapus dari Keranjang"**

   - `updateCartQuantity` dipanggil
   - Item dengan quantity = 0 diidentifikasi
   - Item dihapus dari CartProvider menggunakan `removeItem`
   - Draft transaction di-update ke server
   - Product detail di-reload untuk refresh stock info
   - Variant quantities dengan value = 0 dibersihkan dari map

5. **UI terupdate**
   - Item hilang dari cart
   - Stock tersedia bertambah
   - Tombol kembali ke state default

## Keuntungan Implementasi

1. **User Experience yang Intuitif**

   - User bisa menghapus item langsung dari halaman detail produk
   - Tidak perlu navigasi ke halaman cart untuk menghapus item
   - Visual feedback yang jelas tentang aksi yang akan dilakukan

2. **Konsistensi Data**

   - Cart di-sync dengan server melalui draft transaction
   - Stock info selalu update setelah perubahan
   - No data inconsistency antara local state dan server

3. **Flexible**
   - Support multi-variant update sekaligus
   - Bisa tambah, update, dan hapus item dalam satu aksi
   - State management yang clean

## Testing Checklist

- [x] Set quantity ke 0 dengan tombol minus
- [x] Set quantity ke 0 dengan input manual
- [x] Tombol berubah menjadi "Hapus dari Keranjang"
- [x] Alert merah muncul untuk item yang akan dihapus
- [x] Item berhasil dihapus dari cart setelah klik tombol
- [x] Stock tersedia bertambah setelah item dihapus
- [x] Draft transaction terupdate di server
- [x] UI terupdate dengan benar setelah penghapusan
- [x] Kombinasi hapus dan tambah item berfungsi dengan baik

## Catatan Teknis

### State Management

- `_variantQuantities` map sekarang menyimpan quantity = 0 untuk tracking removal
- Cleanup dilakukan setelah update berhasil untuk menjaga state tetap clean
- `notifyListeners()` dipanggil di tempat yang tepat untuk update UI

### Cart Provider Integration

- Menggunakan existing `removeItem` method dari CartProvider
- Sync dengan draft transaction menggunakan PaymentService
- Reload product detail untuk refresh data dari server

### Error Handling

- Try-catch di `updateCartQuantity` untuk handle error
- Print log untuk debugging
- Return boolean untuk success/failure indication

## Related Files

1. `/lib/features/products/presentation/viewmodels/product_detail_viewmodel.dart`
2. `/lib/features/products/presentation/widgets/add_to_cart_section.dart`

## See Also

- `STACK_OVERFLOW_ERROR_FIX.md` - Fix untuk build issue sebelumnya
- `MULTI_VARIANT_SELECTION_FEATURE.md` - Base feature untuk multi-variant selection
