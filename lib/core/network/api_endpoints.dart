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

  // ===========================================================================
  // DASHBOARD & ANALYTICS ENDPOINTS
  // ===========================================================================

  /// Endpoint for shop KPIs (GET /api/dashboard/stats) - Authenticated
  static String get dashboardStats => '$baseUrl/api/dashboard/stats';

  /// Endpoint for platform metrics (GET /api/dashboard/superadmin) - SuperAdmin Only
  static String get superAdminDashboard => '$baseUrl/api/dashboard/superadmin';

  /// Endpoint for sales report (GET /api/reports/sales) - Authenticated
  static String get reportsSales => '$baseUrl/api/reports/sales';

  // ===========================================================================
  // SUBSCRIPTIONS & PAYMENTS ENDPOINTS
  // ===========================================================================

  /// Endpoint for subscription packages (GET /api/subscriptions/packages) - Public
  static String get subscriptionPackages => '$baseUrl/api/subscriptions/packages';

  /// Endpoint for merchant payment info (GET /api/subscriptions/payment-info) - Public
  static String get paymentInfo => '$baseUrl/api/subscriptions/payment-info';

  /// Endpoint for manual payment submission (POST /api/subscriptions/payments/manual) - Shop Admin
  static String get submitManualPayment => '$baseUrl/api/subscriptions/payments/manual';

  /// Endpoint for shop payment history (GET /api/subscriptions/payments/my) - Authenticated
  static String get myPayments => '$baseUrl/api/subscriptions/payments/my';

  /// Endpoint for pending payments list (GET /api/subscriptions/payments/pending) - SuperAdmin Only
  static String get pendingPayments => '$baseUrl/api/subscriptions/payments/pending';

  /// Helper for approving payment (PATCH /api/subscriptions/payments/:id/approve) - SuperAdmin Only
  static String approvePayment(String id) => '$baseUrl/api/subscriptions/payments/$id/approve';

  /// Helper for rejecting payment (PATCH /api/subscriptions/payments/:id/reject) - SuperAdmin Only
  static String rejectPayment(String id) => '$baseUrl/api/subscriptions/payments/$id/reject';

  // ===========================================================================
  // SUPERADMIN SHOP MANAGEMENT ENDPOINTS
  // ===========================================================================

  /// Endpoint for listing all registered shops (GET /api/admin/shops) - SuperAdmin Only
  static String get adminShops => '$baseUrl/api/admin/shops';

  /// Helper for fetching shop profile & managers (GET /api/admin/shops/:id) - SuperAdmin Only
  static String adminShopById(String id) => '$baseUrl/api/admin/shops/$id';
}
