# 📌 Quick Reference - Sun POS Structure

Cheat sheet untuk navigasi cepat dalam project.

---

## 📁 Folder Structure at a Glance

```
lib/
├── main.dart                    # Start here
├── core/                        # Import: package:sun_pos/core/core.dart
├── features/
│   ├── auth/                   # Import: .../auth/auth.dart
│   ├── products/               # Import: .../products/products.dart
│   ├── customers/              # Import: .../customers/customers.dart
│   ├── sales/                  # Import: .../sales/sales.dart
│   ├── transactions/           # Import: .../transactions/transactions.dart
│   └── dashboard/              # Import: .../dashboard/dashboard.dart
└── shared/widgets/             # Shared UI components
```

---

## 🎯 Import Cheat Sheet

### Cross-Feature Imports (Use Barrel Files)

```dart
// Auth
import 'package:sun_pos/features/auth/auth.dart';
// → User, Role, AuthProvider, LoginPage

// Products
import 'package:sun_pos/features/products/products.dart';
// → Product, Category, ProductProvider, ProductsPage

// Customers
import 'package:sun_pos/features/customers/customers.dart';
// → Customer, CustomerGroup, CustomerProvider

// Sales
import 'package:sun_pos/features/sales/sales.dart';
// → CartProvider, PaymentService, POSTransactionPage

// Transactions
import 'package:sun_pos/features/transactions/transactions.dart';
// → TransactionDetail, TransactionListProvider

// Dashboard
import 'package:sun_pos/features/dashboard/dashboard.dart';
// → StoreProvider, DashboardPage

// Core utilities
import 'package:sun_pos/core/core.dart';
// → AppConfig, AppColors, CurrencyFormatter, etc.
```

### Intra-Feature Imports (Use Relative Paths)

```dart
// Within same feature folder
import '../../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import '../services/payment_service.dart';
```

---

## 🔍 Find Files Fast

### By Type:

| What             | Where                                                  |
| ---------------- | ------------------------------------------------------ |
| **Models**       | `features/[name]/data/models/`                         |
| **API Services** | `features/[name]/data/services/`                       |
| **Providers**    | `features/[name]/providers/`                           |
| **Pages**        | `features/[name]/presentation/pages/`                  |
| **Widgets**      | `features/[name]/presentation/widgets/`                |
| **Utils**        | `core/utils/` or `features/[name]/presentation/utils/` |

### By Feature:

| Feature       | Main Files                                                                |
| ------------- | ------------------------------------------------------------------------- |
| **Auth**      | `auth_provider.dart`, `login_page.dart`, `user.dart`                      |
| **Products**  | `product_provider.dart`, `products_page.dart`, `product.dart`             |
| **Customers** | `customer_provider.dart`, `customer_list_page.dart`, `customer.dart`      |
| **Sales**     | `cart_provider.dart`, `pos_transaction_page.dart`, `payment_service.dart` |
| **Dashboard** | `store_provider.dart`, `dashboard_page.dart`                              |

---

## 🗺️ Dependency Quick Map

```
auth (base)
  ↓
products, customers
  ↓
sales, transactions
  ↓
dashboard
```

**Rule:** Lower levels can't depend on higher levels.

---

## 📝 Common Tasks

### 1. Add New Page

```bash
# Location
features/[feature]/presentation/pages/my_new_page.dart

# Template
import 'package:flutter/material.dart';
import '../../providers/my_provider.dart';

class MyNewPage extends StatelessWidget {
  const MyNewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Page')),
      body: Container(),
    );
  }
}
```

### 2. Add New Model

```bash
# Location
features/[feature]/data/models/my_model.dart

# Don't forget to export in barrel file!
# features/[feature]/[feature].dart
export 'data/models/my_model.dart';
```

### 3. Add New Provider

```bash
# Location
features/[feature]/providers/my_provider.dart

# Register in main.dart
ChangeNotifierProvider(create: (_) => MyProvider()),
```

### 4. Add New Service

```bash
# Location
features/[feature]/data/services/my_service.dart

# OR for UI services
features/[feature]/presentation/services/my_service.dart
```

---

## 🚦 Import Decision Tree

```
Need to import something?
│
├─ From another feature?
│  └─ Use: import 'package:sun_pos/features/[name]/[name].dart';
│
├─ From same feature?
│  ├─ Same folder? → import 'my_file.dart';
│  ├─ Parent folder? → import '../my_file.dart';
│  └─ Sibling folder? → import '../../folder/my_file.dart';
│
├─ Core utility?
│  └─ Use: import 'package:sun_pos/core/core.dart';
│
└─ Shared widget?
   └─ Use: import 'package:sun_pos/shared/widgets/my_widget.dart';
```

---

## 🎨 Code Style Guide

### File Naming

```
✅ user_profile_page.dart      (snake_case)
❌ UserProfilePage.dart        (PascalCase)
❌ user-profile-page.dart      (kebab-case)
```

### Class Naming

```dart
✅ class UserProfilePage extends StatelessWidget
❌ class userProfilePage extends StatelessWidget
❌ class user_profile_page extends StatelessWidget
```

### Import Ordering

```dart
// 1. Dart core
import 'dart:async';

// 2. Flutter
import 'package:flutter/material.dart';

// 3. External packages
import 'package:provider/provider.dart';

// 4. Feature barrel files
import 'package:sun_pos/features/products/products.dart';
import 'package:sun_pos/core/core.dart';

// 5. Relative imports (same feature)
import '../../providers/my_provider.dart';
import '../widgets/my_widget.dart';
```

---

## 🔧 Useful Commands

```bash
# Find all uses of a class
grep -r "ProductProvider" lib/

# Find imports from a feature
grep -r "features/products" lib/

# Flutter clean build
flutter clean && flutter pub get && flutter run

# Analyze code
flutter analyze

# Format code
dart format lib/

# Run tests
flutter test
```

---

## 📱 Main App Flow

```
main.dart
  ↓
MultiProvider setup (AuthProvider, ProductProvider, etc.)
  ↓
MaterialApp
  ↓
Router (app_router.dart)
  ↓
Auth Guard checks
  ↓
LoginPage OR DashboardPage
```

---

## 🏗️ Feature Template

Create new feature structure:

```bash
features/my_feature/
├── my_feature.dart              # Barrel file
├── data/
│   ├── models/
│   │   └── my_model.dart
│   └── services/
│       └── my_api_service.dart
├── providers/
│   └── my_provider.dart
└── presentation/
    ├── pages/
    │   └── my_page.dart
    └── widgets/
        └── my_widget.dart
```

---

## 💡 Pro Tips

1. **Use barrel files** - Import clean, maintain easy
2. **Follow the layers** - Don't skip architectural layers
3. **Keep features isolated** - Minimize cross-dependencies
4. **Provider for state** - Don't use global variables
5. **Comments are good** - Explain WHY, not WHAT

---

## 🆘 Troubleshooting

| Problem                | Solution                        |
| ---------------------- | ------------------------------- |
| "Undefined class"      | Add import or check barrel file |
| Import path too long   | Use barrel file instead         |
| Circular dependency    | Review dependency map           |
| Provider not found     | Check main.dart registration    |
| Hot reload not working | Try hot restart or full rebuild |

---

## 📚 Documentation Files

- `PROJECT_STRUCTURE_GUIDE.md` - Complete structure explanation
- `BARREL_FILES_USAGE_GUIDE.md` - How to use barrel files
- `FEATURE_DEPENDENCY_MAP.md` - Feature relationships
- `README.md` - Project overview

---

## 🎓 Learning Path for New Developers

1. Week 1: Read all docs + explore `auth` feature
2. Week 2: Understand `products` + `customers`
3. Week 3: Learn `sales` (POS system) - most complex
4. Week 4: Study `transactions` + `dashboard`
5. Week 5: Practice by adding small features

---

**Print this page and keep it handy! 📌**

Last Updated: Feb 6, 2026
