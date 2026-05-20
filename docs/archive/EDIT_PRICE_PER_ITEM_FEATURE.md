# Implementasi Fitur Edit Harga Per Item

## Ringkasan

Fitur ini memungkinkan pengguna untuk mengubah harga per item di halaman Order Confirmation menggunakan Modal Bottom Sheet yang elegant dan user-friendly. **Harga yang sudah diubah akan terkirim ke backend saat submit**.

## Perubahan yang Dilakukan

### 1. OrderConfirmationPage Enhancement

**File**: `/lib/features/sales/presentation/pages/order_confirmation_page.dart`

#### State Management

- Menambahkan `_cartItems` dan `_totalAmount` sebagai variabel state yang bisa diubah
- Menambahkan method `_recalculateTotal()` untuk menghitung ulang total setelah perubahan harga
- **Updated callback signature** untuk mengirim updated cart items dan total amount

#### Modal Bottom Sheet Implementation

- **Method**: `_showEditPriceModal(int index)`
- Implementasi modal bottom sheet yang responsif dan modern
- Input field untuk edit harga dengan validasi
- UI yang konsisten dengan design system aplikasi

#### UI Enhancements

- Harga per item sekarang bisa diklik (GestureDetector)
- Visual indicator (icon edit) untuk menunjukkan bahwa harga bisa diubah
- Styling dengan container hijau untuk membedakan dari quantity

### 2. PaymentService Backend Integration

**File**: `/lib/features/sales/presentation/services/payment_service.dart`

#### Updated Callback Signature

```dart
// SEBELUM
final Function(String customerName, String customerPhone) onConfirm;

// SESUDAH
final Function(String customerName, String customerPhone, List<CartItem> updatedCartItems, double updatedTotalAmount) onConfirm;
```

#### Backend Integration

- **Method**: `_confirmOrder()` sekarang menerima updated cart items dan total amount
- **Cart Provider Update**: CartProvider di-update dengan harga yang sudah dimodifikasi sebelum dikirim ke backend
- **Transaction Processing**: Backend menerima data dengan harga yang sudah diubah

#### Integration Flow

```dart
// 1. Clear cart and re-populate with updated items
cartProvider.clearCart();
for (final item in updatedCartItems) {
  cartProvider.addItem(item.product, quantity: item.quantity);
}

// 2. Process transaction with updated data
transactionResponse = await transactionProvider.processPayment(
  cartItems: updatedCartItems,
  totalAmount: updatedTotalAmount,
  // ... other parameters
);
```

#### Features

- **Real-time calculation**: Total otomatis dihitung ulang setelah perubahan harga
- **Input validation**: Validasi untuk memastikan harga berupa angka positif
- **Error handling**: Menampilkan pesan error jika input tidak valid
- **Responsive design**: Modal menyesuaikan dengan keyboard

## Cara Menggunakan

1. **Akses halaman Order Confirmation**
2. **Lihat daftar produk** - setiap item menampilkan quantity dan harga
3. **Klik pada harga** (container hijau dengan icon edit)
4. **Modal akan muncul** dengan input field untuk harga baru
5. **Masukkan harga baru** dan klik "Simpan"
6. **Total akan otomatis terupdate**

## Detail Implementasi

### Modal Bottom Sheet Features

- **Curved corners** dengan radius 20px
- **Handle bar** di atas modal untuk indikasi drag
- **Product preview** menampilkan gambar dan nama produk
- **Auto-focus** pada input field
- **Keyboard responsive** - modal naik saat keyboard muncul

### Input Validation

- Harus berupa angka
- Harus lebih besar dari 0
- Format currency dengan prefix "Rp"

### State Management

```dart
// Variabel state
late List<CartItem> _cartItems;
late double _totalAmount;

// Method untuk recalculate
void _recalculateTotal() {
  setState(() {
    _totalAmount = _cartItems.fold(0.0, (sum, item) =>
      sum + (item.product.price * item.quantity));
  });
}
```

### UI Design

- **Consistent color scheme**: Menggunakan orange sebagai primary color
- **Visual hierarchy**: Quantity (biru), Price (hijau), Subtotal (orange)
- **Accessibility**: Tombol dengan size yang cukup untuk touch
- **Loading states**: Disabled state saat processing

## Benefits

1. **Flexibility**: Cashier bisa menyesuaikan harga per item sesuai kebutuhan
2. **Real-time feedback**: Total langsung terupdate
3. **User-friendly**: Interface yang intuitif dan mudah digunakan
4. **Error prevention**: Validasi input mencegah error
5. **Professional appearance**: Design yang konsisten dengan aplikasi
6. **✅ Backend Integration**: Harga yang diubah benar-benar terkirim ke server
7. **✅ Data Consistency**: CartProvider terupdate dengan harga baru sebelum submit
8. **✅ Transaction Accuracy**: Backend menerima data yang akurat

## Technical Flow

### Data Flow Sequence

```
1. User clicks price in OrderConfirmationPage
2. Modal opens with current price
3. User edits price and saves
4. _cartItems updated with new price
5. _totalAmount recalculated
6. User clicks "Konfirmasi Pesanan"
7. Updated data sent to PaymentService
8. CartProvider cleared and repopulated with new prices
9. Transaction processed with correct data
10. Backend receives accurate pricing
```

## Integration Points

Fitur ini terintegrasi dengan:

- **CartItem model**: Menggunakan `copyWith()` method
- **Product model**: Menggunakan `copyWith()` method untuk update harga
- **Parent widgets**: Menyediakan getter untuk updated data

## Future Enhancements

Potential improvements:

1. **Bulk edit**: Edit multiple prices sekaligus
2. **Price history**: Track perubahan harga
3. **Discount system**: Apply percentage atau fixed discount
4. **Price templates**: Save frequently used custom prices
5. **Audit trail**: Log siapa yang mengubah harga

## Technical Notes

- Menggunakan `copyWith()` pattern untuk immutable data
- State management dengan `setState()`
- Responsive design dengan `MediaQuery.viewInsets`
- Error handling dengan try-catch dan SnackBar
- Memory efficient dengan late initialization
