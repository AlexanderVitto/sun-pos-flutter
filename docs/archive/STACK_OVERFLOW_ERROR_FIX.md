# StackOverflowError Fix - Build Issue Resolution

## Issue

The Flutter build was failing with:

```
FAILURE: Build failed with an exception.
* What went wrong:
java.lang.StackOverflowError (no error message)
```

## Root Cause

The `ProductDetailViewModel` was configured as a **global provider** in `main.dart` with a default `productId: 0`. This created a circular dependency or infinite recursion during the provider initialization phase.

### Problems with the Original Implementation:

1. **Global Provider Scope**: `ProductDetailViewModel` was registered in `MultiProvider` at the app level
2. **Invalid Default State**: Using `productId: 0` as a default didn't make sense semantically
3. **Lifecycle Mismatch**: Product detail view models should be scoped to individual product detail pages, not globally
4. **Potential Circular Dependencies**: The global provider dependency tree was causing initialization issues

## Solution

### 1. Removed Global Provider Registration

**File**: `lib/main.dart`

**Removed:**

```dart
ChangeNotifierProxyProvider<CartProvider, ProductDetailViewModel>(
  create: (_) => ProductDetailViewModel(
    productId: 0, // Invalid default
    apiService: ProductApiService(),
  ),
  update: (_, cartProvider, viewModel) {
    if (viewModel != null) {
      viewModel.updateCartProvider(cartProvider);
      return viewModel;
    }
    return ProductDetailViewModel(
      productId: 0,
      apiService: ProductApiService(),
    )..updateCartProvider(cartProvider);
  },
),
```

**Also removed unused imports:**

- `features/products/presentation/viewmodels/product_detail_viewmodel.dart`
- `features/products/data/services/product_api_service.dart`

### 2. Created Local Provider Instance

**File**: `lib/features/products/presentation/pages/product_detail_page.dart`

**Changed from:**

```dart
return Consumer<ProductDetailViewModel>(
  builder: (context, viewModel, child) {
    if (viewModel.productId != productId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.updateProductId(productId);
      });
    }
    return _ProductDetailView(viewModel: viewModel, productId: productId);
  },
);
```

**Changed to:**

```dart
return ChangeNotifierProxyProvider<CartProvider, ProductDetailViewModel>(
  create: (_) => ProductDetailViewModel(
    productId: productId,  // ✅ Correct productId from constructor
    apiService: ProductApiService(),
  ),
  update: (_, cartProvider, viewModel) {
    if (viewModel != null) {
      viewModel.updateCartProvider(cartProvider);

      // Update productId if different
      if (viewModel.productId != productId) {
        viewModel.updateProductId(productId);
      }

      return viewModel;
    }

    return ProductDetailViewModel(
      productId: productId,
      apiService: ProductApiService(),
    )..updateCartProvider(cartProvider);
  },
  child: Consumer<ProductDetailViewModel>(
    builder: (context, viewModel, child) {
      return _ProductDetailView(viewModel: viewModel, productId: productId);
    },
  ),
);
```

## Benefits of This Approach

1. **Proper Scoping**: Each `ProductDetailPage` instance creates its own `ProductDetailViewModel`
2. **Correct Initialization**: The view model is initialized with the actual `productId` from the page
3. **No Circular Dependencies**: Eliminates the global provider dependency that caused StackOverflowError
4. **Better Resource Management**: View models are disposed when the page is disposed
5. **CartProvider Integration**: Still maintains reactive connection to `CartProvider` through `ChangeNotifierProxyProvider`

## Verification

Build completed successfully:

```bash
flutter build apk --debug
✓ Built build/app/outputs/flutter-apk/app-debug.apk (99.5s)
```

## Related Files Modified

1. `/lib/main.dart` - Removed global ProductDetailViewModel provider
2. `/lib/features/products/presentation/pages/product_detail_page.dart` - Added local provider

## Best Practice Recommendation

**When to use global providers:**

- Providers that maintain app-wide state (Auth, Cart, Settings, etc.)
- Services that should be singletons

**When to use local providers:**

- View models specific to a single page/screen
- Providers that depend on dynamic parameters (like productId)
- Short-lived state that should be disposed with the page

## Date

October 5, 2025
