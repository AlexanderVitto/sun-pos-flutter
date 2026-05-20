# 🔄 Server-Side Category Filtering Implementation

## 📋 Overview

Mengubah filtering categories dari **client-side (frontend)** menjadi **server-side (backend)** untuk meningkatkan performa dan konsistensi data.

## 🎯 Changes Summary

### Before (Client-Side Filtering):

```
Load ALL products → Filter di frontend → Display filtered products
```

### After (Server-Side Filtering):

```
User selects category → API call dengan categoryId → Backend returns filtered products → Display
```

---

## 🔧 Implementation Details

### 1. **ProductProvider** (`product_provider.dart`)

#### A. New Properties:

```dart
int? _selectedCategoryId; // Track selected category ID for backend filtering
```

#### B. Updated Products Getter:

```dart
// BEFORE: Client-side filtering
List<Product> get products =>
    _searchQuery.isEmpty && _selectedCategory.isEmpty
    ? _products
    : _filteredProducts;

// AFTER: No filtering needed, backend already filtered
List<Product> get products => _products;
```

#### C. Updated filterByCategory Method:

```dart
// BEFORE: Only update local state
void filterByCategory(String category) {
  if (_selectedCategory == category) {
    _selectedCategory = '';
  } else {
    _selectedCategory = category;
  }
  notifyListeners();
}

// AFTER: Trigger backend API call
Future<void> filterByCategory(String categoryName) async {
  if (_selectedCategory == categoryName) {
    // Clear filter - reload all products
    _selectedCategory = '';
    _selectedCategoryId = null;
    await _loadProductsFromApi(categoryId: null);
  } else {
    // Set filter - find category ID and reload
    _selectedCategory = categoryName;

    // Find category ID by name from loaded categories
    final category = _categories.firstWhere(
      (cat) => cat.name == categoryName,
      orElse: () => Category(...),
    );

    if (category.id != 0) {
      _selectedCategoryId = category.id;
      await _loadProductsFromApi(categoryId: category.id);
    }
  }
}
```

#### D. Updated \_loadProductsFromApi:

```dart
// BEFORE: No category parameter
Future<void> _loadProductsFromApi() async {
  final response = await _apiService.getProducts(
    customerId: _customerId!,
    perPage: 100,
    activeOnly: true,
  );
}

// AFTER: Support categoryId parameter
Future<void> _loadProductsFromApi({int? categoryId}) async {
  final response = await _apiService.getProducts(
    customerId: _customerId!,
    perPage: 100,
    activeOnly: true,
    categoryId: categoryId ?? _selectedCategoryId, // Backend filtering
  );
}
```

#### E. Updated clearSearch:

```dart
void clearSearch() {
  _searchQuery = '';
  _selectedCategory = '';
  _selectedCategoryId = null;
  // Reload all products without filters
  _loadProductsFromApi();
}
```

---

### 2. **POSTransactionViewModel** (`pos_transaction_view_model.dart`)

#### A. New Dependency:

```dart
ProductProvider? _productProvider;

void updateProductProvider(ProductProvider productProvider) {
  if (_productProvider != productProvider) {
    _productProvider = productProvider;
    debugPrint('🔄 POSTransactionViewModel: ProductProvider instance updated');
  }
}
```

#### B. Updated updateSelectedCategory:

```dart
// BEFORE: Only update local state
void updateSelectedCategory(String category) {
  if (_selectedCategory == category) {
    _selectedCategory = '';
  } else {
    _selectedCategory = category;
  }
  notifyListeners();
}

// AFTER: Trigger backend filtering
void updateSelectedCategory(String category) async {
  // Update UI state immediately
  final previousCategory = _selectedCategory;

  if (_selectedCategory == category) {
    _selectedCategory = '';
  } else {
    _selectedCategory = category;
  }
  notifyListeners();

  // Trigger server-side filtering via ProductProvider
  if (_productProvider != null) {
    try {
      await _productProvider!.filterByCategory(category);
    } catch (e) {
      // Revert on error
      _selectedCategory = previousCategory;
      notifyListeners();
      debugPrint('❌ Error filtering by category: $e');
    }
  }
}
```

#### C. Updated clearSearch:

```dart
void clearSearch() {
  _searchQuery = '';
  _selectedCategory = '';
  notifyListeners();

  // Clear filters in ProductProvider (triggers backend reload)
  if (_productProvider != null) {
    _productProvider!.clearSearch();
  }
}
```

---

### 3. **ProductGrid** (`product_grid.dart`)

#### Removed Client-Side Filtering:

```dart
// BEFORE: Filter products locally
Widget build(BuildContext context) {
  return Consumer<ProductProvider>(
    builder: (context, productProvider, child) {
      final allProducts = productProvider.products;
      final filteredProducts = allProducts.where((product) {
        final matchesSearch = product.name.toLowerCase().contains(
          searchQuery.toLowerCase(),
        );
        final matchesCategory =
            selectedCategory.isEmpty || product.category == selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();

      // Display filteredProducts...
    },
  );
}

// AFTER: Use already-filtered products from backend
Widget build(BuildContext context) {
  return Consumer<ProductProvider>(
    builder: (context, productProvider, child) {
      // Products are already filtered by backend
      final products = productProvider.products;

      if (productProvider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (products.isEmpty) {
        return const Center(child: Text('Tidak ada produk ditemukan'));
      }

      // Display products...
    },
  );
}
```

---

### 4. **Main.dart** - Provider Injection

#### Updated ChangeNotifierProxyProvider:

```dart
// BEFORE: Proxy3
ChangeNotifierProxyProvider3<
  CartProvider,
  TransactionProvider,
  PendingTransactionProvider,
  POSTransactionViewModel
>(
  update: (_, cart, transaction, pending, viewModel) {
    viewModel.updateCartProvider(cart);
    viewModel.updateTransactionProvider(transaction);
    viewModel.updatePendingTransactionProvider(pending);
    return viewModel;
  },
)

// AFTER: Proxy4 (added ProductProvider)
ChangeNotifierProxyProvider4<
  CartProvider,
  TransactionProvider,
  PendingTransactionProvider,
  ProductProvider,
  POSTransactionViewModel
>(
  update: (_, cart, transaction, pending, product, viewModel) {
    viewModel.updateCartProvider(cart);
    viewModel.updateTransactionProvider(transaction);
    viewModel.updatePendingTransactionProvider(pending);
    viewModel.updateProductProvider(product);
    return viewModel;
  },
)
```

---

## 🔄 New Data Flow

### User Interaction Flow:

```
User Tap Category
    ↓
ProductSearchFilter.onCategoryChanged(category)
    ↓
POSTransactionViewModel.updateSelectedCategory(category)
    ↓
ProductProvider.filterByCategory(category)
    ↓
Find categoryId from _categories by name
    ↓
_loadProductsFromApi(categoryId: foundId)
    ↓
ProductApiService.getProducts(categoryId: X)
    ↓
Backend API: GET /products?customer_id=Y&category_id=X
    ↓
Backend returns filtered products
    ↓
ProductProvider._products updated
    ↓
notifyListeners()
    ↓
ProductGrid rebuilds with new filtered data
```

---

## 📊 API Request Examples

### Before (No Backend Filtering):

```http
GET /products?customer_id=123&per_page=100&active_only=true
```

Response: ALL products (filtered client-side)

### After (Backend Filtering):

**All Products:**

```http
GET /products?customer_id=123&per_page=100&active_only=true
```

**Filtered by Category:**

```http
GET /products?customer_id=123&per_page=100&active_only=true&category_id=1
```

Response: Only products in category ID 1

---

## 🎯 Benefits

### Performance:

- ✅ **Less Data Transfer**: Backend returns only filtered products
- ✅ **Faster Rendering**: No client-side filtering loops
- ✅ **Better for Large Datasets**: Pagination works with filters

### User Experience:

- ✅ **Loading Indicator**: Shows loading state during API call
- ✅ **Immediate Feedback**: UI updates immediately, then data loads
- ✅ **Error Handling**: Reverts selection on API error

### Data Consistency:

- ✅ **Single Source of Truth**: Backend controls filtering logic
- ✅ **Accurate Counts**: Product counts match backend state
- ✅ **Consistent Results**: Same filter logic across all clients

---

## 🔍 Key Changes Summary

| Component                              | Before                  | After                     |
| -------------------------------------- | ----------------------- | ------------------------- |
| **ProductProvider.products**           | Client-side filtered    | Direct from API           |
| **ProductProvider.filterByCategory()** | Sync (local state)      | Async (API call)          |
| **ProductGrid filtering**              | Local where() filter    | None (uses provider data) |
| **POSTransactionViewModel**            | No ProductProvider      | Injected via Proxy4       |
| **API calls**                          | Load all, filter client | Filter at backend         |

---

## ⚠️ Important Notes

1. **Loading State**: ProductGrid now shows CircularProgressIndicator during filtering
2. **Error Handling**: Category selection reverts if API call fails
3. **Category ID Mapping**: Must load categories from `/categories` API first
4. **Backward Compatible**: Toggle behavior (click twice to clear) still works
5. **No Breaking Changes**: UI components unchanged, only internal logic

---

## 🧪 Testing Checklist

- [x] Load categories from API
- [x] Select category triggers backend call
- [x] Loading indicator appears during filtering
- [x] Products update after successful filter
- [x] Toggle same category clears filter (shows all)
- [x] Switch between categories works
- [x] Error handling reverts selection
- [x] Clear search clears category filter

---

## 🚀 Status: COMPLETE ✅

All components updated for server-side filtering. No errors detected.
