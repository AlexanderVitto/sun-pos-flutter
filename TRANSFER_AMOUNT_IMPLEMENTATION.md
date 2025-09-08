# Transfer Amount Implementation

## Overview

Implementasi fitur `transfer_amount` pada `processPayment` untuk mendukung pembayaran melalui transfer bank dengan default value 0.

## Changes Made

### 1. TransactionProvider Enhancement

- **Added**: `transferAmount` parameter ke method `processPayment()` dengan default value 0
- **Added**: `transferAmount` parameter ke method `_createTransactionRequest()` dengan default value 0

```dart
Future<CreateTransactionResponse?> processPayment({
  required List<CartItem> cartItems,
  required double totalAmount,
  String? notes,
  String paymentMethod = '',
  int storeId = 1,
  String? customerName,
  String? customerPhone,
  String? status,
  double? cashAmount,
  double transferAmount = 0, // ✅ Default value 0
}) async {
  // Implementation...
}
```

### 2. CreateTransactionRequest Model Enhancement

- **Added**: `transferAmount` field ke model dengan default value 0
- **Updated**: Constructor untuk menerima `transferAmount` dengan default 0
- **Updated**: `toJson()` method untuk include `transfer_amount`
- **Updated**: `fromJson()` method untuk parse `transfer_amount` dengan fallback ke 0

```dart
class CreateTransactionRequest {
  final int storeId;
  final String paymentMethod;
  final double paidAmount;
  final String? notes;
  final String transactionDate;
  final List<TransactionDetail> details;
  final String? customerName;
  final String? customerPhone;
  final String? status;
  final double? cashAmount;
  final double transferAmount; // ✅ Non-nullable with default

  const CreateTransactionRequest({
    required this.storeId,
    required this.paymentMethod,
    required this.paidAmount,
    this.notes,
    required this.transactionDate,
    required this.details,
    this.customerName,
    this.customerPhone,
    this.status,
    this.cashAmount,
    this.transferAmount = 0, // ✅ Default value 0
  });

  factory CreateTransactionRequest.fromJson(Map<String, dynamic> json) {
    return CreateTransactionRequest(
      // ... other fields ...
      transferAmount: json['transfer_amount']?.toDouble() ?? 0, // ✅ Fallback to 0
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store_id': storeId,
      'payment_method': paymentMethod,
      'paid_amount': paidAmount,
      'notes': notes,
      'transaction_date': transactionDate,
      'details': details.map((detail) => detail.toJson()).toList(),
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'status': status,
      'cash_amount': cashAmount,
      'transfer_amount': transferAmount, // ✅ Always included, minimum 0
    };
  }
}
```

````

### 3. PaymentService Enhancement
- **Added**: `transferAmount` parameter ke method `processPayment()` dengan default value 0
- **Updated**: `_showPaymentConfirmationDialog()` untuk menerima `transferAmount`
- **Updated**: `_confirmPayment()` untuk menerima dan meneruskan `transferAmount`
- **Updated**: Semua pemanggilan `transactionProvider.processPayment()` dengan `transferAmount`

```dart
static Future<void> processPayment({
  required BuildContext context,
  required CartProvider cartProvider,
  required TextEditingController notesController,
  double? cashAmount,
  double transferAmount = 0, // ✅ Default value 0
}) async {
  // Implementation...
}
````

## API Request Format

Sekarang ketika transaksi diproses, request body akan include `transfer_amount`:

### For Payment Transactions

```json
{
  "store_id": 1,
  "payment_method": "transfer",
  "paid_amount": 150000.0,
  "notes": "Payment via bank transfer",
  "transaction_date": "2025-09-01",
  "details": [
    {
      "product_id": 123,
      "quantity": 2,
      "unit_price": 75000.0,
      "subtotal": 150000.0
    }
  ],
  "customer_name": "John Doe",
  "customer_phone": "081234567890",
  "status": "completed",
  "cash_amount": null,
  "transfer_amount": 150000.0
}
```

### For Draft Transactions

```json
{
  "store_id": 1,
  "payment_method": "cash",
  "paid_amount": 150000.0,
  "notes": "Draft Transaction - Cart Update",
  "transaction_date": "2025-09-01",
  "details": [...],
  "customer_name": "Customer",
  "status": "draft",
  "cash_amount": null,
  "transfer_amount": 0
}
```

### For Order Transactions

```json
{
  "store_id": 1,
  "payment_method": "cash",
  "paid_amount": 150000.0,
  "notes": "Order for customer",
  "transaction_date": "2025-09-01",
  "details": [...],
  "customer_name": "Customer",
  "status": "pending",
  "cash_amount": null,
  "transfer_amount": 0
}
```

## Usage Examples

### Basic Payment with Transfer Amount

```dart
PaymentService.processPayment(
  context: context,
  cartProvider: cartProvider,
  notesController: notesController,
  transferAmount: 150000.0, // Transfer amount
);
```

### Mixed Payment (Cash + Transfer)

```dart
PaymentService.processPayment(
  context: context,
  cartProvider: cartProvider,
  notesController: notesController,
  cashAmount: 50000.0,      // Cash portion
  transferAmount: 100000.0, // Transfer portion
);
```

### Cash Only Payment (Default Transfer Amount)

```dart
PaymentService.processPayment(
  context: context,
  cartProvider: cartProvider,
  notesController: notesController,
  cashAmount: 150000.0,
  // transferAmount: 0 (default, tidak perlu di-specify)
);
```

### Transfer Only Payment

```dart
PaymentService.processPayment(
  context: context,
  cartProvider: cartProvider,
  notesController: notesController,
  cashAmount: null,          // No cash
  transferAmount: 150000.0,  // Full transfer
);
```

### Mixed Payment (Most Common Use Case)

```dart
PaymentService.processPayment(
  context: context,
  cartProvider: cartProvider,
  notesController: notesController,
  cashAmount: 50000.0,      // Cash portion
  transferAmount: 100000.0, // Transfer portion
);
```

## Benefits

1. **Multi-payment Support**: Mendukung pembayaran campuran (cash + transfer)
2. **Payment Tracking**: Server dapat tracking berapa yang dibayar cash vs transfer
3. **Default Value**: transferAmount default 0, lebih predictable dan tidak nullable
4. **Backward Compatible**: Existing code tidak perlu diubah, default behavior unchanged
5. **Consistent**: Semua jenis transaksi (payment/draft/order) mendukung parameter ini
6. **Analytics Ready**: Data transfer amount tersimpan untuk reporting
7. **No Null Issues**: Dengan default value 0, tidak ada null pointer concerns

## Integration Points

### UI Layer

- Payment confirmation pages dapat menambahkan input field untuk transfer amount
- Calculator untuk split payment (cash + transfer)
- Validation untuk memastikan total payment amount match

### Business Logic

- Calculation untuk change amount (jika ada)
- Validation untuk minimum transfer amount
- Receipt generation dengan breakdown payment methods

### Backend Integration

- API endpoint sudah ready untuk menerima `transfer_amount`
- Database dapat store dan track payment methods
- Reporting dapat breakdown by payment method

## Notes

- Parameter `transferAmount` memiliki default value 0 (bukan nullable)
- Backward compatible dengan existing code
- Draft dan order transactions menggunakan default 0 untuk transfer amount
- Dapat dikombinasikan dengan `cashAmount` untuk mixed payments
- JSON field name di API adalah `transfer_amount` (snake_case)
- Selalu dikirim ke server (minimum value 0, tidak pernah null)
- Lebih predictable dan type-safe dibandingkan nullable approach
