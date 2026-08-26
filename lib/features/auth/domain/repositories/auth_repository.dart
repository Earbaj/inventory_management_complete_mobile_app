import '../entities/auth_tokens_entity.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<AuthTokensEntity> login({
    required String email,
    required String password,
  });

  Future<AuthTokensEntity> register({
    required String name,
    required String email,
    required String password,
    String? shopName,
    String? phone,
  });

  Future<void> requestForgotPasswordOtp({
    required String email,
  });

  Future<void> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  });

  Future<UserEntity> getMe();

  Future<void> logout();

  Future<String?> getSavedToken();

  Future<UserEntity?> getSavedUser();

  Future<void> deleteAccount();
}
