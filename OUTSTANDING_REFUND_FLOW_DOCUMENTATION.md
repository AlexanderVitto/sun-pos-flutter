# 📋 Flow Refund untuk Transaksi Outstanding - Dokumentasi Lengkap

## 🎯 Overview

Transaksi **Outstanding** adalah transaksi yang **belum dibayar lunas** (masih ada hutang). Ketika melakukan refund pada transaksi outstanding, sistem menggunakan pendekatan **EDIT TRANSAKSI** bukan membuat refund record baru.

**Paradigma**: Outstanding = Belum bayar → Refund = Hapus item yang tidak jadi dibeli → Edit transaksi langsung

---

## 🔍 1. Identifikasi Transaksi Outstanding

### Helper Getter

```dart
bool get _isOutstandingTransaction =>
    widget.transaction.status.toLowerCase() == 'outstanding';
```

**Kondisi**: `transaction.status == 'outstanding'`

---

## 📊 2. Informasi Hutang (Debt Information)

### Helper Getters untuk Outstanding

#### A. Sisa Hutang Saat Ini

```dart
double get _remainingDebt {
  if (!_isOutstandingTransaction) return 0;
  return widget.transaction.outstandingAmount;
}
```

- **Input**: `transaction.outstandingAmount`
- **Output**: Jumlah hutang yang masih tersisa

#### B. Prediksi Status Setelah Refund

```dart
String get _predictedStatus {
  if (!_isOutstandingTransaction) return widget.transaction.status;

  final remainingDebt = _remainingDebt;
  final refundAmount = _calculateTotalRefund();

  if (refundAmount >= remainingDebt) {
    return 'completed';  // Lunas jika refund >= hutang
  }
  return 'outstanding';   // Masih hutang
}
```

- **Logic**:
  - Jika `refundAmount >= remainingDebt` → Status jadi `'completed'`
  - Jika tidak → Status tetap `'outstanding'`

#### C. Sisa Hutang Setelah Refund

```dart
double get _newRemainingDebt {
  if (!_isOutstandingTransaction) return 0;

  final remainingDebt = _remainingDebt;
  final refundAmount = _calculateTotalRefund();

  final newDebt = remainingDebt - refundAmount;
  return newDebt > 0 ? newDebt : 0;
}
```

- **Formula**: `newDebt = remainingDebt - refundAmount`
- **Output**: Sisa hutang baru (minimum 0)

---

## 🎨 3. UI/UX untuk Outstanding Refund

### A. Dialog Konfirmasi

**Title**:

```dart
_isOutstandingTransaction
  ? 'Konfirmasi Edit Transaksi'  // Outstanding
  : 'Konfirmasi Refund'           // Completed
```

**Icon & Color**:

```dart
Icon: _isOutstandingTransaction ? Icons.edit : Icons.help_outline
Color: _isOutstandingTransaction ? Colors.orange : Colors.green
```

**Message**:

```dart
'Transaksi ini belum dibayar. Item yang dipilih akan dihapus dari transaksi.'
```

### B. Informasi yang Ditampilkan

**Outstanding Transaction Info Card**:

```dart
if (_isOutstandingTransaction) ...[
  _buildDebtInfoRow('Sisa Hutang Saat Ini', currencyFormat.format(_remainingDebt), Colors.orange.shade800),
  _buildDebtInfoRow('Total Refund', currencyFormat.format(totalRefund), Colors.green.shade700),
  _buildDebtInfoRow('Sisa Hutang Setelah Refund', currencyFormat.format(_newRemainingDebt),
    _predictedStatus == 'completed' ? Colors.green.shade800 : Colors.orange.shade800),

  // Status badge
  Container(
    child: Text(_predictedStatus == 'completed' ? 'Lunas' : 'Masih Hutang'),
  ),
]
```

### C. Field yang TIDAK Ditampilkan untuk Outstanding

- ❌ **Metode Refund** (Cash/Transfer/Cash & Transfer)
- ❌ **Jumlah Cash**
- ❌ **Jumlah Transfer**

**Reason**: Outstanding belum ada pembayaran, jadi tidak ada uang yang perlu dikembalikan.

---

## ⚙️ 4. Core Logic: Update Outstanding Transaction

### Method: `_updateOutstandingTransaction()`

#### **Step 1: Build Updated Cart Items**

```dart
final List<CartItem> updatedCartItems = [];

for (var detail in widget.transaction.details) {
  // Get refund quantity
  final refundQty = _selectedItems[detail.id] == true
      ? (int.tryParse(_quantityControllers[detail.id]?.text ?? '0') ?? 0)
      : 0;

  // Calculate remaining quantity after refund
  final remainingQty = detail.quantity - detail.returnedQty - refundQty;

  // Only add items that still have quantity
  if (remainingQty > 0) {
    // Create CartItem from transaction detail
    updatedCartItems.add(CartItem(
      id: detail.id,
      product: Product(...), // Real data from transaction detail
      quantity: remainingQty,
      addedAt: detail.createdAt,
    ));
  }
}
```

**Key Points**:

- ✅ **Hanya item yang TIDAK di-refund** yang masuk ke `updatedCartItems`
- ✅ **Quantity baru** = `original quantity - returned quantity - refund quantity`
- ✅ **Real data** dari transaction detail dan product variant (no mock data)

#### **Step 2: Calculate New Total Amount**

```dart
final newTotalAmount = updatedCartItems.fold<double>(
  0,
  (sum, item) => sum + (item.product.price * item.quantity),
);
```

**Formula**: `newTotalAmount = Σ(item.price × item.quantity)`

#### **Step 3: Determine New Status**

```dart
status: newTotalAmount <= 0 ? 'completed' : 'outstanding'
```

**Logic**:

- Jika `newTotalAmount <= 0` → Status jadi `'completed'` (semua item di-refund)
- Jika `newTotalAmount > 0` → Status tetap `'outstanding'`

#### **Step 4: Calculate New Reminder Date**

```dart
outstandingReminderDate: newTotalAmount > 0
    ? _calculateNewReminderDate()  // Add 10 days
    : null                          // Clear if completed
```

**Helper Method**:

```dart
String _calculateNewReminderDate() {
  DateTime newReminderDate;

  if (widget.transaction.outstandingReminderDate != null) {
    // Add 10 days from existing reminder date
    newReminderDate = widget.transaction.outstandingReminderDate!.add(
      const Duration(days: 10),
    );
  } else {
    // Add 10 days from now
    newReminderDate = DateTime.now().add(const Duration(days: 10));
  }

  return newReminderDate.toIso8601String();
}
```

**Logic**: Perpanjang reminder date +10 hari untuk memberi waktu lebih lama bayar hutang

#### **Step 5: Update Notes**

```dart
notes: _notesController.text.trim().isEmpty
    ? widget.transaction.notes
    : '${widget.transaction.notes ?? ''}\n[Refund: ${_notesController.text.trim()}]'
```

**Format**: Append catatan refund ke notes yang sudah ada

#### **Step 6: Call Update Transaction API**

```dart
final response = await transactionProvider.updateTransaction(
  transactionId: widget.transaction.id,
  cartItems: updatedCartItems,
  totalAmount: newTotalAmount,
  notes: notes,
  paymentMethod: 'cash',  // Default, not important for outstanding
  storeId: widget.transaction.store.id,
  customerName: widget.transaction.customer?.name,
  customerPhone: widget.transaction.customer?.phoneNumber,
  status: newTotalAmount <= 0 ? 'completed' : 'outstanding',
  cashAmount: 0,
  transferAmount: 0,
  outstandingReminderDate: newTotalAmount > 0 ? _calculateNewReminderDate() : null,
);

if (response == null) {
  throw Exception('Failed to update transaction');
}
```

---

## 🔄 5. Complete Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. User Opens Refund Page for Outstanding Transaction          │
│    - Status: 'outstanding'                                      │
│    - Outstanding Amount: Rp 30.000.000                          │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 2. UI Displays Outstanding-Specific Interface                   │
│    - Debt info card (orange theme)                              │
│    - NO payment method selection                                │
│    - Shows: Current debt, Refund amount, New debt               │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 3. User Selects Items to Refund                                 │
│    Example:                                                      │
│    - Item A: 1x @ Rp 10.000.000 ✓ (selected, refund qty: 1)    │
│    - Item B: 1x @ Rp 10.000.000 ✗ (not selected)                │
│    - Item C: 1x @ Rp 10.000.000 ✗ (not selected)                │
│    Total Refund: Rp 10.000.000                                  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 4. System Calculates New Values                                 │
│    - Remaining Debt: Rp 30.000.000                              │
│    - Refund Amount: Rp 10.000.000                               │
│    - New Remaining Debt: Rp 30.000.000 - Rp 10.000.000          │
│      = Rp 20.000.000                                            │
│    - Predicted Status: 'outstanding' (debt still > 0)           │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 5. User Clicks Submit → Confirmation Dialog Shows               │
│    "Konfirmasi Edit Transaksi"                                  │
│    - Current Debt: Rp 30.000.000                                │
│    - Total Refund: Rp 10.000.000                                │
│    - New Debt: Rp 20.000.000                                    │
│    - Status: Masih Hutang                                       │
│    ⚠️  "Item akan dihapus dan tidak dapat dikembalikan"         │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 6. User Confirms → _submitRefund() Executes                     │
│    Checks: _isOutstandingTransaction == true                    │
│    Routes to: _updateOutstandingTransaction()                   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 7. Build Updated Cart Items                                     │
│    Loop through transaction.details:                            │
│    - Item A: refundQty = 1, remainingQty = 0 → SKIP            │
│    - Item B: refundQty = 0, remainingQty = 1 → ADD TO CART     │
│    - Item C: refundQty = 0, remainingQty = 1 → ADD TO CART     │
│    Result: updatedCartItems = [Item B, Item C]                 │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 8. Calculate New Total Amount                                   │
│    newTotalAmount = (Item B: Rp 10M) + (Item C: Rp 10M)        │
│                   = Rp 20.000.000                               │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 9. Determine New Status                                         │
│    newTotalAmount = Rp 20.000.000 > 0                          │
│    → status = 'outstanding'                                     │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 10. Calculate New Reminder Date                                 │
│     Old reminder: 09 November 2025                              │
│     New reminder: 09 November 2025 + 10 days                    │
│                 = 19 November 2025                              │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 11. Call TransactionProvider.updateTransaction()                │
│     PUT /transactions/{id}                                      │
│     Body: {                                                     │
│       details: [Item B, Item C],                                │
│       totalAmount: 20000000,                                    │
│       status: 'outstanding',                                    │
│       outstandingReminderDate: '2025-11-19T...',               │
│       ...                                                       │
│     }                                                           │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 12. API Response Success                                        │
│     - Transaction updated in database                           │
│     - TransactionEvents.transactionUpdated() fired              │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 13. UI Feedback                                                 │
│     ✓ Show success snackbar: "Transaksi berhasil diperbarui"   │
│     ✓ Navigator.pop(true) → Return to detail page              │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ 14. Transaction Detail Page Refresh                             │
│     - Detects result == true                                    │
│     - Calls _loadTransactionDetails()                           │
│     - Fetches updated transaction from API                      │
│     - UI updates with new values:                               │
│       • Total Amount: Rp 20.000.000 (was Rp 30.000.000)        │
│       • Total Items: 2 barang (was 3 barang)                   │
│       • Due Date: 19 November 2025 (was 09 November 2025)      │
│       • Outstanding Amount: Rp 20.000.000                       │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🆚 6. Comparison: Outstanding vs Completed Refund

| Aspect              | Outstanding Transaction                   | Completed Transaction               |
| ------------------- | ----------------------------------------- | ----------------------------------- |
| **Status**          | `'outstanding'` (belum bayar)             | `'completed'` (sudah bayar)         |
| **Action**          | Edit transaction                          | Create refund record                |
| **API Endpoint**    | `PUT /transactions/{id}`                  | `POST /refunds`                     |
| **Provider Method** | `TransactionProvider.updateTransaction()` | `RefundListProvider.createRefund()` |
| **Payment Method**  | ❌ Not required                           | ✅ Required (cash/transfer)         |
| **Cash Amount**     | ❌ Not required (0)                       | ✅ Required                         |
| **Transfer Amount** | ❌ Not required (0)                       | ✅ Required                         |
| **Cart Items**      | Only remaining items                      | N/A (uses refund details)           |
| **Total Amount**    | Recalculated from remaining               | Original total unchanged            |
| **Status After**    | `'completed'` or `'outstanding'`          | `'refund'`                          |
| **Reminder Date**   | Extended +10 days if still outstanding    | N/A                                 |
| **UI Theme**        | 🟠 Orange (debt warning)                  | 🟢 Green (refund)                   |
| **Dialog Title**    | "Konfirmasi Edit Transaksi"               | "Konfirmasi Refund"                 |
| **Debt Info**       | ✅ Shown                                  | ❌ Not shown                        |
| **Success Message** | "Transaksi berhasil diperbarui"           | "Refund berhasil dibuat"            |

---

## 📝 7. Key Principles

### ✅ DO's

1. **Edit transaction directly** untuk outstanding (bukan create refund)
2. **Gunakan real data** dari transaction details dan product variants
3. **Hitung ulang total amount** dari item yang tersisa
4. **Update status** ke 'completed' jika semua item di-refund
5. **Perpanjang reminder date** +10 hari jika masih outstanding
6. **Tampilkan debt info** untuk membantu user decision
7. **Validasi selection** minimal 1 item
8. **Refresh detail page** setelah update sukses

### ❌ DON'Ts

1. **Jangan create refund record** untuk outstanding
2. **Jangan minta payment method** untuk outstanding (tidak ada uang dikembalikan)
3. **Jangan gunakan mock data** (stock: 999, DateTime.now())
4. **Jangan hardcode values** yang bisa didapat dari API
5. **Jangan lupa handle error** dengan informative messages
6. **Jangan skip validation** untuk quantity dan selection

---

## 🎯 8. Expected Outcomes

### A. Full Refund (All Items)

**Before**:

- Total Amount: Rp 30.000.000
- Total Items: 3 barang
- Status: 'outstanding'
- Outstanding Amount: Rp 30.000.000

**After**:

- Total Amount: Rp 0
- Total Items: 0 barang
- Status: 'completed' ✅
- Outstanding Amount: Rp 0
- Reminder Date: null (cleared)

### B. Partial Refund (Some Items)

**Before**:

- Total Amount: Rp 30.000.000
- Total Items: 3 barang
- Status: 'outstanding'
- Outstanding Amount: Rp 30.000.000
- Due Date: 09 November 2025

**Refund**: 1 item @ Rp 10.000.000

**After**:

- Total Amount: Rp 20.000.000
- Total Items: 2 barang
- Status: 'outstanding' (still debt)
- Outstanding Amount: Rp 20.000.000
- Due Date: 19 November 2025 (+10 days)

---

## 🔧 9. Error Handling

### Possible Errors

1. **No items selected**

   ```dart
   'Pilih minimal 1 item untuk di-refund'
   ```

2. **Update transaction failed**

   ```dart
   'Gagal memperbarui transaksi: {error}'
   ```

3. **API call failed**
   ```dart
   'Failed to update transaction'
   ```

### Recovery Actions

- Show error snackbar (red background)
- Keep user on page (don't close)
- Reset loading state
- Preserve user input

---

## 📊 10. Data Flow

```
CreateRefundPage
    ↓ (user selects items)
_selectedItems: {id: true/false}
_quantityControllers: {id: TextEditingController}
    ↓ (user clicks submit)
_showConfirmationDialog()
    ↓ (shows debt calculations)
_submitRefund()
    ↓ (checks transaction type)
_updateOutstandingTransaction()
    ↓ (builds updated cart)
updatedCartItems: List<CartItem>
    ↓ (calculates new total)
newTotalAmount: double
    ↓ (determines new status)
status: 'completed' or 'outstanding'
    ↓ (calculates new reminder)
outstandingReminderDate: String?
    ↓ (calls API)
TransactionProvider.updateTransaction()
    ↓ (API PUT request)
TransactionApiService.updateTransaction()
    ↓ (backend updates)
Database: transactions table updated
    ↓ (API response)
CreateTransactionResponse
    ↓ (success)
Navigator.pop(true)
    ↓ (parent page detects)
TransactionDetailPage.result == true
    ↓ (refresh data)
_loadTransactionDetails()
    ↓ (UI updates)
Transaction header shows new values ✅
```

---

## 🚀 11. Implementation Checklist

- [✅] Helper getter `_isOutstandingTransaction`
- [✅] Helper getter `_remainingDebt`
- [✅] Helper getter `_predictedStatus`
- [✅] Helper getter `_newRemainingDebt`
- [✅] Helper method `_calculateNewReminderDate()`
- [✅] Conditional UI for outstanding (orange theme, debt info)
- [✅] Hide payment method fields for outstanding
- [✅] Method `_updateOutstandingTransaction()`
- [✅] Build updatedCartItems from remaining items
- [✅] Calculate newTotalAmount from remaining items
- [✅] Determine status based on newTotalAmount
- [✅] Calculate new reminder date (+10 days)
- [✅] Call TransactionProvider.updateTransaction()
- [✅] Error handling with try-catch
- [✅] Success feedback with snackbar
- [✅] Return true to trigger parent refresh
- [✅] Parent page auto-refresh on result == true
- [✅] Use real data (no mock data)
- [✅] Update getter in TransactionDetailPage to use `_detailedTransaction`
- [✅] Count active items only (remainingQty > 0)

---

## 📚 12. Related Files

- `/lib/features/refunds/presentation/pages/create_refund_page.dart`
- `/lib/features/sales/providers/transaction_provider.dart`
- `/lib/features/dashboard/presentation/pages/transaction_detail_page.dart`
- `/lib/features/transactions/data/services/transaction_api_service.dart`
- `/lib/features/transactions/data/models/create_transaction_response.dart`

---

## 📈 13. Version History

- **v1.0.18+19** (Current)
  - ✅ Outstanding refund = edit transaction (not create refund)
  - ✅ Auto extend reminder date +10 days
  - ✅ Real data extraction (no mock)
  - ✅ Auto refresh detail page after update
  - ✅ Active items count (remainingQty > 0)

---

## 💡 14. Business Logic Summary

**Outstanding Transaction Refund = Koreksi Transaksi**

Ketika customer belum bayar (`outstanding`), lalu ingin "refund" beberapa item:

- **Bukan refund uang** (karena belum bayar)
- **Tapi koreksi transaksi** (item tidak jadi dibeli)
- **Edit transaksi langsung** dengan menghapus item yang tidak jadi
- **Total amount berkurang** sesuai item yang dihapus
- **Hutang berkurang** karena total transaksi berkurang
- **Reminder date diperpanjang** +10 hari untuk memberi waktu lebih

**Analogi**: Seperti edit pesanan sebelum checkout, bukan refund setelah checkout.

---

**Dokumentasi ini dibuat**: 10 November 2025
**Versi Aplikasi**: 1.0.18+19
**Status**: ✅ Implemented & Tested
