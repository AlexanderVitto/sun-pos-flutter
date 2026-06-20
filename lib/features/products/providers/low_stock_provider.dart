import 'package:flutter/foundation.dart';

import '../data/models/low_stock_product.dart';
import '../data/services/product_api_service.dart';

/// State untuk fitur notifikasi stok menipis di dashboard.
///
/// Mengambil data dari `GET /products/low-stock?store_id=..&per_page=..`.
class LowStockProvider extends ChangeNotifier {
  final ProductApiService _api = ProductApiService();

  List<LowStockProduct> _items = [];
  int _total = 0;
  bool _isLoading = false;
  String? _error;
  int? _loadedStoreId;

  List<LowStockProduct> get items => _items;
  int get total => _total;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLowStock => _total > 0;

  /// Muat ulang data low-stock untuk [storeId]. Aman dipanggil berulang;
  /// tidak akan menumpuk request saat sedang loading.
  Future<void> load({int? storeId}) async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.getLowStockProducts(storeId: storeId);
      _items = response.data;
      _total = response.total;
      _loadedStoreId = storeId;
    } catch (e) {
      _error = e.toString();
      _items = [];
      _total = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Muat hanya jika belum pernah dimuat untuk toko ini (hindari fetch ganda).
  Future<void> ensureLoaded({int? storeId}) async {
    if (_loadedStoreId == storeId && (_items.isNotEmpty || _error == null)) {
      // Sudah dimuat untuk toko ini; biarkan. Pemanggil bisa pakai [load]
      // untuk refresh manual.
      if (_loadedStoreId != null) return;
    }
    await load(storeId: storeId);
  }

  void clear() {
    _items = [];
    _total = 0;
    _error = null;
    _loadedStoreId = null;
    notifyListeners();
  }
}
