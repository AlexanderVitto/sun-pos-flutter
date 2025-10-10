# Remove Payment Payload untuk Status Draft, Pending, dan Outstanding

## Ringkasan

Implementasi logic untuk menghapus payload `payments` dari request body ketika membuat atau mengubah transaksi dengan status `draft`, `pending`, atau `outstanding`.

## Alasan Perubahan

### Masalah Sebelumnya

- Request body selalu menyertakan payload `payments` terlepas dari status transaksi
- Untuk status draft/pending/outstanding, data pembayaran belum relevan
- Dapat menyebabkan error atau inkonsistensi data di backend

### Solusi

- ❌ **Hapus** payload `payments` untuk status: `draft`, `pending`, `outstanding`
- ✅ **Sertakan** payload `payments` untuk status lainnya (misalnya: `completed`)

## Perubahan File

### 1. `lib/features/transactions/data/models/create_transaction_request.dart`

#### Before (Sebelum)

```dart
Map<String, dynamic> toJson() {
  final Map<String, dynamic> json = {};

  if (storeId != null) json['store_id'] = storeId;
  if (customerName != null) json['customer_name'] = customerName;
  if (customerPhone != null) json['customer_phone'] = customerPhone;

  // ❌ SELALU menyertakan payments jika ada
  if (payments != null) {
    json['payments'] = payments!.map((payment) => payment.toJson()).toList();
  }

  if (status != null) json['status'] = status;
  if (notes != null) json['notes'] = notes;
  if (transactionDate != null) json['transaction_date'] = transactionDate;
  if (outstandingReminderDate != null) {
    json['outstanding_reminder_date'] = outstandingReminderDate;
  }
  if (details != null) {
    json['details'] = details!.map((detail) => detail.toJson()).toList();
  }

  return json;
}
```

#### After (Setelah)

```dart
Map<String, dynamic> toJson() {
  final Map<String, dynamic> json = {};

  if (storeId != null) json['store_id'] = storeId;
  if (customerName != null) json['customer_name'] = customerName;
  if (customerPhone != null) json['customer_phone'] = customerPhone;

  // ✅ HANYA sertakan payments jika status BUKAN draft/pending/outstanding
  if (payments != null &&
      status != null &&
      !['draft', 'pending', 'outstanding'].contains(status!.toLowerCase())) {
    json['payments'] = payments!.map((payment) => payment.toJson()).toList();
  }

  if (status != null) json['status'] = status;
  if (notes != null) json['notes'] = notes;
  if (transactionDate != null) json['transaction_date'] = transactionDate;
  if (outstandingReminderDate != null) {
    json['outstanding_reminder_date'] = outstandingReminderDate;
  }
  if (details != null) {
    json['details'] = details!.map((detail) => detail.toJson()).toList();
  }

  return json;
}
```

## Logic Conditional Payment

### Kondisi untuk Menyertakan Payment

```dart
if (payments != null &&
    status != null &&
    !['draft', 'pending', 'outstanding'].contains(status!.toLowerCase())) {
  // Include payments in JSON
}
```

### Breakdown Logic:

1. ✅ `payments != null` - Payment data ada
2. ✅ `status != null` - Status transaksi ada
3. ✅ `!['draft', 'pending', 'outstanding'].contains(status!.toLowerCase())` - Status BUKAN draft/pending/outstanding

**Semua kondisi harus TRUE untuk menyertakan payment**

## Behavior Baru

### 1. Status: `draft`

```dart
CreateTransactionRequest(
  storeId: 1,
  status: 'draft',
  payments: [PaymentHistory(...)],  // Ada payment data
  details: [...],
)
```

**Request Body:**

```json
{
  "store_id": 1,
  "status": "draft",
  "details": [...]
  // ❌ "payments" TIDAK disertakan
}
```

### 2. Status: `pending`

```dart
CreateTransactionRequest(
  storeId: 1,
  status: 'pending',
  payments: [PaymentHistory(...)],
  details: [...],
)
```

**Request Body:**

```json
{
  "store_id": 1,
  "status": "pending",
  "details": [...]
  // ❌ "payments" TIDAK disertakan
}
```

### 3. Status: `outstanding`

```dart
CreateTransactionRequest(
  storeId: 1,
  status: 'outstanding',
  payments: [PaymentHistory(...)],
  details: [...],
)
```

**Request Body:**

```json
{
  "store_id": 1,
  "status": "outstanding",
  "details": [...]
  // ❌ "payments" TIDAK disertakan
}
```

### 4. Status: `completed`

```dart
CreateTransactionRequest(
  storeId: 1,
  status: 'completed',
  payments: [
    PaymentHistory(
      paymentMethod: 'cash',
      amount: 100000,
    )
  ],
  details: [...],
)
```

**Request Body:**

```json
{
  "store_id": 1,
  "status": "completed",
  "payments": [
    {
      "payment_method": "cash",
      "amount": 100000
    }
  ],
  "details": [...]
  // ✅ "payments" DISERTAKAN
}
```

## Dampak pada API Endpoints

### 1. Create Transaction (`POST /api/transactions`)

- ✅ Status `draft` → Payment payload **dihapus**
- ✅ Status `pending` → Payment payload **dihapus**
- ✅ Status `completed` → Payment payload **disertakan**

### 2. Update Transaction (`PUT /api/transactions/{id}`)

- ✅ Update ke status `draft` → Payment payload **dihapus**
- ✅ Update ke status `pending` → Payment payload **dihapus**
- ✅ Update ke status `outstanding` → Payment payload **dihapus**
- ✅ Update ke status `completed` → Payment payload **disertakan**

## Use Cases

### Use Case 1: Membuat Draft Transaction

```dart
// Di payment_service.dart atau transaction_helper.dart
final request = CreateTransactionRequest(
  storeId: 1,
  customerName: 'John Doe',
  status: 'draft',
  payments: null,  // Tidak perlu isi payment
  details: [
    TransactionDetail(productId: 1, quantity: 2, unitPrice: 50000),
  ],
);

// Request body yang dikirim:
// {
//   "store_id": 1,
//   "customer_name": "John Doe",
//   "status": "draft",
//   "details": [...]
//   // NO payments field
// }
```

### Use Case 2: Membuat Pending Transaction

```dart
final request = CreateTransactionRequest(
  storeId: 1,
  customerName: 'Jane Smith',
  status: 'pending',
  payments: null,  // Tidak perlu isi payment
  details: [...],
);

// Request body yang dikirim:
// {
//   "store_id": 1,
//   "customer_name": "Jane Smith",
//   "status": "pending",
//   "details": [...]
//   // NO payments field
// }
```

### Use Case 3: Update Draft ke Completed

```dart
// Step 1: Draft (tanpa payment)
final draftRequest = CreateTransactionRequest(
  storeId: 1,
  status: 'draft',
  details: [...],
);
// → payments tidak disertakan

// Step 2: Update ke Completed (dengan payment)
final completeRequest = CreateTransactionRequest(
  storeId: 1,
  status: 'completed',
  payments: [
    PaymentHistory(paymentMethod: 'cash', amount: 100000),
  ],
  details: [...],
);
// → payments DISERTAKAN
```

## Testing Checklist

### Create Transaction

- [ ] Create dengan status `draft` → payments tidak ada di request body
- [ ] Create dengan status `pending` → payments tidak ada di request body
- [ ] Create dengan status `completed` → payments ada di request body
- [ ] Create dengan status `outstanding` → payments tidak ada di request body

### Update Transaction

- [ ] Update ke status `draft` → payments tidak ada di request body
- [ ] Update ke status `pending` → payments tidak ada di request body
- [ ] Update ke status `completed` → payments ada di request body
- [ ] Update ke status `outstanding` → payments tidak ada di request body

### Edge Cases

- [ ] Status null → payments tidak disertakan (karena status != null check)
- [ ] Payments null → tidak ada masalah (karena payments != null check)
- [ ] Status dengan case berbeda (DRAFT, Draft, draft) → tetap tidak menyertakan (karena toLowerCase())

## Keuntungan

1. **Data Consistency**

   - Data payment hanya dikirim ketika relevan
   - Menghindari konflik data payment pada draft/pending/outstanding

2. **Backend Compatibility**

   - Backend tidak perlu handle payment data yang tidak relevan
   - Validasi lebih sederhana di backend

3. **Clear Separation**

   - Draft/Pending/Outstanding = Transaksi belum final, belum ada payment
   - Completed = Transaksi final, harus ada payment

4. **Flexible**
   - Mudah menambah status baru ke list jika diperlukan
   - Logic terpusat di satu tempat (toJson method)

## Files Affected

### Modified

- ✅ `lib/features/transactions/data/models/create_transaction_request.dart`
  - Updated `toJson()` method dengan conditional payment inclusion

### API Services yang Terpengaruh

- ✅ `TransactionApiService.createTransaction()` - Menggunakan `CreateTransactionRequest`
- ✅ `TransactionApiService.updateTransaction()` - Menggunakan `CreateTransactionRequest`
- ✅ All payment services yang create/update transaction

## Notes

- ⚠️ **Case Insensitive**: Logic menggunakan `toLowerCase()` untuk handle case yang berbeda
- ⚠️ **Status List**: Mudah menambah/hapus status dari list jika requirements berubah
- ⚠️ **Backward Compatible**: Existing code tidak perlu diubah, cukup update model saja

## Implementasi Selesai ✅

Tanggal: 10 Oktober 2025

**Summary:**

- Payment payload otomatis dihapus untuk status `draft`, `pending`, `outstanding`
- Payment payload tetap disertakan untuk status lainnya (seperti `completed`)
- Logic terpusat di `CreateTransactionRequest.toJson()`
- Berlaku untuk create dan update transaction
