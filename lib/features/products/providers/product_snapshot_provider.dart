import 'package:flutter/foundation.dart';

import '../data/models/product.dart';
import '../data/repositories/product_cache_repository.dart';
import '../data/services/product_api_service.dart';

/// Mengelola snapshot produk offline: sinkronisasi dari API ke cache lokal
/// (Drift) dan pembacaan dari cache.
///
/// Sumber data ini HARGA BASE — diskon per grup pelanggan belum ditangani.
class ProductSnapshotProvider extends ChangeNotifier {
  ProductSnapshotProvider({
    ProductApiService? apiService,
    ProductCacheRepository? repository,
  }) : _api = apiService ?? ProductApiService(),
       _repo = repository ?? ProductCacheRepository();

  final ProductApiService _api;
  final ProductCacheRepository _repo;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  DateTime? _lastSyncedAt;
  DateTime? get lastSyncedAt => _lastSyncedAt;

  int _cachedCount = 0;
  int get cachedCount => _cachedCount;

  String? _lastError;
  String? get lastError => _lastError;

  bool get hasCache => _cachedCount > 0;

  /// Tarik seluruh produk toko dari API lalu simpan ke cache lokal.
  /// Mengembalikan `true` bila sukses. Aman dipanggil saat offline — akan
  /// gagal diam-diam (return false) dan cache lama tetap dipertahankan.
  Future<bool> sync({required int storeId}) async {
    if (_isSyncing) return false;
    _isSyncing = true;
    _lastError = null;
    notifyListeners();

    try {
      final products = await _api.getProductsSnapshot(storeId: storeId);
      await _repo.saveSnapshot(storeId, products);
      await _refreshMeta(storeId);
      debugPrint('✅ Sync snapshot produk selesai: ${products.length} item');
      return true;
    } catch (e) {
      _lastError = e.toString();
      debugPrint('❌ Sync snapshot produk gagal: $e');
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Baca produk dari cache lokal (untuk dipakai saat offline).
  Future<List<Product>> loadCached({
    required int storeId,
    String? search,
    int? categoryId,
  }) {
    return _repo.getProducts(
      storeId: storeId,
      search: search,
      categoryId: categoryId,
    );
  }

  /// Muat ulang metadata (jumlah & waktu sync terakhir) tanpa hit API.
  Future<void> refreshMeta(int storeId) async {
    await _refreshMeta(storeId);
    notifyListeners();
  }

  Future<void> _refreshMeta(int storeId) async {
    _cachedCount = await _repo.count(storeId);
    _lastSyncedAt = await _repo.lastCachedAt(storeId);
  }

  /// Hapus snapshot satu toko (mis. saat logout).
  Future<void> clear(int storeId) async {
    await _repo.clear(storeId);
    _cachedCount = 0;
    _lastSyncedAt = null;
    notifyListeners();
  }
}
