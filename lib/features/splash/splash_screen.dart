import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/providers/auth_provider.dart';
import '../../core/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Tunggu sebentar untuk loading effect
    await Future.delayed(const Duration(seconds: 2));

    // Init auth provider untuk cek token
    await authProvider.init();

    if (!mounted) return;

    // Redirect berdasarkan status authentication
    if (authProvider.isAuthenticated) {
      // Ada token, ke dashboard
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      // Tidak ada token, ke login
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[700],
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo atau icon aplikasi
            Icon(Icons.store, size: 80, color: Colors.white),
            SizedBox(height: 24),

            // Nama aplikasi
            Text(
              'Sun POS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),

            Text(
              'Point of Sale System',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 40),

            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),

            Text(
              'Checking authentication...',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
