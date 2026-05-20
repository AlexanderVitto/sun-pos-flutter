# Logout Error Fix

## 🐛 Error Description

**Error Message:**

```
# Logout Error Fix

## 🐛 Error Description

**Error Message:**
```

FlutterError (Looking up a deactivated widget's ancestor is unsafe.
At this point the state of the widget's element tree is no longer stable.
To safely refer to a widget's ancestor in its dispose() method, save a reference
to the ancestor by calling dependOnInheritedWidgetOfExactType() in the widget's
didChangeDependencies() method.)

```

**Additional Build Error:**
```

Target kernel_snapshot_program failed: Exception
flutter analyze: use_build_context_synchronously

````

**When it occurs:**
- Error terjadi ketika user melakukan logout dari aplikasi
- Widget context diakses setelah widget sudah di-dispose
- BuildContext digunakan setelah async gap tanpa proper guard

---

## 🔍 Root Cause

### Masalah di Kode Lama:

```dart
void _handleLogout(BuildContext context) async {
  final authProvider = context.read<AuthProvider>(); // ❌ Read context too early
  final confirmed = await showDialog<bool>(...);

  if (confirmed == true && mounted) {
    await authProvider.logout(); // After logout, widget might be disposed
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login); // ❌ Context might be invalid
      });
    }
  }
}
````

**Isu:**

1. `context.read<AuthProvider>()` dipanggil di awal, sebelum dialog
2. Setelah `authProvider.logout()`, widget tree bisa sudah berubah
3. Mengakses `context` setelah async operation (logout) bisa unsafe
4. `Navigator.of(context)` dipanggil setelah widget mungkin sudah dispose
5. **Flutter analyzer mendeteksi `use_build_context_synchronously`** - BuildContext digunakan across async gap

---

## ✅ Solution (Final Version)

### Kode yang Diperbaiki:

```dart
Future<void> _handleLogout(BuildContext context) async {
  // ✅ Capture NavigatorState and AuthProvider BEFORE any async operation
  final NavigatorState navigator = Navigator.of(context);
  final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Ya, Keluar'),
          ),
        ],
      );
    },
  );

  if (confirmed != true) return;

  // ✅ Check if widget is still mounted
  if (!mounted) return;

  try {
    // ✅ Perform logout using captured authProvider
    await authProvider.logout();
  } catch (e) {
    debugPrint('Error during logout: $e');
  }

  // ✅ Navigate using captured navigator (safe across async gap)
  navigator.pushNamedAndRemoveUntil(
    AppRoutes.login,
    (route) => false, // Remove all previous routes
  );
}
```

---

## 🎯 Key Changes

### 1. **Capture Both NavigatorState AND AuthProvider Early**

```dart
final NavigatorState navigator = Navigator.of(context);
final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
```

- ✅ Kedua reference disimpan **SEBELUM** operasi async
- ✅ Tidak perlu akses context setelah async gap
- ✅ Menyelesaikan warning `use_build_context_synchronously`

### 2. **Use Provider.of Instead of context.read**

```dart
Provider.of<AuthProvider>(context, listen: false)
```

- ✅ Lebih eksplisit dan jelas
- ✅ `listen: false` memastikan tidak trigger rebuild

### 3. **Try-Catch for Error Handling**

```dart
try {
  await authProvider.logout();
} catch (e) {
  debugPrint('Error during logout: $e');
}
```

- ✅ Handle error saat logout
- ✅ Tetap lanjut ke navigation meskipun logout gagal

### 4. **Use pushNamedAndRemoveUntil**

```dart
navigator.pushNamedAndRemoveUntil(
  AppRoutes.login,
  (route) => false,
);
```

- ✅ Clear semua route sebelumnya
- ✅ Mencegah user back ke dashboard setelah logout

---

````

**When it occurs:**
- Error terjadi ketika user melakukan logout dari aplikasi
- Widget context diakses setelah widget sudah di-dispose

---

## 🔍 Root Cause

### Masalah di Kode Lama:

```dart
void _handleLogout(BuildContext context) async {
  final authProvider = context.read<AuthProvider>(); // ❌ Read context too early
  final confirmed = await showDialog<bool>(...);

  if (confirmed == true && mounted) {
    await authProvider.logout(); // After logout, widget might be disposed
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login); // ❌ Context might be invalid
      });
    }
  }
}
````

**Isu:**

1. `context.read<AuthProvider>()` dipanggil di awal, sebelum dialog
2. Setelah `authProvider.logout()`, widget tree bisa sudah berubah
3. Mengakses `context` setelah async operation (logout) bisa unsafe
4. `Navigator.of(context)` dipanggil setelah widget mungkin sudah dispose

---

## ✅ Solution

### Kode yang Diperbaiki:

```dart
void _handleLogout(BuildContext context) async {
  // ✅ Store navigator reference BEFORE async operations
  final navigator = Navigator.of(context);

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Ya, Keluar'),
          ),
        ],
      );
    },
  );

  if (confirmed == true) {
    // ✅ Check if widget is still mounted
    if (!mounted) return;

    // ✅ Get authProvider reference just before using it
    final authProvider = context.read<AuthProvider>();

    // Perform logout
    await authProvider.logout();

    // ✅ Navigate using stored navigator reference (safe across async gap)
    navigator.pushReplacementNamed(AppRoutes.login);
  }
}
```

---

## 🎯 Key Changes

### 1. **Store Navigator Reference Early**

```dart
final navigator = Navigator.of(context);
```

- Menyimpan reference ke Navigator **sebelum** operasi async
- Navigator reference tetap valid meskipun widget tree berubah

### 2. **Check Mounted State**

```dart
if (!mounted) return;
```

- Memastikan widget masih mounted sebelum melanjutkan
- Mencegah akses ke context yang sudah invalid

### 3. **Late Provider Access**

```dart
// Get authProvider reference just before using it
final authProvider = context.read<AuthProvider>();
```

- Membaca AuthProvider **setelah** dialog selesai
- Lebih dekat ke waktu penggunaannya

### 4. **Use Stored Navigator**

```dart
navigator.pushReplacementNamed(AppRoutes.login);
```

- Menggunakan navigator yang sudah disimpan
- Tidak perlu akses context lagi
- Tidak perlu `WidgetsBinding.instance.addPostFrameCallback`

---

## 📋 Best Practices untuk Async Navigation

### ✅ DO:

```dart
// Store navigator before async operations
final navigator = Navigator.of(context);

// Perform async operation
await someAsyncOperation();

// Use stored navigator
navigator.pushReplacementNamed('/route');
```

### ❌ DON'T:

```dart
// Perform async operation
await someAsyncOperation();

// Try to access context after async
Navigator.of(context).pushReplacementNamed('/route'); // ❌ Unsafe!
```

---

## 🔄 Flow Comparison

### Before (❌ Error-prone):

```
1. Read AuthProvider from context
2. Show confirmation dialog (async)
3. Logout (async)
4. Check mounted
5. Use PostFrameCallback
6. Access context for navigation ❌ (might be disposed)
```

### After (✅ Safe):

```
1. Store Navigator reference
2. Show confirmation dialog (async)
3. Check mounted
4. Read AuthProvider from context
5. Logout (async)
6. Use stored Navigator ✅ (safe)
```

---

## 🧪 Testing

**Scenario 1: Normal Logout**

- ✅ User clicks logout
- ✅ Confirmation dialog appears
- ✅ User confirms
- ✅ Logout successful
- ✅ Navigate to login screen
- ✅ No errors

**Scenario 2: Cancel Logout**

- ✅ User clicks logout
- ✅ Confirmation dialog appears
- ✅ User cancels
- ✅ Dialog closes
- ✅ Stay on dashboard
- ✅ No errors

**Scenario 3: Widget Disposed During Logout**

- ✅ User clicks logout
- ✅ Confirmation dialog appears
- ✅ Widget gets disposed (edge case)
- ✅ mounted check prevents error
- ✅ No crash

---

## 📝 Related Files

**Modified:**

- `lib/features/dashboard/presentation/pages/dashboard_page.dart`

**Method:**

- `_handleLogout(BuildContext context)`

---

## 💡 Why This Works

1. **Navigator is Immutable**: Once obtained, the Navigator object reference remains valid
2. **Early Capture**: Capturing before async prevents context invalidation issues
3. **Mounted Check**: Ensures widget is still in tree before proceeding
4. **No PostFrameCallback Needed**: Direct navigation is safe with stored Navigator

---

## ⚠️ Important Notes

### Context Safety Rules:

1. **Never** store `BuildContext` as a field
2. **Always** check `mounted` before using context after `await`
3. **Store** Navigator/ScaffoldMessenger references before async operations
4. **Use** stored references for navigation/snackbars after async

### When to Store References:

Store before async if you need:

- `Navigator.of(context)` → Navigation
- `ScaffoldMessenger.of(context)` → Snackbars
- `Theme.of(context)` → Theme data
- Any InheritedWidget lookup

---

## 🎓 Additional Resources

**Flutter Best Practices:**

- [BuildContext Safety](https://api.flutter.dev/flutter/widgets/BuildContext-class.html)
- [State.mounted Property](https://api.flutter.dev/flutter/widgets/State/mounted.html)
- [Async Programming](https://dart.dev/codelabs/async-await)

**Common Patterns:**

```dart
// Pattern 1: Store navigator
final navigator = Navigator.of(context);
await operation();
navigator.pushNamed('/route');

// Pattern 2: Check mounted
if (!mounted) return;
final result = await operation();
if (!mounted) return;
// Use result

// Pattern 3: Use callback context
showDialog(
  context: context,
  builder: (dialogContext) {
    // Use dialogContext, not outer context
  },
);
```

---

**Fixed Date**: October 12, 2025  
**Status**: ✅ Resolved
