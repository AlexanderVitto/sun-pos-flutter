import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF6366f1)),
          SizedBox(height: 16),
          Text(
            'Loading product details...',
            style: TextStyle(color: Color(0xFF6b7280), fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ErrorView({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0x1aef4444),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                LucideIcons.alertCircle,
                size: 64,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6b7280),
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366f1),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.refreshCw, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Coba Lagi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.package, size: 64, color: Color(0xFF9ca3af)),
            SizedBox(height: 16),
            Text(
              'Data Produk Tidak Tersedia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6b7280),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Silakan periksa koneksi internet Anda dan coba lagi.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF9ca3af), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
