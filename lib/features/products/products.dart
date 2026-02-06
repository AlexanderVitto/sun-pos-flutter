// Products Feature - Public API
// Export all public interfaces from products feature

// ============================================================================
// DATA LAYER
// ============================================================================

// Models
export 'data/models/product.dart';
export 'data/models/category.dart';
export 'data/models/product_variant.dart';
export 'data/models/customer_pricing.dart';
export 'data/models/customer_info.dart';
export 'data/models/formatted_prices.dart';
export 'data/models/unit.dart';
export 'data/models/pagination.dart';

// API Responses
export 'data/models/product_response.dart';
export 'data/models/product_detail_response.dart' hide ProductVariant;
export 'data/models/category_response.dart';

// Services
export 'data/services/product_api_service.dart';

// ============================================================================
// PROVIDERS (State Management)
// ============================================================================
export 'providers/product_provider.dart';
export 'providers/api_product_provider.dart';

// ============================================================================
// PRESENTATION LAYER - Only export what's needed externally
// ============================================================================

// Pages
export 'presentation/pages/products_page.dart';
export 'presentation/pages/product_detail_page.dart';
// Note: add_product_page.dart is internal, not exported

// ViewModels (if used by other features)
export 'presentation/viewmodels/product_detail_viewmodel.dart';
