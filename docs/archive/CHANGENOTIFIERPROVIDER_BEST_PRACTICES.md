# ChangeNotifierProxyProvider Best Practices Implementation

## Pembelajaran dari Dokumentasi Resmi

Berdasarkan dokumentasi resmi `ChangeNotifierProxyProvider` di [pub.dev](https://pub.dev/documentation/provider/latest/provider/ChangeNotifierProxyProvider-class.html), telah dilakukan perbaikan implementasi untuk mengikuti best practices yang benar.

## Masalah dalam Implementasi Sebelumnya

### ❌ **Anti-Pattern: Creating New Instance in Update**

**Implementasi Lama (SALAH):**

```dart
ChangeNotifierProxyProvider<CartProvider, ProductDetailViewModel>(
  create: (context) => ProductDetailViewModel(...),
  update: (context, cartProvider, previous) {
    // ❌ MASALAH: Membuat instance baru setiap kali update
    // Ini menyebabkan state hilang dan overhead tidak perlu
    return ProductDetailViewModel(
      productId: productId,
      apiService: ProductApiService(),
      cartProvider: cartProvider,
    );
  },
)
```

**Dampak Negatif:**

- ✗ State akan hilang setiap kali `CartProvider` berubah
- ✗ Overhead karena dispose provider lama dan subscribe ke yang baru
- ✗ Performance buruk karena recreate ViewModel berulang kali
- ✗ Memory leak potential karena dispose tidak proper

## Implementasi yang Benar (Sesuai Dokumentasi)

### ✅ **Best Practice: Reuse Instance and Update Properties**

**Implementasi Baru (BENAR):**

```dart
ChangeNotifierProxyProvider<CartProvider, ProductDetailViewModel>(
  create: (_) => ProductDetailViewModel(
    productId: productId,
    apiService: ProductApiService(),
  ),
  update: (_, cartProvider, viewModel) {
    // ✅ BENAR: Reuse instance yang sudah ada
    if (viewModel != null) {
      viewModel.updateCartProvider(cartProvider);
      viewModel.updateProductId(productId);
      return viewModel; // Return instance yang sama
    }

    // Fallback jika viewModel null
    return ProductDetailViewModel(
      productId: productId,
      apiService: ProductApiService(),
    )..updateCartProvider(cartProvider);
  },
)
```

## Perubahan pada ViewModel

### **Sebelum (Constructor-based Dependencies):**

```dart
class ProductDetailViewModel extends ChangeNotifier {
  final CartProvider _cartProvider; // ❌ Final dependency
  final int productId;               // ❌ Final product ID

  ProductDetailViewModel({
    required this.productId,
    required CartProvider cartProvider, // ❌ Required in constructor
  }) : _cartProvider = cartProvider;
}
```

### **Sesudah (Update-based Dependencies):**

```dart
class ProductDetailViewModel extends ChangeNotifier {
  CartProvider? _cartProvider;  // ✅ Mutable dependency
  int _productId;              // ✅ Mutable product ID

  ProductDetailViewModel({
    required int productId,
    // ✅ CartProvider tidak required di constructor
  }) : _productId = productId;

  /// ✅ Update method sesuai dokumentasi
  void updateCartProvider(CartProvider cartProvider) {
    if (_cartProvider != cartProvider) {
      _cartProvider = cartProvider;
    }
  }

  /// ✅ Support untuk update product ID (reuse ViewModel)
  void updateProductId(int newProductId) {
    if (_productId != newProductId) {
      _productId = newProductId;
      // Reset state untuk product baru
      _resetStateForNewProduct();
      loadProductDetail();
    }
  }
}
```

## Keuntungan Implementasi Baru

### 1. **State Preservation**

- ✅ State ViewModel dipertahankan ketika `CartProvider` berubah
- ✅ User input (quantity, selected variant) tidak hilang
- ✅ Loading state tetap konsisten

### 2. **Performance Optimization**

- ✅ Tidak ada instance creation berulang kali
- ✅ Tidak ada dispose/subscribe overhead
- ✅ Memory usage lebih efisien

### 3. **Flexibility & Reusability**

- ✅ ViewModel bisa digunakan untuk product ID berbeda
- ✅ Dependencies bisa diupdate tanpa recreate instance
- ✅ Easier testing karena dependencies injectable

### 4. **Proper Resource Management**

- ✅ Proper disposal lifecycle
- ✅ No memory leaks
- ✅ Clean state transitions

## Pattern yang Dipelajari dari Dokumentasi

### **DON'T: Create in Update**

```dart
// ❌ Jangan lakukan ini
update: (_, dependency, previous) => MyNotifier(dependency: dependency),
```

### **DO: Reuse and Update**

```dart
// ✅ Lakukan ini
update: (_, dependency, previous) => previous?..updateDependency(dependency),
```

### **ViewModel Pattern yang Benar:**

```dart
class MyNotifier with ChangeNotifier {
  Dependency? _dependency;

  // ✅ Update method instead of constructor injection
  void updateDependency(Dependency dependency) {
    if (_dependency != dependency) {
      _dependency = dependency;
      // Update logic here, may call notifyListeners if needed
    }
  }
}
```

## Real-World Example Implementation

### **Use Case: Product Detail dengan Cart Integration**

**Skenario:**

1. User membuka product detail page
2. User menambah/kurang quantity
3. CartProvider berubah (dari page lain)
4. User quantity input harus tetap preserved

**Dengan Pattern Lama:**

- ❌ Quantity reset ke 1 ketika CartProvider berubah
- ❌ Selected variant reset ke default
- ❌ Loading state mungkin flicker

**Dengan Pattern Baru:**

- ✅ Quantity tetap preserved
- ✅ Selected variant tetap preserved
- ✅ Smooth state transitions

## Testing Benefits

### **Easier Unit Testing:**

```dart
test('should preserve state when cart provider changes', () {
  final viewModel = ProductDetailViewModel(productId: 1);
  viewModel.updateQuantity(5);

  final newCartProvider = MockCartProvider();
  viewModel.updateCartProvider(newCartProvider);

  // ✅ State should be preserved
  expect(viewModel.quantity, equals(5));
});
```

## Migration Checklist

Untuk mengimplementasikan pattern ini di provider lain:

- [ ] **Remove final dependencies** dari constructor
- [ ] **Add update methods** untuk setiap dependency
- [ ] **Update ChangeNotifierProxyProvider** untuk reuse instance
- [ ] **Add null safety checks** untuk optional dependencies
- [ ] **Test state preservation** saat dependencies berubah
- [ ] **Verify memory management** dan proper disposal

## Kesimpulan

Implementasi baru mengikuti best practices dari dokumentasi resmi `ChangeNotifierProxyProvider`:

1. **✅ Reuse Instance**: Tidak membuat instance baru di `update`
2. **✅ Update Properties**: Menggunakan update methods untuk dependencies
3. **✅ State Preservation**: Mempertahankan state saat dependencies berubah
4. **✅ Performance**: Menghindari overhead creation/disposal
5. **✅ Clean Architecture**: Separation of concerns yang lebih baik

Pattern ini sekarang menjadi referensi untuk implementasi `ChangeNotifierProxyProvider` yang benar di seluruh aplikasi.
