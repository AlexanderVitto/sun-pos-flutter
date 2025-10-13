# Quick Reference: Role-Based Access Control

## 📋 Access Matrix

| Fitur                           | Role ID ≤ 2<br>(Owner/Manager) | Role ID > 2<br>(Restricted User) |
| ------------------------------- | :----------------------------: | :------------------------------: |
| **Dashboard - Full Stats**      |             ✅ Yes             |              ❌ No               |
| **Dashboard - Store Info Only** |             ✅ Yes             |              ✅ Yes              |
| **Transaksi Baru (POS)**        |             ✅ Yes             |              ❌ No               |
| **Pending Transactions**        |             ✅ Yes             |              ✅ Yes              |
| **User Profile**                |             ✅ Yes             |              ✅ Yes              |
| **Quick Actions**               |             ✅ All             |            ⚠️ Limited            |
| **Recent Activity**             |             ✅ Yes             |              ❌ No               |

---

## 🎯 Role Examples

### Full Access (Role ID ≤ 2)

```
Role ID: 1 → Owner
Role ID: 2 → Manager/Staff
```

**Navigation Bar:**

```
[Beranda] [Transaksi] [Pesan] [Profil]
    ✅        ✅        ✅      ✅
```

**Dashboard Content:**

```
✅ Quick Stats (Transaksi, Pendapatan, Rata-rata, Produk)
✅ Store Information
✅ Quick Actions (Transaksi Baru, Kelola Pelanggan, Pengaturan)
✅ Recent Activity
```

---

### Restricted Access (Role ID > 2)

```
Role ID: 3 → Cashier
Role ID: 4+ → Other roles
```

**Navigation Bar:**

```
[Beranda] [Pesan] [Profil]
    ✅      ✅      ✅
```

**Dashboard Content:**

```
✅ Store Information ONLY
✅ "Akses Terbatas" Notice
❌ NO Quick Stats
❌ NO Recent Activity
⚠️ Limited Quick Actions (No "Transaksi Baru")
```

---

## 🔧 Implementation Functions

```dart
// Check if user has full access
RolePermissions.hasFullAccess(user)
// Returns true if ANY role has ID ≤ 2

// Check if user is restricted
RolePermissions.isRestrictedUser(user)
// Returns true if ALL roles have ID > 2

// Check specific access
RolePermissions.canAccessPOSByUser(user)          // POS access
RolePermissions.canAccessDashboardByUser(user)     // Dashboard access
RolePermissions.canAccessPendingTransactionsByUser(user)  // Pending access
RolePermissions.canAccessProfileByUser(user)       // Profile access

// Check dashboard type
RolePermissions.shouldShowFullDashboard(user)
// Returns true for full dashboard, false for limited
```

---

## 📱 UI Differences

### Full Access User Dashboard:

```
┌─────────────────────────────────────┐
│  Header with User Info & Store      │
├─────────────────────────────────────┤
│  📊 Quick Stats (4 cards)           │
│  ├─ Transaksi                       │
│  ├─ Pendapatan                      │
│  ├─ Rata-rata                       │
│  └─ Produk                          │
├─────────────────────────────────────┤
│  🏪 Store Information Card          │
├─────────────────────────────────────┤
│  ⚡ Quick Actions (3 buttons)       │
│  ├─ Transaksi Baru                  │
│  ├─ Kelola Pelanggan                │
│  └─ Pengaturan                      │
├─────────────────────────────────────┤
│  📋 Recent Activity                 │
│  └─ Last 5 transactions             │
└─────────────────────────────────────┘
```

### Restricted User Dashboard:

```
┌─────────────────────────────────────┐
│  Header with User Info & Store      │
├─────────────────────────────────────┤
│  🏪 Store Information Card          │
│  (ONLY THIS SECTION)                │
├─────────────────────────────────────┤
│  ⚠️  Akses Terbatas Notice          │
│  "Akun Anda memiliki akses          │
│   terbatas..."                      │
│  [Role Badge(s)]                    │
└─────────────────────────────────────┘
```

---

## 🔐 Security Notes

⚠️ **IMPORTANT**: This is **frontend-only** access control!

**You MUST also implement:**

1. ✅ Backend API validation for role-based access
2. ✅ Token validation with role information
3. ✅ Server-side permission checks
4. ✅ Audit logging for access attempts

**Never trust frontend validation alone!**

---

## 🧪 Testing Checklist

- [ ] Login dengan role ID = 1 → Semua fitur accessible
- [ ] Login dengan role ID = 2 → Semua fitur accessible
- [ ] Login dengan role ID = 3 → Dashboard limited, no POS
- [ ] Login dengan role ID = 4+ → Dashboard limited, no POS
- [ ] User dengan multiple roles (mixed IDs) → Full access jika ada role ID ≤ 2
- [ ] Navigation bar sesuai dengan access level
- [ ] Quick actions sesuai dengan access level
- [ ] Error handling jika user = null
- [ ] Refresh page tetap maintain access level

---

**Last Updated**: October 12, 2025
