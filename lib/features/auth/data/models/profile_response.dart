import '../models/user.dart';

class ProfileResponse {
  final String status;
  final String message;
  final User data;

  ProfileResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      status: json['status'],
      message: json['message'],
      data: User.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'message': message, 'data': data.toJson()};
  }
}
