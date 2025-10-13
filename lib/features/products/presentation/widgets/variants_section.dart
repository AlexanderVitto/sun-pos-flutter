import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../data/models/product_detail_response.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../viewmodels/product_detail_viewmodel.dart';
import '../../../sales/providers/cart_provider.dart';

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
          Row(
            children: [
              const Icon(
                LucideIcons.layers,
                size: 24,
                color: Color(0xFF6366f1),
              ),
              const SizedBox(width: 12),
              const Text(
                'Varian Produk',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1f2937),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x1a6366f1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${productDetail.variants.length}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6366f1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Variant List
          ...productDetail.variants.map((variant) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _VariantCard(variant: variant, viewModel: viewModel),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _VariantCard extends StatelessWidget {
  final ProductVariant variant;
  final ProductDetailViewModel viewModel;

  const _VariantCard({required this.variant, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        // Get quantity for this variant
        final quantity = viewModel.getVariantQuantity(variant.id);

        // Get quantity already in cart for this variant
        final cartItem = cartProvider.items.firstWhere(
          (item) => item.product.productVariantId == variant.id,
          orElse: () => cartProvider.items.first,
        );
        final quantityInCart = cartItem.product.productVariantId == variant.id
            ? cartItem.quantity
            : 0;

        // Calculate remaining stock
        final remainingStock = variant.stock;
        final isOutOfStock = remainingStock <= 0;
        final isLowStock = remainingStock > 0 && remainingStock <= 10;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: quantity > 0
                  ? const Color(0xFF6366f1)
                  : const Color(0x1a6b7280),
              width: quantity > 0 ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Variant Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          variant.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1f2937),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.formatIDR(variant.price),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10b981),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Stock Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isOutOfStock
                          ? const Color(0x1aef4444)
                          : isLowStock
                          ? const Color(0x1af59e0b)
                          : const Color(0x1a10b981),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isOutOfStock
                            ? const Color(0x3aef4444)
                            : isLowStock
                            ? const Color(0x3af59e0b)
                            : const Color(0x3a10b981),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isOutOfStock
                              ? LucideIcons.xCircle
                              : isLowStock
                              ? LucideIcons.alertTriangle
                              : LucideIcons.check,
                          size: 14,
                          color: isOutOfStock
                              ? const Color(0xFFef4444)
                              : isLowStock
                              ? const Color(0xFFf59e0b)
                              : const Color(0xFF10b981),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Stok: $remainingStock',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isOutOfStock
                                ? const Color(0xFFef4444)
                                : isLowStock
                                ? const Color(0xFFf59e0b)
                                : const Color(0xFF10b981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // SKU and Attributes
              const SizedBox(height: 12),
              Text(
                'SKU: ${variant.sku}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6b7280)),
              ),

              if (variant.attributes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: variant.attributes.entries.map((entry) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0x1a6b7280)),
                      ),
                      child: Text(
                        '${entry.key}: ${entry.value}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6b7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              // Cart Info
              if (quantityInCart > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0x0a6366f1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0x1a6366f1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.shoppingCart,
                        size: 14,
                        color: Color(0xFF6366f1),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Di keranjang: $quantityInCart item',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6366f1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Quantity Controls
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Jumlah:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1f2937),
                    ),
                  ),
                  const Spacer(),
                  // Quantity Controls
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF6366f1)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        // Decrease Button
                        _buildQuantityButton(
                          icon: LucideIcons.minus,
                          onPressed: quantity > 0 && !isOutOfStock
                              ? () => viewModel.decreaseVariantQuantity(
                                  variant.id,
                                )
                              : null,
                        ),
                        // Quantity Input Field
                        _QuantityInputField(
                          variant: variant,
                          viewModel: viewModel,
                          quantity: quantity,
                          remainingStock: remainingStock,
                          isOutOfStock: isOutOfStock,
                        ),
                        // Increase Button
                        _buildQuantityButton(
                          icon: LucideIcons.plus,
                          onPressed: !isOutOfStock && quantity < remainingStock
                              ? () => viewModel.increaseVariantQuantity(
                                  variant.id,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
        color: onPressed != null
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

class _QuantityInputField extends StatefulWidget {
  final ProductVariant variant;
  final ProductDetailViewModel viewModel;
  final int quantity;
  final int remainingStock;
  final bool isOutOfStock;

  const _QuantityInputField({
    required this.variant,
    required this.viewModel,
    required this.quantity,
    required this.remainingStock,
    required this.isOutOfStock,
  });

  @override
  State<_QuantityInputField> createState() => _QuantityInputFieldState();
}

class _QuantityInputFieldState extends State<_QuantityInputField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.quantity}');
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(_QuantityInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quantity != widget.quantity && !_focusNode.hasFocus) {
      _controller.text = '${widget.quantity}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showInputDialog() {
    final tempController = TextEditingController(text: '${widget.quantity}');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(LucideIcons.hash, size: 24, color: Color(0xFF6366f1)),
            const SizedBox(width: 12),
            const Text(
              'Input Jumlah',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1f2937),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.variant.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6b7280),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Stok tersedia: ${widget.remainingStock}',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF10b981),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: tempController,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Jumlah',
                hintText: 'Masukkan jumlah',
                prefixIcon: const Icon(
                  LucideIcons.package,
                  color: Color(0xFF6366f1),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF6366f1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFe5e7eb)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF6366f1),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
              ),
              onSubmitted: (value) {
                _submitQuantity(tempController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF6b7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _submitQuantity(tempController.text);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366f1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'OK',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _submitQuantity(String value) {
    if (value.isEmpty) {
      widget.viewModel.setVariantQuantity(widget.variant.id, 0);
      return;
    }

    final parsedValue = int.tryParse(value);
    if (parsedValue == null) return;

    // Validate against remaining stock
    if (parsedValue > widget.remainingStock) {
      // Show warning and set to max stock
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                LucideIcons.alertTriangle,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Stok tidak mencukupi! Maksimal: ${widget.remainingStock}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFf59e0b),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      widget.viewModel.setVariantQuantity(
        widget.variant.id,
        widget.remainingStock,
      );
    } else {
      widget.viewModel.setVariantQuantity(widget.variant.id, parsedValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isOutOfStock ? null : _showInputDialog,
      child: Container(
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: widget.isOutOfStock ? const Color(0xFFe5e7eb) : Colors.white,
        ),
        child: Text(
          '${widget.quantity}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: widget.isOutOfStock
                ? const Color(0xFF9ca3af)
                : const Color(0xFF1f2937),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
