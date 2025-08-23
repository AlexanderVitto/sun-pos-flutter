import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../routes/app_routes.dart';

/// Widget untuk setup AuthProvider callback dan handle unauthorized navigation
class AuthGuard extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const AuthGuard({super.key, required this.child, required this.navigatorKey});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  @override
  void initState() {
    super.initState();

    // Setup callback untuk handle 401 unauthorized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.setUnauthorizedCallback(() {
        _handleUnauthorizedNavigation();
      });
    });
  }

  void _handleUnauthorizedNavigation() {
    if (widget.navigatorKey.currentState != null) {
      // Show snackbar atau dialog notification
      _showSessionExpiredMessage();

      // Navigate ke login page dan clear stack
      widget.navigatorKey.currentState!.pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  void _showSessionExpiredMessage() {
    final context = widget.navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Session expired. Please login again.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange[600],
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'LOGIN',
            textColor: Colors.white,
            onPressed: () {
              widget.navigatorKey.currentState?.pushNamedAndRemoveUntil(
                AppRoutes.login,
                (route) => false,
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Extension untuk AuthProvider untuk kemudahan penggunaan
extension AuthProviderExtension on AuthProvider {
  /// Check apakah error disebabkan oleh 401 Unauthorized
  bool get isUnauthorizedError {
    if (errorMessage == null) return false;
    final error = errorMessage!.toLowerCase();
    return error.contains('401') ||
        error.contains('unauthorized') ||
        error.contains('unauthenticated') ||
        error.contains('session expired');
  }

  /// Method untuk handle API calls dengan automatic 401 handling
  Future<T?> safeApiCall<T>(
    Future<T> Function() apiCall, {
    String? errorContext,
  }) async {
    try {
      return await apiCall();
    } catch (e) {
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('401') ||
          errorString.contains('unauthorized') ||
          errorString.contains('unauthenticated')) {
        final contextMessage =
            errorContext != null
                ? 'Failed to $errorContext: Session expired'
                : 'Session expired. Please login again.';

        await handleUnauthorized(contextMessage);
        return null;
      }

      // Re-throw untuk error lainnya
      rethrow;
    }
  }
}

/// Utility class untuk consistent 401 handling across the app
class UnauthorizedHandler {
  static const String defaultMessage = 'Session expired. Please login again.';

  /// Check if error is 401 Unauthorized
  static bool isUnauthorizedError(dynamic error) {
    if (error == null) return false;
    final errorString = error.toString().toLowerCase();
    return errorString.contains('401') ||
        errorString.contains('unauthorized') ||
        errorString.contains('unauthenticated');
  }

  /// Handle 401 error with context
  static Future<void> handle401(
    BuildContext context,
    dynamic error, {
    String? customMessage,
  }) async {
    if (!isUnauthorizedError(error)) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.handleUnauthorized(customMessage ?? defaultMessage);
  }

  /// Show 401 error dialog
  static void show401Dialog(
    BuildContext context, {
    String? message,
    VoidCallback? onLoginPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange[600]),
                SizedBox(width: 8),
                Text('Session Expired'),
              ],
            ),
            content: Text(
              message ?? defaultMessage,
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              ElevatedButton.icon(
                onPressed:
                    onLoginPressed ??
                    () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                        (route) => false,
                      );
                    },
                icon: Icon(Icons.login),
                label: Text('Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
    );
  }
}
