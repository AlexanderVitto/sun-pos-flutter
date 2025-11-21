import 'customer_group.dart';

class CustomerGroupListResponse {
  final String status;
  final String message;
  final List<CustomerGroup> data;

  const CustomerGroupListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  bool get isSuccess => status == 'success';

  factory CustomerGroupListResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? groupsData = json['data'];
    final List<CustomerGroup> groups = groupsData != null
        ? groupsData
              .map((groupJson) => CustomerGroup.fromJson(groupJson))
              .toList()
        : [];

    return CustomerGroupListResponse(
      status: json['status'] ?? 'error',
      message: json['message'] ?? '',
      data: groups,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((group) => group.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'CustomerGroupListResponse(status: $status, groups: ${data.length})';
  }
}
