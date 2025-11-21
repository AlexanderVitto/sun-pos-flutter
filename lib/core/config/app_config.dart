enum Environment { staging, production }

class AppConfig {
  // Get environment from --dart-define
  static const String _envString = String.fromEnvironment(
    'ENV',
    defaultValue: 'staging',
  );

  static Environment get environment {
    switch (_envString) {
      case 'production':
        return Environment.production;
      case 'staging':
      default:
        return Environment.staging;
    }
  }

  // API Configuration based on environment
  static String get baseUrl {
    switch (environment) {
      case Environment.production:
        return 'https://sfxsys.com/api/v1';
      case Environment.staging:
        return 'https://stg.sfxsys.com/api/v1';
    }
  }

  static String get appName {
    switch (environment) {
      case Environment.production:
        return 'Sun POS';
      case Environment.staging:
        return 'Sun POS (Staging)';
    }
  }

  static const String appVersion = '1.0.0';

  // Network Configuration
  static const int timeoutSeconds = 30;
  static const int retryAttempts = 3;

  // Debug Configuration
  static bool get isDebugMode => environment == Environment.staging;
  static bool get enableLogging => environment == Environment.staging;

  // Storage Keys
  static String get accessTokenKey => '${_envString}_access_token';
  static String get refreshTokenKey => '${_envString}_refresh_token';
  static String get userProfileKey => '${_envString}_user_profile';

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
