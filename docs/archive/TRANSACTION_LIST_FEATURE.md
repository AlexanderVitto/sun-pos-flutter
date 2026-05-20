# Transaction List Feature Documentation

## Overview

Fitur ini menampilkan daftar transaksi dengan dukungan pencarian, filter, dan pagination. Data diambil dari endpoint API `/api/v1/transactions` dengan berbagai parameter filter yang dapat dikustomisasi.

## Features

### 1. Transaction List Display

- Menampilkan daftar transaksi dengan informasi lengkap
- Format mata uang Indonesia (Rupiah)
- Status badge dengan warna yang berbeda
- Payment method indicator
- Transaction details count

### 2. Search & Filter

- Search by transaction number
- Quick filters: Hari Ini, Minggu Ini, Bulan Ini
- Advanced filters dialog:
  - Date range picker
  - Amount range (min/max)
  - Payment method filter
  - Status filter
- Reset filters functionality

### 3. Pagination & Loading

- Infinite scroll dengan automatic loading
- Pull-to-refresh functionality
- Loading indicators untuk UX yang baik
- Page information display

### 4. Transaction Details

- Detail popup dengan informasi lengkap
- User information (cashier)
- Store information
- Customer information (jika ada)
- Notes (jika ada)

## API Integration

### Endpoint

```
GET {{base_url}}/api/v1/transactions
```

### Supported Parameters

- `per_page`: Items per page (default: 10)
- `search`: Search by transaction number
- `store_id`: Filter by store ID
- `user_id`: Filter by user ID
- `date_from`: Start date (YYYY-MM-DD)
- `date_to`: End date (YYYY-MM-DD)
- `min_amount`: Minimum amount filter
- `max_amount`: Maximum amount filter
- `sort_by`: Sort field (default: created_at)
- `sort_direction`: Sort direction (asc/desc, default: desc)
- `payment_method`: Filter by payment method
- `status`: Filter by status

### Response Structure

```json
{
    "status": "success",
    "message": "Transactions retrieved successfully",
    "data": {
        "data": [...],
        "links": {...},
        "meta": {...}
    }
}
```

## File Structure

```
lib/features/transactions/
├── data/
│   ├── models/
│   │   ├── transaction_list_response.dart     # Response models
│   │   ├── create_transaction_response.dart   # Existing models
│   │   └── ...
│   └── services/
│       └── transaction_api_service.dart       # Updated API service
├── providers/
│   └── transaction_list_provider.dart         # State management
└── presentation/
    └── pages/
        └── transaction_list_page.dart         # Main page UI
```

## Key Components

### 1. TransactionListProvider

State management untuk transaction list dengan fitur:

- Loading transactions dengan pagination
- Filter management
- Search functionality
- Error handling
- Refresh capability

Key methods:

- `loadTransactions(refresh: bool)`
- `loadNextPage()`
- `refreshTransactions()`
- `setSearch(String?)`
- `setDateRange(String?, String?)`
- `setAmountRange(double?, double?)`
- `applyCurrentMonthFilter()`
- `applyTodayFilter()`
- `clearFilters()`

### 2. TransactionListPage

Main UI dengan komponen:

- Search bar dengan real-time filtering
- Quick filter chips
- Transaction cards dengan informasi lengkap
- Infinite scroll list
- Advanced filters dialog
- Transaction details popup

### 3. TransactionListResponse Models

- `TransactionListResponse`: Root response model
- `TransactionListData`: Data container dengan pagination
- `TransactionListItem`: Individual transaction item
- `TransactionLinks`: Pagination links
- `TransactionMeta`: Pagination metadata

## Usage Examples

### Basic Usage

```dart
// Add provider to app
MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (context) => TransactionListProvider(),
    ),
  ],
  child: TransactionListPage(),
)
```

### Programmatic Filter

```dart
final provider = Provider.of<TransactionListProvider>(context, listen: false);

// Apply date filter
provider.setDateRange('2025-08-01', '2025-08-31');

// Apply amount filter
provider.setAmountRange(10000, 100000);

// Search by transaction number
provider.setSearch('TRX2025');

// Refresh with new filters
provider.refreshTransactions();
```

## UI/UX Features

### 1. Responsive Design

- Adaptif untuk berbagai ukuran layar
- Card-based layout yang clean
- Proper spacing dan padding

### 2. Loading States

- Skeleton loading untuk initial load
- Infinite scroll loading indicator
- Pull-to-refresh animation
- Error states dengan retry button

### 3. Visual Indicators

- Status badges dengan warna:
  - Completed: Green
  - Pending: Orange
  - Cancelled: Red
- Payment method chips:
  - Cash: Green
  - Card: Blue
  - Transfer: Purple
  - E-Wallet: Orange

### 4. User Interactions

- Tap transaction card untuk detail
- Long press untuk context menu (future)
- Swipe actions (future enhancement)

## Error Handling

- Network error handling dengan retry
- API error message display
- Validation error handling
- Empty state handling
- Graceful degradation

## Performance Optimization

- Lazy loading dengan pagination
- Efficient state management
- Image caching (jika ada)
- Memory management dengan proper dispose

## Testing

### Demo Usage

```dart
// Run demo app
flutter run -t lib/transaction_list_demo.dart
```

### Test Data

Default filter menggunakan:

- Store ID: 1
- User ID: 1
- Sort by: created_at desc
- Per page: 10

## Integration Points

### 1. Authentication

- Menggunakan SecureStorageService untuk token
- Automatic token handling
- 401 error handling

### 2. Navigation

- Dapat diintegrasikan dengan navigation drawer
- Deep linking support
- Back button handling

### 3. State Persistence

- Filter state dapat disimpan
- Scroll position restoration
- Search history (future)

## Customization Options

### 1. Styling

- Custom colors melalui AppColors
- Theme customization
- Card styling

### 2. Functionality

- Custom sort options
- Additional filter fields
- Export functionality (future)

### 3. Business Logic

- Custom validation rules
- Permission-based access
- Role-based filtering

## Future Enhancements

1. **Export Features**

   - PDF export
   - CSV export
   - Print functionality

2. **Advanced Filters**

   - Multiple store selection
   - Category-based filtering
   - Custom date presets

3. **Bulk Operations**

   - Bulk status update
   - Bulk export
   - Bulk actions

4. **Analytics**

   - Transaction trends
   - Performance metrics
   - Revenue insights

5. **Offline Support**
   - Local caching
   - Offline viewing
   - Sync when online

## Dependencies

- `flutter/material.dart`: UI framework
- `provider`: State management
- `http`: API calls
- `intl`: Date/number formatting
- Existing core services (SecureStorage, etc.)

## Performance Metrics

- Initial load: < 2 seconds
- Pagination load: < 500ms
- Search response: < 300ms
- Filter apply: Immediate
- Memory usage: Optimized with dispose

## Security Considerations

- Bearer token authentication
- HTTPS only communication
- No sensitive data caching
- Proper error message sanitization
- Rate limiting handling
