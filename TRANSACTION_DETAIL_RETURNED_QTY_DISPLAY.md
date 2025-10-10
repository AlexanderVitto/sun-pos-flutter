# Display Returned Quantity pada Transaction Detail

## Ringkasan

Implementasi tampilan jumlah item yang sudah di-refund (`returned_qty`) dan sisa item (`remaining_qty`) pada halaman detail transaksi.

## Perubahan File

### 1. `lib/features/dashboard/presentation/pages/transaction_detail_page.dart`

#### Update Class `TransactionItemDetail`

```dart
class TransactionItemDetail {
  final int id;
  final int productId;
  final int? productVariantId;
  final String productName;
  final String variant;
  final int quantity;
  final int returnedQty;     // ✅ BARU
  final int remainingQty;    // ✅ BARU
  final double unitPrice;
  final double subtotal;
  final double totalAmount;
  final Map<String, dynamic>? product;
  final Map<String, dynamic>? productVariant;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionItemDetail({
    required this.id,
    required this.productId,
    this.productVariantId,
    required this.productName,
    required this.variant,
    required this.quantity,
    this.returnedQty = 0,       // ✅ Default value 0
    this.remainingQty = 0,      // ✅ Default value 0
    required this.unitPrice,
    required this.subtotal,
    required this.totalAmount,
    this.product,
    this.productVariant,
    required this.createdAt,
    required this.updatedAt,
  });
}
```

#### Update Mapping dari API Response

```dart
// Parse items from details array (now properly typed)
if (transactionData.details.isNotEmpty) {
  items = transactionData.details.map((detail) {
    return TransactionItemDetail(
      id: detail.id,
      productId: detail.productId ?? 0,
      productVariantId: detail.productVariantId,
      productName: detail.productName,
      variant: detail.productVariant?.name ?? '',
      quantity: detail.quantity,
      returnedQty: detail.returnedQty,      // ✅ Map dari API
      remainingQty: detail.remainingQty,    // ✅ Map dari API
      unitPrice: detail.unitPrice,
      subtotal: detail.totalAmount,
      totalAmount: detail.totalAmount,
      // ... fields lainnya
    );
  }).toList();
}
```

#### Update UI Display di `_buildItemRow`

```dart
Widget _buildItemRow(TransactionItemDetail item, bool isLast) {
  return Container(
    child: Row(
      children: [
        // Product Image
        Container(...),

        const SizedBox(width: 12),

        // Product Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Name
              Text(item.productName, ...),

              const SizedBox(height: 4),

              // Quantity & Price
              Text(
                '${item.quantity}x @ ${currencyFormat.format(item.unitPrice)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),

              // ✅ BARU: Show returned quantity if any
              if (item.returnedQty > 0) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Refund Badge (Orange)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.orange.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.rotateCcw,
                            size: 12,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Refund: ${item.returnedQty}x',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 6),

                    // Remaining Badge (Green)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.green.shade200,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Sisa: ${item.remainingQty}x',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // Variant (jika ada)
              if (item.variant.isNotEmpty) ...[
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.variant,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}
```

## Visual Design

### Badge untuk Refunded Item

```
┌─────────────────────────────────────┐
│ 📦 Product Name                     │
│ 5x @ Rp 100.000                     │
│                                     │
│ 🔄 Refund: 2x  |  ✅ Sisa: 3x      │
│ ─────────────────────────────────── │
│    Orange          Green            │
└─────────────────────────────────────┘
```

### Color Scheme

1. **Refund Badge (Orange)**

   - Background: `Colors.orange.shade50`
   - Border: `Colors.orange.shade200`
   - Text: `Colors.orange.shade700`
   - Icon: `LucideIcons.rotateCcw` (rotate counter-clockwise)

2. **Remaining Badge (Green)**
   - Background: `Colors.green.shade50`
   - Border: `Colors.green.shade200`
   - Text: `Colors.green.shade700`

## Kondisi Display

### 1. Item Belum Pernah Di-refund

```dart
{
  "quantity": 5,
  "returned_qty": 0,
  "remaining_qty": 5
}
```

**Display:**

```
Product Name
5x @ Rp 100.000
[Variant Name]  // Jika ada
```

❌ Badge refund TIDAK ditampilkan

### 2. Item Sebagian Di-refund

```dart
{
  "quantity": 5,
  "returned_qty": 2,
  "remaining_qty": 3
}
```

**Display:**

```
Product Name
5x @ Rp 100.000
🔄 Refund: 2x  |  ✅ Sisa: 3x
[Variant Name]  // Jika ada
```

✅ Badge refund ditampilkan dengan info lengkap

### 3. Item Full Refund

```dart
{
  "quantity": 5,
  "returned_qty": 5,
  "remaining_qty": 0
}
```

**Display:**

```
Product Name
5x @ Rp 100.000
🔄 Refund: 5x  |  ✅ Sisa: 0x
[Variant Name]  // Jika ada
```

✅ Badge ditampilkan menunjukkan full refund

## Data Flow

### 1. API Response → Model

```json
// API Response
{
  "details": [
    {
      "id": 60,
      "product_name": "Product Name",
      "quantity": 5,
      "returned_qty": 2,
      "remaining_qty": 3,
      "unit_price": 100000
      // ... fields lainnya
    }
  ]
}
```

### 2. Model → TransactionDetailResponse

```dart
TransactionDetailResponse(
  id: 60,
  productName: "Product Name",
  quantity: 5,
  returnedQty: 2,    // ✅ Dari API
  remainingQty: 3,   // ✅ Dari API
  unitPrice: 100000,
)
```

### 3. TransactionDetailResponse → TransactionItemDetail

```dart
TransactionItemDetail(
  id: 60,
  productName: "Product Name",
  quantity: 5,
  returnedQty: 2,    // ✅ Mapped
  remainingQty: 3,   // ✅ Mapped
  unitPrice: 100000,
)
```

### 4. Display di UI

```dart
if (item.returnedQty > 0) {
  // Show badges
  Row(
    children: [
      OrangeBadge("Refund: ${item.returnedQty}x"),
      GreenBadge("Sisa: ${item.remainingQty}x"),
    ],
  )
}
```

## Keuntungan

1. **Informasi Lengkap**

   - User bisa langsung lihat berapa banyak yang sudah di-refund
   - User bisa lihat berapa sisa yang masih bisa di-refund

2. **Visual yang Jelas**

   - Color coding: Orange untuk refund, Green untuk sisa
   - Icon rotate untuk menunjukkan aksi refund
   - Badge design yang clear dan tidak mengganggu

3. **Conditional Display**

   - Badge hanya muncul jika `returnedQty > 0`
   - Tidak mengganggu tampilan untuk item yang belum pernah di-refund

4. **Konsistensi dengan Refund Page**
   - Menggunakan data yang sama dari API
   - Sinkron dengan halaman create refund yang juga menampilkan `remaining_qty`

## Testing Checklist

- [ ] Item dengan `returned_qty = 0` → Badge tidak muncul
- [ ] Item dengan `returned_qty > 0` → Badge muncul dengan info yang benar
- [ ] Item dengan full refund (`remaining_qty = 0`) → Badge menunjukkan "Sisa: 0x"
- [ ] Warna badge sesuai (Orange untuk refund, Green untuk sisa)
- [ ] Icon rotate muncul di badge refund
- [ ] Badge tidak overflow di layar kecil
- [ ] Data `returned_qty` dan `remaining_qty` sesuai dengan API response

## Catatan

- Badge hanya muncul jika ada refund (`returnedQty > 0`)
- Menggunakan `LucideIcons.rotateCcw` untuk icon refund
- Font size lebih kecil (11) untuk badge agar tidak mendominasi
- Badge menggunakan border untuk lebih standout

## Implementasi Selesai ✅

Tanggal: 10 Oktober 2025
