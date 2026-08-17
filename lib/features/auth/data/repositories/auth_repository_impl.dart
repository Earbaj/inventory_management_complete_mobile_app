import '../../../../core/network/api_client.dart';
import '../../domain/entities/auth_tokens_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../mappers/auth_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final ApiClient apiClient;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.apiClient,
  });

  @override
  Future<AuthTokensEntity> login({
    required String email,
    required String password,
  }) async {
    final responseModel = await remoteDataSource.login(
      email: email,
      password: password,
    );

    await localDataSource.saveToken(responseModel.accessToken);
    apiClient.setAuthToken(responseModel.accessToken);

    return AuthMapper.tokensModelToEntity(responseModel);
  }

  @override
  Future<AuthTokensEntity> register({
    required String name,
    required String email,
    required String password,
    String? shopName,
    String? phone,
  }) async {
    final responseModel = await remoteDataSource.register(
      name: name,
      email: email,
      password: password,
      shopName: shopName,
      phone: phone,
    );

    await localDataSource.saveToken(responseModel.accessToken);
    apiClient.setAuthToken(responseModel.accessToken);

    return AuthMapper.tokensModelToEntity(responseModel);
  }

  @override
  Future<void> requestForgotPasswordOtp({required String email}) async {
    await remoteDataSource.requestForgotPasswordOtp(email: email);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    await remoteDataSource.resetPassword(
      email: email,
      otpCode: otpCode,
      newPassword: newPassword,
    );
  }

  @override
  Future<UserEntity> getMe() async {
    final token = await localDataSource.getToken();
    if (token != null) {
      apiClient.setAuthToken(token);
    }
    final userModel = await remoteDataSource.getMe();
    await localDataSource.saveUser(userModel);

    return AuthMapper.userModelToEntity(userModel);
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearAll();
    apiClient.clearAuthToken();
  }

  @override
  Future<String?> getSavedToken() {
    return localDataSource.getToken();
  }

  @override
  Future<UserEntity?> getSavedUser() async {
    final userModel = await localDataSource.getUser();
    if (userModel == null) return null;
    return AuthMapper.userModelToEntity(userModel);
  }
}
