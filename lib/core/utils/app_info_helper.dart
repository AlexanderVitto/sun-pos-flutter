import 'package:package_info_plus/package_info_plus.dart';
import 'device_info_helper.dart';

class AppInfoHelper {
  static PackageInfo? _packageInfo;
  static Map<String, dynamic>? _deviceInfo;
  static String? _deviceId;
  static String? _platform;

  /// Initialize app and device information
  static Future<void> initialize() async {
    _packageInfo = await PackageInfo.fromPlatform();
    _deviceInfo = await DeviceInfoHelper.getDeviceInfo();
    _deviceId = await DeviceInfoHelper.getDeviceIdentifier();
    _platform = _deviceInfo?['platform'] ?? 'unknown';
  }

  /// Get app name
  static String get appName => _packageInfo?.appName ?? 'sun_pos';

  /// Get app version
  static String get appVersion => _packageInfo?.version ?? '1.0.0';

  /// Get build number
  static String get buildNumber => _packageInfo?.buildNumber ?? '1';

  /// Get package name
  static String get packageName =>
      _packageInfo?.packageName ?? 'com.example.sun_pos';

  /// Get device ID
  static String get deviceId => _deviceId ?? 'unknown';

  /// Get platform
  static String get platform => _platform ?? 'unknown';

  /// Get OS information
  static String get osInfo {
    if (_deviceInfo == null) return 'unknown';

    switch (platform) {
      case 'android':
        return 'Android ${_deviceInfo!['version']}';
      case 'ios':
        return '${_deviceInfo!['system_name']} ${_deviceInfo!['system_version']}';
      case 'web':
        return _deviceInfo!['platform_detail'] ?? 'Web';
      case 'windows':
        return 'Windows ${_deviceInfo!['major_version']}.${_deviceInfo!['minor_version']}';
      case 'macos':
        return 'macOS ${_deviceInfo!['major_version']}.${_deviceInfo!['minor_version']}.${_deviceInfo!['patch_version']}';
      case 'linux':
        return _deviceInfo!['pretty_name'] ?? 'Linux';
      default:
        return 'Unknown OS';
    }
  }

  /// Get device name for User-Agent
  static String get deviceName {
    if (_deviceInfo == null) return 'unknown';

    switch (platform) {
      case 'android':
        return '${_deviceInfo!['manufacturer']} ${_deviceInfo!['model']}'
            .replaceAll(' ', '_');
      case 'ios':
        return (_deviceInfo!['model'] ?? 'iPhone').replaceAll(' ', '_');
      case 'web':
        return (_deviceInfo!['browser'] ?? 'Web').replaceAll(' ', '_');
      case 'windows':
      case 'macos':
      case 'linux':
        return (_deviceInfo!['computer_name'] ?? platform).replaceAll(' ', '_');
      default:
        return 'unknown';
    }
  }

  /// Generate User-Agent string
  /// Format: {app_name}/{app_version}({os}; device)
  static String get userAgent {
    return '$appName/$appVersion($osInfo; $deviceName)';
  }

  /// Generate full version string
  static String get fullVersion {
    return '$appVersion+$buildNumber';
  }

  /// Check if app info is initialized
  static bool get isInitialized => _packageInfo != null && _deviceInfo != null;

  /// Force re-initialization
  static Future<void> refresh() async {
    _packageInfo = null;
    _deviceInfo = null;
    _deviceId = null;
    _platform = null;
    await initialize();
  }
}
