/// Item produk dengan stok di bawah / sama dengan minimum, dari endpoint
/// `GET /products/low-stock?store_id=..&per_page=..`.
class LowStockProduct {
  final int productId;
  final String productName;
  final String? variantName;
  final int variantId;
  final int stock;
  final int minStock;

  const LowStockProduct({
    required this.productId,
    required this.productName,
    required this.variantName,
    required this.variantId,
    required this.stock,
    required this.minStock,
  });

  factory LowStockProduct.fromJson(Map<String, dynamic> json) {
    return LowStockProduct(
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      variantName: json['variant_name'],
      variantId: json['variant_id'] ?? 0,
      stock: json['stock'] ?? 0,
      minStock: json['min_stock'] ?? 0,
    );
  }

  /// Nama tampilan: kombinasi nama produk + nama varian (bila ada).
  String get displayName =>
      (variantName != null && variantName!.isNotEmpty)
      ? '$productName $variantName'
      : productName;

  /// true bila benar-benar habis (stok 0).
  bool get isOutOfStock => stock <= 0;
}

/// Response endpoint low-stock beserta total (dari `pagination.total`).
class LowStockResponse {
  final List<LowStockProduct> data;
  final int total;

  const LowStockResponse({required this.data, required this.total});

  factory LowStockResponse.fromJson(Map<String, dynamic> json) {
    final dataField = json['data'];

    List itemsRaw;
    int total;

    if (dataField is List) {
      // Bentuk datar: { data: [...], pagination: { total } }
      itemsRaw = dataField;
      final pagination = json['pagination'] is Map
          ? Map<String, dynamic>.from(json['pagination'])
          : const <String, dynamic>{};
      total = pagination['total'] ?? itemsRaw.length;
    } else if (dataField is Map) {
      // Bentuk Laravel paginator: { data: { data: [...], total: n } }
      final paginator = Map<String, dynamic>.from(dataField);
      itemsRaw = (paginator['data'] as List? ?? const []);
      total = paginator['total'] ?? itemsRaw.length;
    } else {
      itemsRaw = const [];
      total = 0;
    }

    final list = itemsRaw
        .map((e) => LowStockProduct.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return LowStockResponse(data: list, total: total);
  }
}
