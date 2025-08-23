import 'customer.dart';

class UpdateCustomerResponse {
  final String status;
  final String message;
  final Customer? data;

  const UpdateCustomerResponse({
    required this.status,
    required this.message,
    this.data,
  });

  bool get isSuccess => status == 'success';

  factory UpdateCustomerResponse.fromJson(Map<String, dynamic> json) {
    return UpdateCustomerResponse(
      status: json['status'] ?? 'error',
      message: json['message'] ?? '',
      data: json['data'] != null ? Customer.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'message': message, 'data': data?.toJson()};
  }

  @override
  String toString() {
    return 'UpdateCustomerResponse(status: $status, message: $message, data: $data)';
  }
}
