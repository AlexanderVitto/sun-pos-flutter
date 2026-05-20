# HTTP 401 Unauthorized Handler Implementation

## Overview

This implementation provides automatic handling of HTTP 401 Unauthorized responses throughout the application. When a 401 error occurs, the system automatically logs out the user, clears session data, and redirects to the login page.

## Implementation Details

### 1. AuthProvider Enhancements

#### New Methods Added:

- `handleUnauthorized()` - Handles 401 responses
- `_handleApiCall()` - Wrapper for API calls with 401 detection
- `setUnauthorizedCallback()` - Sets navigation callback
- `manualLogout()` - Manual logout with server call

#### Key Features:

```dart
// Handle 401 Unauthorized response
Future<void> handleUnauthorized([String? errorMessage]) async {
  debugPrint('Handling 401 Unauthorized - forcing logout');

  // Set error message
  _errorMessage = errorMessage ?? 'Session expired. Please login again.';

  // Force logout to clear all data
  await forceLogout();

  // Trigger navigation callback
  if (_onUnauthorized != null) {
    _onUnauthorized!();
  }

  notifyListeners();
}
```

### 2. API Call Wrapper

All API calls now use `_handleApiCall()` wrapper that automatically detects 401 responses:

```dart
Future<T?> _handleApiCall<T>(Future<T> Function() apiCall) async {
  try {
    return await apiCall();
  } catch (e) {
    final errorString = e.toString().toLowerCase();

    // Check for HTTP 401 or Unauthorized
    if (errorString.contains('401') ||
        errorString.contains('unauthorized') ||
        errorString.contains('unauthenticated')) {
      await handleUnauthorized(e.toString());
      return null;
    }

    // Re-throw other errors
    rethrow;
  }
}
```

### 3. Updated Methods

#### fetchUserProfile()

- Now uses `_handleApiCall()` wrapper
- Automatically handles 401 responses
- Returns null if 401 detected

#### changePassword()

- Protected with 401 detection
- Auto-logout on session expiry
- Returns false on 401 error

### 4. Navigation Setup

#### Main App Setup (main_with_401_handler.dart):

```dart
@override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.setUnauthorizedCallback(() {
      _handleUnauthorizedNavigation();
    });

    authProvider.init();
  });
}

void _handleUnauthorizedNavigation() {
  if (_navigatorKey.currentState != null) {
    _showSessionExpiredMessage();

    _navigatorKey.currentState!.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }
}
```

## Usage Examples

### 1. Automatic 401 Detection

When any API call returns 401:

```dart
// This will automatically handle 401
final profile = await authProvider.fetchUserProfile();
// If 401 occurs, user is logged out and redirected
```

### 2. Manual 401 Handling

For testing or specific scenarios:

```dart
// Simulate 401 error
await authProvider.handleUnauthorized('Session expired for testing');
```

### 3. Safe API Calls

Using the extension method:

```dart
final result = await authProvider.safeApiCall(
  () => someApiService.getData(),
  errorContext: 'fetch data',
);
```

## Components Overview

### Files Created/Modified:

1. **`auth_provider.dart`** - Enhanced with 401 handling
2. **`auth_guard.dart`** - Utility for 401 handling
3. **`http_401_demo.dart`** - Demo page showing 401 handling
4. **`main_with_401_handler.dart`** - Example main app setup

### Key Features:

- ✅ **Automatic Detection** - Detects 401 in API responses
- ✅ **Auto Logout** - Clears session data automatically
- ✅ **Auto Redirect** - Navigates to login page
- ✅ **User Notification** - Shows session expired message
- ✅ **Fallback Storage** - Works with both secure storage and SharedPreferences
- ✅ **Error Context** - Provides meaningful error messages
- ✅ **Testing Support** - Includes methods for testing 401 scenarios

## Error Detection Logic

The system detects 401 errors by checking for these strings in error messages:

- `"401"`
- `"unauthorized"`
- `"unauthenticated"`
- `"session expired"`

## Flow Diagram

```
API Call → 401 Response → AuthProvider._handleApiCall()
    ↓
handleUnauthorized() → Clear Session Data
    ↓
Trigger Callback → Navigate to Login
    ↓
Show Notification → "Session expired"
```

## Benefits

1. **User Experience**: Seamless handling of expired sessions
2. **Security**: Automatic cleanup of invalid sessions
3. **Consistency**: Unified 401 handling across the app
4. **Maintainability**: Centralized session management
5. **Testing**: Easy to test with simulation methods

## Integration Steps

1. **Setup Callback** in main app initialization
2. **Use Wrapped Methods** for API calls
3. **Handle Navigation** with global navigator key
4. **Test Implementation** using demo methods

## Testing

Use the `Http401Demo` page to test:

- Simulate 401 responses
- Test automatic logout
- Verify navigation to login
- Check session cleanup

## Future Enhancements

- Add retry mechanism for failed requests
- Implement token refresh on 401
- Add logging for 401 events
- Support for different 401 scenarios
