# Refund Confirmation Dialog Implementation

## 🎯 **Fitur Baru**

Menambahkan **dialog konfirmasi** sebelum melakukan submit refund untuk mencegah kesalahan dan memberikan review terakhir sebelum refund diproses.

---

## ✅ **Changes Made**

### **1. Tambah Fungsi Dialog Konfirmasi**

**File**: `lib/features/refunds/presentation/pages/create_refund_page.dart`

#### **Fungsi Baru: `_showConfirmationDialog()`**

```dart
void _showConfirmationDialog() {
  // Calculate refund details
  // Show dialog with refund summary
  showDialog(
    context: context,
    barrierDismissible: false,  // Tidak bisa ditutup dengan tap di luar
    builder: (BuildContext context) {
      return AlertDialog(
        // ... dialog content
      );
    },
  );
}
```

---

### **2. Update Button Handler**

#### **Sebelumnya**

```dart
ElevatedButton(
  onPressed: _isLoading ? null : _submitRefund,  // Langsung submit
  // ...
)
```

#### **Setelah Perubahan**

```dart
ElevatedButton(
  onPressed: _isLoading ? null : _showConfirmationDialog,  // Tampilkan dialog dulu
  // ...
)
```

---

## 🎨 **Dialog Design**

### **Dialog Content**

```
┌──────────────────────────────────────┐
│ ❓ Konfirmasi Refund                 │
├──────────────────────────────────────┤
│                                      │
│ Apakah Anda yakin ingin memproses    │
│ refund ini?                          │
│                                      │
│ ┌────────────────────────────────┐  │
│ │ Transaksi:       #TRX-001      │  │
│ │ Item di-refund:  2 item        │  │
│ │ ─────────────────────────────  │  │
│ │ Metode Refund:   Cash          │  │
│ │ Cash:            Rp 50,000     │  │
│ │ ─────────────────────────────  │  │
│ │ Total Refund:    Rp 50,000     │  │
│ └────────────────────────────────┘  │
│                                      │
│ ℹ️ Refund akan diproses dan tidak    │
│   dapat dibatalkan                   │
│                                      │
├──────────────────────────────────────┤
│          [Batal]    [Ya, Proses]     │
└──────────────────────────────────────┘
```

### **Visual Elements**

1. **Header Icon**

   - Green help icon dengan background
   - Tema hijau konsisten dengan refund theme

2. **Informasi Ringkasan Refund**

   - **Transaksi**: Nomor transaksi yang di-refund
   - **Item di-refund**: Jumlah item yang dipilih
   - **Metode Refund**: Cash / Transfer / Cash & Transfer
   - **Amount Details**:
     - Cash amount (jika ada)
     - Transfer amount (jika ada)
   - **Total Refund**: Total jumlah refund (bold & highlighted)
   - Background hijau untuk highlight

3. **Info Note**

   - Background biru dengan icon info
   - Text: "Refund akan diproses dan tidak dapat dibatalkan"
   - Warning yang jelas tentang irreversibility

4. **Action Buttons**
   - **Batal**: Outlined button (grey) - Tutup dialog
   - **Ya, Proses**: Elevated button (green) - Submit refund

---

## 🔄 **User Flow**

### **Before (Tanpa Dialog)**

```
1. User pilih item untuk refund
2. User input metode & jumlah refund
3. User klik "Konfirmasi Refund"
4. ✅ Refund langsung diproses
```

### **After (Dengan Dialog)**

```
1. User pilih item untuk refund
2. User input metode & jumlah refund
3. User klik "Konfirmasi Refund"
4. 🔔 Dialog konfirmasi muncul
5. User melihat ringkasan:
   - Nomor transaksi
   - Jumlah item yang di-refund
   - Metode refund
   - Detail amount (cash/transfer)
   - Total refund
6. User pilih aksi:
   - Klik "Batal" → Kembali ke halaman refund
   - Klik "Ya, Proses" → Refund diproses
```

---

## 📋 **Dialog Features**

### ✅ **Informasi yang Ditampilkan**

#### **1. Nomor Transaksi**

```dart
'#${widget.transaction.transactionNumber}'
```

#### **2. Jumlah Item yang Di-refund**

```dart
// Count selected items
int selectedItemCount = 0;
for (var detail in widget.transaction.details) {
  if (_selectedItems[detail.id] == true) {
    selectedItemCount++;
  }
}
```

#### **3. Metode Refund**

- **Cash**: "Cash"
- **Transfer**: "Transfer"
- **Cash & Transfer**: "Cash & Transfer"

#### **4. Detail Amount**

**For Cash/Cash & Transfer:**

```dart
if (_refundMethod == 'cash' || _refundMethod == 'cash_and_transfer') {
  // Show cash amount
  currencyFormat.format(cashAmount)
}
```

**For Transfer/Cash & Transfer:**

```dart
if (_refundMethod == 'transfer' || _refundMethod == 'cash_and_transfer') {
  // Show transfer amount
  currencyFormat.format(transferAmount)
}
```

#### **5. Total Refund**

```dart
currencyFormat.format(_calculateTotalRefund())
```

---

## 💡 **Smart Display Logic**

### **Refund Method Text**

```dart
String refundMethodText = '';
switch (_refundMethod) {
  case 'cash':
    refundMethodText = 'Cash';
    break;
  case 'transfer':
    refundMethodText = 'Transfer';
    break;
  case 'cash_and_transfer':
    refundMethodText = 'Cash & Transfer';
    break;
}
```

### **Conditional Amount Display**

Dialog secara dinamis menampilkan amount berdasarkan metode:

**Cash Only:**

- Show: Cash amount
- Show: Total refund

**Transfer Only:**

- Show: Transfer amount
- Show: Total refund

**Cash & Transfer:**

- Show: Cash amount
- Show: Transfer amount
- Show: Total refund (sum of both)

---

## 🎯 **Benefits**

### 1. **Prevent Accidental Submission** ❌→✅

- User harus konfirmasi 2x sebelum refund diproses
- Mengurangi kesalahan input

### 2. **Final Review** 👀

- User bisa melihat ringkasan lengkap sebelum submit:
  - Transaksi yang di-refund
  - Item yang dipilih
  - Metode refund
  - Detail amount
  - Total refund

### 3. **Clear Warning** ⚠️

- Dialog menjelaskan bahwa refund tidak dapat dibatalkan
- User aware tentang irreversibility

### 4. **Better UX** ✨

- Professional dan polished
- Consistent dengan refund confirmation pattern
- Color coding: Green untuk refund (matching theme)

---

## 🧪 **Testing Checklist**

### **Test Case 1: Cash Refund**

- [ ] Pilih item untuk refund
- [ ] Pilih metode: Cash
- [ ] Input jumlah cash
- [ ] Klik "Konfirmasi Refund"
- [ ] Verifikasi dialog muncul dengan:
  - Nomor transaksi
  - Jumlah item
  - Metode: Cash
  - Cash amount
  - Total refund
- [ ] Klik "Ya, Proses"
- [ ] Verifikasi refund terproses

### **Test Case 2: Transfer Refund**

- [ ] Pilih item untuk refund
- [ ] Pilih metode: Transfer
- [ ] Input jumlah transfer
- [ ] Klik "Konfirmasi Refund"
- [ ] Verifikasi dialog muncul dengan:
  - Metode: Transfer
  - Transfer amount
  - Total refund
- [ ] Klik "Ya, Proses"
- [ ] Verifikasi refund terproses

### **Test Case 3: Cash & Transfer Refund**

- [ ] Pilih item untuk refund
- [ ] Pilih metode: Cash & Transfer
- [ ] Input cash dan transfer amount
- [ ] Klik "Konfirmasi Refund"
- [ ] Verifikasi dialog muncul dengan:
  - Metode: Cash & Transfer
  - Cash amount
  - Transfer amount
  - Total refund (sum)
- [ ] Klik "Ya, Proses"
- [ ] Verifikasi refund terproses

### **Test Case 4: Multiple Items Refund**

- [ ] Pilih 3+ item untuk refund
- [ ] Set quantities untuk each item
- [ ] Klik "Konfirmasi Refund"
- [ ] Verifikasi dialog menampilkan:
  - Correct item count (e.g., "3 item")
  - Correct total refund calculation

### **Test Case 5: Batal dari Dialog**

- [ ] Buka dialog konfirmasi
- [ ] Klik tombol "Batal"
- [ ] Verifikasi dialog tertutup
- [ ] Verifikasi kembali ke halaman create refund
- [ ] Verifikasi refund BELUM diproses

### **Test Case 6: Validation Still Works**

- [ ] Jangan pilih item (atau invalid input)
- [ ] Klik "Konfirmasi Refund"
- [ ] Verifikasi validation error muncul
- [ ] Dialog TIDAK muncul
- [ ] Fix input → Dialog muncul

### **Test Case 7: Tap di Luar Dialog**

- [ ] Buka dialog konfirmasi
- [ ] Tap di area gelap (backdrop)
- [ ] Verifikasi dialog TIDAK tertutup (barrierDismissible: false)

### **Test Case 8: Loading State**

- [ ] Buka dialog dan klik "Ya, Proses"
- [ ] Verifikasi dialog tertutup
- [ ] Verifikasi loading indicator muncul di button
- [ ] Verifikasi button disabled selama proses

---

## ⚙️ **Code Structure**

### **1. Dialog Function**

```dart
void _showConfirmationDialog() {
  // 1. Format currency
  // 2. Calculate total refund
  // 3. Get cash and transfer amounts
  // 4. Determine refund method text
  // 5. Count selected items
  // 6. Show dialog with summary
}
```

### **2. Submit Handler (Unchanged)**

```dart
Future<void> _submitRefund() async {
  // Proses submit refund
  // Logic tidak berubah, hanya dipanggil dari dialog
}
```

### **3. Button Update**

```dart
onPressed: _isLoading ? null : _showConfirmationDialog,
```

---

## 🎨 **Dialog Components Breakdown**

### **Title Section**

- Icon: `Icons.help_outline` dengan background green
- Text: "Konfirmasi Refund" - Bold, size 18

### **Content Section**

1. **Question Text**

   - "Apakah Anda yakin ingin memproses refund ini?"
   - Size 16, regular weight

2. **Summary Container (Green)**

   ```
   - Transaksi: #[transactionNumber]
   - Item di-refund: [count] item
   ─────────────────────────────
   - Metode Refund: [method]
   - Cash: Rp [amount] (if applicable)
   - Transfer: Rp [amount] (if applicable)
   ─────────────────────────────
   - Total Refund: Rp [total] (bold)
   ```

   - Background: Green shade 50
   - Border: Green shade 200

3. **Warning Note (Blue)**
   - Icon: `Icons.info_outline`
   - Text: "Refund akan diproses dan tidak dapat dibatalkan"
   - Background: Blue shade 50
   - Text color: Blue shade 700
   - Important irreversibility warning

### **Actions Section**

1. **Batal Button**

   - Type: OutlinedButton
   - Color: Grey
   - Action: `Navigator.of(context).pop()`

2. **Ya, Proses Button**
   - Type: ElevatedButton
   - Color: Green 600
   - Action: Close dialog + `_submitRefund()`

---

## 🎨 **Color Scheme**

### **Dialog Theme: Green** 💚

- Header icon background: `Colors.green.shade100`
- Header icon color: `Colors.green.shade600`
- Summary background: `Colors.green.shade50`
- Summary border: `Colors.green.shade200`
- Primary button: `Colors.green.shade600`
- Total refund text: `Colors.green.shade700`

**Why Green?**

- Green = Refund, return, money back
- Consistent dengan refund theme di seluruh app
- Clear visual identity

---

## 📊 **Dynamic Display Examples**

### **Example 1: Cash Refund**

```
Metode Refund:   Cash
Cash:            Rp 50,000
─────────────────────────────
Total Refund:    Rp 50,000
```

### **Example 2: Transfer Refund**

```
Metode Refund:   Transfer
Transfer:        Rp 75,000
─────────────────────────────
Total Refund:    Rp 75,000
```

### **Example 3: Cash & Transfer**

```
Metode Refund:   Cash & Transfer
Cash:            Rp 30,000
Transfer:        Rp 20,000
─────────────────────────────
Total Refund:    Rp 50,000
```

---

## 🔗 **Related Files**

- **Modified**: `lib/features/refunds/presentation/pages/create_refund_page.dart`
- **Related**: `lib/features/sales/presentation/pages/payment_confirmation_page.dart` (similar pattern)
- **Related**: `lib/features/sales/presentation/pages/order_confirmation_page.dart` (similar pattern)

---

## 🚀 **Future Enhancements**

1. **Show Refunded Items List**

   - Display list of items being refunded
   - Show quantities for each item
   - Item-by-item breakdown

2. **Original Payment Method Info**

   - Show how customer originally paid
   - Compare with refund method

3. **Refund Date Display**

   - Show selected refund date in dialog
   - Format: "DD MMM YYYY"

4. **Notes Preview**

   - If notes were added, show in dialog
   - Quick review before submit

5. **Customer Information**

   - Show customer name if available
   - Show customer contact

6. **Calculation Breakdown**
   ```
   Item 1: 2x Rp 10,000 = Rp 20,000
   Item 2: 1x Rp 30,000 = Rp 30,000
   ─────────────────────────────────
   Total Refund:          Rp 50,000
   ```

---

## ✅ **Status: IMPLEMENTED**

Dialog konfirmasi refund berhasil ditambahkan dengan:

- ✅ Clean UI/UX design dengan tema hijau
- ✅ Informasi lengkap (transaksi, item, metode, amount)
- ✅ Dynamic display berdasarkan refund method
- ✅ Clear warning message (irreversible action)
- ✅ Clear action buttons
- ✅ Prevent accidental submission
- ✅ Consistent dengan design system
- ✅ No errors in implementation
