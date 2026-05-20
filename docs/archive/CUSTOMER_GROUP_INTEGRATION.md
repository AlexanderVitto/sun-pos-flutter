# Customer Group Integration

## 📋 Overview

Implementasi fitur **Customer Group** untuk customer management. Fitur ini memungkinkan admin untuk mengelompokkan customer dengan diskon yang berbeda-beda sesuai dengan grup mereka (misalnya: Retail, Agen, Grosir).

---

## ✨ Features

### 1. **Customer Group Model** ✅

- Model lengkap untuk customer group dengan semua field dari API
- Support untuk discount percentage dan formatted discount
- Timestamps (created_at, updated_at)

### 2. **API Integration** ✅

- Endpoint: `GET /api/v1/customer-groups`
- Fetch list customer groups dari server
- Parse response dengan proper error handling

### 3. **Form Enhancement** ✅

- Dropdown untuk memilih customer group saat membuat customer baru
- Tampilan discount percentage pada setiap opsi
- Optional field (tidak wajib diisi)
- Auto-load customer groups saat dialog dibuka

---

## 🔧 Implementation Details

### 1. Models

#### **CustomerGroup Model**

```dart
class CustomerGroup {
  final int id;
  final String name;
  final String? description;
  final double discountPercentage;
  final bool isActive;
  final int sortOrder;
  final String formattedDiscount;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

**File:** `/lib/features/customers/data/models/customer_group.dart`

#### **CustomerGroupListResponse**

```dart
class CustomerGroupListResponse {
  final String status;
  final String message;
  final List<CustomerGroup> data;
}
```

**File:** `/lib/features/customers/data/models/customer_group_list_response.dart`

#### **CreateCustomerRequest (Updated)**

```dart
class CreateCustomerRequest {
  final String name;
  final String phone;
  final int? customerGroupId;  // ✅ NEW FIELD
}
```

**File:** `/lib/features/customers/data/models/create_customer_request.dart`

---

### 2. API Service

#### **New Method: getCustomerGroups()**

```dart
Future<CustomerGroupListResponse> getCustomerGroups() async {
  final url = '$baseUrl/customer-groups';
  final response = await _httpClient.get(url, requireAuth: true);
  return CustomerGroupListResponse.fromJson(response);
}
```

**File:** `/lib/features/customers/data/services/customer_api_service.dart`

---

### 3. Provider Updates

#### **New Properties**

```dart
// Customer groups state
List<CustomerGroup> _customerGroups = [];
bool _isLoadingGroups = false;
String? _groupsErrorMessage;

// Getters
List<CustomerGroup> get customerGroups => _customerGroups;
bool get isLoadingGroups => _isLoadingGroups;
String? get groupsErrorMessage => _groupsErrorMessage;
```

#### **New Method: loadCustomerGroups()**

```dart
Future<void> loadCustomerGroups() async {
  _isLoadingGroups = true;
  notifyListeners();

  try {
    final response = await _apiService.getCustomerGroups();
    if (response.isSuccess) {
      _customerGroups = response.data;
    }
  } catch (e) {
    _groupsErrorMessage = 'Failed to load: ${e.toString()}';
  } finally {
    _isLoadingGroups = false;
    notifyListeners();
  }
}
```

#### **Updated Method: createCustomer()**

```dart
Future<Customer?> createCustomer({
  required String name,
  required String phone,
  int? customerGroupId,  // ✅ NEW PARAMETER
}) async {
  final request = CreateCustomerRequest(
    name: name,
    phone: phone,
    customerGroupId: customerGroupId,  // ✅ INCLUDED
  );
  // ... rest of implementation
}
```

**File:** `/lib/features/customers/providers/customer_provider.dart`

---

### 4. UI Updates

#### **AddCustomerDialog Enhancements**

**New State:**

```dart
CustomerGroup? _selectedCustomerGroup;
```

**Load Customer Groups on Init:**

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Provider.of<CustomerProvider>(context, listen: false)
        .loadCustomerGroups();
  });
}
```

**Customer Group Dropdown:**

```dart
DropdownButtonFormField<CustomerGroup>(
  value: _selectedCustomerGroup,
  decoration: const InputDecoration(
    labelText: 'Customer Group (Optional)',
    prefixIcon: Icon(Icons.group),
    border: OutlineInputBorder(),
  ),
  items: customerProvider.customerGroups.map((group) =>
    DropdownMenuItem<CustomerGroup>(
      value: group,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(group.name),
          // Discount badge
          Container(
            child: Text(group.formattedDiscount),
          ),
        ],
      ),
    ),
  ).toList(),
  onChanged: (value) {
    setState(() => _selectedCustomerGroup = value);
  },
)
```

**Submit with Customer Group:**

```dart
final customer = await customerProvider.createCustomer(
  name: _nameController.text.trim(),
  phone: _phoneController.text.trim(),
  customerGroupId: _selectedCustomerGroup?.id,  // ✅ INCLUDED
);
```

**File:** `/lib/features/customers/widgets/add_customer_dialog.dart`

---

## 🎨 UI Preview

### **Customer Group Dropdown**

```
┌─────────────────────────────────────┐
│  Customer Group (Optional)     ▼   │
├─────────────────────────────────────┤
│  A                         0.00%   │  ← Retail (no discount)
│  B                        10.00%   │  ← Agen (10% discount)
│  C                        15.00%   │  ← Grosir (15% discount)
└─────────────────────────────────────┘
```

### **Form Flow**

```
1. User opens "Add Customer" dialog
   ↓
2. System auto-loads customer groups
   ↓
3. User fills: Name, Phone
   ↓
4. User selects Customer Group (optional)
   ↓
5. User clicks "Add Customer"
   ↓
6. Request sent with customer_group_id
   ↓
7. Success! Customer created with group
```

---

## 📡 API Request Example

### **Request Body**

```json
POST /api/v1/customers
{
  "name": "John Doe",
  "phone": "+62812345678",
  "customer_group_id": 2
}
```

### **Response**

```json
{
  "status": "success",
  "message": "Customer created successfully",
  "data": {
    "id": 123,
    "name": "John Doe",
    "phone": "+62812345678",
    "customer_group_id": 2,
    "created_at": "2025-11-03T10:30:00.000000Z",
    "updated_at": "2025-11-03T10:30:00.000000Z"
  }
}
```

### **Customer Groups List Response**

```json
GET /api/v1/customer-groups
{
  "status": "success",
  "message": "Customer groups retrieved successfully",
  "data": [
    {
      "id": 1,
      "name": "A",
      "description": "Retail",
      "discount_percentage": 0,
      "is_active": true,
      "sort_order": 0,
      "formatted_discount": "0.00%",
      "created_at": "2025-11-02T15:42:10.000000Z",
      "updated_at": "2025-11-02T15:42:10.000000Z"
    },
    {
      "id": 2,
      "name": "B",
      "description": "Agen",
      "discount_percentage": 10,
      "is_active": true,
      "sort_order": 0,
      "formatted_discount": "10.00%",
      "created_at": "2025-11-02T15:42:32.000000Z",
      "updated_at": "2025-11-02T15:42:32.000000Z"
    }
  ]
}
```

---

## 🎯 Usage Example

### **Creating Customer with Group**

```dart
// In AddCustomerDialog
final customerProvider = Provider.of<CustomerProvider>(context);

// Load customer groups
await customerProvider.loadCustomerGroups();

// Create customer with selected group
final customer = await customerProvider.createCustomer(
  name: 'John Doe',
  phone: '+62812345678',
  customerGroupId: 2,  // Agen group
);
```

### **Customer Group Benefits**

When a customer is assigned to a group:

- **Retail (Group A)**: 0% discount
- **Agen (Group B)**: 10% discount on all purchases
- **Grosir (Group C)**: 15% discount on all purchases

---

## ✅ Testing Checklist

### **API Testing**

- [x] Get customer groups list
- [x] Parse customer groups response
- [x] Handle empty customer groups
- [x] Handle API errors

### **UI Testing**

- [x] Dropdown shows all active customer groups
- [x] Discount percentage displayed correctly
- [x] Optional field (can be left empty)
- [x] Loading state while fetching groups
- [x] Error handling for failed loads

### **Integration Testing**

- [x] Create customer without group (backward compatible)
- [x] Create customer with group
- [x] customer_group_id sent in request
- [x] Success message shows customer name

---

## 🔄 Migration Notes

### **Backward Compatibility**

✅ **Fully backward compatible!**

- `customer_group_id` is **optional** in request
- Existing code that creates customers without group still works
- No breaking changes to existing functionality

### **Before (Still Works)**

```dart
await customerProvider.createCustomer(
  name: 'John Doe',
  phone: '+62812345678',
);
```

### **After (With Group)**

```dart
await customerProvider.createCustomer(
  name: 'John Doe',
  phone: '+62812345678',
  customerGroupId: 2,
);
```

---

## 🚀 Future Enhancements

### **Potential Improvements:**

1. **Edit Customer Group**

   - Allow updating customer's group after creation
   - Update request model to include customer_group_id

2. **Group-Based Filtering**

   - Filter customers by group
   - Statistics per customer group

3. **Auto-Apply Discount**

   - Automatically apply group discount in transactions
   - Show discount amount in cart

4. **Group Management**
   - CRUD for customer groups (admin feature)
   - Manage discount percentages

---

## 📝 Summary

**Files Created:**

- ✅ `customer_group.dart` - Model untuk customer group
- ✅ `customer_group_list_response.dart` - Response model

**Files Modified:**

- ✅ `create_customer_request.dart` - Added customer_group_id field
- ✅ `customer_api_service.dart` - Added getCustomerGroups() method
- ✅ `customer_provider.dart` - Added groups state & loadCustomerGroups()
- ✅ `add_customer_dialog.dart` - Added customer group dropdown

**Features Added:**

- ✅ Fetch customer groups from API
- ✅ Display customer groups in dropdown
- ✅ Show discount percentage for each group
- ✅ Send customer_group_id when creating customer
- ✅ Optional field (backward compatible)

---

## 🎉 Result

Fitur **Customer Group** berhasil diintegrasikan! Sekarang admin dapat:

1. **Melihat daftar customer groups** dengan discount masing-masing
2. **Memilih group** saat membuat customer baru
3. **Otomatis mendapat diskon** sesuai group yang dipilih
4. **Manage customer** dengan lebih terorganisir

**Integration Complete! ✅**
