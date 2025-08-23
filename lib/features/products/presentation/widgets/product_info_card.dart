import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/product_detail_response.dart';

class ProductInfoCard extends StatelessWidget {
  final ProductDetail productDetail;

  const ProductInfoCard({super.key, required this.productDetail});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x1a6366f1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1a6366f1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name with Dashboard Typography
          Text(
            productDetail.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1f2937),
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // SKU Badge with Dashboard Style
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0x0f6366f1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x1a6366f1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.hash,
                  size: 16,
                  color: Color(0xFF6366f1),
                ),
                const SizedBox(width: 8),
                Text(
                  'SKU: ${productDetail.sku}',
                  style: const TextStyle(color: Color(0xFF6366f1)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Status Badge with Dashboard Colors
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color:
                  productDetail.isActive
                      ? const Color(0x1a10b981)
                      : const Color(0x1aef4444),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    productDetail.isActive
                        ? const Color(0x3a10b981)
                        : const Color(0x3aef4444),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  productDetail.isActive ? LucideIcons.check : LucideIcons.x,
                  size: 16,
                  color:
                      productDetail.isActive
                          ? const Color(0xFF10b981)
                          : const Color(0xFFef4444),
                ),
                const SizedBox(width: 8),
                Text(
                  productDetail.isActive ? 'Aktif' : 'Tidak Aktif',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color:
                        productDetail.isActive
                            ? const Color(0xFF10b981)
                            : const Color(0xFFef4444),
                  ),
                ),
              ],
            ),
          ),

          // Description with Enhanced Dashboard Style
          if (productDetail.description.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0x0f6366f1), Color(0x0a8b5cf6)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0x1a6366f1)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x0f6366f1),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0x1a6366f1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          LucideIcons.fileText,
                          size: 20,
                          color: Color(0xFF6366f1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Deskripsi Produk',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1f2937),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0x0a6b7280)),
                    ),
                    child: Text(
                      productDetail.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF374151),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Min Stock with Dashboard Icon
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0x0ff59e0b),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x1af59e0b)),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.alertTriangle,
                  size: 20,
                  color: Color(0xFFf59e0b),
                ),
                const SizedBox(width: 12),
                Text(
                  'Stok Minimum: ${productDetail.minStock}',
                  style: const TextStyle(
                    color: Color(0xFFf59e0b),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
