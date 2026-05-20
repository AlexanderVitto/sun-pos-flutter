# Profile Integration Usage Example

## Perubahan yang Telah Dibuat

### 1. AuthService - Endpoint Profile

- Endpoint profile diupdate ke: `{{base_url}}/api/v1/auth/profile`
- Menggunakan method GET dengan autentikasi required

### 2. ProfileResponse Model

- Diupdate untuk menggunakan format response yang sesuai:

```json
{
  "success": true,
  "message": "Profile fetched successfully",
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "admin@example.com",
    "roles": [...]
  }
}
```

### 3. AuthProvider - Login Process

- Setelah login berhasil, otomatis memanggil `fetchUserProfile()`
- Data profile lengkap dengan roles dan permissions disimpan sebagai userData
- Fallback jika profile gagal dimuat, tetap menggunakan data dari login response

## Cara Penggunaan

### 1. Login Process

```dart
// Login akan otomatis memuat profile data
final success = await authProvider.login(email, password);
if (success) {
  // User sudah login dan profile data sudah dimuat
  print('User roles: ${authProvider.userRoles}');
  print('User permissions: ${authProvider.userPermissions}');
}
```

### 2. Cek Permission

```dart
// Menggunakan helper methods baru
if (authProvider.hasPermission('create_product')) {
  // User boleh create product
}

if (authProvider.hasRole('super_admin')) {
  // User adalah super admin
}
```

### 3. Akses User Data

```dart
// Akses data user lengkap
final user = authProvider.user;
if (user != null) {
  print('User ID: ${user.id}');
  print('User Name: ${user.name}');
  print('User Email: ${user.email}');

  // Akses roles dengan detail lengkap
  for (final role in user.roles) {
    print('Role: ${role.name} (${role.displayName})');
    print('Permissions: ${role.permissionNames}');
  }
}
```

### 4. Manual Refresh Profile

```dart
// Jika perlu refresh profile data secara manual
final success = await authProvider.fetchUserProfile();
if (success) {
  print('Profile updated successfully');
}
```

## Format Data yang Disimpan

### User Data Structure

```dart
User {
  id: int,
  name: String,
  email: String,
  roles: List<Role>,
  createdAt: String,
  updatedAt: String
}
```

### Role Data Structure

```dart
Role {
  id: int,
  name: String,           // 'super_admin'
  displayName: String,    // 'Super Admin'
  guardName: String,      // 'web'
  permissions: List<Permission>,
  createdAt: String,
  updatedAt: String
}
```

### Permission Data Structure

```dart
Permission {
  name: String            // 'view_any_user', 'create_product', etc.
}
```

## Storage

Data profile disimpan di:

1. **Secure Storage** (primary) - untuk data sensitif
2. **SharedPreferences** (fallback) - jika secure storage gagal

Data yang disimpan meliputi:

- Access token
- User data lengkap (termasuk roles dan permissions)
- Device ID untuk session management

## Error Handling

- Jika fetch profile gagal setelah login, tetap menggunakan data dari login response
- Automatic logout jika terjadi 401 Unauthorized saat fetch profile
- Fallback storage mechanism untuk kompatibilitas device
- Debug logging untuk monitoring proses

## Notes

- Profile data dimuat otomatis saat login berhasil
- Data disimpan secara persisten di storage
- Helper methods tersedia untuk cek permission dan role
- Backward compatibility tetap terjaga
