class EnvConfig {
  static String _baseUrl = 'https://api.example.com';

  static String get apiBaseUrl => _baseUrl;

  /// Loads environment configuration from .env style key-value mapping or default fallback.
  static void init({String? baseUrl}) {
    if (baseUrl != null && baseUrl.isNotEmpty) {
      _baseUrl = baseUrl;
    }
  }
}
