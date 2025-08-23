# Transaction List Feature - Quick Start Guide

## 🚀 Quick Start

### 1. Run the Demo

```bash
# Simple version (recommended for testing)
flutter run -d macos -t lib/simple_transaction_list_demo.dart

# Full featured version
flutter run -d macos -t lib/transaction_list_demo.dart
```

### 2. Integration Example

```dart
// Add to your app's providers
MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (context) => TransactionListProvider(),
    ),
    // ... your other providers
  ],
  child: MaterialApp(
    home: TransactionListPage(), // or SimpleTransactionListPage()
  ),
)
```

## 🎯 Features Overview

### ✅ What's Working

- ✅ **API Integration** - Connects to `/api/v1/transactions` endpoint
- ✅ **Search** - Search by transaction number
- ✅ **Filters** - Date range, amount, payment method, status
- ✅ **Pagination** - Infinite scroll + pull-to-refresh
- ✅ **UI/UX** - Clean cards, loading states, error handling
- ✅ **Details** - Transaction detail popup
- ✅ **Authentication** - Bearer token integration

### 🎨 UI Components

- **Transaction Cards** with status badges
- **Search Bar** with real-time filtering
- **Quick Filter Chips** (Today, This Week, This Month)
- **Advanced Filter Dialog**
- **Loading States & Error Messages**
- **Pagination Info**

### 🔧 API Parameters Supported

All parameters from your endpoint example:

- `per_page=10`
- `search=TRX`
- `store_id=1`
- `user_id=1`
- `date_from=2025-08-01`
- `date_to=2025-08-31`
- `min_amount=10000`
- `max_amount=100000`
- `sort_by=created_at`
- `sort_direction=desc`

## 📱 Usage Instructions

### Basic Usage

1. **Launch app** - Run one of the demo files
2. **View transactions** - List loads automatically
3. **Search** - Type transaction number in search bar
4. **Filter** - Use quick filter chips or FAB for advanced filters
5. **Details** - Tap any transaction card for details
6. **Refresh** - Pull down to refresh or use refresh FAB

### Filter Options

- **Quick Filters**: Today, This Week, This Month, Reset
- **Advanced Filters**:
  - Date Range Picker
  - Amount Range (Min/Max)
  - Payment Method Dropdown
  - Status Selection
  - Apply/Reset buttons

### Test Actions (Simple Demo)

- **Refresh Data** - Reload transactions
- **Filter Today** - Show today's transactions
- **Filter Month** - Show current month transactions
- **Clear Filters** - Reset all filters

## 🐛 Troubleshooting

### Common Issues

1. **Build Error: AppColors not found**

   ```
   Solution: Ensure app_colors.dart is created in lib/core/constants/
   ```

2. **Build Error: CustomAppBar not found**

   ```
   Solution: Ensure custom_app_bar.dart is created in lib/shared/widgets/
   ```

3. **Network Error**

   ```
   - Check API endpoint URL in TransactionApiService
   - Verify authentication token
   - Check internet connection
   ```

4. **Empty List**
   ```
   - Check API response format
   - Verify filter parameters
   - Check authentication
   ```

### Debug Steps

1. Check console for API errors
2. Verify token in SecureStorage
3. Test API endpoint manually
4. Check model parsing

## 📄 Files Structure

```
lib/
├── features/transactions/
│   ├── data/models/transaction_list_response.dart
│   ├── providers/transaction_list_provider.dart
│   ├── presentation/pages/transaction_list_page.dart
│   └── data/services/transaction_api_service.dart (updated)
├── core/constants/app_colors.dart
├── shared/widgets/custom_app_bar.dart
├── transaction_list_demo.dart
└── simple_transaction_list_demo.dart
```

## 🔄 Integration with Existing App

### Step 1: Add Provider

```dart
// In your main.dart or app setup
ChangeNotifierProvider(
  create: (context) => TransactionListProvider(),
),
```

### Step 2: Navigation

```dart
// Navigate to transaction list
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => TransactionListPage(),
  ),
);
```

### Step 3: Customize (Optional)

```dart
// Custom default filters
final provider = TransactionListProvider();
provider.setStoreId(yourStoreId);
provider.setUserId(yourUserId);
```

## 🎛 Configuration

### API Configuration

```dart
// In TransactionApiService
static const String baseUrl = 'https://sfpos.app/api/v1'; // Your API base URL
```

### Default Settings

```dart
// In TransactionListProvider
int _storeId = 1; // Your default store
int _userId = 1;  // Your default user
int _perPage = 10; // Items per page
```

## 📞 Support

If you encounter any issues:

1. Check the `TRANSACTION_LIST_FEATURE.md` for detailed documentation
2. Review console logs for error messages
3. Verify API endpoint and authentication
4. Test with simple_transaction_list_demo.dart first

## 🎉 Ready to Use!

The transaction list feature is now ready for integration into your Sun POS application. Start with the simple demo to test basic functionality, then move to the full-featured version for production use.
