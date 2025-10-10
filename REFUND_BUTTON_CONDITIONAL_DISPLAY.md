# Implementasi Conditional Display untuk Tombol Refund

## Ringkasan

Implementasi kondisi untuk menampilkan tombol "Refund Item" hanya ketika ada item dengan `remaining_qty > 0` pada detail transaksi.

## Perubahan Response API

### Response Detail Transaksi Baru

```json
{
  "details": [
    {
      "id": 60,
      "product_name": "Product Name",
      "unit_price": 100000,
      "quantity": 2,
      "returned_qty": 2,
      "remaining_qty": 0
      // ... fields lainnya
    }
  ]
}
```

**Field Baru:**

- `returned_qty`: Jumlah yang sudah di-refund
- `remaining_qty`: Sisa jumlah yang bisa di-refund

## File yang Dimodifikasi

### 1. `lib/features/transactions/data/models/transaction_detail_response.dart`

#### Penambahan Field Baru

```dart
class TransactionDetailResponse {
  final int id;
  final int? productId;
  final int? productVariantId;
  final String productName;
  final String productSku;
  final double unitPrice;
  final int quantity;
  final int returnedQty;    // ✅ BARU
  final int remainingQty;   // ✅ BARU
  final double totalAmount;
  // ... fields lainnya

  const TransactionDetailResponse({
    required this.id,
    // ... parameters lainnya
    this.returnedQty = 0,
    this.remainingQty = 0,
    // ...
  });
```

#### Update fromJson

```dart
factory TransactionDetailResponse.fromJson(Map<String, dynamic> json) {
  return TransactionDetailResponse(
    id: json['id'] ?? 0,
    // ... mapping lainnya
    returnedQty: json['returned_qty'] ?? 0,
    remainingQty: json['remaining_qty'] ?? 0,
    // ...
  );
}
```

#### Update toJson, toString, ==, dan hashCode

- Menambahkan `returned_qty` dan `remaining_qty` ke serialization
- Update toString untuk menampilkan field baru
- Update operator == dan hashCode untuk include field baru

### 2. `lib/features/transactions/data/models/create_transaction_response.dart`

#### Penambahan Helper Method

```dart
class TransactionData {
  // ... existing fields

  /// Check if transaction has any items that can be refunded
  bool get hasRefundableItems {
    return details.any((detail) => detail.remainingQty > 0);
  }
}
```

**Kegunaan:**

- Mengecek apakah ada item dengan `remaining_qty > 0`
- Digunakan untuk kondisional menampilkan tombol refund

### 3. `lib/features/dashboard/presentation/pages/transaction_detail_page.dart`

#### Update untuk Status `completed`

```dart
Widget _buildActionButtons(BuildContext context) {
  final status = transaction.status.toLowerCase();

  if (status == 'completed') {
    return Column(
      children: [
        // Tombol "Lihat Struk" - selalu tampil
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _navigateToReceipt(),
            icon: const Icon(LucideIcons.receipt, size: 20),
            label: const Text('Lihat Struk', ...),
            // ... styling
          ),
        ),

        // ✅ Tombol "Refund Item" - hanya jika ada item yang bisa di-refund
        if (_transactionData != null && _transactionData!.hasRefundableItems) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _navigateToRefund(),
              icon: const Icon(LucideIcons.rotateCcw, size: 20),
              label: const Text('Refund Item', ...),
              // ... styling
            ),
          ),
        ],
      ],
    );
  }
}
```

#### Update untuk Status `outstanding`

```dart
// ✅ Tombol refund hanya muncul jika ada item yang bisa di-refund
if (status == 'outstanding' &&
    _transactionData != null &&
    _transactionData!.hasRefundableItems) ...[
  SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: () => _navigateToRefund(),
      icon: const Icon(LucideIcons.rotateCcw, size: 18),
      label: const Text('Refund Item'),
      // ... styling
    ),
  ),
  const SizedBox(height: 12),
],
```

### 4. `lib/features/refunds/presentation/pages/create_refund_page.dart`

#### Update Inisialisasi Controllers

```dart
@override
void initState() {
  super.initState();
  // ✅ Hanya inisialisasi controller untuk item dengan remaining_qty > 0
  for (var detail in widget.transaction.details) {
    if (detail.remainingQty > 0) {
      _quantityControllers[detail.id] = TextEditingController(text: '0');
      _selectedItems[detail.id] = false;
    }
  }
}
```

#### Update Rendering Item List

```dart
// ✅ Filter hanya item dengan remaining_qty > 0
...widget.transaction.details
    .where((detail) => detail.remainingQty > 0)
    .map((detail) {
  return Card(
    // ... card untuk item refund
  );
}).toList(),
```

#### Update Display Quantity

```dart
Row(
  children: [
    Container(
      // ... styling
      child: Text(
        'Sisa: ${detail.remainingQty}x',  // ✅ Tampilkan sisa qty
        style: TextStyle(
          fontSize: 12,
          color: Colors.blue.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    const SizedBox(width: 8),
    Text(currencyFormat.format(detail.unitPrice), ...),
  ],
),
```

#### Update Validasi Max Quantity

```dart
validator: (value) {
  int qty = int.tryParse(value ?? '0') ?? 0;
  if (qty <= 0) {
    return 'Min 1';
  }
  // ✅ Validasi dengan remaining_qty, bukan quantity
  if (qty > detail.remainingQty) {
    return 'Max ${detail.remainingQty}';
  }
  return null;
},
```

#### Update Display Max Hint

```dart
Text(
  'Max: ${detail.remainingQty}',  // ✅ Tampilkan max dari remaining_qty
  style: TextStyle(
    fontSize: 12,
    color: Colors.grey.shade600,
  ),
),
```

## Behavior Baru

### 1. Tombol Refund - Status `completed`

- ✅ **Tampil**: Jika ada minimal 1 item dengan `remaining_qty > 0`
- ❌ **Tidak Tampil**: Jika semua item `remaining_qty = 0` (sudah full refund)

### 2. Tombol Refund - Status `outstanding`

- ✅ **Tampil**: Jika ada minimal 1 item dengan `remaining_qty > 0`
- ❌ **Tidak Tampil**: Jika semua item `remaining_qty = 0`

### 3. Halaman Create Refund

- ✅ Hanya menampilkan item dengan `remaining_qty > 0`
- ✅ Max quantity berdasarkan `remaining_qty`, bukan `quantity`
- ✅ Display "Sisa: Nx" untuk menunjukkan jumlah yang bisa di-refund

## Contoh Skenario

### Skenario 1: Transaksi Baru (Belum Ada Refund)

```json
{
  "details": [{ "id": 1, "quantity": 5, "returned_qty": 0, "remaining_qty": 5 }]
}
```

**Result**:

- ✅ Tombol "Refund Item" tampil
- ✅ Item tampil di halaman refund
- ✅ Max quantity = 5

### Skenario 2: Sebagian Sudah Di-refund

```json
{
  "details": [{ "id": 1, "quantity": 5, "returned_qty": 2, "remaining_qty": 3 }]
}
```

**Result**:

- ✅ Tombol "Refund Item" tampil
- ✅ Item tampil dengan label "Sisa: 3x"
- ✅ Max quantity = 3

### Skenario 3: Sudah Full Refund

```json
{
  "details": [{ "id": 1, "quantity": 5, "returned_qty": 5, "remaining_qty": 0 }]
}
```

**Result**:

- ❌ Tombol "Refund Item" TIDAK tampil
- ❌ Item TIDAK tampil di halaman refund

### Skenario 4: Mixed (Sebagian Full Refund, Sebagian Belum)

```json
{
  "details": [
    { "id": 1, "quantity": 5, "returned_qty": 5, "remaining_qty": 0 },
    { "id": 2, "quantity": 3, "returned_qty": 0, "remaining_qty": 3 }
  ]
}
```

**Result**:

- ✅ Tombol "Refund Item" tampil (ada item 2 yang masih bisa di-refund)
- ❌ Item 1 TIDAK tampil di halaman refund
- ✅ Item 2 tampil di halaman refund dengan max = 3

## Keuntungan

1. **Prevent Invalid Refund**

   - User tidak bisa akses halaman refund jika semua item sudah di-refund
   - Tidak ada item yang ditampilkan jika `remaining_qty = 0`

2. **Better UX**

   - Tombol refund hanya muncul ketika relevan
   - Informasi yang jelas tentang sisa quantity yang bisa di-refund
   - Validasi otomatis berdasarkan `remaining_qty`

3. **Data Consistency**

   - Menggunakan `remaining_qty` dari backend sebagai single source of truth
   - Tidak ada kemungkinan over-refund karena validasi dari API

4. **Clean Interface**
   - UI lebih clean ketika tidak ada item yang bisa di-refund
   - Menghindari confusion dengan menyembunyikan opsi yang tidak applicable

## Testing Checklist

- [ ] Transaksi completed dengan semua item `remaining_qty > 0` → Tombol refund tampil
- [ ] Transaksi completed dengan semua item `remaining_qty = 0` → Tombol refund TIDAK tampil
- [ ] Transaksi completed dengan mixed remaining_qty → Tombol refund tampil
- [ ] Transaksi outstanding dengan items refundable → Tombol refund tampil
- [ ] Halaman refund hanya menampilkan item dengan `remaining_qty > 0`
- [ ] Max quantity validation menggunakan `remaining_qty`
- [ ] Display "Sisa: Nx" sesuai dengan `remaining_qty`
- [ ] Tidak bisa input quantity > `remaining_qty`

## Implementasi Selesai ✅

Tanggal: 10 Oktober 2025
