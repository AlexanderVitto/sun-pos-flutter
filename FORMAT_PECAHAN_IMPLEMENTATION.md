# Implementasi Format Pecahan pada Input Amount

## Ringkasan Implementasi

Telah berhasil menambahkan format pecahan pada semua input amount di aplikasi. Perubahan ini memungkinkan pengguna untuk memasukkan nilai dengan desimal menggunakan format Indonesia (koma sebagai pemisah desimal).

## Fitur Baru

### 1. DecimalTextInputFormatter

- **File**: `/lib/core/utils/decimal_text_input_formatter.dart`
- **Fungsi**: Custom formatter yang mendukung input desimal dengan format Indonesia
- **Format yang didukung**:
  - Angka bulat: `1000`
  - Angka desimal: `1000,50` (koma sebagai pemisah desimal)
  - Maksimal 2 digit desimal secara default

### 2. Helper Methods

- `parseDecimal(String text)`: Mengkonversi string input ke double (contoh: "1000,50" → 1000.50)
- `formatDecimal(double value)`: Memformat double ke string format Indonesia (contoh: 1000.50 → "1000,50")
- `formatCurrencyInput(double value)`: Format dengan pemisah ribuan (contoh: 1234567.89 → "1.234.567,89")

## File yang Dimodifikasi

### 1. PaymentConfirmationPage

- **File**: `lib/features/sales/presentation/pages/payment_confirmation_page.dart`
- **Perubahan**:
  - Menambahkan inputFormatters ke semua TextField amount (\_amountPaidController, \_cashAmountController, \_transferAmountController)
  - Mengupdate parsing menggunakan `DecimalTextInputFormatter.parseDecimal()`
  - Mendukung input desimal untuk pembayaran tunai dan transfer

### 2. PayOutstandingPage

- **File**: `lib/features/transactions/presentation/pages/pay_outstanding_page.dart`
- **Perubahan**:
  - Mengganti `FilteringTextInputFormatter.digitsOnly` dengan `DecimalTextInputFormatter()`
  - Mengupdate validasi dan parsing amount untuk mendukung desimal
  - Input pembayaran hutang sekarang mendukung format pecahan

### 3. AddCashFlowPage

- **File**: `lib/features/cash_flows/presentation/pages/add_cash_flow_page.dart`
- **Perubahan**:
  - Input jumlah cash flow sekarang mendukung desimal
  - Mengupdate validator dan parsing untuk format pecahan
  - Value tetap diconvert ke integer untuk API compatibility

### 4. CreateRefundPage

- **File**: `lib/features/refunds/presentation/pages/create_refund_page.dart`
- **Perubahan**:
  - Input amount untuk cash dan transfer refund mendukung desimal
  - Mengupdate parsing untuk semua perhitungan refund
  - Validasi amount tetap berfungsi dengan format pecahan

## Cara Penggunaan

### Format Input yang Didukung:

1. **Angka Bulat**:

   - Input: `15000`
   - Hasil: 15000.0

2. **Angka Desimal**:

   - Input: `15000,50`
   - Hasil: 15000.50

3. **Desimal Tanpa Angka Bulat**:
   - Input: `,50`
   - Hasil: 0.50

### Validasi:

- Hanya membolehkan angka dan satu koma desimal
- Maksimal 2 digit setelah koma
- Tidak membolehkan multiple koma
- Validasi minimum dan maksimum tetap berfungsi

## Backward Compatibility

- Semua input yang sebelumnya menggunakan angka bulat tetap berfungsi
- API calls tetap kompatibel (nilai dikonversi ke format yang sesuai)
- UI/UX tidak berubah secara visual, hanya menambah kemampuan input desimal

## Testing yang Disarankan

1. **Test Input Desimal**:

   - Masukkan nilai seperti `1000,50` di field amount
   - Pastikan parsing dan kalkulasi benar

2. **Test Validasi**:

   - Coba input invalid seperti `1000,,50` atau `1000,123`
   - Pastikan validasi menolak input tersebut

3. **Test Kalkulasi**:

   - Pastikan perhitungan total, kembalian, dll tetap akurat
   - Test dengan nilai desimal dan bulat

4. **Test API Integration**:
   - Pastikan data terkirim dengan benar ke backend
   - Verify format data sesuai ekspektasi API

## Catatan Teknis

- Format Indonesia menggunakan koma (,) sebagai pemisah desimal
- Implementasi tetap mendukung parsing dot (.) untuk compatibility internal
- Semua perhitungan menggunakan double precision
- Conversion ke integer dilakukan saat diperlukan untuk API compatibility
