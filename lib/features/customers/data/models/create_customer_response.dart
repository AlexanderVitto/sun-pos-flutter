import 'customer.dart';

class CreateCustomerResponse {
  final String status;
  final String message;
  final Customer? data;

  const CreateCustomerResponse({
    required this.status,
    required this.message,
    this.data,
  });

  bool get isSuccess => status == 'success';

  factory CreateCustomerResponse.fromJson(Map<String, dynamic> json) {
    return CreateCustomerResponse(
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
    return 'CreateCustomerResponse(status: $status, message: $message, data: $data)';
  }
}
