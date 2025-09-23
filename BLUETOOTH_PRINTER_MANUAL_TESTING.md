# Testing Manual: Bluetooth Thermal Printer

## ⚡ Quick Test Guide

### Prerequisites

- ✅ Android device dengan Bluetooth
- ✅ Thermal printer yang mendukung Bluetooth + ESC/POS
- ✅ Kertas thermal 58mm sudah terpasang
- ✅ Aplikasi SUN POS sudah ter-install

## 🔧 Setup Test Environment

### 1. Persiapkan Printer

```bash
1. Nyalakan thermal printer
2. Aktifkan mode Bluetooth (LED biru menyala)
3. Pastikan printer dalam kondisi ready (tidak error)
```

### 2. Pairing Printer dengan Android

```bash
1. Buka Settings → Bluetooth di Android
2. Pastikan Bluetooth aktif
3. Tap "Scan for devices" atau "Pair new device"
4. Pilih printer (contoh: "TM-m10", "XP-58IIH")
5. Masukkan PIN jika diminta:
   - Default: 0000, 1234, atau 1111
   - Cek manual printer untuk PIN spesifik
6. Status harus menjadi "Paired"
```

## 🧪 Test Cases

### Test Case 1: Discovery & Connection

**Steps:**

1. Buka aplikasi SUN POS
2. Buat transaksi dummy → selesai sampai ReceiptPage
3. Tap icon printer (kanan atas)
4. Pilih "Pengaturan Printer"
5. Tap tab "Bluetooth"
6. Tap tombol "Cari" (bluetooth_searching icon)

**Expected Results:**

- ✅ Loading indicator muncul
- ✅ List printer paired muncul dalam 2-5 detik
- ✅ Nama printer dan address terlihat jelas
- ✅ Tombol "Hubungkan" tersedia

**If No Printers Found:**

- ❗ Message: "Tidak ada printer Bluetooth ditemukan"
- ❗ Tips muncul tentang pairing
- ❗ Button "Buka Pengaturan Bluetooth" berfungsi

### Test Case 2: Connect to Printer

**Steps:**

1. Dari list printer yang ditemukan
2. Tap tombol "Hubungkan" pada salah satu printer
3. Tunggu proses koneksi

**Expected Results:**

- ✅ Loading spinner pada tombol
- ✅ Koneksi berhasil dalam 3-8 detik
- ✅ Test print otomatis keluar dari printer
- ✅ Notifikasi hijau: "Printer Bluetooth terhubung dan test print berhasil!"
- ✅ Dialog tertutup otomatis

**Test Print Content:**

```
TEST PRINT
Bluetooth Connection Test
21/09/2025 14:30:25
-----------------------------
Printer: [Nama Printer]
Address: [MAC Address]
-----------------------------
Test berhasil!
```

### Test Case 3: Print Receipt

**Steps:**

1. Kembali ke ReceiptPage (printer sudah connected)
2. Icon printer sekarang berwarna/aktif
3. Tap icon printer
4. Pilih "Cetak Struk"

**Expected Results:**

- ✅ Loading dialog muncul
- ✅ Struk lengkap tercetak dalam 5-15 detik
- ✅ Format sama dengan network printer
- ✅ Notifikasi sukses muncul
- ✅ Loading dialog tertutup

**Receipt Content Check:**

```
================================
         [NAMA TOKO]
      [Alamat Toko]
      [Telepon Toko]
================================
Receipt: #[ID]
Tanggal: [Date Time]
Kasir: [User Name]
================================
DETAIL PEMBELIAN
--------------------------------
[Item Name]      [Qty]   [Total]
@ [Unit Price]
--------------------------------
Subtotal              [Amount]
Diskon                [Amount]
================================
TOTAL BAYAR          [Amount]
================================
Metode: [Payment Method]

TERIMA KASIH
Atas kunjungan Anda

[Footer Text]
```

## 🐛 Error Testing

### Test Case 4: Permission Denied

**Steps:**

1. Revoke Bluetooth permissions dalam Settings
2. Coba discovery printer dalam app

**Expected Results:**

- ❗ Permission request dialog muncul
- ❗ Jika denied: Error message dengan guidance
- ❗ Button untuk buka Settings permissions

### Test Case 5: Bluetooth Disabled

**Steps:**

1. Matikan Bluetooth di Android Settings
2. Coba discovery dalam app

**Expected Results:**

- ❗ Request enable Bluetooth dialog
- ❗ Jika declined: Error dengan instruksi manual

### Test Case 6: Printer Out of Range

**Steps:**

1. Connect ke printer successfully
2. Jauhkan printer >10 meter atau matikan printer
3. Coba print receipt

**Expected Results:**

- ❗ Connection timeout error
- ❗ Retry mechanism tersedia
- ❗ Helpful error message

### Test Case 7: No Paired Printers

**Steps:**

1. Unpair semua printer di Android Settings
2. Coba discovery dalam app

**Expected Results:**

- ❗ Empty state dengan message yang helpful
- ❗ Instructions untuk pairing manual
- ❗ Button "Buka Pengaturan Bluetooth"

## ✅ Success Criteria

### Functional Requirements

- [ ] Bluetooth permissions handled correctly
- [ ] Paired printers discovered successfully
- [ ] Connection establishment works reliably
- [ ] Test print executes and produces output
- [ ] Full receipt prints with correct formatting
- [ ] Error states handled gracefully
- [ ] UI feedback appropriate for all states

### Performance Requirements

- [ ] Discovery completes within 5 seconds
- [ ] Connection establishes within 8 seconds
- [ ] Receipt prints within 15 seconds
- [ ] UI remains responsive during operations
- [ ] Memory usage reasonable

### UX Requirements

- [ ] Loading states clear and informative
- [ ] Error messages helpful and actionable
- [ ] Success feedback satisfying
- [ ] Navigation intuitive
- [ ] Help text comprehensive

## 🔍 Debugging Tips

### Common Issues & Solutions

**"Bluetooth permission not granted"**

```bash
Solution: Go to Settings → Apps → SUN POS → Permissions
Enable: Bluetooth, Location, Nearby devices
```

**"No printers discovered but printer is paired"**

```bash
Check: Printer name contains "printer", "pos", "thermal", "tm-", "rp-"
Solution: May need to adjust discovery filter in code
```

**"Connection failed"**

```bash
Check: Printer not used by other app
Check: Bluetooth signal strength
Solution: Restart printer, retry connection
```

**"Test print successful but receipt print fails"**

```bash
Check: Paper not jammed
Check: Printer buffer not full
Solution: Restart printer, check ESC/POS compatibility
```

## 📱 Device Testing Matrix

### Android Versions

- [ ] Android 6.0 (API 23) - Permission model changes
- [ ] Android 10.0 (API 29) - Location permission required
- [ ] Android 12.0 (API 31) - New Bluetooth permissions
- [ ] Android 13.0+ (API 33+) - Latest permission model

### Printer Models

- [ ] Epson TM-m10/m30 - Popular series
- [ ] Xprinter XP-58IIH - Common budget option
- [ ] Star SM-S210i - Professional grade
- [ ] Generic ESC/POS - Various brands

Dengan mengikuti test cases di atas, Anda dapat memastikan fitur Bluetooth thermal printer berfungsi dengan baik dan memberikan pengalaman user yang optimal.
