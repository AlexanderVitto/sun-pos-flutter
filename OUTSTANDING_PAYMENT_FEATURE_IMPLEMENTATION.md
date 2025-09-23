# Outstanding Payment Feature Implementation

## 🎯 **Feature Overview**

Implementasi fitur **Utang/Lunas** yang memungkinkan user untuk:

- Memilih status pembayaran: **Lunas** atau **Utang**
- Mengatur tanggal jatuh tempo untuk pembayaran utang
- Mengirim data ke API dengan status `outstanding` dan `outstanding_reminder_date`

---

## ✅ **Changes Made**

### **1. Model Enhancement - CreateTransactionRequest**

**File**: `lib/features/transactions/data/models/create_transaction_request.dart`

#### **Added Fields**

```dart
final String? outstandingReminderDate;
```

#### **Constructor Update**

```dart
const CreateTransactionRequest({
  // existing parameters...
  this.outstandingReminderDate,
});
```

#### **JSON Serialization**

```dart
Map<String, dynamic> toJson() {
  return {
    // existing fields...
    'outstanding_reminder_date': outstandingReminderDate,
  };
}

factory CreateTransactionRequest.fromJson(Map<String, dynamic> json) {
  return CreateTransactionRequest(
    // existing fields...
    outstandingReminderDate: json['outstanding_reminder_date'],
  );
}
```

#### **CopyWith Method**

```dart
CreateTransactionRequest copyWith({
  // existing parameters...
  String? outstandingReminderDate,
}) {
  return CreateTransactionRequest(
    // existing assignments...
    outstandingReminderDate: outstandingReminderDate ?? this.outstandingReminderDate,
  );
}
```

---

### **2. Provider Enhancement - TransactionProvider**

**File**: `lib/features/sales/providers/transaction_provider.dart`

#### **processPayment Method**

```dart
Future<CreateTransactionResponse?> processPayment({
  // existing parameters...
  String? outstandingReminderDate,
}) async {
  // implementation...
}
```

#### **updateTransaction Method**

```dart
Future<CreateTransactionResponse?> updateTransaction({
  // existing parameters...
  String? outstandingReminderDate,
}) async {
  // implementation...
}
```

#### **\_createTransactionRequest Method**

```dart
CreateTransactionRequest _createTransactionRequest({
  // existing parameters...
  String? outstandingReminderDate,
}) {
  return CreateTransactionRequest(
    // existing fields...
    outstandingReminderDate: outstandingReminderDate,
  );
}
```

---

### **3. UI Enhancement - PaymentConfirmationPage**

**File**: `lib/features/sales/presentation/pages/payment_confirmation_page.dart`

#### **New State Variables**

```dart
String _paymentStatus = 'lunas'; // 'lunas' or 'utang'
DateTime? _outstandingDueDate; // Tanggal jatuh tempo untuk utang
```

#### **Updated Callback Signature**

```dart
final Function(
  String customerName,
  String customerPhone,
  String paymentMethod,
  double? cashAmount,
  double? transferAmount,
  String paymentStatus,           // ✅ NEW
  String? outstandingReminderDate, // ✅ NEW
) onConfirm;
```

#### **Payment Status Selection UI**

```dart
// Payment Status Selection Card
Card(
  child: Column(
    children: [
      // Lunas Option
      InkWell(
        onTap: () => setState(() => _paymentStatus = 'lunas'),
        child: Container(/* Lunas UI */),
      ),

      // Utang Option
      InkWell(
        onTap: () => setState(() => _paymentStatus = 'utang'),
        child: Container(/* Utang UI */),
      ),

      // Due Date Picker (conditional)
      if (_paymentStatus == 'utang') ...[
        DatePicker(/* Date picker UI */),
      ],
    ],
  ),
),
```

#### **Enhanced Validation**

```dart
bool get _isPaymentValid {
  // Check if due date is required for debt payment
  if (_paymentStatus == 'utang' && _outstandingDueDate == null) {
    return false;
  }

  // existing validation logic...
}
```

#### **Date Formatting**

```dart
// Format tanggal jatuh tempo untuk API (YYYY-MM-DD)
String? outstandingReminderDateStr;
if (_paymentStatus == 'utang' && _outstandingDueDate != null) {
  outstandingReminderDateStr =
    '${_outstandingDueDate!.year}-${_outstandingDueDate!.month.toString().padLeft(2, '0')}-${_outstandingDueDate!.day.toString().padLeft(2, '0')}';
}
```

---

### **4. Service Layer Enhancement - PaymentService**

**File**: `lib/features/sales/presentation/services/payment_service.dart`

#### **Updated onConfirm Callback**

```dart
onConfirm: (
  customerName,
  customerPhone,
  paymentMethod,
  cashAmount,
  transferAmount,
  paymentStatus,           // ✅ NEW
  outstandingReminderDate, // ✅ NEW
) {
  _confirmPayment(
    context,
    cartProvider,
    customerName,
    customerPhone,
    paymentMethod,
    notesController,
    cashAmount,
    transferAmount,
    paymentStatus,           // ✅ NEW
    outstandingReminderDate, // ✅ NEW
  );
},
```

#### **Enhanced \_confirmPayment Method**

```dart
static void _confirmPayment(
  BuildContext context,
  CartProvider cartProvider,
  String customerName,
  String customerPhone,
  String paymentMethod,
  TextEditingController notesController,
  double? cashAmount,
  double? transferAmount,
  String paymentStatus,           // ✅ NEW
  String? outstandingReminderDate, // ✅ NEW
) async {
  // Status logic
  final transactionStatus = paymentStatus == 'utang' ? 'outstanding' : 'pending';

  // API calls with new parameters...
}
```

#### **Status Logic Implementation**

```dart
// For existing draft update
transactionResponse = await transactionProvider.updateTransaction(
  // existing parameters...
  status: paymentStatus == 'utang' ? 'outstanding' : 'pending',
  outstandingReminderDate: outstandingReminderDate,
);

// For new transaction creation
transactionResponse = await transactionProvider.processPayment(
  // existing parameters...
  status: paymentStatus == 'utang' ? 'outstanding' : 'pending',
  outstandingReminderDate: outstandingReminderDate,
);
```

---

## 🎨 **UI/UX Features**

### **Payment Status Selection**

- **Visual Design**: Card-based layout dengan icon yang jelas
- **Lunas Option**: Hijau dengan icon ✅ check_circle
- **Utang Option**: Orange dengan icon ⏰ schedule
- **Interactive**: Tap to select dengan visual feedback

### **Date Picker Integration**

- **Conditional Display**: Hanya muncul jika pilih "Utang"
- **Validation**: Tanggal jatuh tempo wajib diisi untuk utang
- **Theme**: Menggunakan orange theme untuk konsistensi
- **Date Range**: Minimum hari ini, maksimal 1 tahun ke depan

### **Validation Enhancement**

- **Real-time Validation**: Button disable jika validasi gagal
- **Visual Feedback**: Pesan error untuk tanggal yang belum dipilih
- **Consistent UX**: Mengintegrasikan dengan validasi payment method yang ada

---

## 📡 **API Integration**

### **Request Body Changes**

#### **For Lunas (Paid) Transaction**

```json
{
  "store_id": 1,
  "payment_method": "cash",
  "paid_amount": 50000,
  "status": "pending",
  "outstanding_reminder_date": null
}
```

#### **For Utang (Outstanding) Transaction**

```json
{
  "store_id": 1,
  "payment_method": "cash",
  "paid_amount": 50000,
  "status": "outstanding", // ✅ NEW
  "outstanding_reminder_date": "2025-10-01" // ✅ NEW
}
```

---

## 🔄 **Flow Diagram**

```
PaymentConfirmationPage
        ↓
[User selects "Utang"]
        ↓
[Date picker appears]
        ↓
[User picks due date]
        ↓
[Press "Konfirmasi Pembayaran"]
        ↓
PaymentService._confirmPayment
        ↓
[Status = "outstanding"]
        ↓
TransactionProvider.processPayment
        ↓
[API Request with outstanding_reminder_date]
        ↓
PaymentSuccessPage
```

---

## 🧪 **Testing Scenarios**

### **Scenario 1: Lunas Payment**

1. Pilih "Lunas" pada PaymentConfirmationPage
2. Pastikan date picker tidak muncul
3. Klik "Konfirmasi Pembayaran"
4. Verify API request: `status: "pending"`, `outstanding_reminder_date: null`

### **Scenario 2: Utang Payment - Valid Date**

1. Pilih "Utang" pada PaymentConfirmationPage
2. Date picker muncul
3. Pilih tanggal jatuh tempo (misal: 2025-10-15)
4. Klik "Konfirmasi Pembayaran"
5. Verify API request: `status: "outstanding"`, `outstanding_reminder_date: "2025-10-15"`

### **Scenario 3: Utang Payment - No Date Selected**

1. Pilih "Utang" pada PaymentConfirmationPage
2. Date picker muncul tapi tidak dipilih
3. Button "Konfirmasi Pembayaran" disabled
4. Error message muncul: "Tanggal jatuh tempo wajib diisi untuk pembayaran utang"

### **Scenario 4: Switch Between Options**

1. Pilih "Utang" → date picker muncul
2. Pilih tanggal (misal: 2025-10-20)
3. Switch ke "Lunas" → date picker hilang, `_outstandingDueDate = null`
4. Button enabled untuk konfirmasi

---

## 🔧 **Development Notes**

### **Backward Compatibility**

- ✅ Tidak ada breaking changes pada existing API calls
- ✅ Default values untuk `outstandingReminderDate` adalah `null`
- ✅ Existing transactions tetap berfungsi normal

### **Error Handling**

- ✅ Validation pada UI level
- ✅ Null safety untuk optional parameters
- ✅ Graceful degradation jika date picker gagal

### **Performance**

- ✅ Minimal impact karena hanya tambahan field
- ✅ Conditional rendering untuk date picker
- ✅ Efficient state management

---

## 🚀 **Future Enhancements**

1. **Outstanding Transaction Management**

   - List view untuk transaksi outstanding
   - Filter berdasarkan due date
   - Reminder notifications

2. **Payment Reminder System**

   - Push notifications pada jatuh tempo
   - Email/SMS reminders
   - Auto-follow up system

3. **Reporting & Analytics**
   - Outstanding payment reports
   - Aging analysis
   - Collection efficiency metrics

---

## 📋 **Checklist**

- [x] Model enhancement (CreateTransactionRequest)
- [x] Provider enhancement (TransactionProvider)
- [x] UI implementation (PaymentConfirmationPage)
- [x] Service layer update (PaymentService)
- [x] API integration setup
- [x] Validation logic
- [x] Error handling
- [x] Documentation

**Status**: ✅ **COMPLETE**

---

## 🎉 **Summary**

Fitur **Utang/Lunas** telah berhasil diimplementasikan dengan:

- **Backend Integration**: Status `outstanding` dan field `outstanding_reminder_date`
- **User-Friendly UI**: Radio button selection dan date picker
- **Robust Validation**: Memastikan tanggal jatuh tempo diisi untuk utang
- **Seamless Flow**: Terintegrasi dengan existing payment confirmation flow
- **Backward Compatible**: Tidak mengganggu existing functionality

Fitur ini ready untuk testing dan deployment! 🚀
