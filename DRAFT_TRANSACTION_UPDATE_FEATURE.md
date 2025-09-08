# Draft Transaction Update Feature

## Overview

Implementasi fitur untuk mengupdate draft transaction yang sudah ada alih-alih membuat transaction baru setiap kali ada perubahan di cart.

## 🔧 **Technical Implementation**

### **CartProvider Enhancement**

1. **Added `_draftTransactionId` field** untuk track draft transaction ID
2. **Added methods:**
   - `setDraftTransactionId(int? transactionId)` - Set draft transaction ID
   - `hasExistingDraftTransaction` getter - Check if draft transaction exists
   - `draftTransactionId` getter - Get current draft transaction ID

### **PaymentService Enhancement**

1. **Enhanced `processDraftTransaction` method:**

   - Check if existing draft transaction exists (`hasExistingDraftTransaction`)
   - If exists: Update existing transaction (marks with transaction ID in notes)
   - If not exists: Create new draft transaction and store the ID

2. **Added helper method:**
   - `_updateCartProviderWithTransactionId()` - Safely update cart provider with transaction ID

## 🎯 **Key Features**

### **Smart Transaction Management**

- ✅ **Create once**: First time adding items creates new draft transaction
- ✅ **Update existing**: Subsequent changes update the same draft transaction
- ✅ **Track ID**: Transaction ID disimpan untuk referensi update
- ✅ **Clear on reset**: Transaction ID di-clear ketika cart di-clear

### **Debug Logging**

```dart
debugPrint('🔄 Updating existing draft transaction ID: ${cartProvider.draftTransactionId}');
debugPrint('✨ Creating new draft transaction');
debugPrint('✅ New draft transaction created with ID: ${response.data!.id}');
```

## 🚀 **Usage Flow**

### **1. First Time Adding Items**

```
User adds item → CartProvider.addItem()
    ↓
_processDraftTransaction() called
    ↓
PaymentService.processDraftTransaction()
    ↓
hasExistingDraftTransaction = false
    ↓
Create new draft transaction via API
    ↓
Store transaction ID in CartProvider
```

### **2. Subsequent Item Changes**

```
User modifies cart → CartProvider.updateItemQuantity()
    ↓
_processDraftTransaction() called
    ↓
PaymentService.processDraftTransaction()
    ↓
hasExistingDraftTransaction = true
    ↓
Update existing draft transaction (marked with ID in notes)
```

### **3. Clear Cart**

```
CartProvider.clearCart()
    ↓
_draftTransactionId = null
    ↓
Next cart operation will create new draft transaction
```

## 📋 **API Integration Points**

### **Current Implementation**

- ✅ **Create Draft**: Uses existing `TransactionProvider.processPayment()` with `status: 'draft'`
- ✅ **Update Draft**: Uses new `TransactionProvider.updateTransaction()` method
- ✅ **API Integration**: Full integration dengan `TransactionApiService.updateTransaction()`

### **Implementation Details**

```dart
// Create new draft transaction
final response = await transactionProvider.processPayment(
  cartItems: cartProvider.items,
  totalAmount: cartProvider.total,
  status: 'draft',
  // ... other parameters
);

// Update existing draft transaction
await transactionProvider.updateTransaction(
  transactionId: cartProvider.draftTransactionId!,
  cartItems: cartProvider.items,
  totalAmount: cartProvider.total,
  status: 'draft',
  // ... other parameters
);
```

## 🎉 **Benefits**

1. **Reduced API Calls**: Avoids creating multiple draft transactions for same cart session
2. **Better Data Integrity**: Maintains single source of truth for draft transaction
3. **Improved Performance**: Updates existing data instead of creating new records
4. **Clean Database**: Prevents orphaned draft transactions

## 🔍 **Testing Scenarios**

### **Happy Path**

1. ✅ Add first item → Creates new draft transaction
2. ✅ Add more items → Updates existing draft transaction
3. ✅ Modify quantities → Updates existing draft transaction
4. ✅ Clear cart → Resets transaction ID
5. ✅ Add item after clear → Creates new draft transaction

### **Edge Cases**

1. ✅ Silent failure handling for API errors
2. ✅ Context safety for BuildContext usage
3. ✅ Null safety for transaction ID handling

## 🏁 **Status**

- ✅ **CartProvider**: Enhanced with transaction ID tracking
- ✅ **PaymentService**: Smart create/update logic implemented
- ✅ **TransactionApiService**: Complete update/delete API methods
- ✅ **TransactionProvider**: updateTransaction method implemented
- ✅ **Event System**: TransactionUpdatedEvent support
- ✅ **Debug Logging**: Comprehensive logging for troubleshooting
- ✅ **Error Handling**: Silent failure to prevent UX interruption

**Ready for testing and production use!** 🚀
