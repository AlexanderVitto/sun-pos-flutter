# Role-Based Access Control Implementation

## Overview

Implementasi kontrol akses berbasis Role ID untuk membatasi fitur yang dapat diakses oleh user tertentu.

## Aturan Akses

### User dengan Role ID ≤ 2 (Full Access)

User dengan **role ID 1 atau 2** memiliki **akses penuh** ke semua fitur:

✅ **Dashboard**

- Melihat ringkasan hari ini (transaksi, pendapatan, rata-rata, produk)
- Melihat quick stats dengan statistik lengkap
- Akses quick actions (Transaksi Baru, Kelola Pelanggan, Pengaturan)
- Melihat aktivitas terbaru (recent transactions)

✅ **Transaksi (POS)**

- Membuat transaksi baru
- Mengelola transaksi
- Akses penuh ke fitur Point of Sale

✅ **Pending Transactions**

- Melihat dan mengelola pesanan pending
- Update status pesanan

✅ **Profile**

- Kelola akun dan profil user
- Update informasi pribadi

---

### User dengan Role ID > 2 (Restricted Access)

User dengan **role ID 3 atau lebih tinggi** memiliki **akses terbatas**:

✅ **Dashboard (Limited)**

- ❌ TIDAK ada quick stats (transaksi, pendapatan, rata-rata, produk)
- ✅ Hanya menampilkan **informasi toko** (nama, alamat, telepon, status)
- ✅ Notifikasi "Akses Terbatas" dengan informasi role

✅ **Pending Transactions**

- Melihat dan mengelola pesanan pending
- Update status pesanan

✅ **Profile**

- Kelola akun dan profil user
- Update informasi pribadi

❌ **Tidak Dapat Mengakses:**

- ❌ Transaksi Baru (POS)
- ❌ Quick Stats di Dashboard
- ❌ Recent Activity di Dashboard
- ❌ Quick Action "Transaksi Baru"

---

## Implementasi Teknis

### 1. File yang Dimodifikasi

#### `lib/core/utils/role_permissions.dart`

Ditambahkan fungsi-fungsi baru untuk cek role ID:

```dart
// Check if user is restricted (role ID > 2)
static bool isRestrictedUser(User? user) {
  if (user == null) return true;
  return user.roles.every((role) => role.id > 2);
}

// Check if user has full access (role ID <= 2)
static bool hasFullAccess(User? user) {
  if (user == null) return false;
  return user.roles.any((role) => role.id <= 2);
}

// Check access by User object
static bool canAccessDashboardByUser(User? user) {
  return user != null; // All users can see dashboard
}

static bool canAccessPOSByUser(User? user) {
  return hasFullAccess(user); // Only full access
}

static bool canAccessPendingTransactionsByUser(User? user) {
  return user != null; // All users
}

static bool canAccessProfileByUser(User? user) {
  return user != null; // All users
}

// Check if should show full or limited dashboard
static bool shouldShowFullDashboard(User? user) {
  return hasFullAccess(user);
}
```

#### `lib/features/dashboard/presentation/pages/dashboard_page.dart`

**Import User model:**

```dart
import '../../../auth/data/models/user.dart';
```

**Update method signatures untuk menggunakan User object:**

```dart
// Sebelum:
List<Widget> _getAvailablePages(List<String>? userRoles)

// Sesudah:
List<Widget> _getAvailablePages(User? user)
```

**Update `_buildDashboardContent` untuk conditional rendering:**

```dart
Widget _buildDashboardContent() {
  return Consumer<AuthProvider>(
    builder: (context, authProvider, child) {
      final user = authProvider.user;
      final showFullDashboard = RolePermissions.shouldShowFullDashboard(user);

      if (showFullDashboard) {
        // Show full dashboard with stats, quick actions, recent activity
      } else {
        // Show limited dashboard with only store info
      }
    },
  );
}
```

**Tambah widget baru `_buildRestrictedUserNotice`:**

- Menampilkan notifikasi bahwa user memiliki akses terbatas
- Menampilkan role dan role ID user
- Styling kuning/amber untuk indikasi peringatan

### 2. Flow Diagram

```
User Login
    ↓
Check User Roles
    ↓
    ├─→ Has role with ID ≤ 2? → FULL ACCESS
    │   ├─ Dashboard (Full)
    │   ├─ POS/Transaksi
    │   ├─ Pending Transactions
    │   └─ Profile
    │
    └─→ All roles have ID > 2? → RESTRICTED ACCESS
        ├─ Dashboard (Limited - only store info)
        ├─ Pending Transactions
        └─ Profile
```

---

## Testing Scenarios

### Test Case 1: User dengan Role ID = 1 (Owner)

**Expected Result:**

- ✅ Dapat melihat semua menu di bottom navigation
- ✅ Dashboard menampilkan quick stats, quick actions, recent activity
- ✅ Dapat akses Transaksi Baru (POS)
- ✅ Dapat akses semua fitur

### Test Case 2: User dengan Role ID = 2 (Staff/Manager)

**Expected Result:**

- ✅ Dapat melihat semua menu di bottom navigation
- ✅ Dashboard menampilkan quick stats, quick actions, recent activity
- ✅ Dapat akses Transaksi Baru (POS)
- ✅ Dapat akses semua fitur

### Test Case 3: User dengan Role ID = 3 (Cashier/Other)

**Expected Result:**

- ✅ Hanya melihat 3 menu: Beranda, Pesan, Profil
- ❌ TIDAK ada menu "Transaksi"
- ✅ Dashboard HANYA menampilkan informasi toko
- ❌ TIDAK ada quick stats, quick actions (Transaksi Baru), recent activity
- ✅ Menampilkan notifikasi "Akses Terbatas"
- ✅ Dapat akses Pending Transactions
- ✅ Dapat akses Profile

### Test Case 4: User dengan Multiple Roles

**Expected Result:**

- Jika **salah satu** role memiliki ID ≤ 2 → **FULL ACCESS**
- Jika **semua** role memiliki ID > 2 → **RESTRICTED ACCESS**

---

## Keuntungan Implementasi Ini

1. **Flexible**: Berdasarkan role ID yang dinamis dari database
2. **Scalable**: Mudah menambahkan role baru tanpa hardcode
3. **Secure**: Check dilakukan di level aplikasi
4. **User-Friendly**: User restricted tetap bisa akses fitur yang diperlukan
5. **Clear Feedback**: Notifikasi jelas tentang keterbatasan akses

---

## Next Steps (Optional Improvements)

1. **Backend Validation**:

   - Pastikan API juga melakukan validasi role ID
   - Jangan hanya mengandalkan frontend

2. **Permission-based Access**:

   - Bisa dikembangkan lebih detail dengan permission specific
   - Contoh: `can_view_sales_report`, `can_create_transaction`, dll

3. **Audit Log**:

   - Track aktivitas user yang mencoba akses fitur restricted
   - Logging untuk security purposes

4. **Custom Error Pages**:
   - Halaman khusus jika user mencoba akses fitur yang tidak diizinkan

---

## Catatan Penting

⚠️ **Security Warning**:

- Implementasi ini hanya kontrol di **frontend**
- **HARUS** ada validasi yang sama di **backend/API**
- User yang "pintar" bisa bypass frontend validation
- Backend validation adalah layer security utama

⚠️ **Role ID Convention**:

- Pastikan konsisten: Role ID 1-2 = Full Access, >2 = Restricted
- Update dokumentasi jika ada perubahan convention
- Komunikasikan dengan backend team tentang role structure

---

## File Changes Summary

### Modified Files:

1. ✅ `lib/core/utils/role_permissions.dart` - Added role ID check functions
2. ✅ `lib/features/dashboard/presentation/pages/dashboard_page.dart` - Conditional UI rendering

### New Features:

1. ✅ Role ID based access control
2. ✅ Limited dashboard for restricted users
3. ✅ Restricted user notice widget
4. ✅ Dynamic bottom navigation based on access

---

**Implementation Date**: October 12, 2025
**Version**: 1.0.0
