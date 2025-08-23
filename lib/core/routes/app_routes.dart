class AppRoutes {
  // Auth Routes
  static const String login = '/login';
  static const String signup = '/signup';
  static const String changePassword = '/change-password';

  // Main Routes
  static const String home = '/';
  static const String dashboard = '/dashboard';

  // Product Routes
  static const String products = '/products';
  static const String addProduct = '/products/add';
  static const String editProduct = '/products/edit';
  static const String productDetail = '/products/detail';

  // Sales Routes
  static const String sales = '/sales';
  static const String newSale = '/sales/new';
  static const String saleDetail = '/sales/detail';
  static const String paymentSuccess = '/sales/payment-success';
  static const String receipt = '/sales/receipt';

  // Transaction Routes
  static const String transactions = '/transactions';
  static const String transactionList = '/transactions/list';
  static const String transactionDetail = '/transactions/detail';

  // Customer Routes
  static const String customers = '/customers';
  static const String addCustomer = '/customers/add';
  static const String editCustomer = '/customers/edit';
  static const String customerDetail = '/customers/detail';

  // Report Routes
  static const String reports = '/reports';
  static const String salesReport = '/reports/sales';
  static const String productReport = '/reports/products';
  static const String customerReport = '/reports/customers';

  // Cash Flow Routes
  static const String cashFlows = '/cash-flows';
  static const String addCashFlow = '/cash-flows/add';

  // Settings Routes
  static const String settings = '/settings';
  static const String profile = '/settings/profile';
  static const String preferences = '/settings/preferences';
}
