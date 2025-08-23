class MostSoldProductModel {
  final int productId;
  final String productName;
  final String productSku;
  final int totalSold;

  MostSoldProductModel({
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.totalSold,
  });

  factory MostSoldProductModel.fromJson(Map<String, dynamic> json) {
    return MostSoldProductModel(
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      productSku: json['product_sku'] ?? '',
      totalSold: json['total_sold'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_sku': productSku,
      'total_sold': totalSold,
    };
  }
}
