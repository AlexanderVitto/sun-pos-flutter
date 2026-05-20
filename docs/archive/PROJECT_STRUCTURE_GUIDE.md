# 📁 Project Structure Guide - Sun POS

## 🎯 Tujuan

Panduan ini membantu developer baru memahami struktur folder dan cara trace file dependencies dengan mudah.

---

## 📊 Struktur Folder Saat Ini

```
lib/
├── main.dart                    # Entry point aplikasi
├── core/                        # Core utilities & configurations
│   ├── config/                  # App configuration (env, API)
│   ├── constants/               # Constants (colors, strings, icons)
│   ├── events/                  # Event broadcasting (transaction events)
│   ├── network/                 # HTTP clients (SSL, Auth)
│   ├── routes/                  # Navigation routes
│   ├── services/                # Core services (API, storage, SSL)
│   ├── theme/                   # App theming
│   ├── utils/                   # Utility functions
│   ├── auth/                    # Auth guard
│   └── widgets/                 # Core reusable widgets
│
├── data/                        # ⚠️ DEPRECATED - Use features/*/data instead
│   └── models/                  # Old models (akan dipindah)
│
├── shared/                      # Shared widgets across features
│   └── widgets/
│
└── features/                    # Feature modules (Clean Architecture)
    ├── auth/
    ├── cash_flows/
    ├── customers/
    ├── dashboard/
    ├── products/
    ├── sales/
    ├── transactions/
    └── ...
```

---

## 🏗️ Struktur Feature Module (Clean Architecture)

Setiap feature mengikuti pola ini:

```
features/[feature_name]/
├── data/
│   ├── models/              # Data models & DTOs
│   ├── services/            # API services
│   └── repositories/        # (optional) Data repositories
│
├── domain/                  # (optional) Business logic layer
│   ├── entities/
│   └── usecases/
│
├── presentation/            # UI Layer
│   ├── pages/              # Screen/Page widgets
│   ├── widgets/            # Feature-specific widgets
│   ├── view_models/        # (optional) ViewModels
│   └── utils/              # (optional) UI helpers
│
└── providers/              # State management (Provider/ChangeNotifier)
```

---

## 📝 Contoh: Tracing Dependencies untuk Sales Feature

### **File:** `features/sales/presentation/pages/pos_transaction_page.dart`

**Struktur Dependencies:**

```
pos_transaction_page.dart
│
├── Providers (State Management)
│   ├── ../../providers/cart_provider.dart
│   ├── ../../providers/pending_transaction_provider.dart
│   └── ../../../transactions/providers/transaction_list_provider.dart
│
├── Models (Data)
│   └── ../../../../data/models/product.dart  ⚠️ Should be: features/products/data/models/product.dart
│
├── View Models
│   └── ../view_models/pos_transaction_view_model.dart
│
├── Widgets (UI Components)
│   ├── ../widgets/pos_app_bar.dart
│   ├── ../widgets/mobile_layout.dart
│   ├── ../widgets/tablet_layout.dart
│   └── ../widgets/bottom_navigation_bar_widget.dart
│
├── Pages (Navigation)
│   ├── cart_page.dart
│   └── ../../../products/presentation/pages/product_detail_page.dart
│
└── Services
    ├── ../services/payment_service.dart
    └── ../utils/pos_ui_helpers.dart
```

---

## 🔧 Masalah yang Perlu Diperbaiki

### 1️⃣ **Duplikasi Models**

**Masalah:**

- Models ada di 2 tempat: `lib/data/models/` dan `lib/features/*/data/models/`
- Menyebabkan confusion: mana yang harus dipakai?

**Solusi:**

```bash
# Hapus lib/data/models/ dan pindahkan ke features yang sesuai
lib/data/models/product.dart     → lib/features/products/data/models/product.dart
lib/data/models/customer.dart    → lib/features/customers/data/models/customer.dart
lib/data/models/cart_item.dart   → lib/features/sales/data/models/cart_item.dart
lib/data/models/user.dart        → lib/features/auth/data/models/user.dart
lib/data/models/sale.dart        → lib/features/transactions/data/models/sale.dart
```

### 2️⃣ **Import Path Terlalu Panjang**

**Sebelum:**

```dart
import '../../../../data/models/product.dart';
import '../../../transactions/providers/transaction_list_provider.dart';
```

**Sesudah (dengan barrel files):**

```dart
import 'package:sun_pos/features/products/products.dart';
import 'package:sun_pos/features/transactions/transactions.dart';
```

### 3️⃣ **Tidak Ada Index/Barrel Files**

**Solusi:** Buat barrel files untuk setiap feature

---

## ✅ Rekomendasi Struktur Baru

### **Create Barrel Files**

Setiap feature memiliki file `[feature_name].dart` yang export semua public APIs:

**`lib/features/products/products.dart`:**

```dart
// Models
export 'data/models/product.dart';
export 'data/models/category.dart';
export 'data/models/product_variant.dart';
export 'data/models/customer_pricing.dart';

// Services
export 'data/services/product_api_service.dart';

// Providers
export 'providers/product_provider.dart';

// Pages (optional - only if needed outside feature)
export 'presentation/pages/products_page.dart';
export 'presentation/pages/product_detail_page.dart';
```

**`lib/features/sales/sales.dart`:**

```dart
// Models
export 'data/models/pending_transaction_api_models.dart';

// Providers
export 'providers/cart_provider.dart';
export 'providers/transaction_provider.dart';
export 'providers/pending_transaction_provider.dart';

// Services
export 'presentation/services/payment_service.dart';
export 'presentation/services/bluetooth_printer_service.dart';

// View Models
export 'presentation/view_models/pos_transaction_view_model.dart';

// Pages
export 'presentation/pages/pos_transaction_page.dart';
export 'presentation/pages/cart_page.dart';
```

---

## 📖 Cara Menggunakan

### **Import dari Feature Lain:**

```dart
// ❌ SEBELUM: Path relatif panjang
import '../../../../data/models/product.dart';
import '../../../products/providers/product_provider.dart';

// ✅ SESUDAH: Package import dengan barrel file
import 'package:sun_pos/features/products/products.dart';
```

### **Import dalam Feature yang Sama:**

```dart
// ✅ Gunakan relative path pendek
import '../../providers/cart_provider.dart';
import '../widgets/product_card.dart';
```

---

## 🗺️ Dependency Map (Feature → Feature)

```
auth
 ├── Tidak depend ke feature lain
 └── Digunakan oleh: semua features (via Provider)

products
 ├── Depends on: auth (untuk access control)
 └── Digunakan oleh: sales, dashboard

customers
 ├── Depends on: auth, products (untuk pricing)
 └── Digunakan oleh: sales, transactions

sales
 ├── Depends on: auth, products, customers, transactions
 └── Core feature untuk POS transaction

transactions
 ├── Depends on: auth, products, customers
 └── Digunakan oleh: sales, dashboard, reports

dashboard
 ├── Depends on: auth, transactions, products
 └── Root feature

cash_flows
 ├── Depends on: auth
 └── Standalone feature

reports
 ├── Depends on: auth, transactions
 └── Standalone feature

refunds
 ├── Depends on: auth, transactions, products
 └── Standalone feature
```

---

## 🚀 Action Plan untuk Refactoring

### **Phase 1: Create Barrel Files** (1-2 jam)

```bash
1. Buat [feature_name].dart untuk setiap feature
2. Export public APIs di setiap barrel file
3. Test import di beberapa file
```

### **Phase 2: Migrate Old Models** (2-3 jam)

```bash
1. Pindahkan lib/data/models/* ke features yang sesuai
2. Update import di semua file yang menggunakan
3. Hapus folder lib/data/models/
```

### **Phase 3: Update Imports** (3-4 jam)

```bash
1. Replace relative imports dengan package imports
2. Gunakan barrel files untuk cross-feature imports
3. Keep relative imports untuk intra-feature imports
```

### **Phase 4: Documentation** (1 jam)

```bash
1. Update README.md dengan struktur baru
2. Add comments di barrel files
3. Create dependency diagram
```

---

## 📚 Best Practices

### ✅ DO:

- Gunakan package imports untuk cross-feature dependencies
- Gunakan relative imports dalam feature yang sama
- Buat barrel files untuk public APIs
- Follow Clean Architecture layers
- Keep features independent sebisa mungkin

### ❌ DON'T:

- Import dari folder `presentation/` feature lain langsung
- Circular dependencies antar features
- Expose internal implementation details
- Mix business logic dengan UI

---

## 🔍 Quick Reference: Find Dependencies

### **Untuk Page/Widget:**

1. Buka file page (e.g., `pos_transaction_page.dart`)
2. Lihat semua import statements di atas
3. Group by category:
   - Providers: State management
   - Models: Data structures
   - Services: Business logic/API
   - Widgets: UI components
   - Pages: Navigation

### **Untuk Trace Usage:**

```bash
# Cari dimana ProductProvider digunakan
grep -r "ProductProvider" lib/

# Cari import dari products feature
grep -r "features/products" lib/
```

---

## 📞 Troubleshooting

**Q: Import path terlalu panjang (../../../../...)**

- A: Gunakan package import dengan barrel file

**Q: Circular dependency error**

- A: Review dependency map, pisahkan shared code ke core/

**Q: Dimana saya harus taruh utility function?**

- A:
  - Feature-specific → `features/[name]/presentation/utils/`
  - Global → `core/utils/`

**Q: Model dipakai di banyak feature, taruh dimana?**

- A: Taruh di feature yang "memiliki" model tersebut, export via barrel file

---

## 📈 Metrics untuk Clean Architecture

**Good indicators:**

- ✅ Import statements < 15 per file
- ✅ Path depth < 3 levels (../../)
- ✅ No circular dependencies
- ✅ Clear separation of concerns

**Bad indicators:**

- ❌ Path depth > 4 levels (../../../../)
- ❌ Importing from internal folders of other features
- ❌ Mixed responsibilities in one file
- ❌ Tight coupling between features

---

**Last Updated:** Feb 6, 2026
**Version:** 1.0.0
