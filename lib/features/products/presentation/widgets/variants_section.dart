import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/product_detail_response.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../viewmodels/product_detail_viewmodel.dart';

class VariantsSection extends StatelessWidget {
  final ProductDetailViewModel viewModel;

  const VariantsSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final productDetail = viewModel.productDetail!;
    if (productDetail.variants.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
          // Section Header with Dashboard Style
          const Row(
            children: [
              Icon(LucideIcons.layers, size: 24, color: Color(0xFF6366f1)),
              SizedBox(width: 12),
              Text(
                'Varian Produk',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1f2937),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Variant Selector with Dashboard Chips
          if (productDetail.variants.length > 1)
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: productDetail.variants.length,
                itemBuilder: (_, index) {
                  final variant = productDetail.variants[index];
                  final isSelected = index == viewModel.selectedVariantIndex;

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: FilterChip(
                      label: Text(variant.name),
                      selected: isSelected,
                      onSelected: (_) => viewModel.selectVariant(index),
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0x1a6366f1),
                      checkmarkColor: const Color(0xFF6366f1),
                      labelStyle: TextStyle(
                        color:
                            isSelected
                                ? const Color(0xFF6366f1)
                                : const Color(0xFF6b7280),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color:
                            isSelected
                                ? const Color(0xFF6366f1)
                                : const Color(0x1a6b7280),
                      ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 24),

          // Selected Variant Details with Dashboard Card
          _VariantDetails(variant: viewModel.selectedVariant!),
        ],
      ),
    );
  }
}

class _VariantDetails extends StatelessWidget {
  final ProductVariant variant;

  const _VariantDetails({required this.variant});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1a6b7280)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Variant Name and SKU with Dashboard Style
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      variant.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1f2937),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SKU: ${variant.sku}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6b7280),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      variant.stock > 10
                          ? const Color(0x1a10b981)
                          : const Color(0x1aef4444),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        variant.stock > 10
                            ? const Color(0x3a10b981)
                            : const Color(0x3aef4444),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      variant.stock > 10
                          ? LucideIcons.check
                          : LucideIcons.alertTriangle,
                      size: 14,
                      color:
                          variant.stock > 10
                              ? const Color(0xFF10b981)
                              : const Color(0xFFef4444),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      variant.stock > 10 ? 'Tersedia' : 'Stok Rendah',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            variant.stock > 10
                                ? const Color(0xFF10b981)
                                : const Color(0xFFef4444),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Price and Stock in Dashboard Cards
          Row(
            children: [
              Expanded(
                child: _buildVariantInfoCard(
                  'Harga Jual',
                  CurrencyFormatter.formatIDR(variant.price),
                  LucideIcons.dollarSign,
                  const Color(0xFF10b981),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVariantInfoCard(
                  'Stok',
                  '${variant.stock} unit',
                  LucideIcons.package,
                  variant.stock > 10
                      ? const Color(0xFF10b981)
                      : const Color(0xFFef4444),
                ),
              ),
            ],
          ),

          // Attributes with Dashboard Style
          if (variant.attributes.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x1a6b7280)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        LucideIcons.list,
                        size: 16,
                        color: Color(0xFF6366f1),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Atribut',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1f2937),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...variant.attributes.entries
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${entry.key}: ${entry.value}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6b7280),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVariantInfoCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
