import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

/// Abstract Remote Data Source Contract for Auth API Communications
abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<AuthResponseModel> register({
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

  Future<UserModel> getMe();

  Future<void> deleteAccount();
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
    developer.log('🔐 [AuthRemoteDataSource] Calling login for email: $email', name: 'AuthRemoteDataSource');
    try {
      final responseJson = await apiClient.post(
        ApiEndpoints.login,
        body: {
          'email': email,
          'password': password,
        },
        isPublic: true,
      );

      developer.log('✅ [AuthRemoteDataSource] Login successful. Parsing AuthResponseModel...', name: 'AuthRemoteDataSource');
      return AuthResponseModel.fromJson(responseJson);
    } catch (e, stackTrace) {
      developer.log('❌ [AuthRemoteDataSource] Login API Error: $e', name: 'AuthRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    String? shopName,
    String? phone,
  }) async {
    developer.log('🔐 [AuthRemoteDataSource] Calling register for name: $name, email: $email', name: 'AuthRemoteDataSource');
    try {
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

      developer.log('✅ [AuthRemoteDataSource] Register successful. Parsing AuthResponseModel...', name: 'AuthRemoteDataSource');
      return AuthResponseModel.fromJson(responseJson);
    } catch (e, stackTrace) {
      developer.log('❌ [AuthRemoteDataSource] Register API Error: $e', name: 'AuthRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> requestForgotPasswordOtp({
    required String email,
  }) async {
    developer.log('🔐 [AuthRemoteDataSource] Calling requestForgotPasswordOtp for email: $email', name: 'AuthRemoteDataSource');
    try {
      await apiClient.post(
        ApiEndpoints.forgotPassword,
        body: {
          'email': email,
        },
        isPublic: true,
      );
      developer.log('✅ [AuthRemoteDataSource] Forgot password OTP request successful.', name: 'AuthRemoteDataSource');
    } catch (e, stackTrace) {
      developer.log('❌ [AuthRemoteDataSource] Forgot Password OTP Error: $e', name: 'AuthRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    developer.log('🔐 [AuthRemoteDataSource] Calling resetPassword for email: $email', name: 'AuthRemoteDataSource');
    try {
      await apiClient.post(
        ApiEndpoints.resetPassword,
        body: {
          'email': email,
          'otpCode': otpCode,
          'newPassword': newPassword,
        },
        isPublic: true,
      );
      developer.log('✅ [AuthRemoteDataSource] Reset password successful.', name: 'AuthRemoteDataSource');
    } catch (e, stackTrace) {
      developer.log('❌ [AuthRemoteDataSource] Reset Password Error: $e', name: 'AuthRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<UserModel> getMe() async {
    developer.log('🔐 [AuthRemoteDataSource] Calling getMe()...', name: 'AuthRemoteDataSource');
    try {
      final responseJson = await apiClient.get(
        ApiEndpoints.me,
        isPublic: false,
      );

      final userData = responseJson is Map && responseJson.containsKey('user')
          ? responseJson['user']
          : responseJson;

      developer.log('✅ [AuthRemoteDataSource] getMe() successful. Parsing UserModel...', name: 'AuthRemoteDataSource');
      return UserModel.fromJson(userData);
    } catch (e, stackTrace) {
      developer.log('❌ [AuthRemoteDataSource] getMe() API Error: $e', name: 'AuthRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount() async {
    developer.log('🔐 [AuthRemoteDataSource] Calling DELETE ${ApiEndpoints.deleteAccount}...', name: 'AuthRemoteDataSource');
    try {
      await apiClient.delete(ApiEndpoints.deleteAccount);
      developer.log('✅ [AuthRemoteDataSource] deleteAccount() successful.', name: 'AuthRemoteDataSource');
    } catch (e, stackTrace) {
      developer.log('⚠️ [AuthRemoteDataSource] deleteAccount() API Error: $e', name: 'AuthRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
