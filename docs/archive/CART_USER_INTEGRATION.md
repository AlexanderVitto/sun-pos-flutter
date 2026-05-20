# Cart Provider User Integration

## 📋 Deskripsi

Dokumentasi implementasi integrasi data user ke dalam CartProvider untuk mendukung tracking user yang sedang melakukan transaksi.

## 🚀 Implementasi

### 1. **Field User Ditambahkan ke CartProvider**

```dart
class CartProvider extends ChangeNotifier {
  // ... existing fields
  User? _currentUser;

  // Getter untuk mengakses user
  User? get currentUser => _currentUser;
}
```

### 2. **Method Baru yang Tersedia**

#### **Set User Data:**

```dart
// Set user dari AuthProvider
cartProvider.setCurrentUser(authProvider.user);

// Initialize saat startup (tanpa trigger notifyListeners)
cartProvider.initializeWithUser(authProvider.user);
```

#### **Get User Information:**

```dart
// Nama user
String? userName = cartProvider.userName;

// Email user
String? userEmail = cartProvider.userEmail;

// ID user
int? userId = cartProvider.userId;

// Role user (role pertama jika ada multiple roles)
String? userRole = cartProvider.userRole;

// Full user object
User? user = cartProvider.user;

// Check apakah user sudah login
bool hasUser = cartProvider.hasUser;
```

#### **Clear User Data:**

```dart
// Clear user data dari cart
cartProvider.clearUser();
```

## 🔧 Contoh Penggunaan

### **1. Integrasi dengan AuthProvider**

```dart
class PosTransactionPage extends StatefulWidget {
  @override
  _PosTransactionPageState createState() => _PosTransactionPageState();
}

class _PosTransactionPageState extends State<PosTransactionPage> {
  @override
  void initState() {
    super.initState();

    // Initialize cart dengan user data dari auth
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      // Set user data ke cart provider
      cartProvider.initializeWithUser(authProvider.user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CartProvider, AuthProvider>(
      builder: (context, cartProvider, authProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('POS - ${cartProvider.userName ?? "Guest"}'),
          ),
          // ... rest of the UI
        );
      },
    );
  }
}
```

### **2. Display User Info dalam Cart**

```dart
class CartSummaryWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cart Summary'),
                SizedBox(height: 8),

                // User info
                if (cartProvider.hasUser) ...[
                  Text('Cashier: ${cartProvider.userName}'),
                  Text('Role: ${cartProvider.userRole}'),
                  SizedBox(height: 8),
                ],

                // Cart totals
                Text('Total Items: ${cartProvider.itemCount}'),
                Text('Total: \$${cartProvider.total.toStringAsFixed(2)}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

### **3. Kirim User Data dalam Transaction**

```dart
class PaymentService {
  static Future<void> processPayment({
    required BuildContext context,
    required CartProvider cartProvider,
    required TextEditingController notesController,
  }) async {
    // Ambil data user dari cart
    final currentUser = cartProvider.user;

    if (currentUser == null) {
      PosUIHelpers.showErrorSnackbar(context, 'User tidak ditemukan');
      return;
    }

    // Process payment dengan user data
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

    final response = await transactionProvider.processPayment(
      cartItems: cartProvider.items,
      totalAmount: cartProvider.total,
      notes: notesController.text.trim(),
      paymentMethod: 'cash',
      customerName: cartProvider.customerName ?? 'Customer',
      customerPhone: cartProvider.customerPhone,
      // User data untuk transaction tracking
      userId: currentUser.id,
      userName: currentUser.name,
      userEmail: currentUser.email,
    );

    // Handle response...
  }
}
```

### **4. Auto-sync dengan Auth State Changes**

```dart
class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: Consumer2<AuthProvider, CartProvider>(
        builder: (context, authProvider, cartProvider, child) {
          // Auto sync user data ketika auth state berubah
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (authProvider.isAuthenticated && authProvider.user != null) {
              cartProvider.setCurrentUser(authProvider.user);
            } else {
              cartProvider.clearUser();
            }
          });

          return MaterialApp(
            // ... app configuration
          );
        },
      ),
    );
  }
}
```

## 📊 Benefit

### **1. Transaction Tracking**

- Setiap transaksi dapat di-track dengan user yang melakukan
- Audit trail untuk keperluan laporan

### **2. User Experience**

- Display nama cashier di UI
- Role-based access control dalam cart operations

### **3. Data Consistency**

- Sinkronisasi otomatis dengan auth state
- User data tersedia di seluruh cart lifecycle

### **4. Security**

- User validation sebelum process transaction
- Track user activities dalam cart operations

## 🔄 State Management Flow

```
AuthProvider Login → CartProvider.setCurrentUser() → UI Updates
AuthProvider Logout → CartProvider.clearUser() → Cart Reset
```

## ✅ Status Implementation

- ✅ User field ditambahkan ke CartProvider
- ✅ Getter methods untuk user information
- ✅ Set/Clear user methods
- ✅ Integration-ready dengan AuthProvider
- ✅ Documentation dan contoh penggunaan

## 🎯 Next Steps

1. **Implement di POS pages** - Integrate dengan halaman POS utama
2. **Transaction logging** - Tambahkan user tracking di transaction records
3. **Role-based features** - Implementasi fitur berdasarkan user role
4. **Analytics** - Track user activity untuk analytics
