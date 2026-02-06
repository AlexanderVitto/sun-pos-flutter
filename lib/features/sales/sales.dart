// Sales Feature - Public API
// Export all public interfaces from sales feature

// ============================================================================
// DATA LAYER
// ============================================================================

// Models
export 'data/models/pending_transaction_api_models.dart';

// Services
export 'data/services/pending_transaction_api_service.dart';

// ============================================================================
// PROVIDERS (State Management)
// ============================================================================
export 'providers/cart_provider.dart';
export 'providers/transaction_provider.dart';
export 'providers/pending_transaction_provider.dart';

// ============================================================================
// PRESENTATION LAYER
// ============================================================================

// View Models
export 'presentation/view_models/pos_transaction_view_model.dart';

// Services
export 'presentation/services/payment_service.dart';
export 'presentation/services/bluetooth_printer_service.dart';
export 'presentation/services/thermal_printer_service.dart';
export 'presentation/services/printer_preferences_service.dart';

// Pages - Only export main pages accessible from other features
export 'presentation/pages/pos_transaction_page.dart';
export 'presentation/pages/cart_page.dart';
export 'presentation/pages/pending_transaction_list_page.dart';
export 'presentation/pages/customer_selection_page.dart';

// Utils
export 'presentation/utils/pos_ui_helpers.dart';

// ============================================================================
// WIDGETS - Only export reusable widgets needed by other features
// ============================================================================

// Note: Most widgets are internal to this feature
// Only export if other features need them
export 'presentation/widgets/product_card.dart';
export 'presentation/widgets/customer_selector_widget.dart';
