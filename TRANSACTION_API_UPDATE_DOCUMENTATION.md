# Transaction API Payload & Response Update Documentation

## Summary

Updated transaction API models to support new payload structure with multiple payment methods and enhanced response data.

## Date

October 10, 2025

---

## 1. CREATE TRANSACTION

### Request Payload (POST /transactions)

```json
{
  "store_id": 1,
  "customer_name": "Ahmad Rahman",
  "customer_phone": "08345678901",
  "payments": [
    {
      "payment_method": "cash",
      "amount": 200000,
      "payment_date": "2025-10-08T20:20:00.000Z",
      "notes": "Cash payment"
    }
  ],
  "status": "completed",
  "notes": "Pembelian minuman dan snack",
  "transaction_date": "2025-10-08",
  "outstanding_reminder_date": "2025-10-15",
  "details": [
    {
      "product_variant_id": 243,
      "quantity": 2,
      "unit_price": 100000
    }
  ]
}
```

### Response (201/200)

```json
{
    "status": "success",
    "message": "Transaction created successfully",
    "data": {
        "id": 12,
        "transaction_number": "TRX20251010XI1FYQ",
        "date": "2025-10-10 05:18:22",
        "total_amount": 200000,
        "total_paid": 200000,
        "change_amount": 0,
        "outstanding_amount": 0,
        "is_fully_paid": null,
        "status": "completed",
        "notes": "Pembelian minuman dan snack",
        "transaction_date": "2025-10-08T00:00:00.000000Z",
        "outstanding_reminder_date": "2025-10-15T00:00:00.000000Z",
        "user": { ... },
        "store": { ... },
        "customer": { ... },
        "details": [ ... ],
        "payment_histories": [ ... ],
        "created_at": "2025-10-10T05:18:22.000000Z",
        "updated_at": "2025-10-10T05:18:22.000000Z"
    }
}
```

### Models Changed

- **CreateTransactionRequest**:

  - ❌ Removed: `paymentMethod`, `paidAmount`, `cashAmount`, `transferAmount`
  - ✅ Added: `payments` (List<PaymentHistory>)
  - New getter: `totalPaidAmount` - calculates total from all payments

- **CreateTransactionResponse**:
  - Changed: `success` → `status` (boolean → string)
  - **TransactionData**:
    - ❌ Removed: `paidAmount`, `paymentMethod`, `detailsCount`
    - ✅ Added: `totalPaid`, `outstandingAmount`, `isFullyPaid`, `details` (full array), `paymentHistories` (full array)

---

## 2. UPDATE TRANSACTION

### Request & Response

Same structure as CREATE TRANSACTION (uses same models)

---

## 3. GET LIST TRANSACTIONS

### Request (GET /transactions)

Query parameters remain the same:

- page, per_page, search, store_id, user_id
- date_from, date_to, min_amount, max_amount
- sort_by, sort_direction, payment_method, status

### Response (200)

```json
{
    "status": "success",
    "message": "Transactions retrieved successfully",
    "data": {
        "data": [
            {
                "id": 12,
                "transaction_number": "TRX20251010XI1FYQ",
                "date": "2025-10-10 05:18:22",
                "total_amount": 200000,
                "total_paid": 200000,
                "change_amount": 0,
                "outstanding_amount": 0,
                "is_fully_paid": null,
                "status": "completed",
                "notes": "...",
                "transaction_date": "2025-10-08T00:00:00.000000Z",
                "outstanding_reminder_date": "2025-10-15T00:00:00.000000Z",
                "user": { ... },
                "store": { ... },
                "customer": { ... },
                "details_count": 1,
                "created_at": "...",
                "updated_at": "..."
            }
        ],
        "links": {
            "first": "...",
            "last": "...",
            "prev": null,
            "next": null
        },
        "meta": {
            "current_page": 1,
            "from": 1,
            "last_page": 1,
            "links": [ ... ],
            "path": "...",
            "per_page": 10,
            "to": 1,
            "total": 1
        }
    }
}
```

### Models Changed

- **TransactionListResponse**:
  - Changed return type from `Map<String, dynamic>` to proper typed model
  - Now uses `TransactionListData` with pagination
- **TransactionListItem**:
  - ❌ Removed: `paidAmount`, `paymentMethod`
  - ✅ Added: `totalPaid`, `outstandingAmount`, `isFullyPaid`

---

## 4. GET DETAIL TRANSACTION

### Request (GET /transactions/{id})

No changes in URL parameters

### Response (200)

Same structure as CREATE/UPDATE response (uses `CreateTransactionResponse`)

### Models Changed

- **getTransaction()**: Return type changed from `Map<String, dynamic>` to `CreateTransactionResponse`

---

## New Models Created

### 1. PaymentHistory

```dart
class PaymentHistory {
  final int? id;
  final int? transactionId;
  final String paymentMethod;
  final double amount;
  final String paymentDate;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

### 2. ProductVariant

```dart
class ProductVariant {
  final int id;
  final String name;
  final String sku;
  final double price;
  final double costPrice;
  final int stock;
  final Map<String, dynamic>? attributes;
  final String? image;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### 3. TransactionDetailResponse

```dart
class TransactionDetailResponse {
  final int id;
  final int? productId;
  final int? productVariantId;
  final String productName;
  final String productSku;
  final double unitPrice;
  final int quantity;
  final double totalAmount;
  final dynamic product;
  final ProductVariant? productVariant;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

---

## Files Modified

1. ✅ **create_transaction_request.dart** - Updated payload structure
2. ✅ **create_transaction_response.dart** - Updated response structure
3. ✅ **transaction_list_response.dart** - Updated list item structure
4. ✅ **transaction_api_service.dart** - Updated return types for all methods
5. ✅ **payment_history.dart** - NEW FILE
6. ✅ **product_variant.dart** - NEW FILE
7. ✅ **transaction_detail_response.dart** - Updated for full details

---

## API Service Method Signatures

### Before

```dart
Future<CreateTransactionResponse> createTransaction(CreateTransactionRequest)
Future<Map<String, dynamic>> getTransaction(int transactionId)
Future<Map<String, dynamic>> getTransactions({...})
Future<CreateTransactionResponse> updateTransaction(int, CreateTransactionRequest)
```

### After

```dart
Future<CreateTransactionResponse> createTransaction(CreateTransactionRequest)
Future<CreateTransactionResponse> getTransaction(int transactionId)
Future<TransactionListResponse> getTransactions({...})
Future<CreateTransactionResponse> updateTransaction(int, CreateTransactionRequest)
```

---

## Status Values

Available transaction statuses:

- `draft` - Draft transaction
- `pending` - Pending payment
- `completed` - Completed transaction
- `cancelled` - Cancelled transaction
- `refunded` - Refunded transaction
- `outstanding` - Outstanding payment (requires `outstanding_reminder_date`)

---

## Breaking Changes

### Request Changes

1. ❌ `payment_method` (string) → ✅ `payments` (array)
2. ❌ `paid_amount` (number) → ✅ Calculated from `payments` array
3. ❌ `cash_amount`, `transfer_amount` → ✅ Individual payment amounts in array

### Response Changes

1. ❌ `success` (boolean) → ✅ `status` (string: "success" | "error")
2. ❌ `paid_amount` → ✅ `total_paid`
3. ❌ `payment_method` → ✅ `payment_histories` (array)
4. ✅ NEW: `outstanding_amount`, `is_fully_paid`
5. ✅ NEW: Full `details` and `payment_histories` arrays in response

---

## Migration Notes

### For Create/Update Transaction

**Old Code:**

```dart
final request = CreateTransactionRequest(
  paymentMethod: 'cash',
  paidAmount: 200000,
  cashAmount: 200000,
  ...
);
```

**New Code:**

```dart
final request = CreateTransactionRequest(
  payments: [
    PaymentHistory(
      paymentMethod: 'cash',
      amount: 200000,
      paymentDate: DateTime.now().toIso8601String(),
      notes: 'Cash payment',
    ),
  ],
  ...
);
```

### For Response Handling

**Old Code:**

```dart
final response = await api.createTransaction(request);
print(response.data.paidAmount);
print(response.data.paymentMethod);
```

**New Code:**

```dart
final response = await api.createTransaction(request);
print(response.data.totalPaid);
print(response.data.paymentHistories.first.paymentMethod);
```

---

## Testing Checklist

- [x] Create transaction with single payment
- [x] Create transaction with multiple payments
- [x] Create outstanding transaction with reminder date
- [x] Get transaction list with pagination
- [x] Get transaction detail by ID
- [x] Update transaction
- [x] Handle validation errors (422)
- [x] Handle authentication errors (401)

---

## Notes

1. The API now supports **multiple payment methods** per transaction through the `payments` array
2. Each payment can have its own `payment_method`, `amount`, `payment_date`, and `notes`
3. The response includes full `details` array with product variant information
4. The response includes `payment_histories` array showing all payments made
5. Outstanding transactions require `outstanding_reminder_date` field
6. All monetary values are in rupiah (IDR)

---

## Example Usage

### Creating a Transaction with Multiple Payments

```dart
final request = CreateTransactionRequest(
  storeId: 1,
  customerName: 'John Doe',
  customerPhone: '08123456789',
  payments: [
    PaymentHistory(
      paymentMethod: 'cash',
      amount: 100000,
      paymentDate: DateTime.now().toIso8601String(),
      notes: 'Down payment',
    ),
    PaymentHistory(
      paymentMethod: 'transfer',
      amount: 100000,
      paymentDate: DateTime.now().toIso8601String(),
      notes: 'Bank transfer',
    ),
  ],
  status: 'completed',
  transactionDate: '2025-10-10',
  details: [
    TransactionDetail(
      productVariantId: 243,
      quantity: 2,
      unitPrice: 100000,
    ),
  ],
);

final response = await apiService.createTransaction(request);
print('Transaction Number: ${response.data.transactionNumber}');
print('Total Paid: ${response.data.totalPaid}');
```

---

End of Documentation
