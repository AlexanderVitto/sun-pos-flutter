import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sun_pos/features/sales/presentation/view_models/pos_transaction_view_model.dart';
import '../utils/pos_ui_helpers.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  final VoidCallback onPaymentPressed;
  final VoidCallback? onOrderPressed;

  const BottomNavigationBarWidget({
    super.key,
    required this.onPaymentPressed,
    this.onOrderPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<POSTransactionViewModel>(
      builder: (_, viewModel, child) {
        final cartProvider = viewModel.cartProvider;
        final itemCount = cartProvider?.itemCount ?? 0;
        final total = cartProvider?.total ?? 0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1f2937).withValues(alpha: 0.1),
                spreadRadius: 0,
                blurRadius: 20,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total: Rp ${PosUIHelpers.formatPrice(total)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF10b981),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$itemCount item dalam keranjang',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6b7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Buttons row
                Row(
                  children: [
                    // Pesan button
                    if (onOrderPressed != null) ...[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow:
                              itemCount > 0
                                  ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFf97316,
                                      ).withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: ElevatedButton(
                          onPressed: itemCount > 0 ? onOrderPressed : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFf97316),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'PESAN',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Bayar Sekarang button
                    // Container(
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(12),
                    //     boxShadow:
                    //         itemCount > 0
                    //             ? [
                    //               BoxShadow(
                    //                 color: const Color(
                    //                   0xFF10b981,
                    //                 ).withValues(alpha: 0.3),
                    //                 blurRadius: 12,
                    //                 offset: const Offset(0, 4),
                    //               ),
                    //             ]
                    //             : null,
                    //   ),
                    //   child: ElevatedButton(
                    //     onPressed: itemCount > 0 ? onPaymentPressed : null,
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: const Color(0xFF10b981),
                    //       foregroundColor: Colors.white,
                    //       padding: const EdgeInsets.symmetric(
                    //         horizontal: 20,
                    //         vertical: 16,
                    //       ),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(12),
                    //       ),
                    //       elevation: 0,
                    //     ),
                    //     child: const Row(
                    //       mainAxisSize: MainAxisSize.min,
                    //       children: [
                    //         Icon(Icons.payment_rounded, size: 18),
                    //         SizedBox(width: 6),
                    //         Text(
                    //           'BAYAR',
                    //           style: TextStyle(
                    //             fontWeight: FontWeight.bold,
                    //             fontSize: 14,
                    //             letterSpacing: 0.5,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
