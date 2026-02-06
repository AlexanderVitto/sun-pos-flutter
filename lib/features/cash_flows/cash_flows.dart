// Cash Flows Feature - Public API
// Export all public interfaces from cash flows feature

// ============================================================================
// DATA LAYER
// ============================================================================

// Models
export 'data/models/cash_flow.dart';
export 'data/models/cash_flow_response.dart';
export 'data/models/create_cash_flow_request.dart';

// Services
export 'data/services/cash_flow_api_service.dart';

// ============================================================================
// PROVIDERS (State Management)
// ============================================================================
export 'providers/cash_flow_provider.dart';

// ============================================================================
// PRESENTATION LAYER
// ============================================================================

// Pages
export 'presentation/pages/cash_flows_page.dart';
export 'presentation/pages/add_cash_flow_page.dart';

// Widgets
export 'presentation/widgets/cash_flow_card.dart';
export 'presentation/widgets/cash_flow_filter_dialog.dart';
