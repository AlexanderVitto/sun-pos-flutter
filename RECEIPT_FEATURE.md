# Receipt/Struk Feature

Fitur receipt/struk untuk aplikasi POS yang menampilkan detail transaksi setelah pembayaran berhasil.

## Files yang Terkait

### 1. Receipt Page (`receipt_page.dart`)

**Lokasi:** `lib/features/sales/presentation/pages/receipt_page.dart`

**Fitur:**

- Header toko dengan logo dan informasi kontak
- Detail transaksi (nomor, tanggal, kasir, metode pembayaran)
- Daftar item yang dibeli dengan harga dan total
- Ringkasan total dengan subtotal, pajak, dan diskon
- Ucapan terima kasih dan informasi kebijakan
- Tombol share (copy ke clipboard) dan print
- Navigasi ke transaksi baru atau dashboard

**Parameter yang dibutuhkan:**

```dart
ReceiptPage(
  receiptId: 'TRX123456789',
  transactionDate: DateTime.now(),
  items: List<CartItem>,
  subtotal: 50000.0,
  tax: 5000.0,
  discount: 0.0,
  total: 55000.0,
  paymentMethod: 'Tunai',
)
```

### 2. Payment Success Page (`payment_success_page.dart`)

**Lokasi:** `lib/features/sales/presentation/pages/payment_success_page.dart`

**Fitur:**

- Animasi sukses dengan ikon centang
- Ringkasan transaksi (nomor, total, bayar, kembalian)
- Tombol navigasi ke receipt lengkap
- Tombol untuk transaksi baru atau kembali ke dashboard
- Terintegrasi dengan CartProvider untuk mendapatkan data cart

**Parameter yang dibutuhkan:**

```dart
PaymentSuccessPage(
  paymentMethod: 'Tunai',
  amountPaid: 55000.0,
)
```

### 3. Integrasi dengan POS Transaction

**File:** `lib/features/sales/presentation/pages/pos_transaction_page.dart`

Telah dimodifikasi untuk:

- Import PaymentSuccessPage
- Navigasi ke PaymentSuccessPage setelah konfirmasi pembayaran
- Clear cart sebelum navigasi

## Routes

Tambahkan routes berikut ke `app_routes.dart`:

```dart
static const String paymentSuccess = '/sales/payment-success';
static const String receipt = '/sales/receipt';
```

Dan ke `app_router.dart`:

```dart
case AppRoutes.paymentSuccess:
  final args = settings.arguments as Map<String, dynamic>?;
  if (args != null) {
    return MaterialPageRoute(
      builder: (_) => PaymentSuccessPage(
        paymentMethod: args['paymentMethod'] ?? 'Tunai',
        amountPaid: args['amountPaid'] ?? 0.0,
      ),
    );
  }
  return MaterialPageRoute(builder: (_) => const NewSalePage());

case AppRoutes.receipt:
  final args = settings.arguments as Map<String, dynamic>?;
  if (args != null) {
    return MaterialPageRoute(
      builder: (_) => ReceiptPage(
        receiptId: args['receiptId'] ?? '',
        transactionDate: args['transactionDate'] ?? DateTime.now(),
        items: args['items'] ?? [],
        subtotal: args['subtotal'] ?? 0.0,
        tax: args['tax'] ?? 0.0,
        discount: args['discount'] ?? 0.0,
        total: args['total'] ?? 0.0,
        paymentMethod: args['paymentMethod'] ?? 'Tunai',
      ),
    );
  }
  return MaterialPageRoute(builder: (_) => const NewSalePage());
```

## Demo Files

### 1. Simple Receipt Demo (`simple_receipt_demo.dart`)

Demo standalone untuk melihat tampilan receipt dengan data dummy.

### 2. POS Receipt Demo (`pos_receipt_demo.dart`)

Demo lengkap yang menunjukkan alur dari:

1. POS Transaction
2. Pemilihan produk dan cart management
3. Payment confirmation
4. Payment success page
5. Receipt lengkap

## Alur Penggunaan

1. **User melakukan transaksi di POS**

   - Pilih produk
   - Tambahkan ke cart
   - Klik tombol "BAYAR"

2. **Konfirmasi pembayaran**

   - Dialog konfirmasi dengan total
   - User klik "Bayar"

3. **Payment Success Page**

   - Tampilan sukses dengan ringkasan
   - Tombol "Lihat Struk" untuk receipt lengkap
   - Tombol "Transaksi Baru" untuk kembali ke POS
   - Tombol "Kembali ke Dashboard"

4. **Receipt Page**
   - Struk lengkap dengan semua detail
   - Tombol share dan print
   - Navigasi ke transaksi baru atau dashboard

## Customization

### Informasi Toko

Edit bagian `_buildStoreHeader()` di `receipt_page.dart`:

```dart
const Text(
  'TOKO SERBAGUNA JAYA',
  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
),
Text(
  'Jl. Merdeka No. 123, Yogyakarta\nTelp: (0274) 123-456',
  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
),
```

### Pajak dan Diskon

Modifikasi kalkulasi di `PaymentSuccessPage`:

```dart
final tax = subtotal * 0.1; // 10% tax
final discount = 0.0; // No discount
```

### Format Currency

Function `_formatPrice()` menggunakan format Indonesia:

```dart
String _formatPrice(double price) {
  return price.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]}.',
  );
}
```

## Dependencies

Pastikan dependencies berikut ada di `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
  lucide_icons: ^0.257.0
  intl: ^0.19.0
```

## Testing

Jalankan demo untuk testing:

```bash
# Demo receipt standalone
flutter run lib/simple_receipt_demo.dart

# Demo POS lengkap dengan receipt
flutter run lib/pos_receipt_demo.dart
```

## Screenshots

Demo menunjukkan:

- ✅ POS transaction page dengan product grid
- ✅ Cart management dengan badge counter
- ✅ Payment confirmation dialog
- ✅ Payment success page dengan animasi
- ✅ Receipt lengkap dengan header toko
- ✅ Share functionality (copy to clipboard)
- ✅ Navigation flow yang smooth

## Future Enhancements

1. **Print Integration**

   - Integrasi dengan printer thermal
   - PDF generation untuk digital receipt

2. **Email Receipt**

   - Input email customer
   - Send receipt via email

3. **Receipt Templates**

   - Multiple template designs
   - Customizable layouts

4. **Receipt History**
   - Save receipts locally
   - Search dan view past receipts
