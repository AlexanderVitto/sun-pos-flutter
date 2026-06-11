import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../network/connectivity_provider.dart';

/// Indikator koneksi kompak: titik berwarna + label.
///
/// Dipakai di tempat sempit seperti header/app bar. Warna & teks reaktif
/// terhadap [ConnectivityProvider].
class ConnectionStatusIndicator extends StatelessWidget {
  const ConnectionStatusIndicator({
    super.key,
    this.showLabel = true,
    this.onLight = false,
  });

  /// Tampilkan teks status di samping titik.
  final bool showLabel;

  /// Set `true` jika ditempatkan di atas background terang (teks jadi gelap).
  final bool onLight;

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivity, child) {
        final status = connectivity.status;
        final (color, label, icon) = _visualsFor(status);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == ConnectionStatus.checking)
              SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            else
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            if (showLabel) ...[
              const SizedBox(width: 6),
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: onLight
                      ? color
                      : Colors.white.withValues(alpha: 0.95),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  (Color, String, IconData) _visualsFor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.online:
        return (const Color(0xFF10b981), 'Online', LucideIcons.wifi);
      case ConnectionStatus.offline:
        return (const Color(0xFFef4444), 'Offline', LucideIcons.wifiOff);
      case ConnectionStatus.checking:
        return (const Color(0xFFf59e0b), 'Memeriksa…', LucideIcons.loader);
    }
  }
}

/// Banner offline yang menempel di atas konten.
///
/// Otomatis menyembunyikan diri saat online. Menyediakan tombol "Coba lagi"
/// untuk memaksa pengecekan ulang koneksi.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivity, child) {
        if (!connectivity.isOffline) return const SizedBox.shrink();

        return Material(
          color: const Color(0xFFef4444),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.wifiOff,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Tidak ada koneksi internet. Transaksi akan disimpan & '
                      'dikirim saat kembali online.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: connectivity.refresh,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Coba lagi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
