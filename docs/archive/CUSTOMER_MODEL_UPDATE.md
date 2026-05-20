# Customer Model Update - Customer Group Fields

## 📋 Overview

Update model `Customer` untuk mendukung field-field baru dari API response yang mencakup informasi **Customer Group**.

---

## 🔄 API Response Update

### **Endpoint:** `GET /api/v1/customers`

### **New Response Structure:**

```json
{
  "status": "success",
  "message": "Customers retrieved successfully",
  "data": {
    "data": [
      {
        "id": 3,
        "name": "Ahmad Rahman",
        "phone": "08345678901",
        "address": null,
        "customer_group_id": null,
        "has_customer_group": false,
        "customer_group_name": null,
        "formatted_discount": null,
        "created_at": "2025-10-08T16:30:36.000000Z",
        "updated_at": "2025-10-08T16:30:36.000000Z"
      }
    ],
    "links": { ... },
    "meta": { ... }
  }
}
```

### **Example with Customer Group:**

```json
{
  "id": 5,
  "name": "Toko Maju Jaya",
  "phone": "+62812345678",
  "address": "Jl. Sudirman No. 123",
  "customer_group_id": 2,
  "has_customer_group": true,
  "customer_group_name": "B - Agen",
  "formatted_discount": "10.00%",
  "created_at": "2025-11-03T10:30:00.000000Z",
  "updated_at": "2025-11-03T10:30:00.000000Z"
}
```

---

## 🔧 Model Changes

### **Customer Model - Before**

```dart
class Customer {
  final int id;
  final String name;
  final String phone;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Only 5 fields
}
```

### **Customer Model - After**

```dart
class Customer {
  final int id;
  final String name;
  final String phone;
  final String? address;                // ✅ NEW
  final int? customerGroupId;           // ✅ NEW
  final bool hasCustomerGroup;          // ✅ NEW
  final String? customerGroupName;      // ✅ NEW
  final String? formattedDiscount;      // ✅ NEW
  final DateTime createdAt;
  final DateTime updatedAt;

  // Now 10 fields - 5 new fields added
}
```

---

## 📝 New Fields Details

### 1. **address** (String? - nullable)

- Customer's address
- Can be null if not provided
- Used for delivery or billing purposes

### 2. **customerGroupId** (int? - nullable)

- Foreign key to customer_groups table
- Null if customer doesn't belong to any group
- Links to specific customer group

### 3. **hasCustomerGroup** (bool - default: false)

- Quick check if customer has a group
- `true` if customer_group_id is not null
- `false` if customer has no group

### 4. **customerGroupName** (String? - nullable)

- Display name of the customer group
- Example: "A - Retail", "B - Agen", "C - Grosir"
- Null if customer has no group

### 5. **formattedDiscount** (String? - nullable)

- Pre-formatted discount percentage
- Example: "0.00%", "10.00%", "15.00%"
- Null if customer has no group
- Ready for UI display

---

## 💡 Usage Examples

### **Example 1: Customer Without Group**

```dart
final customer = Customer.fromJson({
  "id": 3,
  "name": "Ahmad Rahman",
  "phone": "08345678901",
  "address": null,
  "customer_group_id": null,
  "has_customer_group": false,
  "customer_group_name": null,
  "formatted_discount": null,
  "created_at": "2025-10-08T16:30:36.000000Z",
  "updated_at": "2025-10-08T16:30:36.000000Z"
});

// Access fields
print(customer.name);              // "Ahmad Rahman"
print(customer.hasCustomerGroup);  // false
print(customer.customerGroupName); // null
print(customer.formattedDiscount); // null
```

### **Example 2: Customer With Group**

```dart
final customer = Customer.fromJson({
  "id": 5,
  "name": "Toko Maju Jaya",
  "phone": "+62812345678",
  "address": "Jl. Sudirman No. 123",
  "customer_group_id": 2,
  "has_customer_group": true,
  "customer_group_name": "B - Agen",
  "formatted_discount": "10.00%",
  "created_at": "2025-11-03T10:30:00.000000Z",
  "updated_at": "2025-11-03T10:30:00.000000Z"
});

// Access fields
print(customer.name);              // "Toko Maju Jaya"
print(customer.hasCustomerGroup);  // true
print(customer.customerGroupId);   // 2
print(customer.customerGroupName); // "B - Agen"
print(customer.formattedDiscount); // "10.00%"
```

---

## 🎨 UI Display Examples

### **Customer List Item - With Group**

```
┌────────────────────────────────────────┐
│  👤 Toko Maju Jaya                     │
│  📞 +62812345678                       │
│  👥 B - Agen          [10.00%]     │  ← Group & Discount
│  📅 Created: 2025-11-03                │
└────────────────────────────────────────┘
```

### **Customer List Item - Without Group**

```
┌────────────────────────────────────────┐
│  👤 Ahmad Rahman                       │
│  📞 08345678901                        │
│  👥 No Group                           │
│  📅 Created: 2025-10-08                │
└────────────────────────────────────────┘
```

### **Customer Card Widget Example**

```dart
Widget buildCustomerCard(Customer customer) {
  return Card(
    child: Column(
      children: [
        Text(customer.name),
        Text(customer.phone),
        if (customer.hasCustomerGroup) ...[
          Row(
            children: [
              Icon(Icons.group),
              Text(customer.customerGroupName ?? ''),
              Chip(
                label: Text(customer.formattedDiscount ?? ''),
                backgroundColor: Colors.green[100],
              ),
            ],
          ),
        ] else
          Text('No Group', style: TextStyle(color: Colors.grey)),
        if (customer.address != null)
          Text(customer.address!),
      ],
    ),
  );
}
```

---

## 🔍 Conditional Logic

### **Check if Customer Has Group**

```dart
if (customer.hasCustomerGroup) {
  // Customer belongs to a group
  print('Group: ${customer.customerGroupName}');
  print('Discount: ${customer.formattedDiscount}');
} else {
  // Customer has no group
  print('No customer group assigned');
}
```

### **Display Group Badge**

```dart
Widget buildGroupBadge(Customer customer) {
  if (!customer.hasCustomerGroup) {
    return const SizedBox.shrink();
  }

  return Container(
    padding: EdgeInsets.symmetric(h: 8, v: 4),
    decoration: BoxDecoration(
      color: Colors.green[50],
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      children: [
        Text(customer.customerGroupName ?? ''),
        SizedBox(width: 4),
        Text(
          customer.formattedDiscount ?? '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
      ],
    ),
  );
}
```

---

## 📊 Database Relationship

### **customers Table**

```sql
customers
├── id (PK)
├── name
├── phone
├── address
├── customer_group_id (FK) → customer_groups.id
├── created_at
└── updated_at
```

### **customer_groups Table**

```sql
customer_groups
├── id (PK)
├── name
├── description
├── discount_percentage
├── is_active
├── sort_order
├── created_at
└── updated_at
```

### **Relationship:**

- One customer can belong to zero or one customer group
- One customer group can have many customers
- Relationship: `customers.customer_group_id → customer_groups.id`

---

## ✅ Backward Compatibility

### **All new fields are nullable or have defaults:**

- ✅ `address` → nullable, won't break existing code
- ✅ `customerGroupId` → nullable, optional
- ✅ `hasCustomerGroup` → default false
- ✅ `customerGroupName` → nullable
- ✅ `formattedDiscount` → nullable

### **Existing code continues to work:**

```dart
// Old code (still works)
final name = customer.name;
final phone = customer.phone;

// New code (enhanced)
if (customer.hasCustomerGroup) {
  final group = customer.customerGroupName;
  final discount = customer.formattedDiscount;
}
```

---

## 🧪 Testing

### **Test Case 1: Parse Customer Without Group**

```dart
test('Parse customer without group', () {
  final json = {
    "id": 3,
    "name": "Ahmad Rahman",
    "phone": "08345678901",
    "address": null,
    "customer_group_id": null,
    "has_customer_group": false,
    "customer_group_name": null,
    "formatted_discount": null,
    "created_at": "2025-10-08T16:30:36.000000Z",
    "updated_at": "2025-10-08T16:30:36.000000Z"
  };

  final customer = Customer.fromJson(json);

  expect(customer.name, 'Ahmad Rahman');
  expect(customer.hasCustomerGroup, false);
  expect(customer.customerGroupName, null);
  expect(customer.formattedDiscount, null);
});
```

### **Test Case 2: Parse Customer With Group**

```dart
test('Parse customer with group', () {
  final json = {
    "id": 5,
    "name": "Toko Maju Jaya",
    "phone": "+62812345678",
    "address": "Jl. Sudirman No. 123",
    "customer_group_id": 2,
    "has_customer_group": true,
    "customer_group_name": "B - Agen",
    "formatted_discount": "10.00%",
    "created_at": "2025-11-03T10:30:00.000000Z",
    "updated_at": "2025-11-03T10:30:00.000000Z"
  };

  final customer = Customer.fromJson(json);

  expect(customer.name, 'Toko Maju Jaya');
  expect(customer.hasCustomerGroup, true);
  expect(customer.customerGroupId, 2);
  expect(customer.customerGroupName, 'B - Agen');
  expect(customer.formattedDiscount, '10.00%');
  expect(customer.address, 'Jl. Sudirman No. 123');
});
```

---

## 🚀 Benefits

### **For Developers:**

- ✅ Type-safe access to customer group data
- ✅ No need for manual group lookups
- ✅ Ready-to-display formatted values
- ✅ Cleaner code with `hasCustomerGroup` flag

### **For Business:**

- ✅ Quick customer categorization
- ✅ Instant discount information
- ✅ Better customer insights
- ✅ Streamlined pricing logic

### **For Users:**

- ✅ Clear visual indicators
- ✅ Transparent discount information
- ✅ Professional presentation
- ✅ Accurate pricing

---

## 📝 Summary

**Changes Made:**

- ✅ Added 5 new fields to Customer model
- ✅ All fields properly nullable or with defaults
- ✅ Backward compatible with existing code
- ✅ Ready for UI integration
- ✅ toString() method updated

**Files Modified:**

- `/lib/features/customers/data/models/customer.dart`
- `/lib/features/customers/providers/customer_provider.dart`

**Impact:**

- ✅ Enhanced customer data model
- ✅ Support for customer groups
- ✅ Ready-to-display discount info
- ✅ No breaking changes
- ✅ Better type safety

---

**🎉 Customer Model Successfully Updated!**

Now every customer object includes complete customer group information, making it easier to display discounts, categorize customers, and provide a better user experience.
