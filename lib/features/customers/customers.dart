// Customers Feature - Public API
// Export all public interfaces from customers feature

// ============================================================================
// DATA LAYER
// ============================================================================

// Models
export 'data/models/customer.dart';
export 'data/models/customer_group.dart';
export 'data/models/create_customer_request.dart';
export 'data/models/create_customer_response.dart';
export 'data/models/update_customer_request.dart';
export 'data/models/update_customer_response.dart';
export 'data/models/customer_list_response.dart';
export 'data/models/customer_group_list_response.dart';
export 'data/models/payment_receipt_item.dart';

// Services
export 'data/services/customer_api_service.dart';

// ============================================================================
// PROVIDERS (State Management)
// ============================================================================
export 'providers/customer_provider.dart';

// ============================================================================
// PRESENTATION LAYER
// ============================================================================

// Pages
export 'presentation/pages/customer_list_page.dart';
export 'presentation/pages/customer_detail_page.dart';
export 'presentation/pages/outstanding_customers_page.dart';
export 'presentation/pages/customer_outstanding_detail_page.dart';
export 'presentation/pages/customer_payment_page.dart';
export 'presentation/pages/customer_payment_receipt_page.dart';
export 'presentation/pages/add_customer_page.dart';
export 'presentation/pages/customers_page.dart';
export 'presentation/pages/update_customer_page.dart';

// Widgets (reusable)
export 'presentation/widgets/customer_selection_card.dart';
export 'presentation/widgets/customer_list_item.dart';
