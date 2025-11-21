# 🎯 Quick Reference - Flutter Flavor Commands

## 📱 Run Commands

### Development/Testing

```bash
# Quick run staging (recommended for development)
make run-staging

# Quick run production (for final testing)
make run-prod
```

### Direct Flutter Commands

```bash
# Staging
flutter run --dart-define=ENV=staging --flavor staging

# Production
flutter run --dart-define=ENV=production --flavor production
```

## 🔨 Build Commands

### APK (for direct installation)

```bash
# Build staging APK
make build-staging-apk

# Build production APK
make build-prod-apk
```

### AAB (for Google Play Store)

```bash
# Build staging AAB
make build-staging

# Build production AAB
make build-prod
```

## 🎨 VS Code Run & Debug

Tekan `F5` atau klik "Run and Debug", lalu pilih:

- **Sun POS (Staging)** - Debug mode staging
- **Sun POS (Production)** - Debug mode production
- **Sun POS (Staging - Release)** - Release mode staging
- **Sun POS (Production - Release)** - Release mode production

## 📦 Output Files Location

### APK Files

```
build/app/outputs/flutter-apk/
├── app-staging-release.apk      ← Staging APK
└── app-production-release.apk   ← Production APK
```

### AAB Files

```
build/app/outputs/bundle/
├── stagingRelease/app-staging-release.aab       ← Staging AAB
└── productionRelease/app-production-release.aab ← Production AAB
```

## 🌐 Environment Details

| Environment    | Base URL                        | App Name          | App ID                        |
| -------------- | ------------------------------- | ----------------- | ----------------------------- |
| **Staging**    | `https://stg.sfxsys.com/api/v1` | Sun POS (Staging) | `com.example.sun_pos.staging` |
| **Production** | `https://sfxsys.com/api/v1`     | Sun POS           | `com.example.sun_pos`         |

## 💡 Tips

### Install Both Versions

Karena memiliki Application ID berbeda, Anda bisa install staging dan production di device yang sama untuk testing!

### Default Behavior

Jika tidak specify environment, akan menggunakan **staging** sebagai default.

### Checking Current Environment in Code

```dart
import 'package:sun_pos/core/config/app_config.dart';

// Get current environment
print('Environment: ${AppConfig.environment}');
print('Base URL: ${AppConfig.baseUrl}');
print('App Name: ${AppConfig.appName}');
print('Debug Mode: ${AppConfig.isDebugMode}');
```

### Clean Build

Jika ada masalah dengan build:

```bash
make clean
# atau
flutter clean
```

## 🚨 Common Issues

### Issue: Flavor not found

**Solution**: Pastikan sudah run `flutter pub get` setelah ubah `build.gradle.kts`

### Issue: Wrong environment

**Solution**: Check argument `--dart-define=ENV=...` sudah benar

### Issue: Build failed

**Solution**: Try clean first: `flutter clean` then rebuild

## 📋 Pre-Release Checklist

Sebelum release production:

- [ ] Test di staging environment dulu
- [ ] Verify base URL production benar
- [ ] Update version number di `pubspec.yaml`
- [ ] Test production APK di real device
- [ ] Check semua fitur works dengan production API

---

**Need help?** Run `make help` untuk see all available commands.
