# Implementasi Fitur Thermal Printer untuk ESC/POS

## Overview

Fitur thermal printer telah ditambahkan ke aplikasi POS untuk mencetak struk pembayaran menggunakan ESC/POS thermal printers yang umum digunakan di kasir.

## Dependencies Yang Ditambahkan

```yaml
# Thermal Printer
esc_pos_utils: ^1.1.0
esc_pos_printer: ^4.0.2
network_info_plus: ^6.1.4
```

## Komponen Yang Dibuat

### 1. ThermalPrinterService (`thermal_printer_service.dart`)

Service untuk mengelola koneksi dan pencetakan ke thermal printer:

**Fitur Utama:**

- **Discover Printers**: Mencari printer di jaringan lokal (simplified network scanning)
- **Connect to Printer**: Menghubungkan ke printer via IP address dan port
- **Print Receipt**: Mencetak struk transaksi dengan format ESC/POS
- **Test Print**: Mencetak halaman test untuk verifikasi koneksi
- **Disconnect**: Memutus koneksi printer

**Methods:**

```dart
Future<List<String>> discoverPrinters()
Future<bool> connectToPrinter(String ipAddress, {int port = 9100})
Future<bool> printReceipt({...})
Future<bool> testPrint()
void disconnect()
```

### 2. PrinterSettingsDialog (`printer_settings_dialog.dart`)

Dialog untuk pengaturan dan koneksi printer:

**Fitur:**

- **Auto Discovery**: Pencarian otomatis printer di jaringan
- **Manual Connection**: Input manual IP address dan port
- **Connection Status**: Indikator status koneksi
- **Test Print**: Tombol untuk test print setelah koneksi
- **Tips & Info**: Panduan penggunaan untuk user

### 3. Enhanced ReceiptPage (`receipt_page.dart`)

ReceiptPage yang sudah diupgrade dari StatelessWidget ke StatefulWidget:

**Fitur Baru:**

- **Printer Menu**: PopupMenuButton dengan opsi printer
- **Dynamic Icons**: Icon berubah berdasarkan status koneksi printer
- **Print Receipt**: Implementasi pencetakan ke thermal printer
- **Setup Printer**: Akses ke dialog pengaturan printer
- **Test Print**: Fungsi test print langsung dari receipt page

## Cara Penggunaan

### 1. Setup Printer Pertama Kali

1. Tap icon printer di ReceiptPage
2. Pilih "Pengaturan Printer"
3. Gunakan "Cari Printer Otomatis" atau input manual IP address
4. Klik "Hubungkan" untuk koneksi dan test print

### 2. Mencetak Struk

1. Pastikan printer sudah terhubung (icon printer berwarna)
2. Tap icon printer → "Cetak Struk"
3. Loading akan muncul selama proses pencetakan
4. Notification akan muncul untuk konfirmasi hasil

### 3. Test Print

1. Tap icon printer → "Test Print"
2. Printer akan mencetak halaman test dengan informasi koneksi

## Format Struk Yang Dicetak

```
================================
     NAMA TOKO
  Alamat Toko
       Telp: No. Telepon
================================

STRUK PEMBAYARAN
================================

No. Transaksi: TXN-20240907-001
Tanggal       : 07/09/2024 14:30
Kasir         : Admin POS
Pembayaran    : Tunai

--------------------------------
DETAIL PEMBELIAN
--------------------------------
Item                 Qty   Total
--------------------------------
Nama Produk 1
Rp 15,000             2   Rp 30,000

Nama Produk 2
Rp 8,500              1   Rp 8,500

--------------------------------
Subtotal             Rp 38,500
Diskon               Rp 3,500
================================
TOTAL BAYAR          Rp 35,000
================================

CATATAN:
[Catatan khusus jika ada]

        TERIMA KASIH
      Atas kunjungan Anda

Barang yang sudah dibeli tidak dapat
ditukar kembali kecuali ada kerusakan
dari pihak toko
```

## Konfigurasi Printer

### Pengaturan Default

- **Paper Size**: 58mm thermal paper (PaperSize.mm58)
- **Port**: 9100 (standar ESC/POS)
- **Encoding**: UTF-8
- **Connection**: TCP/IP over WiFi

### Printer Yang Kompatibel

- Semua printer thermal yang mendukung ESC/POS protocol
- Brand umum: Epson, Star, Citizen, Bixolon, dll
- Koneksi WiFi/Ethernet dengan port 9100

## Error Handling

### Kemungkinan Error dan Solusi

1. **"Printer belum terhubung"**

   - Pastikan printer dan device di WiFi yang sama
   - Cek IP address printer
   - Restart printer dan coba lagi

2. **"Gagal terhubung ke printer"**

   - Verifikasi IP address dan port
   - Pastikan printer dalam kondisi ready
   - Cek firewall settings

3. **"Test print gagal"**

   - Cek kertas thermal masih ada
   - Pastikan tidak ada paper jam
   - Restart printer connection

4. **"Gagal mencetak struk"**
   - Cek koneksi network
   - Pastikan printer tidak sedang digunakan aplikasi lain
   - Coba test print terlebih dahulu

## Network Requirements

### Untuk Auto Discovery

- Device dan printer harus dalam network yang sama
- Subnet mask biasanya 255.255.255.0
- IP range yang di-scan: 192.168.1.100-200, 192.168.0.100-200, 10.0.0.100-200

### Untuk Manual Connection

- IP address printer (cek di pengaturan printer)
- Port 9100 (default ESC/POS)
- Koneksi TCP yang stabil

## Tips Optimasi

1. **Simpan Settings**: IP address yang berhasil konek disimpan untuk penggunaan berikutnya
2. **Connection Reuse**: Service mempertahankan koneksi untuk multiple print jobs
3. **Error Recovery**: Auto-retry untuk koneksi yang terputus
4. **Background Processing**: Pencetakan tidak blocking UI

## Future Enhancements

1. **Bluetooth Support**: Untuk printer Bluetooth
2. **Multiple Printer Support**: Manage beberapa printer sekaligus
3. **Print Templates**: Custom template untuk berbagai jenis struk
4. **Print Queue**: Antrian pencetakan untuk volume tinggi
5. **QR Code**: Integrasi QR code di struk untuk verifikasi

## Technical Notes

- Menggunakan package `esc_pos_utils` untuk format ESC/POS commands
- `esc_pos_printer` untuk network connectivity
- Paper size default 58mm, bisa dikustomisasi sesuai kebutuhan
- Font dan styling disesuaikan dengan capabilities printer thermal

Fitur thermal printer ini memberikan pengalaman POS yang lebih profesional dan sesuai dengan kebutuhan bisnis retail modern.
