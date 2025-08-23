import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/role_permissions.dart';
import '../../features/auth/providers/auth_provider.dart';

class PermissionWrapper extends StatelessWidget {
  final String requiredPermission;
  final Widget child;
  final Widget? fallback;
  final bool showFallback;

  const PermissionWrapper({
    super.key,
    required this.requiredPermission,
    required this.child,
    this.fallback,
    this.showFallback = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;

        if (user == null) {
          return _buildUnauthorized();
        }

        final hasAccess = RolePermissions.hasPermission(
          user.roleNames,
          requiredPermission,
        );

        if (hasAccess) {
          return child;
        }

        if (showFallback) {
          return fallback ?? _buildUnauthorized();
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildUnauthorized() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Akses Terbatas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Anda tidak memiliki izin untuk mengakses fitur ini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

// Specific permission wrappers for common use cases
class DashboardPermission extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const DashboardPermission({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context) {
    return PermissionWrapper(
      requiredPermission: RolePermissions.accessDashboard,
      fallback: fallback,
      child: child,
    );
  }
}

class ReportsPermission extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const ReportsPermission({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context) {
    return PermissionWrapper(
      requiredPermission: RolePermissions.accessReports,
      fallback: fallback,
      child: child,
    );
  }
}

class POSPermission extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const POSPermission({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context) {
    return PermissionWrapper(
      requiredPermission: RolePermissions.accessPOS,
      fallback: fallback,
      child: child,
    );
  }
}

class ProductsPermission extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const ProductsPermission({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context) {
    return PermissionWrapper(
      requiredPermission: RolePermissions.accessProducts,
      fallback: fallback,
      child: child,
    );
  }
}
