import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/change_password_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/products/presentation/pages/products_page.dart';
import '../../features/products/presentation/pages/add_product_page.dart';
import '../../features/sales/presentation/pages/sales_page.dart';
import '../../features/sales/presentation/pages/new_sale_page.dart';
import '../../features/sales/presentation/pages/payment_success_page.dart';
import '../../features/sales/presentation/pages/receipt_page.dart';
import '../../features/customers/presentation/pages/customers_page.dart';
import '../../features/customers/presentation/pages/add_customer_page.dart';
import '../../features/customers/pages/customer_detail_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/transactions/data/models/store.dart';
import '../../features/transactions/presentation/pages/transaction_list_page.dart';
import '../../features/cash_flows/presentation/pages/cash_flows_page.dart';
import '../../features/cash_flows/presentation/pages/add_cash_flow_page.dart';

class AppRouter {
  static Store _getDefaultStore() {
    final now = DateTime.now();
    return Store(
      id: 1,
      name: 'Default Store',
      address: 'Default Address',
      phoneNumber: '(000) 000-0000',
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case AppRoutes.changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordPage());

      case AppRoutes.home:
      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPage());

      case AppRoutes.products:
        return MaterialPageRoute(builder: (_) => const ProductsPage());

      case AppRoutes.addProduct:
        return MaterialPageRoute(builder: (_) => const AddProductPage());

      case AppRoutes.sales:
        return MaterialPageRoute(builder: (_) => const SalesPage());

      case AppRoutes.newSale:
        return MaterialPageRoute(builder: (_) => const NewSalePage());

      case AppRoutes.paymentSuccess:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (context) => PaymentSuccessPage(
              paymentMethod: args['paymentMethod'] ?? 'Tunai',
              amountPaid: args['amountPaid'] ?? 0.0,
              totalAmount: args['totalAmount'] ?? 0.0,
              transactionNumber: args['transactionNumber'],
              store: args['store'] ?? _getDefaultStore(), // Add store parameter
              cartItems: args['cartItems'],
              user: args['user'],
              status: args['status'],
              dueDate: args['dueDate'],
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => const NewSalePage());

      case AppRoutes.receipt:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (_) => ReceiptPage(
              receiptId: args['receiptId'] ?? '',
              transactionDate: args['transactionDate'] ?? DateTime.now(),
              items: args['items'] ?? [],
              store: args['store'] ?? _getDefaultStore(), // Add default store
              user: args['user'], // Add user parameter
              subtotal: args['subtotal'] ?? 0.0,
              discount: args['discount'] ?? 0.0,
              total: args['total'] ?? 0.0,
              paymentMethod: args['paymentMethod'] ?? 'Tunai',
              status: args['status'], // Add status parameter
              dueDate: args['dueDate'], // Add dueDate parameter
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => const NewSalePage());

      case AppRoutes.transactionList:
        return MaterialPageRoute(builder: (_) => const TransactionListPage());

      case AppRoutes.customers:
        return MaterialPageRoute(builder: (_) => const CustomersPage());

      case AppRoutes.addCustomer:
        return MaterialPageRoute(builder: (_) => const AddCustomerPage());

      case AppRoutes.customerDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (_) => CustomerDetailPage(
              customerId: args['customerId'] ?? 0,
              customer: args['customer'],
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => const CustomersPage());

      case AppRoutes.reports:
        return MaterialPageRoute(builder: (_) => const ReportsPage());

      case AppRoutes.cashFlows:
        return MaterialPageRoute(builder: (_) => const CashFlowsPage());

      case AppRoutes.addCashFlow:
        return MaterialPageRoute(builder: (_) => const AddCashFlowPage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
