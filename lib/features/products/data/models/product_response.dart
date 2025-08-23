import 'product.dart';
import 'pagination.dart';

class ProductData {
  final List<Product> data;
  final PaginationLinks links;
  final PaginationMeta meta;

  ProductData({required this.data, required this.links, required this.meta});

  factory ProductData.fromJson(Map<String, dynamic> json) {
    var productsList = json['data'] as List<dynamic>? ?? [];
    List<Product> products =
        productsList
            .map((productJson) => Product.fromJson(productJson))
            .toList();

    return ProductData(
      data: products,
      links: PaginationLinks.fromJson(json['links'] ?? {}),
      meta: PaginationMeta.fromJson(json['meta'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((product) => product.toJson()).toList(),
      'links': links.toJson(),
      'meta': meta.toJson(),
    };
  }
}

class ProductResponse {
  final String status;
  final String message;
  final ProductData data;

  ProductResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      status: json['status'] ?? 'error',
      message: json['message'] ?? '',
      data: ProductData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'message': message, 'data': data.toJson()};
  }

  bool get isSuccess => status == 'success';
}
