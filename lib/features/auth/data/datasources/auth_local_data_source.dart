abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static String? _cachedToken;

  @override
  Future<void> saveToken(String token) async {
    _cachedToken = token;
  }

  @override
  Future<String?> getToken() async {
    return _cachedToken;
  }

  @override
  Future<void> clearToken() async {
    _cachedToken = null;
  }
}
