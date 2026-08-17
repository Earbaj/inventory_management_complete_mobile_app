import '../config/env_config.dart';

class ApiEndpoints {
  static String get baseUrl => EnvConfig.apiBaseUrl;

  // Auth endpoints
  static String get login => '$baseUrl/api/auth/login';
  static String get register => '$baseUrl/api/auth/register';
  static String get forgotPassword => '$baseUrl/api/auth/forgot-password';
  static String get resetPassword => '$baseUrl/api/auth/reset-password';
  static String get me => '$baseUrl/api/auth/me';
}
