# Customer Group Validation Implementation

## 📋 Overview

Implementasi validasi customer group ID yang memastikan setiap customer memiliki customer group sebelum dapat melakukan transaksi. Sistem akan mengarahkan user ke halaman update customer jika customer group belum diisi.

## 🎯 Problem Statement

- API produk memerlukan `customer_id` (customer group ID) untuk mendapatkan harga yang sesuai
- Beberapa customer mungkin belum memiliki customer group ID
- User perlu diminta untuk mengisi customer group ID sebelum dapat melanjutkan transaksi

## ✨ Features Implemented

### 1. Update Customer Page

**File**: `lib/features/customers/presentation/pages/update_customer_page.dart`

#### Key Features:

- ✅ Full page UI dengan gradient header modern
- ✅ Form update untuk name, phone, address, customer group
- ✅ Visual customer group selection dengan radio buttons
- ✅ Required mode untuk customer group (parameter `requiresCustomerGroup`)
- ✅ Change summary untuk review sebelum save
- ✅ Customer info card menampilkan ID dan tanggal dibuat
- ✅ Validasi form lengkap
- ✅ Success/Error handling dengan snackbar

#### Parameters:

```dart
UpdateCustomerPage({
  required Customer customer,        // Customer yang akan diupdate
  bool requiresCustomerGroup = false // Jika true, customer group wajib diisi
})
```

#### UI Flow:

1. Header dengan gradient background
2. Alert banner jika `requiresCustomerGroup = true`
3. Customer info card (ID, created date)
4. Form fields (name, phone, address)
5. Customer group list dengan visual selection
6. Changes summary (jika ada perubahan)
7. Action buttons (Batal / Update)

### 2. Customer Selection Page Validation

**File**: `lib/features/sales/presentation/pages/customer_selection_page.dart`

#### Changes:

- Import `UpdateCustomerPage`
- Check customer group ID pada method `_selectCustomer()`
- Tampilkan dialog konfirmasi jika customer group null
- Navigate ke `UpdateCustomerPage` dengan `requiresCustomerGroup: true`
- Retry selection setelah customer diupdate

#### Flow Diagram:

```
Customer Selection
       ↓
Check customerGroupId
       ↓
   [null?]
       ↓ Yes
Show Dialog
       ↓
User confirms
       ↓
Navigate to UpdateCustomerPage
       ↓
Customer updated
       ↓
Retry _selectCustomer()
       ↓
   [null?]
       ↓ No
Set productProvider.setCustomerId()
       ↓
Load transaction
       ↓
Navigate to POS
```

### 3. Pending Transaction Resume Validation

**File**: `lib/features/sales/presentation/pages/pending_transaction_list_page.dart`

#### Changes:

- Import `UpdateCustomerPage`
- Check customer group ID pada method `_resumeTransaction()`
- Validasi untuk API transactions (`PendingTransactionItem`)
- Validasi untuk local transactions (`PendingTransaction`)
- Tampilkan dialog konfirmasi jika customer group null
- Navigate ke `UpdateCustomerPage` dengan `requiresCustomerGroup: true`
- Retry resume setelah customer diupdate

#### Flow Diagram:

```
Resume Transaction
       ↓
Get transaction detail
       ↓
Check customer.customerGroupId
       ↓
   [null?]
       ↓ Yes
Show Dialog
       ↓
User confirms
       ↓
Navigate to UpdateCustomerPage
       ↓
Customer updated
       ↓
Retry _resumeTransaction()
       ↓
   [null?]
       ↓ No
Set productProvider.setCustomerId()
       ↓
Load cart items
       ↓
Navigate to POS
```

### 4. Update Customer Request Model

**File**: `lib/features/customers/data/models/update_customer_request.dart`

#### Changes:

- Tambah field `address` (optional)
- Tambah field `customerGroupId` (optional)
- Update `toJson()` untuk include new fields

```dart
class UpdateCustomerRequest {
  final String name;
  final String phone;
  final String? address;
  final int? customerGroupId;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'name': name,
      'phone': phone,
    };

    if (address != null) {
      json['address'] = address!;
    }

    if (customerGroupId != null) {
      json['customer_group_id'] = customerGroupId!;
    }

    return json;
  }
}
```

### 5. Customer Provider Update

**File**: `lib/features/customers/providers/customer_provider.dart`

#### Changes:

- Update method signature `updateCustomer()` untuk support address dan customerGroupId

```dart
Future<Customer?> updateCustomer({
  required int customerId,
  required String name,
  required String phone,
  String? address,            // NEW
  int? customerGroupId,       // NEW
})
```

## 🎨 User Experience

### Dialog Message

```
┌─────────────────────────────────────┐
│ ⚠️  Customer Group Belum Diisi      │
├─────────────────────────────────────┤
│                                     │
│ Customer "Nama Customer" belum      │
│ memiliki customer group.            │
│                                     │
│ Customer group diperlukan untuk     │
│ mendapatkan harga produk yang       │
│ sesuai.                             │
│                                     │
│ Apakah Anda ingin mengisi customer  │
│ group sekarang?                     │
│                                     │
├─────────────────────────────────────┤
│  [Batal]    [Isi Customer Group]    │
└─────────────────────────────────────┘
```

### Update Customer Page Header (Required Mode)

```
┌─────────────────────────────────────┐
│ 🔧  Update Customer                 │
│     Perbarui informasi customer     │
│                                     │
│ ⚠️  Customer group diperlukan       │
│     untuk mendapatkan harga produk  │
└─────────────────────────────────────┘
```

## 🔄 Complete User Flows

### Flow 1: New Transaction with Customer Without Group

```
1. User taps "Mulai Transaksi"
2. User searches/selects customer
3. System checks customerGroupId
4. If null → Show dialog
5. User confirms → Navigate to UpdateCustomerPage
6. User selects customer group
7. User saves → Customer updated
8. System retries selection
9. System sets productProvider.setCustomerId()
10. Navigate to POS with correct pricing
```

### Flow 2: Resume Pending Transaction with Customer Without Group

```
1. User views pending transactions
2. User taps "Lanjutkan Transaksi"
3. System fetches transaction detail
4. System checks customer.customerGroupId
5. If null → Show dialog
6. User confirms → Navigate to UpdateCustomerPage
7. User selects customer group
8. User saves → Customer updated
9. System retries resume
10. System sets productProvider.setCustomerId()
11. Load cart items
12. Navigate to POS with correct pricing
```

### Flow 3: Customer Already Has Group (Normal Flow)

```
1. User selects customer
2. System checks customerGroupId
3. customerGroupId exists ✅
4. System sets productProvider.setCustomerId()
5. Load products with correct pricing
6. Continue to POS
```

## 🔍 Implementation Details

### Validation Logic

```dart
// In _selectCustomer() and _resumeTransaction()

// 1. Check customer group ID
if (customer.customerGroupId == null) {
  // 2. Show confirmation dialog
  final shouldUpdate = await showDialog<bool>(...);

  // 3. Navigate to update page if confirmed
  if (shouldUpdate == true) {
    final updatedCustomer = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateCustomerPage(
          customer: customer,
          requiresCustomerGroup: true,  // Force selection
        ),
      ),
    );

    // 4. Retry if updated
    if (updatedCustomer != null) {
      _selectCustomer(updatedCustomer);  // Recursive retry
    }
  }
  return;  // Exit early
}

// 5. Continue normal flow if customer group exists
productProvider.setCustomerId(customer.customerGroupId!);
// ... continue transaction
```

### Required Customer Group Mode

```dart
// In UpdateCustomerPage

// Show warning banner
if (widget.requiresCustomerGroup) {
  Container(
    decoration: BoxDecoration(
      color: Colors.orange.withValues(alpha: 0.2),
      ...
    ),
    child: Text(
      'Customer group diperlukan untuk mendapatkan harga produk',
      ...
    ),
  )
}

// Validate on submit
Future<void> _handleSubmit() async {
  if (widget.requiresCustomerGroup && _selectedGroup == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pilih Customer Group terlebih dahulu'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  // ... continue save
}
```

## 📊 Benefits

### 1. Data Integrity

- ✅ Memastikan setiap customer memiliki customer group sebelum transaksi
- ✅ Mencegah error saat fetch products (customer_id required)
- ✅ Harga produk selalu sesuai dengan customer group

### 2. User Experience

- ✅ Clear messaging tentang kenapa customer group diperlukan
- ✅ Guided flow untuk update customer
- ✅ Retry otomatis setelah update
- ✅ Tidak perlu manual refresh atau restart

### 3. Business Logic

- ✅ Enforced pricing rules per customer group
- ✅ Prevent transactions without proper pricing
- ✅ Maintain data consistency

### 4. Developer Experience

- ✅ Centralized validation logic
- ✅ Reusable UpdateCustomerPage component
- ✅ Type-safe null checks
- ✅ Clear flow control with early returns

## 🧪 Testing Checklist

### Test Case 1: New Transaction - Customer Without Group

- [ ] Select customer without customer group ID
- [ ] Dialog appears with warning message
- [ ] Click "Batal" → Returns to customer list
- [ ] Click "Isi Customer Group" → Navigate to update page
- [ ] Required banner visible on update page
- [ ] Select customer group
- [ ] Save → Success message appears
- [ ] Automatically retry selection
- [ ] Products load with correct pricing
- [ ] Transaction starts successfully

### Test Case 2: Resume Transaction - Customer Without Group (API)

- [ ] Resume pending transaction (API) with customer without group
- [ ] Dialog appears with warning message
- [ ] Click "Isi Customer Group" → Navigate to update page
- [ ] Select customer group
- [ ] Save → Success message appears
- [ ] Automatically retry resume
- [ ] Cart items loaded
- [ ] Products load with correct pricing
- [ ] Navigate to POS successfully

### Test Case 3: Resume Transaction - Customer Without Group (Local)

- [ ] Resume pending transaction (local) with customer without group
- [ ] Dialog appears with warning message
- [ ] Click "Isi Customer Group" → Navigate to update page
- [ ] Select customer group
- [ ] Save → Success message appears
- [ ] Automatically retry resume
- [ ] Cart items loaded
- [ ] Products load with correct pricing
- [ ] Navigate to POS successfully

### Test Case 4: Customer With Group (Normal Flow)

- [ ] Select customer with customer group ID
- [ ] No dialog appears
- [ ] Product provider setCustomerId called
- [ ] Products load immediately
- [ ] Transaction starts successfully

### Test Case 5: Update Customer Page - Optional Mode

- [ ] Navigate to UpdateCustomerPage with `requiresCustomerGroup: false`
- [ ] No warning banner visible
- [ ] "WAJIB" badge not shown
- [ ] Can save without selecting group
- [ ] Customer updated successfully

### Test Case 6: Update Customer Page - Required Mode

- [ ] Navigate to UpdateCustomerPage with `requiresCustomerGroup: true`
- [ ] Warning banner visible
- [ ] "WAJIB" badge shown on section title
- [ ] Try to save without group → Error message
- [ ] Select group and save → Success

### Test Case 7: Form Validation

- [ ] Name field: Empty → Error
- [ ] Name field: Less than 2 chars → Error
- [ ] Phone field: Empty → Error
- [ ] Phone field: Invalid format → Error
- [ ] Phone field: Duplicate (other customer) → Error
- [ ] Address field: Empty → OK (optional)
- [ ] All valid → Save successful

### Test Case 8: Changes Summary

- [ ] No changes → Submit button disabled
- [ ] Change name → Shows in summary
- [ ] Change phone → Shows in summary
- [ ] Change address → Shows in summary
- [ ] Change customer group → Shows in summary
- [ ] Multiple changes → All shown

## 🔗 Related Files

### Modified Files

1. `/lib/features/customers/presentation/pages/update_customer_page.dart` - NEW
2. `/lib/features/customers/data/models/update_customer_request.dart` - UPDATED
3. `/lib/features/customers/providers/customer_provider.dart` - UPDATED
4. `/lib/features/sales/presentation/pages/customer_selection_page.dart` - UPDATED
5. `/lib/features/sales/presentation/pages/pending_transaction_list_page.dart` - UPDATED

### Related Documentation

- `CUSTOMER_BASED_PRODUCT_PRICING.md` - Original pricing implementation
- `CUSTOMER_PRODUCT_PRICING_INTEGRATION.md` - Integration details
- `RESUME_TRANSACTION_PRICING.md` - Resume transaction pricing

## 💡 Technical Notes

### Why Recursive Retry?

```dart
// After update, we recursively call the same method
if (updatedCustomer != null) {
  _selectCustomer(updatedCustomer);  // Recursive
}
```

**Benefits**:

- Reuses existing validation logic
- No code duplication
- Automatically handles all edge cases
- Clean control flow

### Why Early Return?

```dart
if (customer.customerGroupId == null) {
  // ... show dialog and update
  return;  // Exit early
}
// Continue normal flow
```

**Benefits**:

- Prevents nested if-else
- Clear separation of concerns
- Easier to read and maintain
- Reduces cognitive complexity

### Why Required Parameter?

```dart
UpdateCustomerPage({
  required Customer customer,
  bool requiresCustomerGroup = false,  // Optional with default
})
```

**Benefits**:

- Reusable component for different contexts
- Normal edit: `requiresCustomerGroup = false`
- Forced update: `requiresCustomerGroup = true`
- Single source of truth for UI logic

## 🎓 Lessons Learned

1. **Validation at the Right Layer**: Check customer group at the transaction entry points (selection, resume) rather than at the API level
2. **User Guidance**: Clear messaging helps users understand why they need to take action
3. **Automated Retry**: Removing manual steps improves UX significantly
4. **Reusable Components**: UpdateCustomerPage serves both normal updates and forced updates
5. **Type Safety**: Null checks prevent runtime errors and guide proper data flow

## 🚀 Future Enhancements

### Potential Improvements:

1. **Batch Update**: Allow updating multiple customers' groups at once
2. **Smart Defaults**: Suggest customer group based on customer type/history
3. **Inline Quick Select**: Show customer group picker directly in dialog
4. **Analytics**: Track how many customers are missing groups
5. **Notifications**: Remind admin about customers without groups
6. **Import Helper**: Bulk import with group assignment

### API Enhancements:

1. **Required Field**: Make customer_group_id required at API level
2. **Default Group**: API returns default group if none specified
3. **Group Migration**: API endpoint to bulk assign groups

---

**Implementation Date**: November 3, 2025  
**Status**: ✅ Complete  
**Version**: 1.0.0
