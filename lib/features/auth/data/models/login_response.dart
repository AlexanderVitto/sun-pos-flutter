import 'user.dart';

class LoginResponse {
  final String status;
  final String message;
  final LoginData data;

  LoginResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'],
      message: json['message'],
      data: LoginData.fromJson(json['data']),
    );
  }
}

class LoginData {
  final User user;
  final String token;

  LoginData({required this.user, required this.token});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(user: User.fromJson(json['user']), token: json['token']);
  }
}
