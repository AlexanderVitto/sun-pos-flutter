import 'package:flutter_test/flutter_test.dart';
import 'package:sun_pos/core/config/app_config.dart';

void main() {
  group('AppConfig Flavor Tests', () {
    test('Default environment should be staging', () {
      expect(AppConfig.environment, Environment.staging);
    });

    test('Staging environment configuration', () {
      expect(AppConfig.baseUrl, 'https://stg.sfxsys.com/api/v1');
      expect(AppConfig.appName, 'Sun POS (Staging)');
      expect(AppConfig.isDebugMode, true);
      expect(AppConfig.enableLogging, true);
    });

    test('Storage keys should include environment prefix', () {
      expect(AppConfig.accessTokenKey, 'staging_access_token');
      expect(AppConfig.refreshTokenKey, 'staging_refresh_token');
      expect(AppConfig.userProfileKey, 'staging_user_profile');
    });

    test('Default headers should be configured correctly', () {
      final headers = AppConfig.defaultHeaders;
      expect(headers['Content-Type'], 'application/json');
      expect(headers['Accept'], 'application/json');
      expect(headers['User-Agent'], 'Sun POS (Staging)/1.0.0');
    });

    test('Auth headers should include Bearer token', () {
      const testToken = 'test_token_123';
      final authHeaders = AppConfig.getAuthHeaders(testToken);
      expect(authHeaders['Authorization'], 'Bearer $testToken');
      expect(authHeaders['Content-Type'], 'application/json');
    });
  });
}
