# 📜 Infinite Loading Implementation for Products

## 📋 Overview

Implementasi lazy loading / infinite scroll pada products page untuk meningkatkan performa dan user experience dengan memuat data secara bertahap.

## 🔄 Changes Made

### 1. **ProductProvider** (`product_provider.dart`)

#### A. New State Variables:

```dart
bool _isLoadingMore = false;  // Loading state untuk pagination
int _currentPage = 1;         // Current page
int _totalPages = 1;          // Total pages dari API
bool _hasMore = true;         // Ada data lagi atau tidak
```

#### B. Updated \_loadProductsFromApi:

```dart
Future<void> _loadProductsFromApi({
  int? categoryId,
  int page = 1,       // ← Support page parameter
  bool append = false, // ← Support append mode
}) async {
  // Set loading state berdasarkan mode
  if (append) {
    _isLoadingMore = true;  // Loading more indicator
  } else {
    _isLoading = true;      // Initial loading
  }

  // API call dengan pagination
  final response = await _apiService.getProducts(
    customerId: _customerId!,
    page: page,           // ← Page number
    perPage: 20,          // ← 20 items per page (was 100)
    activeOnly: true,
    categoryId: categoryId ?? _selectedCategoryId,
  );

  // Update pagination meta from response
  _currentPage = response.data.meta.currentPage;
  _totalPages = response.data.meta.lastPage;
  _hasMore = _currentPage < _totalPages;

  // Append or replace products
  if (append) {
    _products.addAll(newProducts);  // ← Append untuk infinite scroll
  } else {
    _products.clear();
    _products.addAll(newProducts);   // ← Replace untuk initial/refresh
  }
}
```

#### C. New Method - loadMoreProducts:

```dart
Future<void> loadMoreProducts() async {
  // Guard: Don't load if already loading or no more data
  if (_isLoadingMore || !_hasMore) {
    return;
  }

  final nextPage = _currentPage + 1;
  await _loadProductsFromApi(
    categoryId: _selectedCategoryId,
    page: nextPage,
    append: true,  // ← Append mode untuk infinite scroll
  );
}
```

#### D. Reset Pagination on Filter Change:

```dart
// filterByCategory, clearSearch, refreshProducts
_currentPage = 1;  // Reset ke page 1
await _loadProductsFromApi(page: 1);
```

---

### 2. **ProductGrid** (`product_grid.dart`)

#### A. Convert to StatefulWidget:

```dart
// BEFORE: StatelessWidget
class ProductGrid extends StatelessWidget { ... }

// AFTER: StatefulWidget with ScrollController
class ProductGrid extends StatefulWidget { ... }
class _ProductGridState extends State<ProductGrid> {
  final ScrollController _scrollController = ScrollController();
}
```

#### B. Add Scroll Listener:

```dart
@override
void initState() {
  super.initState();
  _scrollController.addListener(_onScroll);
}

void _onScroll() {
  // Trigger load more when 200px from bottom
  if (_scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent - 200) {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    productProvider.loadMoreProducts();
  }
}

@override
void dispose() {
  _scrollController.dispose();
  super.dispose();
}
```

#### C. Updated GridView with Loading Indicator:

```dart
return GridView.builder(
  controller: _scrollController,  // ← Attach scroll controller
  itemCount: products.length + (productProvider.isLoadingMore ? 1 : 0),
  itemBuilder: (context, index) {
    // Show loading indicator at the end
    if (index == products.length) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final product = products[index];
    return ProductCard(product: product, ...);
  },
);
```

---

## 📊 Flow Diagram

### Initial Load:

```
Customer selected
    ↓
productProvider.setCustomerId(5)
    ↓
_loadProductsFromApi(page: 1, append: false)
    ↓
API: GET /products?customer_id=5&page=1&per_page=20
    ↓
_products = [Product 1-20]
_currentPage = 1
_totalPages = 5
_hasMore = true
    ↓
UI shows 20 products
```

### Infinite Scroll:

```
User scrolls down
    ↓
_onScroll() detects near bottom (200px threshold)
    ↓
productProvider.loadMoreProducts()
    ↓
Check: !_isLoadingMore && _hasMore ✅
    ↓
_loadProductsFromApi(page: 2, append: true)
    ↓
API: GET /products?customer_id=5&page=2&per_page=20
    ↓
_products.addAll([Product 21-40])  // Append
_currentPage = 2
_hasMore = true
    ↓
UI shows 40 products + loading indicator removed
```

---

## 🎯 Key Features

### ✅ Lazy Loading

- Load 20 products per page (was 100 all at once)
- Reduces initial load time
- Better memory management

### ✅ Infinite Scroll

- Auto-load more when scrolling near bottom (200px threshold)
- Smooth UX without pagination buttons
- Loading indicator at bottom during fetch

### ✅ Smart Loading States

- `_isLoading`: Initial/refresh loading (full screen)
- `_isLoadingMore`: Pagination loading (bottom indicator)
- Prevents duplicate requests

### ✅ Pagination Reset

- Reset to page 1 when:
  - Filter by category changes
  - Search cleared
  - Products refreshed

### ✅ End Detection

- `_hasMore` flag prevents unnecessary API calls
- `_currentPage < _totalPages` check from API meta

---

## 🔍 API Response Meta

```json
{
  "status": "success",
  "data": {
    "data": [...],
    "meta": {
      "current_page": 1,
      "last_page": 5,      // ← Used for _totalPages
      "per_page": 20,
      "total": 95
    }
  }
}
```

**Usage:**

```dart
_currentPage = response.data.meta.currentPage;
_totalPages = response.data.meta.lastPage;
_hasMore = _currentPage < _totalPages;  // 1 < 5 = true
```

---

## 🎨 UI States

### 1. Initial Loading:

```
┌─────────────────────┐
│  CircularProgress   │  ← Full screen loader
│     Indicator       │     (_isLoading = true)
└─────────────────────┘
```

### 2. Products Loaded:

```
┌─────────────────────┐
│ [Product 1-20]      │  ← GridView with products
│                     │
│  [Scroll down...]   │
└─────────────────────┘
```

### 3. Loading More:

```
┌─────────────────────┐
│ [Product 1-20]      │  ← Existing products
│                     │
│  ┌──────────────┐   │
│  │ ○ Loading... │   │  ← Bottom indicator
│  └──────────────┘   │     (_isLoadingMore = true)
└─────────────────────┘
```

### 4. All Loaded:

```
┌─────────────────────┐
│ [Product 1-95]      │  ← All products loaded
│                     │     (_hasMore = false)
│  [End of list]      │     No more loading
└─────────────────────┘
```

---

## 🚀 Performance Benefits

| Before                    | After                  |
| ------------------------- | ---------------------- |
| Load 100 products at once | Load 20 per page       |
| Heavy initial load        | Fast initial load      |
| Large memory footprint    | Efficient memory use   |
| Single API call           | Multiple smaller calls |
| No loading feedback       | Clear loading states   |

---

## ✅ Status: COMPLETE

- ✅ Pagination state management
- ✅ Infinite scroll detection
- ✅ Loading indicators (initial + more)
- ✅ Append mode for new data
- ✅ Reset pagination on filter change
- ✅ End of data detection
- ✅ No errors detected
