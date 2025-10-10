import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../refunds/data/models/refund_detail_response.dart';
import '../../../refunds/data/models/refund_list_response.dart';
import '../../../refunds/data/services/refund_api_service.dart';

class RefundDetailPage extends StatefulWidget {
  final int refundId;

  const RefundDetailPage({super.key, required this.refundId});

  @override
  State<RefundDetailPage> createState() => _RefundDetailPageState();
}

class _RefundDetailPageState extends State<RefundDetailPage> {
  final RefundApiService _apiService = RefundApiService();
  RefundDetailData? _refundDetail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRefundDetail();
  }

  Future<void> _loadRefundDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      debugPrint('🔍 Loading refund detail for ID: ${widget.refundId}');

      final response = await _apiService.getRefundById(widget.refundId);

      debugPrint('📦 Refund detail API response: $response');

      final refundDetailResponse = RefundDetailResponse.fromJson(response);

      setState(() {
        _refundDetail = refundDetailResponse.data;
        _isLoading = false;
      });

      debugPrint(
        '✅ Refund detail loaded successfully: ${_refundDetail?.refundNumber}',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading refund detail: $e');
      debugPrint('Stack trace: $stackTrace');

      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Refund',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_refundDetail != null)
            IconButton(
              icon: const Icon(LucideIcons.printer, color: Color(0xFF6366f1)),
              onPressed: () {
                // TODO: Implement print refund
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur print akan segera tersedia'),
                  ),
                );
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildShimmerLoading();
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.alertCircle,
              color: Color(0xFFEF4444),
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat detail refund',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadRefundDetail,
              icon: const Icon(LucideIcons.refreshCw),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366f1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_refundDetail == null) {
      return const Center(
        child: Text(
          'Data refund tidak ditemukan',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRefundDetail,
      color: const Color(0xFF6366f1),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildRefundHeader(),
            const SizedBox(height: 16),
            _buildInfoCards(),
            const SizedBox(height: 16),
            _buildRefundDetails(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRefundHeader() {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withValues(alpha: 0.3),
            blurRadius: 20,
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.arrowLeftRight,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'REFUND',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusText(_refundDetail!.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _refundDetail!.refundNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(LucideIcons.calendar, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                DateFormat(
                  'dd MMMM yyyy, HH:mm',
                ).format(DateTime.parse(_refundDetail!.refundDate)),
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white24, thickness: 1),
          const SizedBox(height: 24),
          const Text(
            'Total Refund',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(_refundDetail!.totalRefundAmount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAmountBreakdown(
                  'Tunai',
                  _refundDetail!.cashRefundAmount,
                  LucideIcons.banknote,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAmountBreakdown(
                  'Transfer',
                  _refundDetail!.transferRefundAmount,
                  LucideIcons.creditCard,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountBreakdown(String label, double amount, IconData icon) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(amount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Customer',
                  _refundDetail!.customer?.name ?? '-',
                  _refundDetail!.customer?.phone,
                  LucideIcons.user,
                  const Color(0xFF6366f1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  'Store',
                  _refundDetail!.store?.name ?? '-',
                  _refundDetail!.store?.phoneNumber,
                  LucideIcons.store,
                  const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_refundDetail!.transaction != null)
            _buildTransactionCard(_refundDetail!.transaction!),
          if (_refundDetail!.user != null) ...[
            const SizedBox(height: 12),
            _buildUserCard(_refundDetail!.user!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    String? subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionCard(RefundTransaction transaction) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.receipt,
                  color: Color(0xFF10B981),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Transaksi Original',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Nomor',
            transaction.transactionNumber,
            LucideIcons.hash,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Tanggal',
            DateFormat(
              'dd MMM yyyy, HH:mm',
            ).format(DateTime.parse(transaction.date)),
            LucideIcons.calendar,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Total',
            currencyFormat.format(transaction.totalAmount),
            LucideIcons.dollarSign,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Status',
            _getTransactionStatusText(transaction.status),
            LucideIcons.checkCircle,
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(RefundDetailUser user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.userCog,
                  color: Color(0xFFF59E0B),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Diproses Oleh',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),
          _buildInfoRow('Nama', user.name, LucideIcons.user),
          const SizedBox(height: 8),
          _buildInfoRow('Email', user.email, LucideIcons.mail),
          if (user.roles != null && user.roles!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              'Role',
              user.roles!.first.displayName,
              LucideIcons.shield,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildRefundDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366f1).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.package,
                    color: Color(0xFF6366f1),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Item yang Direfund',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          if (_refundDetail!.details != null &&
              _refundDetail!.details!.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _refundDetail!.details!.length,
              separatorBuilder:
                  (context, index) =>
                      const Divider(height: 1, color: Color(0xFFE5E7EB)),
              itemBuilder: (context, index) {
                final item = _refundDetail!.details![index];
                return _buildRefundItem(item);
              },
            )
          else
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Tidak ada item',
                  style: TextStyle(color: Color(0xFF9CA3AF)),
                ),
              ),
            ),
          if (_refundDetail!.notes != null &&
              _refundDetail!.notes!.isNotEmpty) ...[
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7).withValues(alpha: 0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    LucideIcons.messageSquare,
                    size: 16,
                    color: Color(0xFFD97706),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Catatan',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD97706),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _refundDetail!.notes!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRefundItem(RefundDetailItem item) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Icon(
              LucideIcons.package,
              color: Color(0xFF6B7280),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SKU: ${item.productSku}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366f1).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${item.quantityRefunded}x',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6366f1),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currencyFormat.format(item.unitPrice),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormat.format(item.totalRefundAmount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 4),
              if (item.productVariant != null && item.productVariant!.stock > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Stok: ${item.productVariant!.stock}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'PENDING';
      case 'completed':
        return 'SELESAI';
      case 'cancelled':
        return 'DIBATALKAN';
      default:
        return status.toUpperCase();
    }
  }

  String _getTransactionStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'outstanding':
        return 'Outstanding';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildShimmerHeader(),
          const SizedBox(height: 16),
          _buildShimmerInfoCards(),
          const SizedBox(height: 16),
          _buildShimmerDetails(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildShimmerHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.white.withValues(alpha: 0.3),
        highlightColor: Colors.white.withValues(alpha: 0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  width: 48,
                  height: 48,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 80,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 200,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 24),
            Container(height: 1, color: Colors.white),
            const SizedBox(height: 24),
            Container(
              width: 100,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerInfoCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE5E7EB),
        highlightColor: const Color(0xFFF3F4F6),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildShimmerCard(height: 100)),
                const SizedBox(width: 12),
                Expanded(child: _buildShimmerCard(height: 100)),
              ],
            ),
            const SizedBox(height: 12),
            _buildShimmerCard(height: 140),
            const SizedBox(height: 12),
            _buildShimmerCard(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCard({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
    );
  }

  Widget _buildShimmerDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Shimmer.fromColors(
              baseColor: const Color(0xFFE5E7EB),
              highlightColor: const Color(0xFFF3F4F6),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 150,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder:
                (context, index) =>
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
            itemBuilder: (context, index) {
              return _buildShimmerItem();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE5E7EB),
        highlightColor: const Color(0xFFF3F4F6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 120,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 80,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 100,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 60,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
