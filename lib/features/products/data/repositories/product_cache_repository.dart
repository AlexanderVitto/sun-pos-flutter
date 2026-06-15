import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/database/app_database.dart';
import '../models/product.dart';

/// Repository untuk snapshot produk offline (harga base).
///
/// Bertanggung jawab menyimpan & membaca produk dari Drift, serta
/// merekonstruksi model [Product] dari payload JSON yang tersimpan.
class ProductCacheRepository {
  ProductCacheRepository({AppDatabase? db})
    : _db = db ?? AppDatabase.instance;

  final AppDatabase _db;

  /// Ganti seluruh snapshot produk untuk satu toko dengan data baru.
  ///
  /// Operasi dilakukan dalam satu transaksi: hapus snapshot lama toko ini,
  /// lalu masukkan data baru. `cachedAt` diisi dari [now] (default waktu
  /// sekarang) — diteruskan agar mudah ditest & deterministik.
  Future<void> saveSnapshot(
    int storeId,
    List<Product> products, {
    DateTime? now,
  }) async {
    final timestamp = now ?? DateTime.now();

    await _db.transaction(() async {
      await (_db.delete(_db.cachedProducts)
            ..where((t) => t.storeId.equals(storeId)))
          .go();

      await _db.batch((batch) {
        batch.insertAll(
          _db.cachedProducts,
          products.map(
            (p) => CachedProductsCompanion.insert(
              id: p.id,
              storeId: storeId,
              name: p.name,
              sku: Value(p.sku),
              categoryId: Value(p.category.id),
              categoryName: Value(p.category.name),
              unitId: Value(p.unit.id),
              isActive: Value(p.isActive),
              rawJson: jsonEncode(p.toJson()),
              cachedAt: timestamp,
            ),
          ),
        );
      });
    });

    debugPrint(
      '💾 Snapshot ${products.length} produk tersimpan untuk store $storeId',
    );
  }

  /// Baca produk dari cache untuk satu toko, opsional filter pencarian
  /// (nama/sku) & kategori. Hasil sudah berupa model [Product].
  Future<List<Product>> getProducts({
    required int storeId,
    String? search,
    int? categoryId,
  }) async {
    final query = _db.select(_db.cachedProducts)
      ..where((t) => t.storeId.equals(storeId));

    if (categoryId != null) {
      query.where((t) => t.categoryId.equals(categoryId));
    }

    if (search != null && search.trim().isNotEmpty) {
      final term = '%${search.trim()}%';
      query.where((t) => t.name.like(term) | t.sku.like(term));
    }

    query.orderBy([(t) => OrderingTerm.asc(t.name)]);

    final rows = await query.get();
    return rows.map(_rowToProduct).where((p) => p != null).cast<Product>().toList();
  }

  /// Waktu snapshot terakhir untuk satu toko (null jika belum pernah dicache).
  Future<DateTime?> lastCachedAt(int storeId) async {
    final maxExpr = _db.cachedProducts.cachedAt.max();
    final query = _db.selectOnly(_db.cachedProducts)
      ..addColumns([maxExpr])
      ..where(_db.cachedProducts.storeId.equals(storeId));
    final row = await query.getSingleOrNull();
    return row?.read(maxExpr);
  }

  /// Jumlah produk yang tersimpan untuk satu toko.
  Future<int> count(int storeId) async {
    final countExpr = _db.cachedProducts.id.count();
    final query = _db.selectOnly(_db.cachedProducts)
      ..addColumns([countExpr])
      ..where(_db.cachedProducts.storeId.equals(storeId));
    final row = await query.getSingleOrNull();
    return row?.read(countExpr) ?? 0;
  }

  /// Hapus snapshot satu toko (mis. saat logout / ganti user).
  Future<void> clear(int storeId) async {
    await (_db.delete(_db.cachedProducts)
          ..where((t) => t.storeId.equals(storeId)))
        .go();
  }

  Product? _rowToProduct(CachedProduct row) {
    try {
      return Product.fromJson(
        jsonDecode(row.rawJson) as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('⚠️ Gagal decode produk cache id=${row.id}: $e');
      return null;
    }
  }
}
