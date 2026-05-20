# Secure Storage Implementation

Implementasi penyimpanan token login yang aman menggunakan `flutter_secure_storage` untuk aplikasi Sun POS.

## 🔐 Fitur Keamanan

### 1. **Flutter Secure Storage**

- Menggunakan Keychain di iOS/macOS
- Menggunakan Android Keystore di Android
- Enkripsi otomatis untuk semua data sensitif
- Perlindungan terhadap reverse engineering

### 2. **Token Management**

- Penyimpanan Access Token yang aman
- Support untuk Refresh Token
- Auto-expiry checking
- Session validation

### 3. **User Data Protection**

- Enkripsi data user
- Device ID tracking
- Login timestamp tracking
- Session backup/restore

## 📁 Struktur File

```
lib/
├── core/
│   ├── services/
│   │   └── secure_storage_service.dart    # Service utama secure storage
│   └── network/
│       └── auth_http_client.dart          # HTTP client dengan auto-auth
├── features/
│   ├── auth/
│   │   ├── providers/
│   │   │   └── auth_provider.dart         # Provider dengan secure storage
│   │   └── data/
│   │       └── services/
│   │           └── auth_service.dart      # Auth service terintegrasi
│   └── debug/
│       └── secure_storage_test_page.dart  # Halaman testing
```

## 🚀 Cara Penggunaan

### 1. **Basic Usage**

```dart
final secureStorage = SecureStorageService();

// Simpan token
await secureStorage.saveAccessToken('your_token_here');

// Ambil token
final token = await secureStorage.getAccessToken();

// Cek session valid
final isValid = await secureStorage.hasValidSession();
```

### 2. **Complete Login Session**

```dart
// Simpan complete session
await secureStorage.saveLoginSession(
  accessToken: 'access_token',
  refreshToken: 'refresh_token',
  userData: userMap,
  deviceId: 'device_123',
);

// Ambil session data
final sessionData = await secureStorage.getLoginSession();
```

### 3. **Dengan AuthProvider**

```dart
// Login
final authProvider = Provider.of<AuthProvider>(context, listen: false);
final success = await authProvider.login(email, password);

// Logout
await authProvider.logout();

// Cek status
final isLoggedIn = authProvider.isAuthenticated;
```

### 4. **HTTP Requests dengan Auto-Auth**

```dart
final httpClient = AuthHttpClient();

// GET dengan auto-authorization header
final response = await httpClient.get('https://api.example.com/data');

// POST dengan auto-authorization header
final response = await httpClient.postJson(
  'https://api.example.com/create',
  {'data': 'value'}
);
```

## 🛡️ Keamanan

### Android

- Menggunakan Android Keystore
- Enkripsi AES dengan kunci yang disimpan di hardware
- Protected dari rooted devices (optional)

### iOS/macOS

- Menggunakan iOS Keychain
- Hardware Security Module (HSM) protection
- Biometric protection (Touch ID/Face ID)

### Data yang Disimpan

- `access_token`: Token akses API
- `refresh_token`: Token untuk refresh
- `user_data`: Data user (JSON)
- `login_time`: Waktu login untuk validasi
- `device_id`: ID unik device

## 🧪 Testing

### Manual Testing

1. Buka aplikasi
2. Login dengan kredensial
3. Akses Dashboard → Klik ikon Shield (🛡️)
4. Test berbagai fungsi secure storage

### Test Functions

- ✅ **Save Token**: Test penyimpanan token
- 📝 **Get Token**: Test pengambilan token
- 💾 **Save User Data**: Test penyimpanan data user
- 👤 **Get User Data**: Test pengambilan data user
- ⏰ **Check Session**: Test validasi session
- 🗑️ **Clear Session**: Test hapus session
- 🔑 **Get All Keys**: Test debug keys
- 🎉 **Full Session**: Test complete flow

## ⚠️ Error Handling

Service ini menangani berbagai error scenario:

```dart
try {
  await secureStorage.saveAccessToken(token);
} catch (e) {
  // Handle secure storage error
  print('Storage error: $e');
}
```

Common errors:

- Platform tidak support
- Storage permission denied
- Corrupted data
- Device tidak memiliki secure hardware

## 🔄 Migration dari SharedPreferences

Jika sebelumnya menggunakan SharedPreferences:

```dart
// Lama (tidak aman)
final prefs = await SharedPreferences.getInstance();
await prefs.setString('token', token);

// Baru (aman)
final secureStorage = SecureStorageService();
await secureStorage.saveAccessToken(token);
```

## 🎯 Best Practices

1. **Selalu gunakan try-catch** untuk operasi storage
2. **Validasi session** secara berkala
3. **Clear session** saat logout
4. **Jangan log** data sensitif
5. **Test di berbagai device** untuk compatibility

## 🔧 Configuration

Konfigurasi tambahan di `secure_storage_service.dart`:

```dart
static const FlutterSecureStorage _storage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    sharedPreferencesName: 'sun_pos_secure_prefs',
    preferencesKeyPrefix: 'sun_pos_',
  ),
  iOptions: IOSOptions(
    groupId: 'group.com.sunpos.secure',
    accountName: 'sun_pos_account',
    accessibility: KeychainAccessibility.first_unlock_this_device,
  ),
);
```

## 📚 Dependencies

Tambahkan ke `pubspec.yaml`:

```yaml
dependencies:
  flutter_secure_storage: ^9.2.2
  uuid: ^4.4.0
```

## 🚨 Troubleshooting

### iOS/macOS Issues

- Pastikan Development Team di Xcode sudah diset
- Enable Keychain Sharing di Capabilities

### Android Issues

- Min SDK version 18+
- Proguard rules untuk obfuscation

### General Issues

- Restart aplikasi setelah install
- Clear app data jika ada corruption
- Check device compatibility

---

**Implementasi ini memberikan tingkat keamanan enterprise-grade untuk token dan data sensitif di aplikasi Sun POS.**
