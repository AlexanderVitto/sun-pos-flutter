// Contoh implementasi untuk menunjukkan inisialisasi user di CartProvider

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import yang diperlukan untuk contoh ini
// import '../features/auth/providers/auth_provider.dart';
// import '../features/sales/providers/cart_provider.dart';

/// Widget untuk mendemonstrasikan inisialisasi user pada CartProvider
/// Gunakan widget ini sebagai contoh implementasi dalam aplikasi
class UserInitializationDemo extends StatefulWidget {
  const UserInitializationDemo({super.key});

  @override
  State<UserInitializationDemo> createState() => _UserInitializationDemoState();
}

class _UserInitializationDemoState extends State<UserInitializationDemo> {
  @override
  void initState() {
    super.initState();

    // Method 1: Inisialisasi manual saat widget dibuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUserInCart();
    });
  }

  /// Inisialisasi user data dari AuthProvider ke CartProvider
  void _initializeUserInCart() {
    // Uncomment untuk penggunaan nyata:
    /*
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    if (authProvider.isAuthenticated && authProvider.user != null) {
      // Gunakan initializeWithUser untuk inisialisasi tanpa trigger rebuild
      cartProvider.initializeWithUser(authProvider.user);
      
      print('✅ User ${authProvider.user!.name} berhasil diinisiasi di cart');
    } else {
      print('❌ User belum login atau tidak tersedia');
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Initialization Demo'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header info
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🚀 initializeWithUser Implementation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Method ini digunakan untuk menginisiasi user data di CartProvider '
                      'tanpa memicu notifyListeners(), cocok untuk setup awal.',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Method demo cards
            _buildMethodCard(
              '1. Manual Initialization',
              'Inisialisasi manual saat widget dibuat',
              '''
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      cartProvider.initializeWithUser(authProvider.user);
    }
  });
}''',
              Colors.green,
            ),

            _buildMethodCard(
              '2. Auto-Sync (Recommended)',
              'Sinkronisasi otomatis di main.dart',
              '''
Consumer2<AuthProvider, CartProvider>(
  builder: (context, authProvider, cartProvider, child) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cartProvider.syncUserData(authProvider.user);
    });
    
    return MaterialApp(...);
  },
)''',
              Colors.blue,
            ),

            _buildMethodCard(
              '3. On Login Success',
              'Set user setelah login berhasil',
              '''
// Di AuthProvider setelah login berhasil
void _onLoginSuccess(User user) {
  // Update auth state
  _user = user;
  _isAuthenticated = true;
  
  // Optional: langsung set ke cart
  final cartProvider = Provider.of<CartProvider>(context, listen: false);
  cartProvider.setCurrentUser(user); // Ini akan trigger notifyListeners
}''',
              Colors.orange,
            ),

            const SizedBox(height: 16),

            // Status demo (commented karena provider tidak tersedia di contoh)
            Card(
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📊 Current Status (Demo)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Auth Status: Demo Mode'),
                    const Text('Cart User: Not Available (Demo)'),
                    const Text('Sync Status: Ready to implement'),
                    const SizedBox(height: 8),
                    Text(
                      'Uncomment kode di _initializeUserInCart() untuk implementasi nyata.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showImplementationDialog();
                    },
                    icon: const Icon(Icons.info),
                    label: const Text('Cara Implementasi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showBenefitsDialog();
                    },
                    icon: const Icon(Icons.star),
                    label: const Text('Benefits'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodCard(
    String title,
    String description,
    String code,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 4, height: 20, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description, style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                code,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImplementationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('🛠 Cara Implementasi'),
            content: const SingleChildScrollView(
              child: Text(
                '1. Pastikan AuthProvider dan CartProvider sudah disetup di MultiProvider\n\n'
                '2. Gunakan Consumer2<AuthProvider, CartProvider> di main.dart\n\n'
                '3. Panggil cartProvider.syncUserData(authProvider.user) dalam addPostFrameCallback\n\n'
                '4. Method initializeWithUser() akan otomatis dipanggil saat app startup\n\n'
                '5. User data akan tersinkronisasi otomatis saat login/logout',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showBenefitsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('⭐ Benefits'),
            content: const SingleChildScrollView(
              child: Text(
                '✅ Auto-sync user data saat app startup\n\n'
                '✅ No manual initialization required\n\n'
                '✅ Consistent user state across app\n\n'
                '✅ Transaction tracking dengan user info\n\n'
                '✅ Better user experience dengan cashier info\n\n'
                '✅ Audit trail untuk security',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
