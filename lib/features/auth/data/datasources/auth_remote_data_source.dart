import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

/// Abstract Remote Data Source Contract for Auth API Communications
abstract class AuthRemoteDataSource {
  /// Calls POST /api/auth/login
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  /// Calls POST /api/auth/register
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    String? shopName,
    String? phone,
  });

  /// Calls POST /api/auth/forgot-password
  Future<void> requestForgotPasswordOtp({
    required String email,
  });

  /// Calls POST /api/auth/reset-password
  Future<void> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  });

  /// Calls GET /api/auth/me
  Future<UserModel> getMe();
}

/// Remote Data Source Implementation using [ApiClient]
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final responseJson = await apiClient.post(
      ApiEndpoints.login,
      body: {
        'email': email,
        'password': password,
      },
      isPublic: true,
    );

    return AuthResponseModel.fromJson(responseJson);
  }

  @override
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    String? shopName,
    String? phone,
  }) async {
    final responseJson = await apiClient.post(
      ApiEndpoints.register,
      body: {
        'name': name,
        'email': email,
        'password': password,
        if (shopName != null) 'shopName': shopName,
        if (phone != null) 'phone': phone,
      },
      isPublic: true,
    );

    return AuthResponseModel.fromJson(responseJson);
  }

  @override
  Future<void> requestForgotPasswordOtp({
    required String email,
  }) async {
    await apiClient.post(
      ApiEndpoints.forgotPassword,
      body: {
        'email': email,
      },
      isPublic: true,
    );
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    await apiClient.post(
      ApiEndpoints.resetPassword,
      body: {
        'email': email,
        'otpCode': otpCode,
        'newPassword': newPassword,
      },
      isPublic: true,
    );
  }

  @override
  Future<UserModel> getMe() async {
    final responseJson = await apiClient.get(
      ApiEndpoints.me,
      isPublic: false,
    );

    final userData = responseJson is Map && responseJson.containsKey('user')
        ? responseJson['user']
        : responseJson;

    return UserModel.fromJson(userData);
  }
}
