import 'category.dart';

class CategoryResponse {
  final String status;
  final String message;
  final List<Category> data;

  CategoryResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    var categoryList = json['data'] as List<dynamic>? ?? [];
    List<Category> categories = categoryList
        .map((categoryJson) => Category.fromJson(categoryJson))
        .toList();

    return CategoryResponse(
      status: json['status'] ?? 'error',
      message: json['message'] ?? '',
      data: categories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((category) => category.toJson()).toList(),
    };
  }

  bool get isSuccess => status == 'success';
}
