class ChangePasswordResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  ChangePasswordResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? 'Password changed successfully',
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data};
  }
}
