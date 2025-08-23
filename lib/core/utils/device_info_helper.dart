import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceInfoHelper {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Get comprehensive device information
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        return {
          'platform': 'web',
          'browser': webInfo.browserName.name,
          'vendor': webInfo.vendor,
          'userAgent': webInfo.userAgent,
          'language': webInfo.language,
          'platform_detail': webInfo.platform,
        };
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'platform': 'android',
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'version': androidInfo.version.release,
          'sdk_int': androidInfo.version.sdkInt,
          'is_physical_device': androidInfo.isPhysicalDevice,
          'android_id': androidInfo.id,
          'board': androidInfo.board,
          'bootloader': androidInfo.bootloader,
          'display': androidInfo.display,
          'fingerprint': androidInfo.fingerprint,
          'hardware': androidInfo.hardware,
          'host': androidInfo.host,
          'product': androidInfo.product,
          'supported_32_bit_abis': androidInfo.supported32BitAbis,
          'supported_64_bit_abis': androidInfo.supported64BitAbis,
          'supported_abis': androidInfo.supportedAbis,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'platform': 'ios',
          'name': iosInfo.name,
          'system_name': iosInfo.systemName,
          'system_version': iosInfo.systemVersion,
          'model': iosInfo.model,
          'localized_model': iosInfo.localizedModel,
          'identifier_for_vendor': iosInfo.identifierForVendor,
          'is_physical_device': iosInfo.isPhysicalDevice,
          'utsname': {
            'sysname': iosInfo.utsname.sysname,
            'nodename': iosInfo.utsname.nodename,
            'release': iosInfo.utsname.release,
            'version': iosInfo.utsname.version,
            'machine': iosInfo.utsname.machine,
          },
        };
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        return {
          'platform': 'windows',
          'computer_name': windowsInfo.computerName,
          'number_of_cores': windowsInfo.numberOfCores,
          'system_memory_in_megabytes': windowsInfo.systemMemoryInMegabytes,
          'user_name': windowsInfo.userName,
          'major_version': windowsInfo.majorVersion,
          'minor_version': windowsInfo.minorVersion,
          'build_number': windowsInfo.buildNumber,
          'platform_id': windowsInfo.platformId,
          'csd_version': windowsInfo.csdVersion,
          'service_pack_major': windowsInfo.servicePackMajor,
          'service_pack_minor': windowsInfo.servicePackMinor,
          'suite_mask': windowsInfo.suitMask,
          'product_type': windowsInfo.productType,
          'reserved': windowsInfo.reserved,
          'build_lab': windowsInfo.buildLab,
          'build_lab_ex': windowsInfo.buildLabEx,
          'digital_product_id': windowsInfo.digitalProductId,
          'display_version': windowsInfo.displayVersion,
          'edition_id': windowsInfo.editionId,
          'install_date': windowsInfo.installDate,
          'product_id': windowsInfo.productId,
          'product_name': windowsInfo.productName,
          'registered_owner': windowsInfo.registeredOwner,
          'release_id': windowsInfo.releaseId,
          'device_id': windowsInfo.deviceId,
        };
      } else if (Platform.isMacOS) {
        final macosInfo = await _deviceInfo.macOsInfo;
        return {
          'platform': 'macos',
          'computer_name': macosInfo.computerName,
          'host_name': macosInfo.hostName,
          'arch': macosInfo.arch,
          'model': macosInfo.model,
          'kernel_version': macosInfo.kernelVersion,
          'os_release': macosInfo.osRelease,
          'major_version': macosInfo.majorVersion,
          'minor_version': macosInfo.minorVersion,
          'patch_version': macosInfo.patchVersion,
          'cpu_frequency': macosInfo.cpuFrequency,
          'memory_size': macosInfo.memorySize,
          'system_guid': macosInfo.systemGUID,
        };
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        return {
          'platform': 'linux',
          'name': linuxInfo.name,
          'version': linuxInfo.version,
          'id': linuxInfo.id,
          'id_like': linuxInfo.idLike,
          'version_codename': linuxInfo.versionCodename,
          'version_id': linuxInfo.versionId,
          'pretty_name': linuxInfo.prettyName,
          'build_id': linuxInfo.buildId,
          'variant': linuxInfo.variant,
          'variant_id': linuxInfo.variantId,
          'machine_id': linuxInfo.machineId,
        };
      }
    } catch (e) {
      debugPrint('Error getting device info: $e');
      return {'platform': 'unknown', 'error': e.toString()};
    }

    return {'platform': 'unknown', 'error': 'Unsupported platform'};
  }

  /// Get a simplified device identifier for logging/analytics
  static Future<String> getDeviceIdentifier() async {
    try {
      final deviceInfo = await getDeviceInfo();
      final platform = deviceInfo['platform'] as String;

      switch (platform) {
        case 'android':
          return '${deviceInfo['manufacturer']}_${deviceInfo['model']}_${deviceInfo['android_id']}'
              .replaceAll(' ', '_');
        case 'ios':
          return '${deviceInfo['model']}_${deviceInfo['identifier_for_vendor']}'
              .replaceAll(' ', '_');
        case 'web':
          return '${deviceInfo['browser']}_${deviceInfo['platform_detail']}'
              .replaceAll(' ', '_');
        case 'windows':
          return '${deviceInfo['computer_name']}_${deviceInfo['device_id']}'
              .replaceAll(' ', '_');
        case 'macos':
          return '${deviceInfo['model']}_${deviceInfo['system_guid']}'
              .replaceAll(' ', '_');
        case 'linux':
          return '${deviceInfo['name']}_${deviceInfo['machine_id']}'.replaceAll(
            ' ',
            '_',
          );
        default:
          return 'unknown_device';
      }
    } catch (e) {
      debugPrint('Error getting device identifier: $e');
      return 'unknown_device';
    }
  }

  /// Get platform-specific display name
  static Future<String> getDeviceDisplayName() async {
    try {
      final deviceInfo = await getDeviceInfo();
      final platform = deviceInfo['platform'] as String;

      switch (platform) {
        case 'android':
          return '${deviceInfo['manufacturer']} ${deviceInfo['model']}';
        case 'ios':
          return deviceInfo['name'] as String;
        case 'web':
          return '${deviceInfo['browser']} on ${deviceInfo['platform_detail']}';
        case 'windows':
          return deviceInfo['computer_name'] as String;
        case 'macos':
          return deviceInfo['computer_name'] as String;
        case 'linux':
          return deviceInfo['pretty_name'] as String;
        default:
          return 'Unknown Device';
      }
    } catch (e) {
      debugPrint('Error getting device display name: $e');
      return 'Unknown Device';
    }
  }

  /// Check if running on a physical device (not emulator/simulator)
  static Future<bool> isPhysicalDevice() async {
    try {
      if (kIsWeb) return false; // Web is never a physical device

      final deviceInfo = await getDeviceInfo();
      final platform = deviceInfo['platform'] as String;

      if (platform == 'android' || platform == 'ios') {
        return deviceInfo['is_physical_device'] as bool? ?? false;
      }

      // For desktop platforms, assume physical device
      return true;
    } catch (e) {
      debugPrint('Error checking if physical device: $e');
      return false;
    }
  }

  /// Get OS version string
  static Future<String> getOSVersion() async {
    try {
      final deviceInfo = await getDeviceInfo();
      final platform = deviceInfo['platform'] as String;

      switch (platform) {
        case 'android':
          return 'Android ${deviceInfo['version']} (API ${deviceInfo['sdk_int']})';
        case 'ios':
          return '${deviceInfo['system_name']} ${deviceInfo['system_version']}';
        case 'web':
          return deviceInfo['userAgent'] as String;
        case 'windows':
          return 'Windows ${deviceInfo['major_version']}.${deviceInfo['minor_version']} (Build ${deviceInfo['build_number']})';
        case 'macos':
          return 'macOS ${deviceInfo['major_version']}.${deviceInfo['minor_version']}.${deviceInfo['patch_version']}';
        case 'linux':
          return deviceInfo['pretty_name'] as String;
        default:
          return 'Unknown OS';
      }
    } catch (e) {
      debugPrint('Error getting OS version: $e');
      return 'Unknown OS';
    }
  }
}
