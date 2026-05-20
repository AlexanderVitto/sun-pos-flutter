# Refund Detail API Integration

## Overview

Implementasi pengambilan data detail refund dari API endpoint `/api/v1/refunds/{refund_id}` dan menampilkannya di RefundDetailPage.

## API Endpoint

### GET Refund Detail

```
GET {{base_url}}/api/v1/refunds/{refund_id}
```

### Response Structure

```json
{
  "status": "success",
  "message": "Refund retrieved successfully",
  "data": {
    "id": 1,
    "refund_number": "RFD20251010JWMZYZ",
    "transaction_id": 12,
    "customer_id": 3,
    "user_id": 1,
    "store_id": 1,
    "total_refund_amount": 100000,
    "refund_method": "cash_and_transfer",
    "cash_refund_amount": 100000,
    "transfer_refund_amount": 0,
    "status": "completed",
    "notes": "Partial refund for 1 out of 2 items",
    "refund_date": "2025-10-10T00:00:00.000000Z",
    "user": { ... },
    "store": { ... },
    "customer": { ... },
    "transaction": { ... },
    "details": [ ... ],
    "created_at": "2025-10-10T05:24:00.000000Z",
    "updated_at": "2025-10-10T05:24:00.000000Z"
  }
}
```

## Implementation

### 1. API Service

**File**: `lib/features/refunds/data/services/refund_api_service.dart`

Method sudah tersedia:

```dart
Future<Map<String, dynamic>> getRefundById(int id) async {
  try {
    final token = await _secureStorage.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('Access token not found');
    }

    final url = Uri.parse('$baseUrl/refunds/$id');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      throw Exception('401: Unauthorized access');
    } else if (response.statusCode == 404) {
      throw Exception('404: Refund not found');
    } else {
      throw Exception(
        'Failed to load refund: ${response.statusCode} - ${response.body}',
      );
    }
  } catch (e) {
    rethrow;
  }
}
```

### 2. Response Models

**File**: `lib/features/refunds/data/models/refund_detail_response.dart`

#### A. RefundDetailResponse (Root)

```dart
class RefundDetailResponse {
  final String status;
  final String message;
  final RefundDetailData data;

  factory RefundDetailResponse.fromJson(Map<String, dynamic> json) {
    return RefundDetailResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      data: RefundDetailData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}
```

#### B. RefundDetailData (Main Data)

```dart
class RefundDetailData {
  final int id;
  final String refundNumber;
  final int transactionId;
  final int customerId;
  final int userId;
  final int storeId;
  final double totalRefundAmount;
  final String refundMethod;
  final double cashRefundAmount;
  final double transferRefundAmount;
  final String status;
  final String? notes;
  final String refundDate;
  final RefundDetailUser? user;
  final RefundStore? store;
  final RefundCustomer? customer;
  final RefundTransaction? transaction;
  final List<RefundDetailItem>? details;
  final String createdAt;
  final String updatedAt;

  factory RefundDetailData.fromJson(Map<String, dynamic> json) {
    return RefundDetailData(
      id: json['id'] as int,
      refundNumber: json['refund_number'] as String,
      transactionId: json['transaction_id'] as int,
      customerId: json['customer_id'] as int,
      userId: json['user_id'] as int,
      storeId: json['store_id'] as int,
      totalRefundAmount: (json['total_refund_amount'] as num).toDouble(),
      refundMethod: json['refund_method'] as String,
      cashRefundAmount: (json['cash_refund_amount'] as num).toDouble(),
      transferRefundAmount: (json['transfer_refund_amount'] as num).toDouble(),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      refundDate: json['refund_date'] as String,
      user: json['user'] != null
          ? RefundDetailUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      store: json['store'] != null
          ? RefundStore.fromJson(json['store'] as Map<String, dynamic>)
          : null,
      customer: json['customer'] != null
          ? RefundCustomer.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
      transaction: json['transaction'] != null
          ? RefundTransaction.fromJson(json['transaction'] as Map<String, dynamic>)
          : null,
      details: json['details'] != null
          ? (json['details'] as List<dynamic>)
              .map((e) => RefundDetailItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }
}
```

#### C. RefundDetailUser (User Info)

```dart
class RefundDetailUser {
  final int id;
  final String name;
  final String email;
  final List<UserRole>? roles;
  final String? createdAt;
  final String? updatedAt;

  factory RefundDetailUser.fromJson(Map<String, dynamic> json) {
    return RefundDetailUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      roles: json['roles'] != null
          ? (json['roles'] as List<dynamic>)
              .map((e) => UserRole.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}
```

#### D. RefundDetailItem (Refund Items)

```dart
class RefundDetailItem {
  final int id;
  final int transactionDetailId;
  final int? productId;
  final int? productVariantId;
  final String productName;
  final String productSku;
  final double unitPrice;
  final int quantityRefunded;
  final double totalRefundAmount;
  final ProductVariant? productVariant;
  final String createdAt;
  final String updatedAt;

  factory RefundDetailItem.fromJson(Map<String, dynamic> json) {
    return RefundDetailItem(
      id: json['id'] as int,
      transactionDetailId: json['transaction_detail_id'] as int,
      productId: json['product_id'] as int?,
      productVariantId: json['product_variant_id'] as int?,
      productName: json['product_name'] as String,
      productSku: json['product_sku'] as String,
      unitPrice: (json['unit_price'] as num).toDouble(),
      quantityRefunded: json['quantity_refunded'] as int,
      totalRefundAmount: (json['total_refund_amount'] as num).toDouble(),
      productVariant: json['product_variant'] != null
          ? ProductVariant.fromJson(json['product_variant'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }
}
```

### 3. RefundDetailPage Implementation

**File**: `lib/features/refunds/presentation/pages/refund_detail_page.dart`

#### State Variables:

```dart
class _RefundDetailPageState extends State<RefundDetailPage> {
  final RefundApiService _apiService = RefundApiService();
  RefundDetailData? _refundDetail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRefundDetail();
  }
}
```

#### Load Data Method:

```dart
Future<void> _loadRefundDetail() async {
  try {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    debugPrint('🔍 Loading refund detail for ID: ${widget.refundId}');

    final response = await _apiService.getRefundById(widget.refundId);

    debugPrint('📦 Refund detail API response: $response');

    final refundDetailResponse = RefundDetailResponse.fromJson(response);

    setState(() {
      _refundDetail = refundDetailResponse.data;
      _isLoading = false;
    });

    debugPrint('✅ Refund detail loaded successfully: ${_refundDetail?.refundNumber}');
  } catch (e, stackTrace) {
    debugPrint('❌ Error loading refund detail: $e');
    debugPrint('Stack trace: $stackTrace');

    setState(() {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
    });
  }
}
```

#### UI States:

```dart
Widget _buildBody() {
  if (_isLoading) {
    return _buildShimmerLoading();  // Show loading animation
  }

  if (_errorMessage != null) {
    return _buildErrorView();  // Show error message with retry
  }

  if (_refundDetail == null) {
    return _buildEmptyView();  // Show empty state
  }

  return _buildRefundContent();  // Show refund details
}
```

## Data Flow

```
RefundDetailPage
      ↓
  initState()
      ↓
_loadRefundDetail()
      ↓
RefundApiService.getRefundById(id)
      ↓
API: GET /api/v1/refunds/{id}
      ↓
Response JSON
      ↓
RefundDetailResponse.fromJson()
      ↓
RefundDetailData
      ↓
setState() → UI Update
```

## Debug Logging

### Console Output Example:

**Loading:**

```
🔍 Loading refund detail for ID: 1
```

**Success:**

```
📦 Refund detail API response: {status: success, message: Refund retrieved successfully, data: {...}}
✅ Refund detail loaded successfully: RFD20251010JWMZYZ
```

**Error:**

```
❌ Error loading refund detail: 404: Refund not found
Stack trace: #0 RefundApiService.getRefundById
...
```

## UI Components

### 1. Loading State

- Shimmer loading animation
- Skeleton cards for better UX

### 2. Error State

- Error icon and message
- Retry button to reload
- User-friendly error text

### 3. Success State

Displays:

- **Refund Header**: Number, status, amount
- **Customer Info**: Name, phone
- **Transaction Info**: Original transaction details
- **Refund Details**: Items refunded with quantities
- **Payment Info**: Cash/transfer amounts, method
- **User Info**: Who processed the refund
- **Notes**: Refund notes if any

### 4. Actions

- Print refund receipt (planned)
- Navigate back
- Refresh data (pull to refresh)

## Field Mapping

### Refund Main Fields

| API Field                | Model Field            | Type      | Description                               |
| ------------------------ | ---------------------- | --------- | ----------------------------------------- |
| `refund_number`          | `refundNumber`         | `String`  | Unique refund identifier                  |
| `total_refund_amount`    | `totalRefundAmount`    | `double`  | Total amount refunded                     |
| `refund_method`          | `refundMethod`         | `String`  | Method: cash_and_transfer, cash, transfer |
| `cash_refund_amount`     | `cashRefundAmount`     | `double`  | Cash portion of refund                    |
| `transfer_refund_amount` | `transferRefundAmount` | `double`  | Transfer portion of refund                |
| `status`                 | `status`               | `String`  | Status: pending, completed, cancelled     |
| `refund_date`            | `refundDate`           | `String`  | ISO 8601 date                             |
| `notes`                  | `notes`                | `String?` | Optional refund notes                     |

### Nested Objects

| Object        | Type                     | Description                 |
| ------------- | ------------------------ | --------------------------- |
| `user`        | `RefundDetailUser`       | User who processed refund   |
| `store`       | `RefundStore`            | Store where refund occurred |
| `customer`    | `RefundCustomer`         | Customer receiving refund   |
| `transaction` | `RefundTransaction`      | Original transaction        |
| `details`     | `List<RefundDetailItem>` | Items being refunded        |

## Error Handling

### Common Errors:

1. **401 Unauthorized**

   - Token expired or invalid
   - Solution: Re-authenticate user

2. **404 Not Found**

   - Refund ID doesn't exist
   - Solution: Show error, navigate back

3. **Network Error**

   - No internet connection
   - Solution: Show retry button

4. **Parsing Error**
   - API response format changed
   - Solution: Log error, show generic message

### Error Display:

```dart
if (_errorMessage != null) {
  return Center(
    child: Column(
      children: [
        Icon(LucideIcons.alertCircle, color: Colors.red),
        Text('Error: $_errorMessage'),
        ElevatedButton(
          onPressed: _loadRefundDetail,
          child: Text('Retry'),
        ),
      ],
    ),
  );
}
```

## Testing Checklist

- [x] API call with valid refund ID
- [x] API call with invalid refund ID (404)
- [x] Handle network errors
- [x] Handle parsing errors
- [x] Display all refund information
- [x] Display customer info correctly
- [x] Display refund items with details
- [x] Show loading state
- [x] Show error state with retry
- [x] Debug logging for troubleshooting
- [x] Navigation back works
- [x] Refresh/reload functionality

## Files Involved

1. **refund_api_service.dart**

   - Has: `getRefundById(int id)` method
   - Returns: `Map<String, dynamic>` from API

2. **refund_detail_response.dart**

   - Models: `RefundDetailResponse`, `RefundDetailData`
   - Nested: `RefundDetailUser`, `RefundDetailItem`, etc.
   - Parsing: All `fromJson()` methods

3. **refund_detail_page.dart**
   - Modified: Added debug logging
   - Enhanced: Better error handling
   - Improved: User-friendly error messages

## Best Practices Applied

1. **Debug Logging**: Comprehensive logs for debugging
2. **Error Handling**: Graceful error handling with stack trace
3. **User Feedback**: Loading, error, and success states
4. **Null Safety**: Proper nullable types
5. **Type Safety**: Explicit type casting
6. **Clean Code**: Separated concerns (API, Model, UI)

---

**Implementation Date**: October 10, 2025  
**Status**: ✅ Completed  
**API Endpoint**: `/api/v1/refunds/{refund_id}`  
**Method**: GET
