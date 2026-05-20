# Demo Usage: Thermal Printer Feature

## Quick Start Guide

### 1. Persiapan Printer

```
1. Pastikan thermal printer sudah dinyalakan
2. Hubungkan printer ke WiFi yang sama dengan device
3. Catat IP address printer (biasanya dapat dilihat di settings printer)
```

### 2. Setup Koneksi Pertama Kali

```
1. Buka ReceiptPage setelah transaksi selesai
2. Tap icon printer (print_disabled) di header
3. Pilih "Pengaturan Printer"
4. Coba "Cari Printer Otomatis" atau:
   - Input IP address manual (contoh: 192.168.1.150)
   - Input port (default: 9100)
5. Tap "Hubungkan"
6. Test print akan otomatis dilakukan
```

### 3. Mencetak Struk

```
1. Icon printer akan berubah menjadi hijau jika terhubung
2. Tap icon printer → "Cetak Struk"
3. Tunggu hingga pencetakan selesai
4. Struk akan tercetak dengan format profesional
```

## Troubleshooting Common Issues

### "Printer belum terhubung"

- Cek WiFi connection
- Restart printer
- Verifikasi IP address

### "Gagal terhubung ke printer"

- Pastikan port 9100 terbuka
- Cek firewall settings
- Coba IP address lain

### "Test print gagal"

- Cek kertas thermal
- Restart printer connection
- Pastikan printer tidak busy

## Demo Scenarios

### Scenario 1: First Time Setup

```dart
// User flow:
1. Complete transaction → ReceiptPage
2. Tap printer icon → shows disabled state
3. Select "Pengaturan Printer"
4. Use auto-discovery or manual IP
5. Connect and test print
6. Ready to print receipts
```

### Scenario 2: Regular Printing

```dart
// User flow:
1. ReceiptPage displayed after payment
2. Tap printer icon → shows connected state
3. Select "Cetak Struk"
4. Loading indicator shown
5. Success notification
6. Physical receipt printed
```

### Scenario 3: Connection Issues

```dart
// User flow:
1. Try to print → connection failed
2. Auto-retry with error message
3. User can setup printer again
4. Or try manual IP configuration
```

## Testing Checklist

- [ ] Printer discovery works
- [ ] Manual IP connection successful
- [ ] Test print produces output
- [ ] Receipt printing with all data
- [ ] Error handling for disconnection
- [ ] UI updates based on connection status
- [ ] Loading states and notifications

## Code Integration Points

### In PaymentService or TransactionComplete:

```dart
// After successful payment, navigate to ReceiptPage
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => ReceiptPage(
      receiptId: transaction.id,
      transactionDate: transaction.createdAt,
      items: cartItems,
      store: currentStore,
      user: currentUser,
      subtotal: transaction.subtotal,
      discount: transaction.discount,
      total: transaction.total,
      paymentMethod: transaction.paymentMethod,
      notes: transaction.notes,
    ),
  ),
);
```

Fitur thermal printer ini memberikan pengalaman POS yang lebih profesional dan sesuai dengan ekspektasi pengguna untuk aplikasi kasir modern.
