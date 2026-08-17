import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();

  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();

  Future<void> clearAll();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _keyToken = 'auth_jwt_bearer_token';
  static const String _keyUser = 'auth_user_profile';

  final FlutterSecureStorage _secureStorage;

  static String? _inMemoryToken;
  static UserModel? _inMemoryUser;

  AuthLocalDataSourceImpl({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  @override
  Future<void> saveToken(String token) async {
    _inMemoryToken = token;
    try {
      await _secureStorage.write(key: _keyToken, value: token);
    } catch (_) {}
  }

  @override
  Future<String?> getToken() async {
    if (_inMemoryToken != null && _inMemoryToken!.isNotEmpty) {
      return _inMemoryToken;
    }
    try {
      _inMemoryToken = await _secureStorage.read(key: _keyToken);
      return _inMemoryToken;
    } catch (_) {
      return _inMemoryToken;
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    _inMemoryUser = user;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUser, jsonEncode(user.toJson()));
    } catch (_) {}
  }

  @override
  Future<UserModel?> getUser() async {
    if (_inMemoryUser != null) {
      return _inMemoryUser;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJsonStr = prefs.getString(_keyUser);
      if (userJsonStr != null && userJsonStr.isNotEmpty) {
        _inMemoryUser = UserModel.fromJson(jsonDecode(userJsonStr));
        return _inMemoryUser;
      }
    } catch (_) {}
    return _inMemoryUser;
  }

  @override
  Future<void> clearAll() async {
    _inMemoryToken = null;
    _inMemoryUser = null;
    try {
      await _secureStorage.delete(key: _keyToken);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUser);
    } catch (_) {}
  }
}
