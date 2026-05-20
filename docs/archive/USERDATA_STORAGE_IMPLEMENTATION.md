# UserData Storage Implementation

## Overview

Implementasi ini memastikan data profile lengkap (termasuk roles dan permissions) disimpan sebagai userData di local storage setelah login dan fetch profile berhasil.

## Fitur yang Ditambahkan

### 1. Helper Method `_saveUserDataToStorage()`

```dart
// Menyimpan userData lengkap ke storage
await _saveUserDataToStorage(user);
```

Method ini menyimpan:

- **Secure Storage (Primary)**: Data lengkap sebagai JSON
- **SharedPreferences (Fallback)**: Data terstruktur dengan key individual

### 2. Enhanced Profile Storage

Setelah `fetchUserProfile()` berhasil:

```dart
// Data profile lengkap disimpan sebagai userData
final userData = _user!.toJson();
await _saveUserDataToStorage(_user!);
```

### 3. Method `getUserDataFromStorage()`

```dart
// Mengambil userData lengkap dari storage
final userData = await authProvider.getUserDataFromStorage();
if (userData != null) {
  print('User ID: ${userData['id']}');
  print('User Name: ${userData['name']}');
  print('User Roles: ${userData['roles']}');
}
```

## Struktur Data yang Disimpan

### Secure Storage

```json
{
  "id": 1,
  "name": "John Doe",
  "email": "admin@example.com",
  "roles": [
    {
      "id": 1,
      "name": "super_admin",
      "display_name": "Super Admin",
      "guard_name": "web",
      "permissions": [
        "view_any_user",
        "create_user",
        "update_user",
        "delete_user",
        "view_any_product",
        "create_product",
        "update_product",
        "delete_product",
        "view_any_transaction",
        "create_transaction",
        "update_transaction",
        "delete_transaction"
      ],
      "created_at": "2024-01-15 10:00:00",
      "updated_at": "2024-01-15 10:00:00"
    }
  ],
  "created_at": "2024-01-15 09:00:00",
  "updated_at": "2024-01-15 09:00:00"
}
```

### SharedPreferences (Fallback)

```
user_id: 1
user_name: "John Doe"
user_email: "admin@example.com"
user_created_at: "2024-01-15 09:00:00"
user_updated_at: "2024-01-15 09:00:00"
user_roles: "[{role_data}]" (as JSON string)
user_permissions: ["view_any_user", "create_user", ...] (as StringList)
```

## Flow Penyimpanan UserData

### 1. Login Process

```
Login → Fetch Profile → Save Complete UserData → Storage
```

1. User login berhasil
2. Otomatis fetch profile dari endpoint `/api/v1/auth/profile`
3. Jika profile berhasil dimuat: simpan data profile lengkap sebagai userData
4. Jika profile gagal: simpan data dari login response sebagai userData

### 2. Profile Update

```
Update Profile → Save UserData → Storage
```

Setiap kali profile diupdate, userData lengkap disimpan ulang.

## Cara Penggunaan

### 1. Akses UserData Saat Runtime

```dart
// Melalui AuthProvider
final user = authProvider.user;
final roles = authProvider.userRoles;
final permissions = authProvider.userPermissions;

// Check permission
if (authProvider.hasPermission('create_product')) {
  // Allow create product
}

// Check role
if (authProvider.hasRole('super_admin')) {
  // Super admin access
}
```

### 2. Retrieve UserData dari Storage

```dart
// Get userData dari storage (berguna untuk debugging atau migration)
final userData = await authProvider.getUserDataFromStorage();
if (userData != null) {
  final userId = userData['id'];
  final userName = userData['name'];
  final userEmail = userData['email'];
  // ... akses data lainnya
}
```

### 3. Update UserData

```dart
// Update user data dan otomatis simpan ke storage
final updatedUser = User(...);
await authProvider.updateUserData(updatedUser);
```

## Error Handling

### 1. Storage Fallback

- Primary: Secure Storage untuk data sensitif
- Fallback: SharedPreferences jika secure storage gagal
- Automatic switching berdasarkan availability

### 2. Profile Load Failure

- Jika fetch profile gagal setelah login: gunakan data login response
- Data tetap disimpan sebagai userData untuk konsistensi
- User tetap bisa menggunakan aplikasi dengan data terbatas

### 3. Debug Logging

```
Login successful, loading user profile...
User profile loaded successfully
UserData saved to secure storage: [id, name, email, roles, created_at, updated_at]
```

## Benefits

1. **Complete Data Persistence**: Roles dan permissions tersimpan lengkap
2. **Offline Access**: Data tersedia meski tanpa internet
3. **Fallback Mechanism**: Kompatibilitas dengan berbagai device
4. **Consistent Structure**: Format userData yang konsisten
5. **Easy Access**: Helper methods untuk akses data
6. **Debug Friendly**: Logging untuk monitoring proses

## Notes

- UserData disimpan otomatis setelah login dan fetch profile
- Format JSON lengkap dengan roles dan permissions
- Fallback mechanism untuk kompatibilitas
- Helper methods untuk kemudahan akses data
- Debug logging untuk monitoring
