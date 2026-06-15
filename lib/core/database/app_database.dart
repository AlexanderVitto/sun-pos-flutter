import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Snapshot produk untuk mode offline.
///
/// Menyimpan kolom yang sering di-query (nama, sku, kategori) sebagai kolom
/// tersendiri agar bisa di-filter/cari cepat, plus [rawJson] yang berisi
/// payload `Product` lengkap (varian, harga base, pricing_info, dll) sehingga
/// model `Product` bisa direkonstruksi utuh dengan `Product.fromJson`.
///
/// Catatan: ini snapshot HARGA BASE. Diskon per grup pelanggan belum disimpan
/// di sini (ditangani terpisah / saat online).
class CachedProducts extends Table {
  /// ID produk dari server.
  IntColumn get id => integer()();

  /// Toko pemilik snapshot ini (produk bisa beda antar toko).
  IntColumn get storeId => integer()();

  TextColumn get name => text()();
  TextColumn get sku => text().withDefault(const Constant(''))();

  IntColumn get categoryId => integer().nullable()();
  TextColumn get categoryName => text().nullable()();
  IntColumn get unitId => integer().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// Payload `Product` lengkap dalam bentuk JSON string.
  TextColumn get rawJson => text()();

  /// Kapan baris ini di-cache (untuk info "terakhir disinkron").
  DateTimeColumn get cachedAt => dateTime()();

  // Produk yang sama bisa ada di lebih dari satu toko → primary key gabungan.
  @override
  Set<Column> get primaryKey => {id, storeId};
}

@DriftDatabase(tables: [CachedProducts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Instance tunggal yang dipakai seluruh aplikasi.
  static final AppDatabase instance = AppDatabase();

  @override
  int get schemaVersion => 1;
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'sun_pos_cache');
}
