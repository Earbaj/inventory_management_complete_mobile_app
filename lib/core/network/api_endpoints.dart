import '../config/env_config.dart';

/// API Endpoints Registry
///
/// Centralized location for defining all backend REST API endpoint URLs.
class ApiEndpoints {
  /// Base API URL dynamically derived from [EnvConfig].
  static String get baseUrl => EnvConfig.apiBaseUrl;

  // ===========================================================================
  // AUTHENTICATION ENDPOINTS
  // ===========================================================================

  /// Endpoint for user login (POST /api/auth/login) - Public
  static String get login => '$baseUrl/api/auth/login';

  /// Endpoint for Shop Owner registration (POST /api/auth/register) - Public
  static String get register => '$baseUrl/api/auth/register';

  /// Endpoint for requesting 6-digit OTP (POST /api/auth/forgot-password) - Public
  static String get forgotPassword => '$baseUrl/api/auth/forgot-password';

  /// Endpoint for resetting password with OTP (POST /api/auth/reset-password) - Public
  static String get resetPassword => '$baseUrl/api/auth/reset-password';

  /// Endpoint for fetching current user profile (GET /api/auth/me) - Authenticated
  static String get me => '$baseUrl/api/auth/me';
}
