import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

/// Service untuk mengelola penyimpanan data sensitif seperti token secara aman
class SecureStorageService {
  static const SecureStorageService _instance =
      SecureStorageService._internal();

  factory SecureStorageService() {
    return _instance;
  }

  const SecureStorageService._internal();

  // Konfigurasi secure storage dengan opsi keamanan tambahan
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      sharedPreferencesName: 'sun_pos_secure_prefs',
      preferencesKeyPrefix: 'sun_pos_',
    ),
    iOptions: IOSOptions(
      groupId: 'group.com.sunpos.secure',
      accountName: 'sun_pos_account',
      synchronizable: true,
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    lOptions: LinuxOptions(),
    wOptions: WindowsOptions(),
    mOptions: MacOsOptions(
      groupId: 'group.com.sunpos.secure',
      accountName: 'sun_pos_account',
      synchronizable: true,
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Keys untuk berbagai data yang disimpan
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _loginTimeKey = 'login_time';
  static const String _deviceIdKey = 'device_id';

  /// Menyimpan access token
  Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: _accessTokenKey, value: token);
      await _storage.write(
        key: _loginTimeKey,
        value: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw Exception('Failed to save access token: $e');
    }
  }

  /// Mengambil access token
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      throw Exception('Failed to retrieve access token: $e');
    }
  }

  /// Menyimpan refresh token
  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
    } catch (e) {
      throw Exception('Failed to save refresh token: $e');
    }
  }

  /// Mengambil refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      throw Exception('Failed to retrieve refresh token: $e');
    }
  }

  /// Menyimpan data user
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final jsonString = json.encode(userData);
      await _storage.write(key: _userDataKey, value: jsonString);
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }

  /// Mengambil data user
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final jsonString = await _storage.read(key: _userDataKey);
      if (jsonString == null) return null;
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to retrieve user data: $e');
    }
  }

  /// Menyimpan device ID untuk tracking session
  Future<void> saveDeviceId(String deviceId) async {
    try {
      await _storage.write(key: _deviceIdKey, value: deviceId);
    } catch (e) {
      throw Exception('Failed to save device ID: $e');
    }
  }

  /// Mengambil device ID
  Future<String?> getDeviceId() async {
    try {
      return await _storage.read(key: _deviceIdKey);
    } catch (e) {
      throw Exception('Failed to retrieve device ID: $e');
    }
  }

  /// Mengambil waktu login terakhir
  Future<DateTime?> getLoginTime() async {
    try {
      final timeString = await _storage.read(key: _loginTimeKey);
      if (timeString == null) return null;
      return DateTime.parse(timeString);
    } catch (e) {
      throw Exception('Failed to retrieve login time: $e');
    }
  }

  /// Mengecek apakah user sudah login dan token masih valid
  Future<bool> hasValidSession() async {
    try {
      final token = await getAccessToken();
      final loginTime = await getLoginTime();

      if (token == null || loginTime == null) return false;

      // Cek apakah token sudah expired (contoh: 24 jam)
      final tokenExpiry = loginTime.add(const Duration(hours: 24));
      return DateTime.now().isBefore(tokenExpiry);
    } catch (e) {
      return false;
    }
  }

  /// Menyimpan semua data login sekaligus
  Future<void> saveLoginSession({
    required String accessToken,
    String? refreshToken,
    required Map<String, dynamic> userData,
    String? deviceId,
  }) async {
    try {
      await saveAccessToken(accessToken);
      if (refreshToken != null) {
        await saveRefreshToken(refreshToken);
      }
      await saveUserData(userData);
      if (deviceId != null) {
        await saveDeviceId(deviceId);
      }
    } catch (e) {
      throw Exception('Failed to save login session: $e');
    }
  }

  /// Mengambil semua data session
  Future<Map<String, dynamic>> getLoginSession() async {
    try {
      final accessToken = await getAccessToken();
      final refreshToken = await getRefreshToken();
      final userData = await getUserData();
      final deviceId = await getDeviceId();
      final loginTime = await getLoginTime();

      return {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'userData': userData,
        'deviceId': deviceId,
        'loginTime': loginTime?.toIso8601String(),
        'isValid': await hasValidSession(),
      };
    } catch (e) {
      throw Exception('Failed to retrieve login session: $e');
    }
  }

  /// Menghapus semua data login (logout)
  Future<void> clearLoginSession() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _userDataKey);
      await _storage.delete(key: _loginTimeKey);
      await _storage.delete(key: _deviceIdKey);
    } catch (e) {
      throw Exception('Failed to clear login session: $e');
    }
  }

  /// Menghapus semua data yang tersimpan
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw Exception('Failed to clear all data: $e');
    }
  }

  /// Mengecek apakah ada data tersimpan
  Future<bool> hasStoredData() async {
    try {
      final allKeys = await _storage.readAll();
      return allKeys.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Mendapatkan semua keys yang tersimpan (untuk debugging)
  Future<List<String>> getAllKeys() async {
    try {
      final allData = await _storage.readAll();
      return allData.keys.toList();
    } catch (e) {
      return [];
    }
  }

  /// Backup data ke string JSON (untuk export/import)
  Future<String> backupData() async {
    try {
      final allData = await _storage.readAll();
      return json.encode(allData);
    } catch (e) {
      throw Exception('Failed to backup data: $e');
    }
  }

  /// Restore data dari string JSON
  Future<void> restoreData(String backupJson) async {
    try {
      final data = json.decode(backupJson) as Map<String, dynamic>;
      for (final entry in data.entries) {
        await _storage.write(key: entry.key, value: entry.value);
      }
    } catch (e) {
      throw Exception('Failed to restore data: $e');
    }
  }
}
