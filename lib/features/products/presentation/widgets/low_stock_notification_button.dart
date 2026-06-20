import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../dashboard/providers/store_provider.dart';
import '../../data/models/low_stock_product.dart';
import '../../providers/low_stock_provider.dart';

/// Icon lonceng notifikasi stok menipis untuk header dashboard.
///
/// Menampilkan badge jumlah produk low-stock; tap membuka bottom sheet
/// berisi daftar dari `GET /products/low-stock?store_id=..`.
class LowStockNotificationButton extends StatefulWidget {
  const LowStockNotificationButton({super.key});

  @override
  State<LowStockNotificationButton> createState() =>
      _LowStockNotificationButtonState();
}

class _LowStockNotificationButtonState
    extends State<LowStockNotificationButton> {
  int? _lastStoreId;

  void _loadFor(int? storeId) {
    final provider = context.read<LowStockProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) provider.load(storeId: storeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Reaktif terhadap pergantian toko: muat ulang saat store berubah.
    final storeId = context.watch<StoreProvider>().selectedStore?.id;
    if (storeId != _lastStoreId) {
      _lastStoreId = storeId;
      if (storeId != null) _loadFor(storeId);
    }

    final lowStock = context.watch<LowStockProvider>();
    final count = lowStock.total;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openSheet(context, storeId),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  LucideIcons.bell,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 20,
                ),
                if (count > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      constraints: const BoxConstraints(minWidth: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openSheet(BuildContext context, int? storeId) {
    // Refresh saat dibuka agar data terkini.
    context.read<LowStockProvider>().load(storeId: storeId);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LowStockSheet(storeId: storeId),
    );
  }
}

/// Bottom sheet daftar produk stok menipis.
class LowStockSheet extends StatelessWidget {
  final int? storeId;
  const LowStockSheet({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.alertTriangle,
                      color: Color(0xFFF59E0B),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Stok Menipis',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Consumer<LowStockProvider>(
                      builder: (context, p, _) => IconButton(
                        tooltip: 'Muat ulang',
                        onPressed: p.isLoading
                            ? null
                            : () => p.load(storeId: storeId),
                        icon: const Icon(LucideIcons.refreshCw, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Consumer<LowStockProvider>(
                  builder: (context, p, _) {
                    if (p.isLoading && p.items.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (p.error != null && p.items.isEmpty) {
                      return _MessageView(
                        icon: LucideIcons.wifiOff,
                        title: 'Gagal memuat data',
                        subtitle: 'Tarik untuk coba lagi.',
                      );
                    }
                    if (p.items.isEmpty) {
                      return _MessageView(
                        icon: LucideIcons.checkCircle2,
                        title: 'Semua stok aman',
                        subtitle: 'Tidak ada produk yang menipis.',
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () => p.load(storeId: storeId),
                      child: ListView.separated(
                        controller: scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: p.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _LowStockTile(item: p.items[i]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LowStockTile extends StatelessWidget {
  final LowStockProduct item;
  const _LowStockTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final out = item.isOutOfStock;
    final color = out ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);
    final label = out ? 'Habis' : 'Menipis';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(LucideIcons.package, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Stok: ${item.stock} · Min: ${item.minStock}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _MessageView({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Icon(icon, size: 56, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
      ],
    );
  }
}
