import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../viewmodels/product_detail_viewmodel.dart';

class QuantityControls extends StatelessWidget {
  final ProductDetailViewModel viewModel;

  const QuantityControls({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final maxStock = viewModel.maxStock;

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
          // Quantity Section Header with Dashboard Style
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0x0f6366f1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.shoppingCart,
                  size: 20,
                  color: Color(0xFF6366f1),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Jumlah Pesanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1f2937),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stock Info with Enhanced Dashboard Badge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  maxStock > 0
                      ? const Color(0x1a10b981)
                      : const Color(0x1aef4444),
                  maxStock > 0
                      ? const Color(0x0a10b981)
                      : const Color(0x0aef4444),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    maxStock > 0
                        ? const Color(0x3a10b981)
                        : const Color(0x3aef4444),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (maxStock > 0
                            ? const Color(0xFF10b981)
                            : const Color(0xFFef4444))
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    maxStock > 0 ? LucideIcons.package : LucideIcons.packageX,
                    size: 16,
                    color:
                        maxStock > 0
                            ? const Color(0xFF10b981)
                            : const Color(0xFFef4444),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    maxStock > 0
                        ? 'Stok tersedia: $maxStock unit'
                        : 'Stok tidak tersedia',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color:
                          maxStock > 0
                              ? const Color(0xFF10b981)
                              : const Color(0xFFef4444),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Quantity Controls with Enhanced Dashboard Style
          if (maxStock > 0) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  'Jumlah:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1f2937),
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x1a6b7280)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildQuantityButton(
                        icon: LucideIcons.minus,
                        onPressed:
                            viewModel.quantity > 1
                                ? viewModel.decreaseQuantity
                                : null,
                      ),
                      Container(
                        width: 80,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: TextField(
                          controller: viewModel.quantityController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1f2937),
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: viewModel.onQuantityChanged,
                        ),
                      ),
                      _buildQuantityButton(
                        icon: LucideIcons.plus,
                        onPressed:
                            viewModel.quantity < maxStock
                                ? viewModel.increaseQuantity
                                : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Manual Input Info
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x0f6366f1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x1a6366f1)),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.info,
                    size: 16,
                    color: Color(0xFF6366f1),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Anda dapat mengetik langsung atau menggunakan tombol +/-',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6366f1)),
                    ),
                  ),
                ],
              ),
            ),

            // Quantity limit info with Dashboard Style
            if (viewModel.quantity >= maxStock) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0x0ff59e0b),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0x1af59e0b)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.alertTriangle,
                      size: 16,
                      color: Color(0xFFf59e0b),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Jumlah maksimal telah tercapai',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFf59e0b),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color:
            onPressed != null
                ? const Color(0xFF6366f1)
                : const Color(0xFFe5e7eb),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 18,
          color: onPressed != null ? Colors.white : const Color(0xFF9ca3af),
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
