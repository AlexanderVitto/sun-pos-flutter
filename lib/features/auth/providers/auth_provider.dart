import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/secure_storage_service.dart';
import '../data/services/auth_service.dart';
import '../data/models/user.dart';
import '../data/models/change_password_request.dart';
import 'package:uuid/uuid.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  User? _user;
  String? _token;
  String? _errorMessage;

  final AuthService _authService = AuthService();
  final SecureStorageService _secureStorage = SecureStorageService();
  final Uuid _uuid = const Uuid();

  // Callback untuk navigasi ke login (akan di-set dari main app)
  VoidCallback? _onUnauthorized;

  // Getter untuk callback
  VoidCallback? get onUnauthorized => _onUnauthorized;

  // Set callback untuk handle 401
  void setUnauthorizedCallback(VoidCallback? callback) {
    _onUnauthorized = callback;
  }

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  User? get user => _user;
  String? get username => _user?.name;
  String? get token => _token;
  String? get errorMessage => _errorMessage;

  // Getter untuk cek apakah ada token
  bool get hasToken => _token != null && _token!.isNotEmpty;

  // Getters untuk user data dan permissions
  List<String> get userRoles => _user?.roleNames ?? [];
  List<String> get userPermissions => _user?.allPermissions ?? [];

  // Helper methods untuk cek permission dan role
  bool hasPermission(String permission) =>
      _user?.hasPermission(permission) ?? false;
  bool hasRole(String role) => _user?.hasRole(role) ?? false;

  // Method sederhana untuk cek token di storage dengan fallback
  Future<bool> hasStoredToken() async {
    try {
      final token = await _secureStorage.getAccessToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      debugPrint('Secure storage error, trying SharedPreferences fallback: $e');
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        return token != null && token.isNotEmpty;
      } catch (fallbackError) {
        debugPrint('SharedPreferences fallback also failed: $fallbackError');
        return false;
      }
    }
  }

  // Initialize - check if user is already logged in dengan fallback
  Future<void> init() async {
    try {
      _isLoading = true;
      notifyListeners();

      String? token;
      Map<String, dynamic>? userData;

      // Coba secure storage terlebih dahulu
      try {
        token = await _secureStorage.getAccessToken();
        if (token != null && token.isNotEmpty) {
          userData = await _secureStorage.getUserData();
        }
      } catch (e) {
        debugPrint(
          'Secure storage error, using SharedPreferences fallback: $e',
        );

        // Fallback ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString('auth_token');

        if (token != null && token.isNotEmpty) {
          // Reconstruct user data dari SharedPreferences
          final userName = prefs.getString('user_name');
          final userEmail = prefs.getString('user_email');
          final userId = prefs.getInt('user_id');

          if (userName != null && userEmail != null && userId != null) {
            userData = {
              'id': userId,
              'name': userName,
              'email': userEmail,
              'roles': ['user'],
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            };
          }
        }
      }

      if (token != null && token.isNotEmpty) {
        // Token ada, set authenticated = true
        _token = token;
        _isAuthenticated = true;

        if (userData != null) {
          _user = User.fromJson(userData);
        }

        debugPrint('Token found - user authenticated');

        // Optional: Fetch fresh profile data dari server
        try {
          await fetchUserProfile();
          debugPrint('Profile refreshed from server');

          // Load transactions or other user-specific data if needed
          
        } catch (e) {
          debugPrint('Failed to refresh profile from server: $e');
          // Tidak masalah jika gagal, masih bisa pakai data lokal
        }
      } else {
        // Token tidak ada, set authenticated = false
        _isAuthenticated = false;
        debugPrint('No token found - user not authenticated');
      }
    } catch (e) {
      debugPrint('Error during init: $e');
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login method dengan secure storage dan fallback
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final loginResponse = await _authService.login(email, password);

      if (loginResponse.status == 'success') {
        _isAuthenticated = true;
        _user = loginResponse.data.user;
        _token = loginResponse.data.token;
        _errorMessage = null;

        // Load profile data setelah login berhasil
        debugPrint('Login successful, loading user profile...');
        try {
          final profileLoaded = await fetchUserProfile();
          if (profileLoaded) {
            debugPrint('User profile loaded successfully');
            // Profile sudah disimpan sebagai userData di fetchUserProfile()
          } else {
            debugPrint(
              'Failed to load user profile, using data from login response',
            );
            // Jika profile gagal, tetap simpan data login sebagai userData
            await _saveUserDataToStorage(_user!);
          }
        } catch (e) {
          debugPrint('Error loading profile after login: $e');
          // Tetap gunakan data dari login response jika profile gagal dimuat
          await _saveUserDataToStorage(_user!);
        }

        // Coba simpan ke secure storage terlebih dahulu
        try {
          String? deviceId = await _secureStorage.getDeviceId();
          deviceId ??= _uuid.v4();

          await _secureStorage.saveLoginSession(
            accessToken: _token!,
            refreshToken: null,
            userData: _user!.toJson(),
            deviceId: deviceId,
          );
          debugPrint('Login data saved to secure storage');
        } catch (e) {
          debugPrint(
            'Secure storage failed, using SharedPreferences fallback: $e',
          );

          // Fallback ke SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', _token!);
          await prefs.setInt('user_id', _user!.id);
          await prefs.setString('user_name', _user!.name);
          await prefs.setString('user_email', _user!.email);
          debugPrint('Login data saved to SharedPreferences');
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = loginResponse.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout method dengan secure storage dan fallback
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Coba hapus dari secure storage terlebih dahulu
      try {
        await _secureStorage.clearLoginSession();
        debugPrint('Logout - cleared secure storage');
      } catch (e) {
        debugPrint(
          'Secure storage clear failed, using SharedPreferences fallback: $e',
        );

        // Fallback ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        await prefs.remove('user_id');
        await prefs.remove('user_name');
        await prefs.remove('user_email');
        debugPrint('Logout - cleared SharedPreferences');
      }

      _isAuthenticated = false;
      _user = null;
      _token = null;
      _errorMessage = null;
    } catch (e) {
      debugPrint('Error during logout: $e');
      // Tetap reset state meskipun ada error
      _isAuthenticated = false;
      _user = null;
      _token = null;
      _errorMessage = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get user profile from API
  Future<bool> fetchUserProfile() async {
    try {
      if (!_isAuthenticated || _token == null) {
        debugPrint('Cannot fetch profile: user not authenticated');
        return false;
      }

      final profileResponse = await _handleApiCall(
        () => _authService.getProfile(),
      );

      if (profileResponse == null) {
        // 401 sudah dihandle oleh _handleApiCall
        return false;
      }

      if (profileResponse.success) {
        _user = profileResponse.data;

        // Simpan profile lengkap sebagai userData di storage
        await _saveUserDataToStorage(_user!);

        notifyListeners();
        return true;
      } else {
        debugPrint('Failed to fetch profile: ${profileResponse.message}');
        return false;
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return false;
    }
  }

  // Refresh token jika diperlukan
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) return false;

      // Implementasi refresh token dengan API
      // final newTokenResponse = await _authService.refreshToken(refreshToken);
      // if (newTokenResponse.success) {
      //   await _secureStorage.saveAccessToken(newTokenResponse.accessToken);
      //   _token = newTokenResponse.accessToken;
      //   notifyListeners();
      //   return true;
      // }

      return false;
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      return false;
    }
  }

  // Cek status session
  Future<bool> checkSessionStatus() async {
    try {
      return await _secureStorage.hasValidSession();
    } catch (e) {
      debugPrint('Error checking session status: $e');
      return false;
    }
  }

  // Update user data
  Future<void> updateUserData(User updatedUser) async {
    try {
      _user = updatedUser;
      await _saveUserDataToStorage(updatedUser);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user data: $e');
    }
  }

  // Force logout (hapus semua data)
  Future<void> forceLogout() async {
    try {
      await _secureStorage.clearAll();
      _isAuthenticated = false;
      _user = null;
      _token = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during force logout: $e');
    }
  }

  // Get session info untuk debugging
  Future<Map<String, dynamic>> getSessionInfo() async {
    try {
      return await _secureStorage.getLoginSession();
    } catch (e) {
      debugPrint('Error getting session info: $e');
      return {};
    }
  }

  // Get userData lengkap dari storage
  Future<Map<String, dynamic>?> getUserDataFromStorage() async {
    try {
      // Coba dari secure storage dulu
      final userData = await _secureStorage.getUserData();
      if (userData != null && userData.isNotEmpty) {
        debugPrint('UserData retrieved from secure storage');
        return userData;
      }
    } catch (e) {
      debugPrint('Secure storage error, trying SharedPreferences: $e');
    }

    try {
      // Fallback ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      final userId = prefs.getInt('user_id');
      if (userId == null) return null;

      final userData = <String, dynamic>{
        'id': userId,
        'name': prefs.getString('user_name') ?? '',
        'email': prefs.getString('user_email') ?? '',
        'created_at': prefs.getString('user_created_at') ?? '',
        'updated_at': prefs.getString('user_updated_at') ?? '',
        'roles': [], // Will be reconstructed if available
      };

      // Try to get roles if available
      final rolesString = prefs.getString('user_roles');
      if (rolesString != null && rolesString.isNotEmpty) {
        try {
          // Parse roles from stored string
          // This is a simplified version, actual implementation may vary
          debugPrint('Found stored roles: $rolesString');
        } catch (e) {
          debugPrint('Error parsing roles: $e');
        }
      }

      // Get permissions if available
      final permissions = prefs.getStringList('user_permissions') ?? [];
      if (permissions.isNotEmpty) {
        userData['permissions'] = permissions;
      }

      debugPrint('UserData retrieved from SharedPreferences');
      return userData;
    } catch (e) {
      debugPrint('Error getting userData from SharedPreferences: $e');
      return null;
    }
  }

  // Handle 401 Unauthorized response
  Future<void> handleUnauthorized([String? errorMessage]) async {
    debugPrint('Handling 401 Unauthorized - forcing logout');

    // Set error message jika ada
    if (errorMessage != null && errorMessage.isNotEmpty) {
      _errorMessage = errorMessage;
    } else {
      _errorMessage = 'Session expired. Please login again.';
    }

    // Force logout untuk clear semua data
    await forceLogout();

    // Trigger callback untuk navigasi ke login
    if (_onUnauthorized != null) {
      _onUnauthorized!();
    }

    notifyListeners();
  }

  // Wrapper untuk API calls yang bisa handle 401
  Future<T?> _handleApiCall<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } catch (e) {
      final errorString = e.toString().toLowerCase();

      // Check untuk HTTP 401 atau Unauthorized
      if (errorString.contains('401') ||
          errorString.contains('unauthorized') ||
          errorString.contains('unauthenticated')) {
        await handleUnauthorized(e.toString());
        return null;
      }

      // Re-throw error lainnya
      rethrow;
    }
  }

  // Test method untuk demo role-based dashboard
  void setTestUser(User user) {
    _user = user;
    _isAuthenticated = true;
    _token =
        'test_token_with_long_string_for_preview_testing_purposes_to_avoid_range_error';
    notifyListeners();
  }

  // Change password method
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      if (newPassword != confirmPassword) {
        throw Exception('New password and confirmation password do not match');
      }

      if (newPassword.length < 6) {
        throw Exception('New password must be at least 6 characters long');
      }

      final request = ChangePasswordRequest(
        currentPassword: currentPassword,
        password: newPassword,
        passwordConfirmation: confirmPassword,
      );

      final response = await _handleApiCall(
        () => _authService.changePassword(request),
      );

      if (response == null) {
        // 401 sudah dihandle oleh _handleApiCall
        _setLoading(false);
        return false;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Helper method untuk simpan userData ke storage
  Future<void> _saveUserDataToStorage(User user) async {
    final userData = user.toJson();
    try {
      await _secureStorage.saveUserData(userData);
      debugPrint('UserData saved to secure storage: ${userData.keys}');
    } catch (e) {
      debugPrint(
        'Secure storage failed, saving userData to SharedPreferences: $e',
      );

      // Fallback ke SharedPreferences - simpan sebagai userData lengkap
      final prefs = await SharedPreferences.getInstance();

      // Simpan data dasar
      await prefs.setInt('user_id', user.id);
      await prefs.setString('user_name', user.name);
      await prefs.setString('user_email', user.email);
      await prefs.setString('user_created_at', user.createdAt);
      await prefs.setString('user_updated_at', user.updatedAt);

      // Simpan roles sebagai JSON string
      final rolesJson = user.roles.map((role) => role.toJson()).toList();
      await prefs.setString('user_roles', rolesJson.toString());

      // Simpan permissions sebagai list string
      await prefs.setStringList('user_permissions', user.allPermissions);

      debugPrint('UserData saved to SharedPreferences');
    }
  }

  // Method untuk manual logout (dipanggil dari UI)
  Future<void> manualLogout() async {
    try {
      // Panggil server logout jika memungkinkan
      if (_isAuthenticated && _token != null) {
        try {
          await _authService.logout();
        } catch (e) {
          debugPrint('Server logout failed: $e');
          // Tetap lanjutkan dengan logout lokal
        }
      }

      await logout();
    } catch (e) {
      debugPrint('Error during manual logout: $e');
      await forceLogout();
    }
  }
}
