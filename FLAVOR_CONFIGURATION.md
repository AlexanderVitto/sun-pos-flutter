# 🚀 Sun POS - Flutter Flavor Configuration

## 📋 Overview

Project ini sudah dikonfigurasi dengan **2 flavor**:

- **Staging** - Untuk development dan testing
- **Production** - Untuk release ke user

## 🌐 Environment Configuration

### Base URLs:

- **Staging**: `https://stg.sfxsys.com/api/v1`
- **Production**: `https://sfxsys.com/api/v1`

### App Names:

- **Staging**: Sun POS (Staging)
- **Production**: Sun POS

### Application IDs:

- **Staging**: `com.example.sun_pos.staging`
- **Production**: `com.example.sun_pos`

## 🛠️ How to Use

### 1. Using Makefile (Recommended)

Lihat semua command yang tersedia:

```bash
make help
```

#### Run App:

```bash
# Staging
make run-staging

# Production
make run-prod
```

#### Build APK:

```bash
# Staging APK
make build-staging-apk

# Production APK
make build-prod-apk
```

#### Build AAB (for Google Play Store):

```bash
# Staging AAB
make build-staging

# Production AAB
make build-prod
```

### 2. Using Flutter Command Directly

#### Run App:

```bash
# Staging
flutter run --dart-define=ENV=staging --flavor staging

# Production
flutter run --dart-define=ENV=production --flavor production
```

#### Build APK:

```bash
# Staging
flutter build apk --dart-define=ENV=staging --flavor staging --release

# Production
flutter build apk --dart-define=ENV=production --flavor production --release
```

#### Build AAB:

```bash
# Staging
flutter build appbundle --dart-define=ENV=staging --flavor staging --release

# Production
flutter build appbundle --dart-define=ENV=production --flavor production --release
```

## 📦 Build Output Locations

### APK Files:

- Staging: `build/app/outputs/flutter-apk/app-staging-release.apk`
- Production: `build/app/outputs/flutter-apk/app-production-release.apk`

### AAB Files (for Play Store):

- Staging: `build/app/outputs/bundle/stagingRelease/app-staging-release.aab`
- Production: `build/app/outputs/bundle/productionRelease/app-production-release.aab`

## 🔧 VS Code Launch Configuration

Tambahkan ke `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Sun POS (Staging)",
      "request": "launch",
      "type": "dart",
      "flutterMode": "debug",
      "args": ["--dart-define=ENV=staging", "--flavor", "staging"]
    },
    {
      "name": "Sun POS (Production)",
      "request": "launch",
      "type": "dart",
      "flutterMode": "debug",
      "args": ["--dart-define=ENV=production", "--flavor", "production"]
    }
  ]
}
```

## 📱 Testing on Device

Kedua flavor bisa diinstall bersamaan di device yang sama karena memiliki Application ID berbeda:

- Staging: `com.example.sun_pos.staging`
- Production: `com.example.sun_pos`

Ini memudahkan untuk testing dan comparison.

## 🎯 Key Features

✅ Separate Base URLs untuk setiap environment  
✅ Separate Application IDs (bisa install bersamaan)  
✅ Separate App Names  
✅ Environment-specific Debug/Logging settings  
✅ Separate Storage Keys untuk setiap environment  
✅ Easy to switch between environments

## 📝 Implementation Details

### Code Changes:

1. `lib/core/config/app_config.dart` - Environment configuration dengan `--dart-define`
2. `android/app/build.gradle.kts` - Android flavor configuration
3. `android/app/src/main/AndroidManifest.xml` - Dynamic app name dari flavor

### How it Works:

- Menggunakan `--dart-define=ENV=staging` untuk pass environment variable
- `String.fromEnvironment('ENV')` di Dart untuk read environment variable
- Android productFlavors untuk separate APK configuration

## 🚨 Important Notes

1. **Jangan hardcode environment** - Selalu gunakan `AppConfig.baseUrl` untuk API calls
2. **Testing** - Selalu test di kedua environment sebelum release
3. **Storage Keys** - Storage keys sudah separated by environment, data tidak akan conflict
4. **Debug Mode** - Staging secara otomatis enable debug logging

## 🔒 Production Release Checklist

Sebelum build production APK/AAB:

- [ ] Test semua fitur di staging environment
- [ ] Pastikan `baseUrl` production sudah benar
- [ ] Update version di `pubspec.yaml` jika perlu
- [ ] Pastikan signing config sudah setup untuk production
- [ ] Test APK production di device sebelum upload ke Play Store

## 📞 Support

Jika ada masalah dengan configuration, check:

1. Environment variable passing dengan benar (`--dart-define=ENV=...`)
2. Flavor name sesuai di command (`--flavor staging` atau `--flavor production`)
3. Build.gradle.kts sudah sync dengan benar

---

**Created**: November 15, 2025  
**Last Updated**: November 15, 2025
