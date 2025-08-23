# Transaction API Implementation

## 📋 Overview

Implementasi lengkap untuk mengirim transaksi ke endpoint `{{base_url}}/api/v1/transactions` dengan method POST. Sistem ini menyediakan struktur yang clean, modular, dan mudah digunakan untuk mengelola transaksi POS.

## 🏗️ Architecture

### 1. Data Models

- **TransactionDetail**: Model untuk detail item transaksi
- **CreateTransactionRequest**: Model untuk request body API
- **CreateTransactionResponse**: Model untuk response API

### 2. Service Layer

- **TransactionApiService**: Service untuk handle API calls

### 3. State Management

- **TransactionProvider**: Provider untuk manage state transaksi

### 4. Helper Classes

- **TransactionHelper**: Helper untuk penggunaan yang lebih mudah

## 📁 File Structure

```
lib/features/transactions/
├── data/
│   ├── models/
│   │   ├── transaction_detail.dart
│   │   ├── create_transaction_request.dart
│   │   └── create_transaction_response.dart
│   └── services/
│       └── transaction_api_service.dart
├── providers/
│   └── transaction_provider.dart
└── helpers/
    └── transaction_helper.dart
```

## 🚀 Quick Start

### 1. Basic Usage dengan Helper

```dart
import 'package:your_app/features/transactions/helpers/transaction_helper.dart';

// Membuat transaksi sederhana
final result = await TransactionHelper.createSimpleTransaction(
  paymentMethod: 'cash',
  paidAmount: 80000,
  items: [
    [1, 1, 2, 15000], // product_id, product_variant_id, quantity, unit_price
    [2, 2, 1, 25000],
    [3, 3, 1, 20000],
  ],
  notes: 'Pembelian minuman dan snack',
);

if (result.success) {
  print('Transaction created: ${result.data?.transactionNumber}');
} else {
  print('Error: ${result.message}');
}
```

### 2. Cash Transaction Shortcut

```dart
// Untuk transaksi cash yang lebih simple
final result = await TransactionHelper.createCashTransaction(
  paidAmount: 50000,
  items: [
    [1, 1, 1, 15000],
    [2, 2, 2, 12500],
  ],
  notes: 'Pembelian cepat',
);
```

### 3. Dengan Provider (untuk UI)

```dart
// Di Widget
Consumer<TransactionProvider>(
  builder: (context, provider, child) {
    return Column(
      children: [
        // Add items
        ElevatedButton(
          onPressed: () {
            provider.addTransactionDetail(TransactionDetail(
              productId: 1,
              productVariantId: 1,
              quantity: 2,
              unitPrice: 15000,
            ));
          },
          child: Text('Add Item'),
        ),

        // Create transaction
        ElevatedButton(
          onPressed: provider.isLoading ? null : () async {
            final success = await provider.createTransaction();
            if (success) {
              // Transaction successful
            }
          },
          child: Text('Create Transaction'),
        ),

        // Show summary
        Text('Total: Rp ${provider.totalAmount}'),
        Text('Change: Rp ${provider.changeAmount}'),
      ],
    );
  },
);
```

## 📝 API Request Format

### Endpoint

```
POST {{base_url}}/api/v1/transactions
```

### Headers

```
Content-Type: application/json
Authorization: Bearer {token}
```

### Request Body

```json
{
  "store_id": 1,
  "payment_method": "cash",
  "paid_amount": 80000,
  "notes": "Pembelian minuman dan snack",
  "transaction_date": "2025-08-09",
  "details": [
    {
      "product_id": 1,
      "product_variant_id": 1,
      "quantity": 2,
      "unit_price": 15000
    },
    {
      "product_id": 2,
      "product_variant_id": 2,
      "quantity": 1,
      "unit_price": 25000
    },
    {
      "product_id": 3,
      "product_variant_id": 3,
      "quantity": 1,
      "unit_price": 20000
    }
  ]
}
```

## 🛠️ Available Methods

### TransactionHelper

| Method                         | Description                                      |
| ------------------------------ | ------------------------------------------------ |
| `createSimpleTransaction()`    | Membuat transaksi dengan format array sederhana  |
| `createTransaction()`          | Membuat transaksi dengan objek TransactionDetail |
| `createCashTransaction()`      | Shortcut untuk transaksi cash                    |
| `validatePaidAmount()`         | Validasi apakah jumlah bayar mencukupi           |
| `calculateTotalAmount()`       | Menghitung total amount dari detail              |
| `calculateChange()`            | Menghitung kembalian                             |
| `validateTransactionDetails()` | Validasi detail transaksi                        |
| `formatCurrency()`             | Format mata uang Indonesia                       |

### TransactionProvider

| Method                      | Description                   |
| --------------------------- | ----------------------------- |
| `addTransactionDetail()`    | Menambah item ke transaksi    |
| `removeTransactionDetail()` | Menghapus item dari transaksi |
| `updateQuantity()`          | Update quantity item          |
| `setPaidAmount()`           | Set jumlah yang dibayar       |
| `setPaymentMethod()`        | Set metode pembayaran         |
| `createTransaction()`       | Buat transaksi (kirim ke API) |
| `clearForm()`               | Bersihkan form transaksi      |

### TransactionApiService

| Method                | Description                            |
| --------------------- | -------------------------------------- |
| `createTransaction()` | Kirim transaksi ke API                 |
| `getTransaction()`    | Ambil data transaksi by ID             |
| `getTransactions()`   | Ambil list transaksi dengan pagination |

## ✅ Validation

### Built-in Validations

- ✅ Quantity harus > 0
- ✅ Unit price tidak boleh negatif
- ✅ Paid amount harus mencukupi
- ✅ Payment method harus valid ('cash', 'card', 'transfer', 'e_wallet')
- ✅ Minimal 1 item dalam transaksi

### Custom Validation Example

```dart
final details = [
  TransactionDetail(productId: 1, productVariantId: 1, quantity: 2, unitPrice: 15000),
];

// Validasi detail
final detailError = TransactionHelper.validateTransactionDetails(details);
if (detailError != null) {
  print('Detail Error: $detailError');
  return;
}

// Validasi paid amount
final paidAmount = 50000.0;
final isValid = TransactionHelper.validatePaidAmount(paidAmount, details);
if (!isValid) {
  print('Paid amount is insufficient');
  return;
}
```

## 🎯 Error Handling

### API Errors

```dart
try {
  final result = await TransactionHelper.createSimpleTransaction(...);
  if (result.success) {
    // Handle success
  } else {
    // Handle API error
    print('API Error: ${result.message}');
  }
} catch (e) {
  // Handle network/other errors
  if (e.toString().contains('401')) {
    // Handle unauthorized
  } else if (e.toString().contains('422')) {
    // Handle validation error
  } else {
    // Handle other errors
    print('Error: $e');
  }
}
```

### Validation Errors

```dart
final request = CreateTransactionRequest(...);
final validationError = TransactionHelper.validateTransactionRequest(request);
if (validationError != null) {
  // Show validation error to user
  showDialog(...);
  return;
}
```

## 🔧 Configuration

### Base URL

Default baseUrl sudah di-set ke `https://sfpos.app/api/v1`. Jika perlu mengubah:

```dart
// Di TransactionApiService
class TransactionApiService {
  static const String baseUrl = 'https://your-api.com/api/v1';
  // ...
}
```

### Default Values

```dart
// Default store_id
int defaultStoreId = 1;

// Default payment method
String defaultPaymentMethod = 'cash';

// Today's date
String todayDate = DateTime.now().toIso8601String().split('T')[0];
```

## 📱 UI Examples

### Demo Pages

1. **CreateTransactionDemo** - Full featured transaction form
2. **SimpleTransactionExample** - Examples using TransactionHelper

### Screenshots & Features

- ✅ Form validation
- ✅ Real-time calculation
- ✅ Error handling
- ✅ Success feedback
- ✅ Loading states
- ✅ Sample data loader

## 🚦 Response Handling

### Success Response (201 Created)

```json
{
  "success": true,
  "message": "Transaction created successfully",
  "data": {
    "id": 123,
    "transaction_number": "TXN-2025-08-11-001",
    "store_id": 1,
    "payment_method": "cash",
    "total_amount": 75000,
    "paid_amount": 80000,
    "change_amount": 5000,
    "status": "completed",
    "created_at": "2025-08-11T10:30:00Z"
  }
}
```

### Error Response (422 Validation Error)

```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "paid_amount": ["Paid amount must be greater than total amount"],
    "details.0.quantity": ["Quantity must be greater than 0"]
  }
}
```

## 🎉 Testing

### Unit Tests

```dart
void main() {
  group('TransactionHelper Tests', () {
    test('should calculate total amount correctly', () {
      final details = [
        TransactionDetail(productId: 1, productVariantId: 1, quantity: 2, unitPrice: 15000),
        TransactionDetail(productId: 2, productVariantId: 2, quantity: 1, unitPrice: 25000),
      ];

      final total = TransactionHelper.calculateTotalAmount(details);
      expect(total, equals(55000.0));
    });

    test('should validate paid amount correctly', () {
      final details = [
        TransactionDetail(productId: 1, productVariantId: 1, quantity: 1, unitPrice: 10000),
      ];

      expect(TransactionHelper.validatePaidAmount(15000, details), isTrue);
      expect(TransactionHelper.validatePaidAmount(5000, details), isFalse);
    });
  });
}
```

## 🔄 Integration

### Dengan Provider Pattern

```dart
// main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => TransactionProvider()),
    // other providers...
  ],
  child: MyApp(),
);
```

### Dengan AuthProvider untuk Token

TransactionApiService sudah terintegrasi dengan SecureStorageService untuk mengambil token otomatis.

## 📈 Performance Tips

1. **Use Provider for UI**: Gunakan TransactionProvider untuk reactive UI
2. **Batch Operations**: Group multiple item additions
3. **Validation Early**: Validate sebelum API call
4. **Cache Results**: Cache transaction results jika diperlukan
5. **Error Recovery**: Implement retry mechanism untuk network errors

## 🛡️ Security

- ✅ Token-based authentication
- ✅ Request/Response validation
- ✅ Secure storage untuk token
- ✅ Input sanitization
- ✅ Error message filtering

## 📚 Best Practices

1. **Always validate** before sending to API
2. **Handle all error cases** (network, validation, server)
3. **Provide user feedback** (loading, success, error)
4. **Use appropriate payment methods**
5. **Calculate totals client-side** for instant feedback
6. **Clear forms** after successful transaction
7. **Log transactions** for debugging

---

**Ready to use! 🚀** Sistem transaksi sudah siap untuk production dengan error handling yang komprehensif dan UI yang user-friendly.
