import '../data/models/create_transaction_request.dart';
import '../data/models/create_transaction_response.dart';
import '../data/models/transaction_detail.dart';
import '../data/services/transaction_api_service.dart';

/// Helper class untuk mempermudah penggunaan fungsi transaksi
class TransactionHelper {
  static final TransactionApiService _apiService = TransactionApiService();

  /// Membuat transaksi dengan format yang sederhana
  ///
  /// [storeId] - ID toko (default: 1)
  /// [paymentMethod] - Metode pembayaran: 'cash', 'card', 'transfer', 'e_wallet'
  /// [paidAmount] - Jumlah yang dibayar
  /// [items] - List item transaksi dengan format [productId, productVariantId, quantity, unitPrice]
  /// [notes] - Catatan transaksi (opsional)
  /// [transactionDate] - Tanggal transaksi dalam format YYYY-MM-DD (default: hari ini)
  ///
  /// Contoh penggunaan:
  /// ```dart
  /// final result = await TransactionHelper.createSimpleTransaction(
  ///   paymentMethod: 'cash',
  ///   paidAmount: 80000,
  ///   items: [
  ///     [1, 1, 2, 15000], // product_id: 1, product_variant_id: 1, quantity: 2, unit_price: 15000
  ///     [2, 2, 1, 25000], // product_id: 2, product_variant_id: 2, quantity: 1, unit_price: 25000
  ///   ],
  ///   notes: 'Pembelian minuman dan snack',
  /// );
  /// ```
  static Future<CreateTransactionResponse> createSimpleTransaction({
    int storeId = 1,
    required String paymentMethod,
    required double paidAmount,
    required List<List<dynamic>> items,
    String? notes,
    String? transactionDate,
    String? customerName,
    String? customerPhone,
  }) async {
    // Convert items to TransactionDetail objects
    final details =
        items.map((item) {
          if (item.length != 4) {
            throw ArgumentError(
              'Each item must have exactly 4 elements: [productId, productVariantId, quantity, unitPrice]',
            );
          }

          return TransactionDetail(
            productId: item[0] as int,
            productVariantId: item[1] as int,
            quantity: item[2] as int,
            unitPrice: (item[3] as num).toDouble(),
          );
        }).toList();

    final request = CreateTransactionRequest(
      storeId: storeId,
      paymentMethod: paymentMethod,
      paidAmount: paidAmount,
      notes: notes,
      transactionDate:
          transactionDate ?? DateTime.now().toIso8601String().split('T')[0],
      details: details,
      customerName: customerName,
      customerPhone: customerPhone,
    );

    return await _apiService.createTransaction(request);
  }

  /// Membuat transaksi dengan objek TransactionDetail
  static Future<CreateTransactionResponse> createTransaction({
    int storeId = 1,
    required String paymentMethod,
    required double paidAmount,
    required List<TransactionDetail> details,
    String? notes,
    String? transactionDate,
    String? customerName,
    String? customerPhone,
  }) async {
    final request = CreateTransactionRequest(
      storeId: storeId,
      paymentMethod: paymentMethod,
      paidAmount: paidAmount,
      notes: notes,
      transactionDate:
          transactionDate ?? DateTime.now().toIso8601String().split('T')[0],
      details: details,
      customerName: customerName,
      customerPhone: customerPhone,
    );

    return await _apiService.createTransaction(request);
  }

  /// Membuat transaksi cash dengan format sederhana
  static Future<CreateTransactionResponse> createCashTransaction({
    int storeId = 1,
    required double paidAmount,
    required List<List<dynamic>> items,
    String? notes,
    String? customerName,
    String? customerPhone,
  }) async {
    return createSimpleTransaction(
      storeId: storeId,
      paymentMethod: 'cash',
      paidAmount: paidAmount,
      items: items,
      notes: notes,
      customerName: customerName,
      customerPhone: customerPhone,
    );
  }

  /// Validasi apakah jumlah bayar mencukupi
  static bool validatePaidAmount(
    double paidAmount,
    List<TransactionDetail> details,
  ) {
    final totalAmount = details.fold(
      0.0,
      (sum, detail) => sum + detail.subtotal,
    );
    return paidAmount >= totalAmount;
  }

  /// Menghitung total amount dari detail transaksi
  static double calculateTotalAmount(List<TransactionDetail> details) {
    return details.fold(0.0, (sum, detail) => sum + detail.subtotal);
  }

  /// Menghitung kembalian
  static double calculateChange(
    double paidAmount,
    List<TransactionDetail> details,
  ) {
    final totalAmount = calculateTotalAmount(details);
    final change = paidAmount - totalAmount;
    return change > 0 ? change : 0.0;
  }

  /// Validasi detail transaksi
  static String? validateTransactionDetails(List<TransactionDetail> details) {
    if (details.isEmpty) {
      return 'Transaction must have at least one item';
    }

    for (int i = 0; i < details.length; i++) {
      final detail = details[i];
      if (detail.quantity <= 0) {
        return 'Item ${i + 1}: Quantity must be greater than 0';
      }
      if (detail.unitPrice < 0) {
        return 'Item ${i + 1}: Unit price cannot be negative';
      }
    }

    return null; // No errors
  }

  /// Validasi request transaksi secara lengkap
  static String? validateTransactionRequest(CreateTransactionRequest request) {
    // Validate details
    final detailsError = validateTransactionDetails(request.details);
    if (detailsError != null) return detailsError;

    // Validate paid amount
    if (request.paidAmount <= 0) {
      return 'Paid amount must be greater than 0';
    }

    if (!validatePaidAmount(request.paidAmount, request.details)) {
      return 'Paid amount is insufficient';
    }

    // Validate payment method
    final validPaymentMethods = ['cash', 'card', 'transfer', 'e_wallet'];
    if (!validPaymentMethods.contains(request.paymentMethod)) {
      return 'Invalid payment method. Must be one of: ${validPaymentMethods.join(', ')}';
    }

    return null; // No errors
  }

  /// Helper untuk format mata uang Indonesia
  static String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]}.')}';
  }

  /// Contoh penggunaan lengkap
  static Future<void> exampleUsage() async {
    try {
      // Contoh 1: Simple transaction
      final result1 = await createSimpleTransaction(
        paymentMethod: 'cash',
        paidAmount: 80000,
        items: [
          [1, 1, 2, 15000], // 2x produk 1 @ Rp 15.000
          [2, 2, 1, 25000], // 1x produk 2 @ Rp 25.000
          [3, 3, 1, 20000], // 1x produk 3 @ Rp 20.000
        ],
        notes: 'Pembelian minuman dan snack',
      );

      if (result1.success) {
        print('Transaction created successfully!');
        print('Transaction Number: ${result1.data?.transactionNumber}');
      } else {
        print('Transaction failed: ${result1.message}');
      }

      // Contoh 2: Cash transaction
      final result2 = await createCashTransaction(
        paidAmount: 50000,
        items: [
          [1, 1, 1, 15000], // 1x produk 1 @ Rp 15.000
          [2, 2, 2, 12500], // 2x produk 2 @ Rp 12.500
        ],
        notes: 'Pembelian cepat',
      );

      print('Cash transaction result: ${result2.success}');
    } catch (e) {
      print('Error creating transaction: $e');
    }
  }
}
