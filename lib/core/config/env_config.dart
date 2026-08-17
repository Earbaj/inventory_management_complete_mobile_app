/// Environment Configuration Helper
///
/// Manages application-wide environment variables such as [apiBaseUrl].
/// Supports loading custom base URLs from `.env` files or fallback defaults.
class EnvConfig {
  static String _baseUrl = 'https://api.example.com';

  /// Returns the current active API base URL.
  static String get apiBaseUrl => _baseUrl;

  /// Initializes the environment configuration with an optional [baseUrl].
  /// Call this method in [main] before running the app.
  static void init({String? baseUrl}) {
    if (baseUrl != null && baseUrl.isNotEmpty) {
      _baseUrl = baseUrl;
    }
  }
}
