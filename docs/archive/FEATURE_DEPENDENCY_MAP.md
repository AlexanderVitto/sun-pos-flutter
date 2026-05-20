# 🗺️ Feature Dependency Map - Sun POS

Visual guide untuk memahami dependency antar features.

---

## 📊 High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                        main.dart                         │
│                    (Entry Point)                         │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    Providers Setup                       │
│  AuthProvider, ProductProvider, CartProvider, etc.      │
└────────┬─────────────────────────────────────┬──────────┘
         │                                     │
         ▼                                     ▼
┌──────────────────┐                  ┌──────────────────┐
│   Core Layer     │                  │  Features Layer  │
│                  │                  │                  │
│ • Config         │                  │ • Auth           │
│ • Services       │◄─────────────────┤ • Products       │
│ • Utils          │                  │ • Sales          │
│ • Theme          │                  │ • Customers      │
│ • Routes         │                  │ • Transactions   │
└──────────────────┘                  │ • Dashboard      │
                                      │ • etc.           │
                                      └──────────────────┘
```

---

## 🔗 Feature Dependencies (Detailed)

### **Legend:**

- `→` Direct dependency (imports from)
- `⇢` Provides data to (used by)

---

### 1️⃣ **auth** (Base Layer - No Dependencies)

```
┌──────────────────────────────────────────┐
│              AUTH FEATURE                │
│                                          │
│  • User authentication & authorization   │
│  • User model with roles & permissions  │
│  • Token management                      │
└──────────────────────────────────────────┘
         ⇢  ⇢  ⇢  ⇢  ⇢
         │  │  │  │  │
   ┌─────┘  │  │  │  └─────┐
   │        │  │  │        │
   ▼        ▼  ▼  ▼        ▼
dashboard products sales customers transactions
```

**Provides to:** All features (via AuthProvider)
**Depends on:** NONE (core only)

**Exported Items:**

- `User`, `Role`, `Permission`
- `AuthProvider`
- `LoginPage`, `ChangePasswordPage`

---

### 2️⃣ **products** (Data Provider)

```
┌──────────────────────────────────────────┐
│            PRODUCTS FEATURE               │
│                                          │
│  • Product catalog management            │
│  • Categories & variants                 │
│  • Stock management                      │
│  • Customer pricing                      │
└──────────────────────────────────────────┘
    ↑                    ⇢  ⇢  ⇢
    │                    │  │  │
   auth           ┌──────┘  │  └────┐
                  │         │       │
                  ▼         ▼       ▼
               sales  dashboard  refunds
```

**Depends on:**

- `auth` → User permissions for access control
- `core` → API client, formatters

**Provides to:**

- `sales` → Product data for POS
- `dashboard` → Product statistics
- `refunds` → Product info for refunds

**Exported Items:**

- `Product`, `Category`, `ProductVariant`
- `ProductProvider`, `ApiProductProvider`
- `ProductsPage`, `ProductDetailPage`

---

### 3️⃣ **customers** (Data Provider)

```
┌──────────────────────────────────────────┐
│           CUSTOMERS FEATURE               │
│                                          │
│  • Customer database                     │
│  • Customer groups                       │
│  • Outstanding balances                  │
│  • Payment tracking                      │
└──────────────────────────────────────────┘
    ↑                    ⇢  ⇢
    │                    │  │
   auth           ┌──────┘  └────┐
   products       │              │
                  ▼              ▼
               sales      transactions
```

**Depends on:**

- `auth` → User permissions
- `products` → Customer pricing integration

**Provides to:**

- `sales` → Customer selection for transactions
- `transactions` → Customer payment history

**Exported Items:**

- `Customer`, `CustomerGroup`
- `CustomerProvider`
- `CustomerListPage`, `OutstandingCustomersPage`

---

### 4️⃣ **sales** (Core Business Logic)

```
┌──────────────────────────────────────────┐
│              SALES FEATURE                │
│                                          │
│  • POS Transaction system                │
│  • Cart management                       │
│  • Payment processing                    │
│  • Receipt printing                      │
│  • Pending transactions                  │
└──────────────────────────────────────────┘
    ↑ ↑ ↑ ↑              ⇢
    │ │ │ │              │
    │ │ │ └──products    │
    │ │ └────customers   │
    │ └──────transactions│
    └────────auth        ▼
                    dashboard
```

**Depends on:**

- `auth` → User authentication
- `products` → Product catalog
- `customers` → Customer selection
- `transactions` → Transaction processing

**Provides to:**

- `dashboard` → Transaction data for stats

**Exported Items:**

- `CartProvider`, `TransactionProvider`
- `POSTransactionViewModel`
- `PaymentService`, `BluetoothPrinterService`
- `POSTransactionPage`, `CartPage`

---

### 5️⃣ **transactions** (Transaction Management)

```
┌──────────────────────────────────────────┐
│          TRANSACTIONS FEATURE             │
│                                          │
│  • Transaction history                   │
│  • Transaction details                   │
│  • Payment records                       │
│  • Outstanding payments                  │
└──────────────────────────────────────────┘
    ↑ ↑ ↑                 ⇢  ⇢  ⇢
    │ │ │                 │  │  │
    │ │ └──customers      │  │  │
    │ └────products  ┌────┘  │  └───┐
    └──────auth      │       │      │
                     ▼       ▼      ▼
                  sales dashboard reports
```

**Depends on:**

- `auth` → User permissions
- `products` → Product details in transactions
- `customers` → Customer transaction history

**Provides to:**

- `sales` → Transaction creation
- `dashboard` → Recent transactions
- `reports` → Transaction analytics

**Exported Items:**

- `TransactionDetail`, `Store`, `PaymentHistory`
- `TransactionListProvider`
- `TransactionListPage`, `PayOutstandingPage`

---

### 6️⃣ **dashboard** (Aggregator)

```
┌──────────────────────────────────────────┐
│            DASHBOARD FEATURE              │
│                                          │
│  • Main dashboard                        │
│  • Statistics overview                   │
│  • Store selection                       │
│  • Recent activities                     │
└──────────────────────────────────────────┘
    ↑ ↑ ↑ ↑
    │ │ │ │
    │ │ │ └──products
    │ │ └────customers
    │ └──────transactions
    └────────auth
```

**Depends on:**

- `auth` → User & store info
- `transactions` → Transaction stats
- `products` → Product counts
- `customers` → Customer data

**Provides to:** None (top-level feature)

**Exported Items:**

- `StoreProvider`
- `DashboardPage`, `TransactionDetailPage`

---

### 7️⃣ **cash_flows** (Standalone)

```
┌──────────────────────────────────────────┐
│          CASH FLOWS FEATURE               │
│                                          │
│  • Cash in/out tracking                  │
│  • Expense management                    │
│  • Cash flow reports                     │
└──────────────────────────────────────────┘
    ↑
    │
   auth
```

**Depends on:**

- `auth` → User permissions
- `core` → API client

**Provides to:** None (standalone)

---

### 8️⃣ **reports** (Standalone)

```
┌──────────────────────────────────────────┐
│            REPORTS FEATURE                │
│                                          │
│  • Sales reports                         │
│  • Product performance                   │
│  • Analytics dashboards                  │
└──────────────────────────────────────────┘
    ↑ ↑
    │ │
    │ └──transactions
    └────auth
```

**Depends on:**

- `auth` → User permissions
- `transactions` → Transaction data

**Provides to:** None (standalone)

---

### 9️⃣ **refunds** (Standalone)

```
┌──────────────────────────────────────────┐
│            REFUNDS FEATURE                │
│                                          │
│  • Refund processing                     │
│  • Refund history                        │
│  • Refund receipts                       │
└──────────────────────────────────────────┘
    ↑ ↑ ↑
    │ │ │
    │ │ └──products
    │ └────transactions
    └──────auth
```

**Depends on:**

- `auth` → User permissions
- `transactions` → Original transaction data
- `products` → Product details

**Provides to:** None (standalone)

---

## 📋 Dependency Matrix

| Feature          | auth | products | customers | sales | transactions | dashboard |
| ---------------- | :--: | :------: | :-------: | :---: | :----------: | :-------: |
| **auth**         |  -   |    -     |     -     |   -   |      -       |     -     |
| **products**     |  ✓   |    -     |     -     |   -   |      -       |     -     |
| **customers**    |  ✓   |    ✓     |     -     |   -   |      -       |     -     |
| **sales**        |  ✓   |    ✓     |     ✓     |   -   |      ✓       |     -     |
| **transactions** |  ✓   |    ✓     |     ✓     |   -   |      -       |     -     |
| **dashboard**    |  ✓   |    ✓     |     ✓     |   -   |      ✓       |     -     |
| **cash_flows**   |  ✓   |    -     |     -     |   -   |      -       |     -     |
| **reports**      |  ✓   |    -     |     -     |   -   |      ✓       |     -     |
| **refunds**      |  ✓   |    ✓     |     -     |   -   |      ✓       |     -     |

**Legend:** ✓ = depends on

---

## 🎯 Feature Complexity Levels

### **Level 1 - Base (No Dependencies)**

- `auth` - Authentication & authorization

### **Level 2 - Data Providers**

- `products` - Product catalog
- `cash_flows` - Cash management

### **Level 3 - Business Logic**

- `customers` - Customer management (uses products)
- `transactions` - Transaction processing

### **Level 4 - Core Business**

- `sales` - POS system (uses all above)

### **Level 5 - Aggregators**

- `dashboard` - Main dashboard (aggregates data)
- `reports` - Analytics (aggregates transactions)
- `refunds` - Refund processing

---

## 🔍 How to Trace Dependencies

### Example: Understanding `pos_transaction_page.dart`

**Step 1: Look at the page location**

```
lib/features/sales/presentation/pages/pos_transaction_page.dart
```

→ This is in **sales** feature

**Step 2: Check imports at top of file**

```dart
import 'package:sun_pos/features/products/products.dart';
import 'package:sun_pos/features/transactions/transactions.dart';
import 'package:sun_pos/features/customers/customers.dart';
```

→ Depends on: **products**, **transactions**, **customers**

**Step 3: Check internal imports**

```dart
import '../../providers/cart_provider.dart';
import '../widgets/pos_app_bar.dart';
```

→ Uses internal: **CartProvider**, **pos_app_bar widget**

**Step 4: Build dependency tree**

```
pos_transaction_page.dart
├── External Dependencies
│   ├── products (Product, ProductProvider)
│   ├── customers (Customer, CustomerProvider)
│   └── transactions (TransactionListProvider)
│
└── Internal Dependencies (sales feature)
    ├── providers/cart_provider.dart
    ├── view_models/pos_transaction_view_model.dart
    ├── widgets/pos_app_bar.dart
    └── services/payment_service.dart
```

---

## 💡 Best Practices

### ✅ DO:

1. **Keep features independent**
   - Minimize cross-feature dependencies
   - Use providers for data sharing

2. **Follow dependency direction**
   - Higher level features can depend on lower level
   - Never let lower level depend on higher level

3. **Use barrel files for clarity**

   ```dart
   import 'package:sun_pos/features/products/products.dart';
   ```

4. **Document new dependencies**
   - Update this map when adding dependencies

---

### ❌ DON'T:

1. **Circular dependencies**

   ```
   ❌ products → sales → products
   ```

2. **Skip layers**

   ```
   ❌ dashboard → core/services directly
   ✅ dashboard → auth → core/services
   ```

3. **Tight coupling**
   ```
   ❌ Importing internal widgets from other features
   ✅ Using providers for data sharing
   ```

---

## 🚀 For New Developers

### Quick Start Checklist:

1. ✅ Read `PROJECT_STRUCTURE_GUIDE.md`
2. ✅ Review this dependency map
3. ✅ Check `BARREL_FILES_USAGE_GUIDE.md`
4. ✅ Explore one feature at a time (start with `auth`)
5. ✅ Use barrel files for imports
6. ✅ Follow the dependency matrix

---

**Last Updated:** Feb 6, 2026
**Maintainer:** Development Team
