import '../../../../core/network/auth_http_client.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/config/app_config.dart';
import '../models/login_response.dart';
import '../models/profile_response.dart';
import '../models/change_password_request.dart';
import '../models/change_password_response.dart';

class AuthService {
  final AuthHttpClient _httpClient = AuthHttpClient();
  final ApiClient _apiClient = ApiClient();

  Future<LoginResponse> login(String email, String password) async {
    try {
      final url = '${AppConfig.baseUrl}/auth/login';

      final response = await _httpClient.postJson(
        url,
        {'email': email, 'password': password},
        requireAuth: false, // Login tidak perlu token
      );

      final responseData = _httpClient.parseJsonResponse(response);
      return LoginResponse.fromJson(responseData);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final url = '${AppConfig.baseUrl}/auth/refresh';

      final response = await _httpClient.postJson(
        url,
        {'refresh_token': refreshToken},
        requireAuth: false, // Refresh token tidak perlu access token
      );

      return _httpClient.parseJsonResponse(response);
    } catch (e) {
      throw Exception('Token refresh failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      final url = '${AppConfig.baseUrl}/auth/logout';

      await _httpClient.post(
        url,
        requireAuth: true, // Logout perlu token untuk invalidasi
      );
    } catch (e) {
      // Logout di server gagal, tapi tetap lanjutkan logout lokal
      print('Server logout failed: $e');
    }
  }

  Future<ProfileResponse> getProfile() async {
    try {
      final url = '${AppConfig.baseUrl}/auth/profile';

      final response = await _httpClient.get(url, requireAuth: true);
      final responseData = _httpClient.parseJsonResponse(response);

      return ProfileResponse.fromJson(responseData);
    } catch (e) {
      throw Exception('Failed to get profile: ${e.toString()}');
    }
  }

  Future<ChangePasswordResponse> changePassword(
    ChangePasswordRequest request,
  ) async {
    try {
      final url = '${AppConfig.baseUrl}/auth/change-password';

      final response = await _httpClient.postJson(
        url,
        request.toJson(),
        requireAuth: true, // Change password memerlukan autentikasi
      );

      final responseData = _httpClient.parseJsonResponse(response);
      return ChangePasswordResponse.fromJson(responseData);
    } catch (e) {
      throw Exception('Failed to change password: ${e.toString()}');
    }
  }

  // Test network connectivity
  Future<bool> testConnection() async {
    try {
      final response = await _apiClient.get('auth/test');
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
}
