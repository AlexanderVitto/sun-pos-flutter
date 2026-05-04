# Sun POS — Project Context for LLM

## Overview

**Sun POS** adalah aplikasi Point of Sale (POS) mobile berbasis **Flutter** untuk Android/iOS. Digunakan oleh kasir/toko untuk membuat transaksi penjualan, mengelola pelanggan, produk, stok, refund, laporan, dan cash flow. Terhubung ke backend REST API (`sfxsys.com`).

- **Package name:** `sun_pos`
- **Current version:** 1.0.33+34
- **Flutter SDK:** ^3.8.0-133.0.dev
- **State management:** `provider` (ChangeNotifier pattern)
- **Language:** Dart, UI dalam bahasa Indonesia

---

## Environments & Flavors

| Flavor       | App Name          | API Base URL                    |
| ------------ | ----------------- | ------------------------------- |
| `staging`    | Sun POS (Staging) | `https://stg.sfxsys.com/api/v1` |
| `production` | Sun POS           | `https://sfxsys.com/api/v1`     |

```bash
# Run
make run-staging
make run-prod

# Build APK
make build-staging-apk
make build-prod-apk

# Build AAB (Play Store)
make build-staging
make build-prod
```

Flutter command manual: `flutter run --dart-define=ENV=staging --flavor staging`

---

## Project Structure

```
lib/
├── main.dart                  # Entry point, MultiProvider setup
├── core/
│   ├── config/app_config.dart # Env, baseUrl, headers, storage keys
│   ├── constants/             # Colors, strings, icons
│   ├── events/                # Event broadcasting (TransactionEvents)
│   ├── network/
│   │   ├── auth_http_client.dart   # HTTP client with auth token
│   │   └── ssl_http_client.dart    # HTTP client with SSL bypass (dev)
│   ├── routes/
│   │   ├── app_router.dart    # Named route definitions
│   │   └── app_routes.dart    # Route constants
│   ├── services/              # Storage, secure storage
│   ├── themes/app_theme.dart  # App theme (Material 3)
│   ├── utils/
│   │   ├── role_permissions.dart  # Role-based access control
│   │   └── app_info_helper.dart   # User-Agent initialization
│   └── widgets/               # Reusable core widgets
│
├── data/                      # ⚠️ DEPRECATED — model lama, gunakan features/*/data
│   └── models/                # cart_item, customer, product, sale, user
│
├── shared/
│   ├── dialogs/               # Shared dialog widgets
│   ├── forms/                 # Shared form widgets
│   └── widgets/               # Shared UI components
│
└── features/                  # Feature modules (Clean Architecture)
    ├── auth/
    ├── cash_flows/
    ├── customers/
    ├── dashboard/
    ├── device_info/
    ├── products/
    ├── profile/
    ├── refunds/
    ├── reports/
    ├── sales/
    ├── splash/
    └── transactions/
```

### Struktur tiap feature:

```
features/[feature]/
├── data/
│   ├── models/       # Data models & DTOs
│   └── services/     # API service classes
├── presentation/
│   ├── pages/        # Screen widgets
│   ├── widgets/      # Feature-specific widgets
│   ├── view_models/  # ViewModels (ChangeNotifier)
│   └── utils/        # UI helpers
├── providers/        # ChangeNotifier providers
└── [feature].dart    # Barrel file (public exports)
```

---

## Key Features & Modules

### 1. Auth (`features/auth/`)

- Login dengan JWT token
- Token disimpan di `flutter_secure_storage` dengan key `{env}_access_token`
- `AuthProvider` — state login, user data, logout

### 2. Sales / POS (`features/sales/`)

- **POS Transaction Page** — halaman utama kasir (produk + cart)
- **Cart** — tambah/edit/hapus item, edit harga per item, diskon per item & total
- **Pending Transactions** — simpan transaksi sebagai draft, resume draft
- **Payment flow:** `pos_transaction_page → cart_page → order_confirmation_page → payment_confirmation_page → order_success_page`
- **Providers:** `CartProvider`, `TransactionProvider`, `PendingTransactionProvider`
- **ViewModel:** `POSTransactionViewModel` (ProxyProvider4 dari Cart+Transaction+Pending+Product)

### 3. Products (`features/products/`)

- List produk dengan kategori filter, search, infinite scroll
- Multi-variant selection
- Customer-based pricing (harga berbeda per grup pelanggan)
- `ApiProductProvider` — fetch dari API
- Models: `Product`, `ProductVariant`, `Category`, `CustomerPricing`

### 4. Transactions (`features/transactions/`)

- Daftar transaksi dengan filter
- Detail transaksi
- Refund dari detail transaksi
- `TransactionListProvider`

### 5. Customers (`features/customers/`)

- CRUD customer
- Customer groups (grup pelanggan → menentukan harga produk)
- Outstanding payment (hutang pelanggan)
- `CustomerProvider`

### 6. Refunds (`features/refunds/`)

- Daftar & detail refund
- Buat refund dari transaksi
- Filter by status
- `RefundListProvider`

### 7. Reports (`features/reports/`)

- Sales report (ringkasan penjualan)
- `ReportsProvider`

### 8. Cash Flows (`features/cash_flows/`)

- Pencatatan arus kas masuk/keluar
- `CashFlowProvider`

### 9. Dashboard (`features/dashboard/`)

- Ringkasan hari ini: transaksi, pendapatan, rata-rata, produk terlaris
- Recent transactions
- `StoreProvider`

---

## State Management Pattern

Semua state management menggunakan `provider` package dengan `ChangeNotifier`.

```dart
// main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => CartProvider()),
    ChangeNotifierProxyProvider<AuthProvider, CartProvider>(...), // auto-sync user
    ChangeNotifierProxyProvider4<...>( // POSTransactionViewModel
      create: (_) => POSTransactionViewModel(),
      update: (_, cart, transaction, pending, product, vm) { ... },
    ),
    ...
  ],
)
```

**Konvensi:**

- Provider diakses via `context.read<X>()` (action) atau `context.watch<X>()` / `Consumer<X>` (reactive UI)
- Jangan panggil `notifyListeners()` di dalam `build()`
- `POSTransactionViewModel` adalah ViewModel utama yang mengorkestrasi Cart + Transaction + Pending

---

## API & Networking

- HTTP client: `package:http`
- `AuthHttpClient` — attach Bearer token dari secure storage ke setiap request
- `SslHttpClient` — untuk development (bypass SSL verification)
- Base URL dari `AppConfig.baseUrl` (staging/production)
- Default headers: `Content-Type: application/json`, `Accept: application/json`, `User-Agent: Sun POS/{version}`
- Timeout: 30 detik, retry: 3x

### Contoh endpoint:

- `POST /transactions` — buat transaksi baru
- `GET /transactions` — list transaksi
- `GET /products` — list produk
- `GET /customers` — list customer
- `POST /refunds` — buat refund

---

## Role-Based Access Control

Di `core/utils/role_permissions.dart`:

| Role ID | Akses                                                                 |
| ------- | --------------------------------------------------------------------- |
| 1–2     | Full access (semua fitur termasuk POS, statistik dashboard)           |
| ≥ 3     | Restricted — hanya dashboard info toko, pending transactions, profile |

---

## Key Models

### Product

```dart
// features/products/data/models/product.dart
Product { id, name, price, variants: List<ProductVariant>, category, ... }
ProductVariant { id, name, price, stock }
CustomerPricing { customerGroupId, price } // harga spesial per grup
```

### Cart Item

```dart
// data/models/cart_item.dart (deprecated path)
CartItem { product, variant, quantity, unitPrice, discount }
```

### Transaction

```dart
// features/transactions/data/models/
CreateTransactionRequest { paymentMethod, paidAmount, items: List<TransactionDetail>, customerId?, notes?, draftId? }
TransactionDetail { productId, variantId, quantity, unitPrice, discount }
```

### Customer

```dart
// features/customers/data/models/customer.dart
Customer { id, name, phone, email, group, outstanding, ... }
```

---

## Navigation / Routes

```dart
// Utama
/                    → SplashScreen
/login               → LoginPage
/dashboard           → DashboardPage
/sales               → SalesPage (POS entry point)
/transactions/list   → TransactionListPage
/customers           → CustomersPage
/reports/sales       → SalesReportPage
/cash-flows          → CashFlowsPage
/settings/profile    → ProfilePage
```

Navigasi menggunakan `Navigator.pushNamed(context, AppRoutes.xxx)`.

---

## Thermal Printer

- Bluetooth: `flutter_blue_plus`
- Network: `esc_pos_printer` + `esc_pos_utils`
- Service: `features/sales/presentation/services/bluetooth_printer_service.dart`
- Receipt dicetak setelah transaksi sukses dari `receipt_page.dart`

---

## Build & Local Storage

- **Token storage:** `flutter_secure_storage` (key: `{env}_access_token`, `{env}_refresh_token`)
- **User profile:** `shared_preferences` (key: `{env}_user_profile`)
- **Locale:** Indonesian (`id_ID`) untuk format tanggal dan angka

---

## Conventions

- **File naming:** `snake_case.dart`
- **Class naming:** `PascalCase`
- **Widget naming:** `PascalCase` + suffix `Page`, `Widget`, `Dialog`
- **Provider naming:** `PascalCase` + suffix `Provider`
- **Service naming:** `PascalCase` + suffix `Service` atau `ApiService`
- **Barrel imports:** gunakan `package:sun_pos/features/xxx/xxx.dart`
- **Semua teks UI dalam Bahasa Indonesia**
- **Format angka:** menggunakan `intl` package, locale `id_ID` (1.000.000,00)
