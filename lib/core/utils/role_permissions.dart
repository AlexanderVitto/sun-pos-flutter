import '../../../features/auth/data/models/user.dart';

class RolePermissions {
  // New role constants
  static const String owner = 'owner';
  static const String staff = 'staff';
  static const String cashier = 'cashier';

  // Legacy role constants (for backward compatibility)
  static const String kepalaToko = 'kepala_toko';
  static const String kasir = 'kasir';

  // Permission constants based on API response
  static const String viewUsers = 'view_users';
  static const String createUsers = 'create_users';
  static const String editUsers = 'edit_users';
  static const String deleteUsers = 'delete_users';

  static const String viewProducts = 'view_products';
  static const String createProducts = 'create_products';
  static const String editProducts = 'edit_products';
  static const String deleteProducts = 'delete_products';

  static const String viewTransactions = 'view_transactions';
  static const String createTransactions = 'create_transactions';
  static const String editTransactions = 'edit_transactions';
  static const String deleteTransactions = 'delete_transactions';

  static const String viewCategories = 'view_categories';
  static const String createCategories = 'create_categories';
  static const String editCategories = 'edit_categories';
  static const String deleteCategories = 'delete_categories';

  static const String viewUnits = 'view_units';
  static const String createUnits = 'create_units';
  static const String editUnits = 'edit_units';
  static const String deleteUnits = 'delete_units';

  static const String updateRoles = 'update_roles';
  static const String deleteRoles = 'delete_roles';

  static const String viewReports = 'view_reports';
  static const String manageSettings = 'manage_settings';

  // Legacy permission mapping for backward compatibility
  static const String accessDashboard = 'access_dashboard';
  static const String accessPOS = 'access_pos';
  static const String accessProducts = 'access_products';
  static const String accessReports = 'access_reports';
  static const String accessProfile = 'access_profile';

  // Role permissions mapping
  static final Map<String, List<String>> rolePermissions = {
    owner: [
      accessDashboard,
      accessPOS,
      accessProducts,
      accessReports,
      accessProfile,
    ],
    staff: [
      accessDashboard,
      accessPOS,
      accessProducts,
      accessReports,
      accessProfile,
    ],
    cashier: [accessPOS, accessProducts, accessProfile],
    // Legacy mappings for backward compatibility
    kepalaToko: [
      accessDashboard,
      accessPOS,
      accessProducts,
      accessReports,
      accessProfile,
    ],
    kasir: [accessPOS, accessProducts, accessProfile],
  };

  // Check if user has permission (supports both List<String> and dynamic types)
  static bool hasPermission(dynamic roles, String permission) {
    if (roles == null) return false;

    if (roles is List<String>) {
      for (String role in roles) {
        String normalizedRole = _normalizeRole(role);
        if (rolePermissions[normalizedRole]?.contains(permission) == true) {
          return true;
        }
      }
      return false;
    } else if (roles is String) {
      String normalizedRole = _normalizeRole(roles);
      return rolePermissions[normalizedRole]?.contains(permission) ?? false;
    }

    return false;
  }

  // NEW: Check permission directly from User object
  static bool userHasPermission(User? user, String permission) {
    if (user == null) return false;
    return user.hasPermission(permission);
  }

  // NEW: Check if user has API permission
  static bool canViewProducts(User? user) {
    return userHasPermission(user, viewProducts);
  }

  static bool canCreateProducts(User? user) {
    return userHasPermission(user, createProducts);
  }

  static bool canEditProducts(User? user) {
    return userHasPermission(user, editProducts);
  }

  static bool canDeleteProducts(User? user) {
    return userHasPermission(user, deleteProducts);
  }

  static bool canViewTransactions(User? user) {
    return userHasPermission(user, viewTransactions);
  }

  static bool canCreateTransactions(User? user) {
    return userHasPermission(user, createTransactions);
  }

  static bool canViewReportsApi(User? user) {
    return userHasPermission(user, viewReports);
  }

  static bool canManageSettings(User? user) {
    return userHasPermission(user, manageSettings);
  }

  // NEW: Check if user is restricted based on role ID (role ID > 2 = restricted)
  static bool isRestrictedUser(User? user) {
    if (user == null) return true;

    // Check if any role has ID > 2
    return user.roles.every((role) => role.id > 2);
  }

  // NEW: Check if user has full access (role ID <= 2)
  static bool hasFullAccess(User? user) {
    if (user == null) return false;

    // User has full access if ANY role has ID <= 2
    return user.roles.any((role) => role.id <= 2);
  }

  // Check if user can access dashboard
  static bool canAccessDashboard(List<String> userRoles) {
    return hasPermission(userRoles, accessDashboard);
  }

  // NEW: Check if user can access dashboard based on User object
  static bool canAccessDashboardByUser(User? user) {
    if (user == null) return false;
    // Restricted users (role ID > 2) can only see limited dashboard
    return true; // All users can see dashboard, but content is restricted
  }

  // Check if user can access POS
  static bool canAccessPOS(List<String> userRoles) {
    return hasPermission(userRoles, accessPOS);
  }

  // NEW: Check if user can access POS by User object
  static bool canAccessPOSByUser(User? user) {
    if (user == null) return false;
    // Restricted users cannot access POS
    return hasFullAccess(user);
  }

  // Check if user can access products
  static bool canAccessProducts(List<String> userRoles) {
    return hasPermission(userRoles, accessProducts);
  }

  // NEW: Check if user can access products by User object
  static bool canAccessProductsByUser(User? user) {
    if (user == null) return false;
    // Restricted users cannot access product management
    return hasFullAccess(user);
  }

  // Check if user can access reports
  static bool canAccessReports(List<String> userRoles) {
    return hasPermission(userRoles, accessReports);
  }

  // NEW: Check if user can access reports by User object
  static bool canAccessReportsByUser(User? user) {
    if (user == null) return false;
    // Restricted users cannot access reports
    return hasFullAccess(user);
  }

  // Check if user can access profile
  static bool canAccessProfile(List<String> userRoles) {
    return hasPermission(userRoles, accessProfile);
  }

  // NEW: Check if user can access profile by User object
  static bool canAccessProfileByUser(User? user) {
    // All users can access their profile
    return user != null;
  }

  // NEW: Check if user can access pending transactions
  static bool canAccessPendingTransactionsByUser(User? user) {
    // All users can access pending transactions
    return user != null;
  }

  // NEW: Check if user should see full dashboard or limited dashboard
  static bool shouldShowFullDashboard(User? user) {
    if (user == null) return false;
    // Only users with role ID <= 2 can see full dashboard
    return hasFullAccess(user);
  }

  // Get available bottom navigation items for user
  static List<String> getAvailableNavItems(List<String> userRoles) {
    List<String> availableItems = [];

    if (canAccessDashboard(userRoles)) {
      availableItems.add('dashboard');
    }
    if (canAccessPOS(userRoles)) {
      availableItems.add('pos');
    }
    if (canAccessProducts(userRoles)) {
      availableItems.add('products');
    }
    if (canAccessReports(userRoles)) {
      availableItems.add('reports');
    }
    if (canAccessProfile(userRoles)) {
      availableItems.add('profile');
    }

    return availableItems;
  }

  // Normalize role name to handle variations
  static String _normalizeRole(String role) {
    switch (role.toLowerCase().replaceAll(' ', '_')) {
      case 'owner':
        return owner;
      case 'staff':
      case 'kepala_toko':
      case 'kepala toko':
      case 'manager':
      case 'admin':
        return staff;
      case 'cashier':
      case 'kasir':
        return cashier;
      default:
        return cashier; // Default to cashier for security
    }
  }

  // Method to get display name for role
  static String getRoleDisplayName(dynamic roles) {
    if (roles == null) return 'Unknown';

    String role;
    if (roles is List<String>) {
      role = roles.isNotEmpty ? roles.first : '';
    } else if (roles is String) {
      role = roles;
    } else {
      return 'Unknown';
    }

    final normalized = _normalizeRole(role);
    switch (normalized) {
      case 'owner':
        return 'Owner';
      case 'staff':
        return 'Staff';
      case 'cashier':
        return 'Cashier';
      // Legacy support
      case 'kepala_toko':
        return 'Kepala Toko';
      case 'kasir':
        return 'Kasir';
      default:
        return 'Unknown';
    }
  }

  // Check if user is owner
  static bool isOwner(dynamic roles) {
    if (roles == null) return false;

    if (roles is List<String>) {
      return roles.any((role) => _normalizeRole(role) == owner);
    } else if (roles is String) {
      return _normalizeRole(roles) == owner;
    }
    return false;
  }

  // Check if user is staff
  static bool isStaff(dynamic roles) {
    if (roles == null) return false;

    if (roles is List<String>) {
      return roles.any((role) => _normalizeRole(role) == staff);
    } else if (roles is String) {
      return _normalizeRole(roles) == staff;
    }
    return false;
  }

  // Check if user is cashier
  static bool isCashier(dynamic roles) {
    if (roles == null) return false;

    if (roles is List<String>) {
      return roles.any((role) => _normalizeRole(role) == cashier);
    } else if (roles is String) {
      return _normalizeRole(roles) == cashier;
    }
    return false;
  }

  // Legacy methods (for backward compatibility)
  static bool isKepalaToko(dynamic roles) {
    return isStaff(roles); // Map kepala_toko to staff
  }

  static bool isKasir(dynamic roles) {
    return isCashier(roles); // Map kasir to cashier
  }
}
