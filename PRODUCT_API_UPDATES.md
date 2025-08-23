# Product API Query Parameters Update

## Overview

The product API endpoint has been enhanced with additional query parameters to provide more flexible filtering, sorting, and pagination options.

## New Endpoint Structure

```
GET {{base_url}}/api/v1/products?search=cola&category_id=1&unit_id=1&active_only=true&sort_by=name&sort_direction=asc&per_page=15
```

## Query Parameters

### Updated Parameters:

| Parameter        | Type        | Default | Description                    |
| ---------------- | ----------- | ------- | ------------------------------ | ----------------------------------------------- |
| `search`         | string      | null    | Search products by name or SKU |
| `category_id`    | integer     | null    | Filter by category ID          |
| `unit_id`        | **NEW**     | integer | null                           | Filter by unit ID                               |
| `active_only`    | **UPDATED** | boolean | true                           | Filter active products only                     |
| `sort_by`        | **NEW**     | string  | null                           | Sort field (name, created_at, updated_at, etc.) |
| `sort_direction` | **NEW**     | string  | null                           | Sort direction (asc or desc)                    |
| `per_page`       | integer     | 15      | Number of items per page       |
| `page`           | integer     | 1       | Page number                    |

### Changes from Previous Version:

1. **`is_active`** → **`active_only`**: Parameter renamed and now defaults to `true`
2. **`unit_id`**: New parameter for filtering by unit
3. **`sort_by`**: New parameter for specifying sort field
4. **`sort_direction`**: New parameter for sort direction (asc/desc)

## Implementation in ProductApiService

### Updated Method Signature:

```dart
Future<ProductResponse> getProducts({
  int page = 1,
  int perPage = 15,
  String? search,
  int? categoryId,
  int? unitId,              // NEW
  bool activeOnly = true,   // UPDATED: renamed from isActive, defaults to true
  String? sortBy,           // NEW
  String? sortDirection,    // NEW
}) async
```

### New Helper Methods:

```dart
// Get products by unit
Future<ProductResponse> getProductsByUnit(
  int unitId, {
  // ... other parameters
}) async

// Get all products including inactive ones
Future<ProductResponse> getAllProducts({
  // ... parameters with activeOnly: false
}) async
```

## Usage Examples

### 1. Basic Search

```dart
final products = await productService.getProducts(
  search: 'cola',
);
```

### 2. Filter by Category and Unit

```dart
final products = await productService.getProducts(
  categoryId: 1,
  unitId: 2,
  activeOnly: true,
);
```

### 3. Sorted Results

```dart
final products = await productService.getProducts(
  sortBy: 'created_at',
  sortDirection: 'desc',
  perPage: 20,
);
```

### 4. Complex Query

```dart
final products = await productService.getProducts(
  search: 'snack',
  categoryId: 1,
  unitId: 1,
  activeOnly: true,
  sortBy: 'name',
  sortDirection: 'asc',
  perPage: 15,
);
```

### 5. Using Helper Methods

```dart
// Search with advanced options
final searchResults = await productService.searchProducts(
  'cola',
  categoryId: 1,
  sortBy: 'name',
  sortDirection: 'asc',
);

// Get products by unit
final unitProducts = await productService.getProductsByUnit(
  1,
  search: 'beverage',
  sortBy: 'created_at',
);

// Get all products (including inactive)
final allProducts = await productService.getAllProducts(
  search: 'test',
  sortBy: 'updated_at',
  sortDirection: 'desc',
);
```

## Query String Generation

The service automatically builds query strings:

### Example Generated URLs:

```
# Basic search
/api/v1/products?search=cola&active_only=true&per_page=15&page=1

# With category filter
/api/v1/products?search=cola&category_id=1&active_only=true&per_page=15&page=1

# With sorting
/api/v1/products?search=cola&category_id=1&unit_id=1&active_only=true&sort_by=name&sort_direction=asc&per_page=15&page=1

# Include inactive products
/api/v1/products?search=cola&active_only=false&per_page=15&page=1
```

## Response Structure

The response structure remains the same:

```json
{
  "status": "success",
  "message": "Products retrieved successfully",
  "data": {
    "data": [...],
    "links": {...},
    "meta": {
      "current_page": 1,
      "per_page": 15,
      "total": 100,
      ...
    }
  }
}
```

## Breaking Changes

### Migration Required:

1. **`isActive` parameter** → **`activeOnly`**

   ```dart
   // Old
   getProducts(isActive: true)

   // New
   getProducts(activeOnly: true)
   ```

2. **Default behavior change**: `activeOnly` now defaults to `true`
   - If you need inactive products, explicitly set `activeOnly: false`

### Backward Compatibility:

- All existing method calls will work with the new defaults
- The `getActiveProducts()` method maintains the same behavior
- New `getAllProducts()` method added for accessing inactive products

## Testing

Use the `ProductQueryParamsDemo` to test all query parameter combinations:

- Interactive form for all parameters
- Real-time URL generation display
- API call testing with response display
- Quick test buttons for common scenarios

## Performance Considerations

### Indexed Fields:

Ensure database indexes exist for optimal performance on:

- `search` fields (product name, SKU)
- `category_id`
- `unit_id`
- `active_only` (status field)
- Sorting fields (`created_at`, `updated_at`, etc.)

### Recommended Limits:

- `per_page`: Keep between 10-50 for optimal performance
- `search`: Minimum 2-3 characters for search queries
- Use specific filters (`category_id`, `unit_id`) to reduce result sets
