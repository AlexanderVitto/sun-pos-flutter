# Update Transaction API Feature

## Overview

Implementasi lengkap untuk update transaction API yang memungkinkan mengupdate draft transaction yang sudah ada dengan data terbaru dari cart.

## 🔧 **API Implementation**

### **TransactionApiService Enhancement**

#### **1. updateTransaction() Method**

```dart
Future<CreateTransactionResponse> updateTransaction(
  int transactionId,
  CreateTransactionRequest request,
) async
```

**Features:**

- ✅ **Full Transaction Update**: Update semua data transaction (items, customer, amounts, etc.)
- ✅ **HTTP PUT Request**: RESTful API standard dengan PUT method
- ✅ **Error Handling**: Comprehensive error handling untuk semua status codes
- ✅ **Authentication**: Bearer token authentication
- ✅ **Validation**: Server-side validation error parsing

**HTTP Status Codes:**

- `200` - Success
- `401` - Unauthorized
- `404` - Transaction not found
- `422` - Validation error
- `400` - Bad request
- `5xx` - Server error

#### **2. deleteTransaction() Method**

```dart
Future<Map<String, dynamic>> deleteTransaction(int transactionId) async
```

**Features:**

- ✅ **Safe Deletion**: HTTP DELETE request dengan proper error handling
- ✅ **Status Code Support**: Handles 200, 204, 401, 404, 403
- ✅ **Response Handling**: Returns response data or success message

#### **3. updateTransactionStatus() Method** (Enhanced)

```dart
Future<Map<String, dynamic>> updateTransactionStatus(
  int transactionId,
  String status,
) async
```

**Features:**

- ✅ **Status Only Update**: Lightweight update untuk status saja
- ✅ **Optimized**: Minimal payload untuk quick status changes

## 🔧 **Provider Implementation**

### **TransactionProvider Enhancement**

#### **updateTransaction() Method**

```dart
Future<CreateTransactionResponse?> updateTransaction({
  required int transactionId,
  required List<CartItem> cartItems,
  required double totalAmount,
  String? notes,
  String paymentMethod = 'cash',
  int storeId = 1,
  String? customerName,
  String? customerPhone,
  String? status,
  double? cashAmount,
  double transferAmount = 0,
}) async
```

**Features:**

- ✅ **Cart Integration**: Direct integration dengan CartItem model
- ✅ **Loading State**: Manages `_isProcessingPayment` state
- ✅ **Error Handling**: User-friendly error messages
- ✅ **Event Emission**: Emits `TransactionUpdatedEvent` untuk real-time updates
- ✅ **Response Tracking**: Updates `_lastTransactionNumber`

## 🎯 **PaymentService Integration**

### **Enhanced processDraftTransaction()**

```dart
// Check existing draft transaction
if (cartProvider.hasExistingDraftTransaction) {
  // Use updateTransaction method
  await transactionProvider.updateTransaction(
    transactionId: cartProvider.draftTransactionId!,
    cartItems: cartProvider.items,
    totalAmount: cartProvider.total,
    // ... other parameters
  );
} else {
  // Create new draft transaction
  final response = await transactionProvider.processPayment(
    // ... create new transaction
  );
}
```

**Smart Logic:**

- ✅ **Create Once**: First time creates new draft transaction
- ✅ **Update Thereafter**: Subsequent changes update existing transaction
- ✅ **ID Tracking**: Maintains transaction ID throughout cart session
- ✅ **Debug Logging**: Comprehensive logging untuk troubleshooting

## 🚀 **API Endpoints**

### **Update Transaction**

```
PUT /api/v1/transactions/{id}
```

**Headers:**

```
Content-Type: application/json
Authorization: Bearer {token}
Accept: application/json
```

**Request Body:** (Same as create transaction)

```json
{
  "store_id": 1,
  "payment_method": "cash",
  "paid_amount": 50000,
  "notes": "Updated draft transaction",
  "transaction_date": "2025-09-07",
  "details": [
    {
      "product_id": 1,
      "product_variant_id": 1,
      "quantity": 2,
      "unit_price": 15000
    }
  ],
  "customer_name": "John Doe",
  "customer_phone": "+62812345678",
  "status": "draft"
}
```

**Response:** (Same as create transaction response)

```json
{
  "success": true,
  "message": "Transaction updated successfully",
  "data": {
    "id": 123,
    "transaction_number": "TXN-2025-09-07-001",
    "total_amount": 30000,
    "status": "draft"
  }
}
```

### **Delete Transaction**

```
DELETE /api/v1/transactions/{id}
```

**Response:**

```json
{
  "success": true,
  "message": "Transaction deleted successfully"
}
```

## 📋 **Event System**

### **TransactionEvents Enhancement**

```dart
// Emit update event
TransactionEvents.instance.transactionUpdated(transactionNumber);

// Listen to events
TransactionEvents.instance.stream.listen((event) {
  if (event is TransactionUpdatedEvent) {
    // Handle transaction update
    print('Transaction updated: ${event.transactionNumber}');
  }
});
```

## 🎉 **Benefits**

### **1. Efficient Data Management**

- ✅ **Reduced API Calls**: Update existing instead of creating new
- ✅ **Better Performance**: Single transaction per cart session
- ✅ **Clean Database**: No orphaned draft transactions

### **2. Real-time Updates**

- ✅ **Event-driven**: TransactionUpdatedEvent untuk real-time sync
- ✅ **State Management**: Proper loading states dan error handling
- ✅ **User Feedback**: Clear success/error messages

### **3. Developer Experience**

- ✅ **Type Safety**: Full TypeScript-like type safety dengan Dart
- ✅ **Error Handling**: Comprehensive error handling at all levels
- ✅ **Debug Support**: Extensive logging untuk troubleshooting

## 🔍 **Usage Examples**

### **Direct API Usage**

```dart
final apiService = TransactionApiService();

// Update transaction
final response = await apiService.updateTransaction(
  123, // transaction ID
  createTransactionRequest,
);

// Delete transaction
await apiService.deleteTransaction(123);

// Update status only
await apiService.updateTransactionStatus(123, 'completed');
```

### **Provider Usage**

```dart
final transactionProvider = Provider.of<TransactionProvider>(context);

// Update via provider
final response = await transactionProvider.updateTransaction(
  transactionId: 123,
  cartItems: cartItems,
  totalAmount: 50000,
  status: 'draft',
);
```

### **Cart Integration**

```dart
// Automatic update when cart changes
cartProvider.addItem(product); // Triggers update if transaction ID exists
cartProvider.updateItemQuantity(itemId, 3); // Updates existing transaction
cartProvider.removeItem(itemId); // Updates existing transaction
```

## 🏁 **Status**

- ✅ **TransactionApiService**: Complete with update/delete methods
- ✅ **TransactionProvider**: Enhanced with updateTransaction method
- ✅ **PaymentService**: Smart create/update logic implemented
- ✅ **Event System**: TransactionUpdatedEvent support
- ✅ **Error Handling**: Comprehensive error handling
- ✅ **Documentation**: Complete API documentation

**Ready for production use!** 🚀

## 🧪 **Testing Scenarios**

### **API Level Testing**

1. ✅ Update existing transaction with new data
2. ✅ Update non-existent transaction (404 error)
3. ✅ Update with invalid data (422 validation error)
4. ✅ Update without authentication (401 error)
5. ✅ Delete existing transaction
6. ✅ Delete non-existent transaction (404 error)

### **Integration Testing**

1. ✅ Cart changes trigger transaction update
2. ✅ New cart session creates new transaction
3. ✅ Clear cart resets transaction ID
4. ✅ Event emission on successful update
5. ✅ Error handling on API failures

All features tested and ready for production deployment! 🎉
