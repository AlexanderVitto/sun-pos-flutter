# POS Tablet Layout Documentation

## Overview

Versi tablet dari aplikasi POS dengan layout side-by-side yang menampilkan keranjang di sebelah kanan list products.

## Features

### Responsive Design

- **Detection**: Menggunakan `MediaQuery.of(context).size.width >= 768` untuk mendeteksi tablet
- **Mobile Layout**: Layout vertikal tradisional dengan cart bottom sheet
- **Tablet Layout**: Layout horizontal dengan cart sidebar

### Layout Components

#### Mobile Layout (`_buildMobileLayout()`)

- Search bar dan filter kategori di atas
- Product grid dengan 2 kolom
- Cart dapat diakses melalui floating action button
- Bottom navigation bar untuk total dan checkout

#### Tablet Layout (`_buildTabletLayout()`)

```dart
Row(
  children: [
    // Left side - Products (70% width)
    Expanded(flex: 7, child: ProductsSection()),

    // Right side - Cart (30% width)
    Expanded(flex: 3, child: CartSidebar()),
  ],
)
```

### Cart Sidebar (`_buildCartSidebar()`)

#### Features:

- **Real-time updates**: Menggunakan `AnimatedBuilder` dengan cached `CartProvider`
- **Header section**: Menampilkan jumlah item dan tombol clear cart
- **Empty state**: Icon dan message ketika cart kosong
- **Item management**:
  - Quantity controls (+/- buttons)
  - Remove item functionality
  - Stock validation
- **Total calculation**: Subtotal, tax, dan total akhir
- **Checkout button**: Full-width button untuk proses pembayaran

#### Cart Item Card:

```dart
Card(
  child: Column(
    children: [
      Text(item.product.name),           // Product name
      Text('Rp ${price}'),               // Price
      Row(
        children: [
          IconButton(Icons.remove),       // Decrease quantity
          Text('${item.quantity}'),       // Current quantity
          IconButton(Icons.add),          // Increase quantity
        ],
      ),
      Text('Rp ${subtotal}'),            // Line total
    ],
  ),
)
```

### Product Grid Enhancements

#### Tablet Optimizations:

- **3 columns** instead of 2 for better space utilization
- **Larger icons** dan better visual hierarchy
- **Responsive card sizing** maintains aspect ratio

## Technical Implementation

### State Management

- **CartProvider caching**: `_cartProvider` cached in `didChangeDependencies()`
- **AnimatedBuilder**: Direct provider listening untuk real-time updates
- **Debug logging**: Comprehensive logging untuk troubleshooting

### Key Methods:

```dart
Widget _buildTabletLayout()         // Main tablet layout
Widget _buildMobileLayout()         // Mobile layout
Widget _buildSearchAndFilter()      // Search & filter section
Widget _buildProductsGrid()         // Products grid with configurable columns
Widget _buildCartSidebar()          // Cart sidebar untuk tablet
Widget _buildBottomNavigationBar()  // Bottom nav untuk mobile
```

### Provider Integration:

```dart
// Cached provider instance
CartProvider? _cartProvider;

@override
void didChangeDependencies() {
  if (_cartProvider == null) {
    _cartProvider = Provider.of<CartProvider>(context, listen: false);
    _cartProvider!.addListener(() {
      if (mounted) setState(() {});
    });
  }
}

// AnimatedBuilder untuk real-time updates
AnimatedBuilder(
  animation: _cartProvider!,
  builder: (context, child) {
    return CartContent();
  },
)
```

## Benefits

### User Experience

- **Always visible cart**: Tablet users can see cart contents tanpa perlu membuka modal
- **Faster checkout**: Direct access ke cart controls
- **Better workflow**: Add items → immediate visual feedback di sidebar
- **Space utilization**: Efficient use of tablet screen real estate

### Performance

- **Single provider instance**: Cached provider prevents context issues
- **Efficient rebuilds**: AnimatedBuilder hanya rebuild yang diperlukan
- **Responsive design**: Automatic adaptation berdasarkan screen size

## Usage

### Running Tablet Demo:

```bash
flutter run lib/tablet_pos_demo.dart --hot
```

### Integration:

```dart
// Auto-detects dan switches layout
final screenWidth = MediaQuery.of(context).size.width;
final isTablet = screenWidth >= 768;

return Scaffold(
  body: isTablet ? _buildTabletLayout() : _buildMobileLayout(),
);
```

## File Structure

```
lib/
├── features/sales/presentation/pages/
│   ├── pos_transaction_page_tablet.dart    # Main tablet-optimized page
│   └── pos_transaction_page.dart           # Original mobile page
└── tablet_pos_demo.dart                    # Demo app for testing
```

## Future Enhancements

- Drag & drop functionality untuk cart items
- Multi-column cart untuk larger tablets
- Keyboard shortcuts untuk power users
- Split payment methods dalam sidebar
- Customer selection dalam cart header
