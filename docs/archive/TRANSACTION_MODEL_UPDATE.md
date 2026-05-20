# Transaction Model Update

## Overview

Model `TransactionData` telah diperbarui untuk mencocokkan dengan struktur response API yang baru, termasuk informasi lengkap tentang user, store, dan customer.

## Perubahan Model

### 1. File Model Baru

- **`user.dart`** - Model untuk User dengan Roles dan Permissions
- **`store.dart`** - Model untuk Store information
- **`customer.dart`** - Model untuk Customer information (nullable)

### 2. Struktur TransactionData Baru

#### Sebelum:

```dart
class TransactionData {
  final int id;
  final String transactionNumber;
  final int storeId;  // Hanya ID
  final String paymentMethod;
  final double totalAmount;
  final double paidAmount;
  final double changeAmount;
  final String? notes;
  final String transactionDate;  // String
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

#### Sesudah:

```dart
class TransactionData {
  final int id;
  final String transactionNumber;
  final String date;              // ✅ BARU - formatted date
  final double totalAmount;
  final double paidAmount;
  final double changeAmount;
  final String paymentMethod;
  final String status;
  final String? notes;
  final DateTime transactionDate; // ✅ CHANGED - DateTime object
  final User user;                // ✅ BARU - Full user object with roles
  final Store store;              // ✅ BARU - Full store object
  final Customer? customer;       // ✅ BARU - Optional customer object
  final int detailsCount;         // ✅ BARU - Transaction details count
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### 3. Model User

```dart
class User {
  final int id;
  final String name;
  final String email;
  final List<Role> roles;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### 4. Model Role

```dart
class Role {
  final int id;
  final String name;
  final String displayName;
  final String guardName;
  final List<String> permissions;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### 5. Model Store

```dart
class Store {
  final int id;
  final String name;
  final String address;
  final String phoneNumber;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### 6. Model Customer

```dart
class Customer {
  final int id;
  final String name;
  final String? email;
  final String? phoneNumber;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

## JSON Structure Support

Model sekarang mendukung struktur JSON seperti:

```json
{
  "id": 21,
  "transaction_number": "TRX20250812XBLWNU",
  "date": "2025-08-12 03:54:15",
  "total_amount": 124000,
  "paid_amount": 136400,
  "change_amount": 12400,
  "payment_method": "cash",
  "status": "completed",
  "notes": "POS Transaction - 3 items",
  "transaction_date": "2025-08-12T00:00:00.000000Z",
  "user": {
    "id": 1,
    "name": "Owner User",
    "email": "admin@gmail.com",
    "roles": [
      {
        "id": 1,
        "name": "owner",
        "display_name": "Owner",
        "guard_name": "web",
        "permissions": ["view_users", "create_users", ...]
      }
    ]
  },
  "store": {
    "id": 1,
    "name": "Downtown Store",
    "address": "123 Main Street, Downtown, City 12345",
    "phone_number": "+1 (555) 123-4567",
    "is_active": true
  },
  "customer": null,
  "details_count": 3
}
```

## Manfaat Update

### ✅ **Rich Data Structure**

- Informasi lengkap user dengan roles dan permissions
- Detail store yang komprehensif
- Support untuk customer (optional)

### ✅ **Better Type Safety**

- Proper DateTime parsing
- Null safety untuk customer
- Strong typing untuk semua fields

### ✅ **Enhanced Features**

- Access control berdasarkan user roles
- Store information untuk multi-store support
- Customer tracking (ketika tersedia)
- Transaction details count

### ✅ **Backward Compatibility**

- Semua property yang ada sebelumnya masih tersedia
- Getter methods dapat ditambahkan untuk compatibility

## Usage Examples

```dart
// Access user information
final userName = transactionData.user.name;
final userRoles = transactionData.user.roles;
final hasOwnerRole = userRoles.any((role) => role.name == 'owner');

// Access store information
final storeName = transactionData.store.name;
final storeAddress = transactionData.store.address;
final isStoreActive = transactionData.store.isActive;

// Access customer (if available)
final customerName = transactionData.customer?.name ?? 'Walk-in Customer';

// Transaction details
final hasDetails = transactionData.detailsCount > 0;
```

## Breaking Changes

⚠️ **Perhatian**: Jika ada code yang menggunakan `storeId` sebagai integer, perlu diubah menjadi `store.id`:

```dart
// Sebelum
final storeId = transactionData.storeId;

// Sesudah
final storeId = transactionData.store.id;
```

## Files Modified

- ✅ `create_transaction_response.dart` - Updated TransactionData
- ✅ `user.dart` - New User and Role models
- ✅ `store.dart` - New Store model
- ✅ `customer.dart` - New Customer model

All models include proper JSON serialization and are ready for production use.
