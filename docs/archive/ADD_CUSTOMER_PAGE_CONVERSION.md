# Konversi Dialog ke Page: Tambah Customer Baru

## 📋 Overview

Fitur tambah customer baru telah diubah dari **Dialog** menjadi **Full Page** untuk memberikan pengalaman yang lebih baik dalam memilih customer group.

## ✅ Perubahan yang Dilakukan

### 1. **AddCustomerPage** (Baru)

**File**: `lib/features/customers/presentation/pages/add_customer_page.dart`

**Fitur Utama**:

- ✨ **Full Screen Page** - Lebih banyak ruang untuk konten
- 📜 **Scrollable Customer Group List** - List yang bisa di-scroll dengan radio selection
- 🎨 **Modern UI Design** - Gradient header card dengan icon
- ✅ **Visual Selection** - Checkmark untuk group yang dipilih
- 🏷️ **Discount Badges** - Tampilan discount untuk setiap group
- 📝 **Form Validation** - Validasi nama dan nomor telepon
- 🔄 **Auto-load Groups** - Customer groups dimuat otomatis saat page dibuka

**UI Components**:

```dart
// Header Card dengan gradient
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
    ),
  ),
  child: Row(
    children: [
      Icon(LucideIcons.userPlus),
      Text('Data Customer'),
      Text('Masukkan informasi customer baru'),
    ],
  ),
)

// Customer Group List dengan radio selection
_buildGroupOption(
  isSelected: true/false,
  icon: LucideIcons.checkCircle2 / LucideIcons.circle,
  name: group.name,
  description: group.description,
  discount: group.formattedDiscount,
  onTap: () => setState(),
)
```

**Form Fields**:

1. **Nama Lengkap**

   - Icon: `LucideIcons.user`
   - Validation: Min 2 karakter, wajib diisi
   - Text capitalization: words

2. **Nomor Telepon**

   - Icon: `LucideIcons.phone`
   - Validation: Format nomor telepon, cek duplikat
   - Input formatters: Only numbers and phone characters
   - Hint: "081234567890 atau +62812345678"

3. **Customer Group**
   - Visual list dengan radio selection
   - **WAJIB dipilih** - Tidak ada opsi "Tanpa Group"
   - Validasi: Customer group harus dipilih sebelum submit
   - Setiap group menampilkan:
     - ✅ Checkmark icon jika dipilih
     - 📝 Nama group
     - 📄 Deskripsi group
     - 🏷️ Badge discount

### 2. **Update Navigation** (4 Files)

#### File 1: `customer_selection_card.dart`

```dart
// SEBELUM (Dialog)
final customer = await showDialog<Customer>(
  context: context,
  builder: (context) => const AddCustomerDialog(),
);

// SESUDAH (Page)
final customer = await Navigator.push<Customer>(
  context,
  MaterialPageRoute(
    builder: (context) => const AddCustomerPage(),
  ),
);
```

#### File 2: `customer_list_page.dart`

```dart
// Import berubah dari:
import '../widgets/add_customer_dialog.dart';
// Menjadi:
import '../presentation/pages/add_customer_page.dart';

// Navigation berubah dari showDialog ke Navigator.push
```

#### File 3: `customers_page.dart`

```dart
// Import berubah dari:
import '../../widgets/add_customer_dialog.dart';
// Menjadi:
import 'add_customer_page.dart';

// Navigation berubah dari showDialog ke Navigator.push
```

#### File 4: `customer_selection_page.dart`

```dart
// Import berubah dari tanpa import menjadi:
import '../../../customers/presentation/pages/add_customer_page.dart';

// Method _showCreateCustomerDialog() disederhanakan:
// SEBELUM: Dialog dengan form inline
// SESUDAH: Navigator.push ke AddCustomerPage

Future<void> _showCreateCustomerDialog() async {
  final customer = await Navigator.push<ApiCustomer.Customer>(
    context,
    MaterialPageRoute(
      builder: (context) => const AddCustomerPage(),
    ),
  );

  if (customer != null && mounted) {
    // Show success and auto-select
    await _selectCustomer(customer);
  }
}

// Method yang dihapus:
// - _createNewCustomer() - Tidak diperlukan lagi
// - _showPhoneInputDialog() - Tidak diperlukan lagi
// - _createCustomerFromDialog() - Diganti dengan navigation ke page
```

## 🎨 Design Improvements

### Color Scheme

```dart
- Background: Color(0xFFF8FAFC) - Light Gray
- Primary: Color(0xFF3B82F6) - Blue
- Text Primary: Color(0xFF1E293B) - Dark Blue
- Text Secondary: Color(0xFF475569) - Gray
- Border: Color(0xFFE2E8F0) - Light Border
- Success: Colors.green
- Error: Colors.red
```

### Typography

```dart
- Page Title: 18px, w600
- Section Headers: 14px, w600
- Form Labels: 14px, w600
- Input Text: default
- Group Names: 14px, w600
- Group Descriptions: 12px
- Discount Badge: 12px, bold
```

### Spacing & Layout

```dart
- Page padding: 20px
- Card padding: 16-20px
- Border radius: 10-12px
- Icon size: 20-28px
- Button height: 16px vertical padding
```

## 🔄 Customer Group Selection Flow

### 1. Page Load

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

### 2. Loading State

```dart
if (customerProvider.isLoadingGroups)
  Container(
    child: Row(
      children: [
        CircularProgressIndicator(),
        Text('Memuat customer groups...'),
      ],
    ),
  )
```

### 3. Empty State

```dart
else if (customerProvider.customerGroups.isEmpty)
  Container(
    decoration: BoxDecoration(
      color: Colors.orange[50],
      border: Border.all(color: Colors.orange[200]),
    ),
    child: Row(
      children: [
        Icon(LucideIcons.info, color: Colors.orange[700]),
        Text('Tidak ada customer group tersedia'),
      ],
    ),
  )
```

### 4. Group List

```dart
Column(
  children: [
    // Opsi "Tanpa Group"
    _buildGroupOption(
      isSelected: _selectedCustomerGroup == null,
      name: 'Tanpa Group',
      discount: 'Harga Normal',
    ),
    Divider(),

    // List customer groups
    ...customerProvider.customerGroups.map((group) {
      return _buildGroupOption(
        isSelected: _selectedCustomerGroup?.id == group.id,
        name: group.name,
        description: group.description,
        discount: group.formattedDiscount,
      );
    }),
  ],
)
```

## 📱 User Experience Flow

### 1. User clicks "Tambah Customer" button

- Navigasi dari dialog ke full page
- Customer groups auto-load

### 2. User fills form

- Nama lengkap (required, min 2 chars)
- Nomor telepon (required, phone format, check duplicate)
- Pilih customer group dari list (optional)

### 3. Customer Group Selection

- User dapat scroll list
- Klik pada group untuk select
- Visual feedback dengan checkmark icon
- Badge menampilkan discount percentage
- Opsi "Tanpa Group" untuk harga normal

### 4. Submit

- Validasi form
- Show loading state
- Create customer via API
- Show success/error message
- Close page dan return customer object

### 5. Return to Previous Page

- Customer baru otomatis dipilih (di customer_selection_card)
- Customer list di-refresh untuk menampilkan customer baru

## 🔍 Validation Rules

### Nama Lengkap

```dart
validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'Nama harus diisi';
  }
  if (value.trim().length < 2) {
    return 'Nama minimal 2 karakter';
  }
  return null;
}
```

### Nomor Telepon

```dart
validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'Nomor telepon harus diisi';
  }

  final phoneRegex = RegExp(r'^\+?[0-9\-\s\(\)]{8,15}$');
  if (!phoneRegex.hasMatch(value.trim())) {
    return 'Format nomor telepon tidak valid';
  }

  if (customerProvider.isCustomerExistsByPhone(value.trim())) {
    return 'Nomor telepon sudah terdaftar';
  }

  return null;
}
```

## 📦 Dependencies

### Packages Used

```yaml
dependencies:
  flutter:
  provider: ^6.0.0
  lucide_icons: ^0.0.1
```

### Models

```dart
- Customer
- CustomerGroup
```

### Providers

```dart
- CustomerProvider
  - loadCustomerGroups()
  - createCustomer()
  - isCustomerExistsByPhone()
  - isLoadingGroups
  - isCreating
  - errorMessage
  - customerGroups
```

## 🎯 Benefits

### Dari Dialog → Page

1. **More Space**

   - Full screen untuk customer group list
   - Tidak terbatas tinggi dialog
   - Lebih mudah di mobile

2. **Better UX**

   - Scrollable list dengan banyak groups
   - Visual selection lebih jelas
   - Group descriptions terlihat penuh

3. **Modern Design**

   - Gradient header card
   - Clean spacing
   - Professional look

4. **Better Performance**
   - List dapat di-optimize
   - Smooth scrolling

## 📸 Visual Preview

### Page Structure

```
┌────────────────────────────┐
│ ← Tambah Customer Baru     │ AppBar
├────────────────────────────┤
│ Scroll Area:               │
│                            │
│ ┌────────────────────────┐ │
│ │ [Icon] Data Customer   │ │ Gradient Header Card
│ │ Masukkan informasi...  │ │
│ └────────────────────────┘ │
│                            │
│ ┌────────────────────────┐ │
│ │ Nama Lengkap           │ │
│ │ [👤] _____________     │ │ Form Section
│ │                        │ │
│ │ Nomor Telepon          │ │
│ │ [📞] _____________     │ │
│ │                        │ │
│ │ Customer Group         │ │
│ │ ┌──────────────────┐   │ │
│ │ │ ○ Tanpa Group    │   │ │
│ │ ├──────────────────┤   │ │ Group List
│ │ │ ✓ VIP Customer   │   │ │
│ │ │ Diskon 15%       │   │ │
│ │ ├──────────────────┤   │ │
│ │ │ ○ Member         │   │ │
│ │ └──────────────────┘   │ │
│ └────────────────────────┘ │
│                            │
│ [Batal] [✓ Simpan Customer]│ Action Buttons
└────────────────────────────┘
```

### Group Option Item

```
┌────────────────────────────────────┐
│ ✓  VIP Customer           [15%]    │
│    Premium membership with benefits │
└────────────────────────────────────┘
  │  │                       │
  │  │                       └─ Discount Badge
  │  └─ Name + Description
  └─ Selection Icon (checkmark/circle)
```

## 🚀 Testing Checklist

- [x] Page navigation dari customer_selection_card
- [x] Page navigation dari customer_list_page
- [x] Page navigation dari customers_page
- [x] Page navigation dari customer_selection_page (sales)
- [x] Customer groups auto-load on page open
- [x] Loading state saat load groups
- [x] Empty state jika tidak ada groups
- [x] Group selection berfungsi (visual feedback)
- [x] Form validation untuk nama (min 2 char)
- [x] Form validation untuk phone (format + duplicate)
- [x] Form validation untuk customer group (wajib dipilih)
- [x] Submit button disabled saat loading
- [x] Success message setelah create
- [x] Error message jika gagal
- [x] Return customer object ke previous page
- [x] Auto-select customer baru di selection card
- [x] Refresh customer list setelah create

## 📝 Notes

1. **Dialog masih ada** (`add_customer_dialog.dart`) tapi tidak digunakan lagi
2. **Navigation pattern** berubah dari `showDialog` ke `Navigator.push`
3. **Return value** tetap sama: `Customer?` object
4. **Auto-select** di customer_selection_card tetap berfungsi
5. **Customer group WAJIB** - tidak ada opsi "Tanpa Group", harus memilih salah satu group

## 🔗 Related Files

- `lib/features/customers/presentation/pages/add_customer_page.dart` (NEW)
- `lib/features/customers/widgets/customer_selection_card.dart` (UPDATED)
- `lib/features/customers/pages/customer_list_page.dart` (UPDATED)
- `lib/features/customers/presentation/pages/customers_page.dart` (UPDATED)
- `lib/features/sales/presentation/pages/customer_selection_page.dart` (UPDATED)
- `lib/features/customers/widgets/add_customer_dialog.dart` (DEPRECATED - tidak digunakan)
