import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../data/models/cart_item.dart';
import '../../../transactions/data/models/payment_history.dart';
import '../../../transactions/data/models/store.dart';
import '../../../transactions/data/models/user.dart';

class ReceiptPdfBuilder {
  static Future<Uint8List> build({
    required String receiptId,
    required DateTime transactionDate,
    required List<CartItem> items,
    required Store store,
    User? user,
    required double subtotal,
    required double discount,
    required double total,
    String paymentMethod = 'Tunai',
    List<PaymentHistory>? paymentHistories,
    String? notes,
    String? status,
    DateTime? dueDate,
  }) async {
    final doc = pw.Document();
    final monoRegular = pw.Font.courier();
    final monoBold = pw.Font.courierBold();

    const divider = '================================';
    const subDivider = '--------------------------------';

    pw.TextStyle ts({double size = 9, bool bold = false}) => pw.TextStyle(
      font: bold ? monoBold : monoRegular,
      fontSize: size,
    );

    pw.Widget centerText(
      String text, {
      double size = 9,
      bool bold = false,
    }) => pw.Center(
      child: pw.Text(
        text,
        style: ts(size: size, bold: bold),
        textAlign: pw.TextAlign.center,
      ),
    );

    pw.Widget rowLeftRight(
      String left,
      String right, {
      bool bold = false,
    }) => pw.Row(
      children: [
        pw.Expanded(child: pw.Text(left, style: ts(bold: bold))),
        pw.Text(right, style: ts(bold: bold)),
      ],
    );

    pw.Widget kvColon(String key, String value) => pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(width: 60, child: pw.Text(key, style: ts())),
        pw.Expanded(child: pw.Text(': $value', style: ts())),
      ],
    );

    String paymentLine() {
      if (paymentHistories != null &&
          paymentHistories.isNotEmpty &&
          paymentHistories.length == 1) {
        return _formatPaymentMethodLabel(paymentHistories.first.paymentMethod);
      }
      if (paymentHistories == null || paymentHistories.isEmpty) {
        return paymentMethod;
      }
      return '';
    }

    doc.addPage(
      pw.MultiPage(
        // Wide horizontal margins create a narrow centered content area
        // that mimics 58mm thermal width on A4 paper.
        pageFormat: PdfPageFormat.a4.copyWith(
          marginLeft: 200,
          marginRight: 200,
          marginTop: 32,
          marginBottom: 32,
        ),
        theme: pw.ThemeData.withFont(base: monoRegular, bold: monoBold),
        build: (context) {
          return [
            // Title (store header removed per requirement)
            pw.Text(divider, style: ts()),
            centerText('STRUK PEMBAYARAN', size: 10, bold: true),
            pw.Text(divider, style: ts()),
            pw.SizedBox(height: 4),

            // Transaction info
            kvColon('No. Transaksi', receiptId),
            kvColon('Tanggal', _formatDateTime(transactionDate)),
            kvColon('Kasir', _toInitials(user?.name ?? 'Admin POS')),
            if (paymentHistories != null && paymentHistories.length > 1) ...[
              kvColon('Pembayaran', ''),
              ...paymentHistories.map(
                (p) => rowLeftRight(
                  '  ${_formatPaymentMethodLabel(p.paymentMethod)}',
                  'Rp ${_formatPrice(p.amount)}',
                ),
              ),
            ] else
              kvColon('Pembayaran', paymentLine()),
            if (status != null && status.isNotEmpty)
              kvColon('Status', _formatTransactionStatusLabel(status)),
            if (status != null &&
                status.toLowerCase() == 'outstanding' &&
                dueDate != null)
              kvColon('Jatuh Tempo', _formatOutstandingDate(dueDate)),
            pw.SizedBox(height: 6),

            // Items section
            pw.Text(subDivider, style: ts()),
            pw.Text('DETAIL PEMBELIAN', style: ts(bold: true)),
            pw.Text(subDivider, style: ts()),
            rowLeftRight('Item', 'Subtotal', bold: true),
            pw.Text(subDivider, style: ts()),

            if (items.isEmpty)
              pw.Text(
                '(Detail item tidak tersedia)',
                style: ts(),
              )
            else
              ...items.expand((item) {
                final itemName = item.product.code.isNotEmpty
                    ? '${item.product.code} ${item.product.name}'
                    : item.product.name;
                return [
                  pw.Text(itemName, style: ts()),
                  rowLeftRight(
                    '${item.quantity}@ ${_formatPrice(item.product.price)}',
                    'Rp ${_formatPrice(item.subtotal)}',
                    bold: true,
                  ),
                  if (item != items.last) pw.SizedBox(height: 3),
                ];
              }),

            // Totals
            if (discount > 0) ...[
              pw.SizedBox(height: 2),
              rowLeftRight('Subtotal', 'Rp ${_formatPrice(subtotal)}'),
              rowLeftRight('Diskon', '- Rp ${_formatPrice(discount)}'),
            ],
            pw.Text(divider, style: ts()),
            rowLeftRight('TOTAL', 'Rp ${_formatPrice(total)}', bold: true),
            pw.Text(divider, style: ts()),
            pw.SizedBox(height: 6),

            // Notes
            if (notes != null && notes.trim().isNotEmpty) ...[
              pw.Text('CATATAN:', style: ts(bold: true)),
              pw.Text(notes, style: ts()),
              pw.SizedBox(height: 6),
            ],

            // Footer
            centerText('TERIMA KASIH', size: 12, bold: true),
            centerText('Atas kunjungan Anda', size: 9),
            pw.SizedBox(height: 6),
            centerText('Barang yang sudah dibeli tidak dapat', size: 9),
            centerText('ditukar kembali kecuali ada kerusakan', size: 9),
            centerText('dari pihak toko', size: 9),
            pw.SizedBox(height: 10),

            // Peringatan kembang api
            centerText('PERINGATAN', size: 9, bold: true),
            centerText(
              'Pengguna kembang api dimainkan mengikuti',
              size: 9,
            ),
            centerText(
              'aturan penggunaan yang tertera di setiap produk.',
              size: 9,
            ),
            centerText(
              'Setiap pembeli mengetahui dan mengerti aturan',
              size: 9,
            ),
            centerText(
              'untuk menjual/memakai produk kembang api ini.',
              size: 9,
            ),
          ];
        },
      ),
    );

    return doc.save();
  }

  static String _formatPrice(double price) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(price);
  }

  static String _formatDateTime(DateTime dt) {
    return DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(dt);
  }

  static String _formatOutstandingDate(DateTime d) {
    try {
      return DateFormat('dd MMMM yyyy', 'id_ID').format(d);
    } catch (_) {
      return 'Tanggal tidak valid';
    }
  }

  /// Build PDF preview for an unconfirmed order (quotation).
  ///
  /// Output is clearly marked "BELUM DIBAYAR" so recipients don't mistake it
  /// for a paid receipt.
  static Future<Uint8List> buildPreview({
    required DateTime previewDate,
    required List<CartItem> items,
    required Store store,
    String? customerName,
    String? customerPhone,
    required double subtotal,
    required double discount,
    required double total,
    String? notes,
    String? status,
  }) async {
    final doc = pw.Document();

    final shortDate = DateFormat('dd/MM/yyyy HH:mm').format(previewDate);
    final longDate = DateFormat('d MMMM yyyy', 'id_ID').format(previewDate);
    final totalQty = items.fold<int>(0, (sum, it) => sum + it.quantity);

    pw.Widget itemRow(CartItem item) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(top: 6, bottom: 2),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              item.product.name,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 2),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 24),
              child: pw.Row(
                children: [
                  pw.SizedBox(
                    width: 50,
                    child: pw.Text(
                      '${item.quantity}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
                  pw.SizedBox(
                    width: 120,
                    child: pw.Text(
                      '@ ${_formatPrice(item.product.price)}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      _formatPrice(item.subtotal),
                      style: const pw.TextStyle(fontSize: 10),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 24, top: 2),
              child: pw.Text(
                '${item.quantity} pcs',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
            ),
          ],
        ),
      );
    }

    pw.Widget totalsBlock() {
      pw.Widget row(String label, String value, {bool bold = false}) {
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                label,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: bold
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal,
                ),
              ),
              pw.Text(
                value,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: bold
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }

      return pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Text(
              'Total Qty: $totalQty',
              style: const pw.TextStyle(fontSize: 11),
            ),
          ),
          pw.SizedBox(
            width: 220,
            child: pw.Column(
              children: [
                if (discount > 0) ...[
                  row('Subtotal', _formatPrice(subtotal)),
                  row('Diskon', '- ${_formatPrice(discount)}'),
                ],
                row('TOTAL', _formatPrice(total), bold: true),
                row('BAYAR', _formatPrice(0.0)),
                row('SISA', _formatPrice(total)),
              ],
            ),
          ),
        ],
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginLeft: 32,
          marginRight: 32,
          marginTop: 32,
          marginBottom: 32,
        ),
        build: (context) {
          return [
            // Preview banner
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 12,
              ),
              decoration: pw.BoxDecoration(
                color: PdfColors.amber100,
                border: pw.Border.all(color: PdfColors.amber800, width: 1),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Center(
                child: pw.Text(
                  'PREVIEW PESANAN - BELUM DIBAYAR',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.amber800,
                  ),
                ),
              ),
            ),
            pw.SizedBox(height: 12),

            // Store header
            pw.Center(
              child: pw.Text(
                store.name.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Center(
              child: pw.Text(
                store.address,
                style: const pw.TextStyle(fontSize: 9),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Center(
              child: pw.Text(
                'Telp: ${store.phoneNumber}',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Divider(thickness: 0.8),

            // Date + customer block
            pw.Text(shortDate, style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 8),
            if (customerName != null && customerName.isNotEmpty)
              pw.Text(
                customerName,
                style: const pw.TextStyle(fontSize: 11),
              ),
            if (customerPhone != null && customerPhone.isNotEmpty)
              pw.Text(
                customerPhone,
                style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
            pw.Text(longDate, style: const pw.TextStyle(fontSize: 10)),
            if (status != null && status.isNotEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Text(
                  'Status: ${_formatTransactionStatusLabel(status)}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            pw.Divider(thickness: 0.8),

            // Items list
            ...items.map(itemRow),
            pw.SizedBox(height: 4),
            pw.Divider(thickness: 0.8),
            pw.SizedBox(height: 8),

            // Totals block
            totalsBlock(),

            if (notes != null && notes.trim().isNotEmpty) ...[
              pw.SizedBox(height: 12),
              pw.Text(
                'CATATAN:',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(notes, style: const pw.TextStyle(fontSize: 9)),
            ],

            pw.SizedBox(height: 24),
            pw.Center(
              child: pw.Text(
                '*** TERIMA KASIH ***',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ];
        },
      ),
    );

    return doc.save();
  }

  static String _toInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';
    return trimmed
        .split(RegExp(r'\s+'))
        .map((part) => part.isNotEmpty ? part[0].toUpperCase() : '')
        .join();
  }

  static String _formatTransactionStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return 'DRAFT';
      case 'pending':
        return 'PENDING';
      case 'completed':
      case 'success':
      case 'sukses':
      case 'selesai':
        return 'SUKSES';
      case 'outstanding':
      case 'utang':
      case 'hutang':
        return 'HUTANG';
      case 'cancelled':
      case 'canceled':
      case 'batal':
        return 'BATAL';
      case 'refunded':
      case 'refund':
        return 'REFUND';
      default:
        return status.toUpperCase();
    }
  }

  static String _formatPaymentMethodLabel(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Tunai';
      case 'transfer':
      case 'bank_transfer':
        return 'Transfer';
      case 'qris':
        return 'QRIS';
      case 'card':
      case 'credit_card':
        return 'Kartu';
      case 'debit':
      case 'debit_card':
        return 'Debit';
      default:
        return method;
    }
  }
}
