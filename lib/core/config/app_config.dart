class AppConfig {
  // API Configuration
  static const String baseUrl = 'https://sfpos.app/api/v1';
  static const String appName = 'Sun POS';
  static const String appVersion = '1.0.0';

  // Network Configuration
  static const int timeoutSeconds = 30;
  static const int retryAttempts = 3;

  // Debug Configuration
  static const bool isDebugMode = false; // Set to false for release
  static const bool enableLogging = false; // Set to false for release

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userProfileKey = 'user_profile';

  // API Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': '$appName/$appVersion',
  };

  static Map<String, String> getAuthHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}
