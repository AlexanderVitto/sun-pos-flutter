import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/product_detail_response.dart';

class CategoryAndUnitInfo extends StatelessWidget {
  final ProductDetail productDetail;

  const CategoryAndUnitInfo({super.key, required this.productDetail});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoCard(
              'Kategori',
              productDetail.category.name,
              productDetail.category.description,
              LucideIcons.tag,
              const Color(0xFF6366f1),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildInfoCard(
              'Satuan',
              '${productDetail.unit.name} (${productDetail.unit.symbol})',
              productDetail.unit.description,
              LucideIcons.ruler,
              const Color(0xFF8b5cf6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6b7280),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1f2937),
              letterSpacing: -0.2,
            ),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6b7280),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
