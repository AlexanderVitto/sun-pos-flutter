# Panduan Penggunaan Bluetooth Thermal Printer

## Overview

Aplikasi SUN POS sekarang mendukung koneksi ke thermal printer melalui Bluetooth. Fitur ini memungkinkan Anda mencetak struk pembayaran secara wireless tanpa perlu koneksi WiFi.

## Persiapan Printer Bluetooth

### 1. Printer yang Didukung

Aplikasi mendukung printer thermal dengan spesifikasi:

- **Protokol**: ESC/POS (Epson Standard Code for Point of Sale)
- **Koneksi**: Bluetooth (SPP - Serial Port Profile)
- **Kertas**: 58mm thermal paper (default)
- **Brand yang Umum**: Epson TM series, Star RP series, Xprinter, GOOJPRT, dll

### 2. Persiapan Printer

1. **Nyalakan Printer**

   - Pastikan printer sudah dinyalakan dan dalam kondisi ready
   - Cek battery printer jika menggunakan printer portable

2. **Aktifkan Mode Bluetooth**

   - Tekan tombol Bluetooth pada printer (biasanya ada indikator LED biru)
   - Beberapa printer otomatis masuk mode pairing saat dinyalakan

3. **Pairing dengan Device Android**
   - Buka **Settings → Bluetooth** di device Android
   - Pastikan Bluetooth sudah diaktifkan
   - Tap **"Scan"** atau **"Search for devices"**
   - Pilih nama printer yang muncul (contoh: "TM-m10", "RP-0001", "XP-58", dll)
   - Masukkan PIN jika diminta (default: **0000**, **1234**, atau **1111**)
   - Tunggu sampai status menjadi **"Paired"**

## Cara Menggunakan

### 1. Buka Pengaturan Printer

1. Selesaikan transaksi sampai ke **ReceiptPage**
2. Tap icon **printer** di bagian atas kanan
3. Pilih **"Pengaturan Printer"**
4. Pilih tab **"Bluetooth"**

### 2. Mencari Printer Bluetooth

1. Tap tombol **"Cari"** (dengan icon bluetooth_searching)
2. Aplikasi akan mencari printer yang sudah dipasangkan (paired)
3. Daftar printer yang ditemukan akan muncul di layar

### 3. Menghubungkan ke Printer

1. Pilih printer dari daftar yang muncul
2. Tap tombol **"Hubungkan"** pada printer yang dipilih
3. Tunggu proses koneksi (loading indicator akan muncul)
4. Jika berhasil, akan ada test print otomatis
5. Notifikasi sukses akan muncul

### 4. Mencetak Struk

Setelah printer terhubung:

1. Kembali ke **ReceiptPage**
2. Tap icon printer → **"Cetak Struk"**
3. Tunggu proses pencetakan
4. Struk akan keluar dari printer

## Troubleshooting

### Printer Tidak Ditemukan

**Penyebab:**

- Printer belum dipasangkan (paired)
- Bluetooth device tidak aktif
- Printer tidak dalam mode pairing

**Solusi:**

1. Pastikan printer sudah dipasangkan di Settings → Bluetooth
2. Restart aplikasi dan coba lagi
3. Restart printer dan device Android
4. Tap **"Buka Pengaturan Bluetooth"** untuk pairing manual

### Gagal Menghubungkan

**Penyebab:**

- Printer sedang digunakan aplikasi lain
- Jarak terlalu jauh (> 10 meter)
- Koneksi Bluetooth tidak stabil

**Solusi:**

1. Pastikan printer tidak terhubung ke device lain
2. Dekatkan device dengan printer
3. Restart Bluetooth di device Android
4. Coba koneksi ulang

### Test Print Gagal

**Penyebab:**

- Kertas thermal habis
- Printer dalam kondisi error
- Protokol printer tidak kompatibel

**Solusi:**

1. Cek kertas thermal di printer
2. Restart printer
3. Pastikan printer mendukung ESC/POS
4. Coba printer lain yang kompatibel

### Permission Error

**Penyebab:**

- Permission Bluetooth tidak diberikan
- Location permission tidak aktif (Android 6+)

**Solusi:**

1. Buka Settings → Apps → SUN POS → Permissions
2. Aktifkan semua permission Bluetooth dan Location
3. Restart aplikasi

## Tips Penggunaan

### 1. Performa Optimal

- Gunakan jarak maksimal 5 meter untuk koneksi stabil
- Pastikan battery printer dalam kondisi baik
- Hindari interference dari device Bluetooth lain

### 2. Maintenance Printer

- Bersihkan print head secara berkala
- Gunakan kertas thermal berkualitas baik
- Simpan printer di tempat kering

### 3. Backup Koneksi

- Siapkan koneksi WiFi sebagai backup
- Test koneksi secara berkala
- Simpan beberapa printer sebagai alternatif

## Format Struk Bluetooth

Struk yang dicetak via Bluetooth memiliki format yang sama dengan network printer:

```
================================
         NAMA TOKO
      Alamat Toko Lengkap
      Telepon: 0123456789
================================
Receipt: #001
Tanggal: 21/09/2025 14:30:25
Kasir: Admin User
================================
DETAIL PEMBELIAN
--------------------------------
Item                 Qty   Total
--------------------------------
Produk A           2   Rp 10.000
@ Rp 5.000

Produk B           1   Rp 15.000
@ Rp 15.000
--------------------------------
Subtotal              Rp 25.000
Diskon                 Rp 2.500
================================
TOTAL BAYAR          Rp 22.500
================================
Metode: Tunai

TERIMA KASIH
Atas kunjungan Anda

Barang yang sudah dibeli tidak dapat
ditukar kembali kecuali ada kerusakan
dari pihak toko
```

## Supported Printer Models

### Epson TM Series

- TM-m10, TM-m30, TM-P20, TM-P60, TM-P80

### Star Micronics

- SM-S210i, SM-S230i, SM-T300i, SM-T400i

### Xprinter

- XP-58IIH, XP-P323B, XP-P200

### Generic ESC/POS

- Kebanyakan printer thermal yang mendukung Bluetooth + ESC/POS

## Catatan Penting

1. **Kompatibilitas**: Tidak semua printer Bluetooth mendukung ESC/POS
2. **Performance**: Bluetooth lebih lambat dari WiFi untuk data besar
3. **Range**: Jarak efektif maksimal 10 meter
4. **Pairing**: Printer harus dipasangkan di level sistem Android dulu
5. **Permission**: Membutuhkan location permission untuk Bluetooth scan di Android 6+

Dengan mengikuti panduan ini, Anda dapat menggunakan printer Bluetooth untuk mencetak struk transaksi dengan mudah dan praktis.
