import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/get_me_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../network/api_client.dart';

/// Service Locator / Dependency Injection Container
///
/// Instantiates and wires together DataSources, Repositories, UseCases, Network Clients, and BLoC instances.
class InjectionContainer {
  // Core Infrastructure
  static late final ApiClient apiClient;

  // Data Sources
  static late final AuthLocalDataSource authLocalDataSource;
  static late final AuthRemoteDataSource authRemoteDataSource;

  // Repository
  static late final AuthRepository authRepository;

  // UseCases
  static late final LoginUseCase loginUseCase;
  static late final RegisterUseCase registerUseCase;
  static late final ForgotPasswordUseCase forgotPasswordUseCase;
  static late final ResetPasswordUseCase resetPasswordUseCase;
  static late final GetMeUseCase getMeUseCase;
  static late final LogoutUseCase logoutUseCase;

  // BLoC State Management
  static late final AuthBloc authBloc;

  /// Initializes all dependencies at app startup in [main].
  static void init() {
    // 1. Network & Data Sources
    apiClient = ApiClient();
    authLocalDataSource = AuthLocalDataSourceImpl();
    authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient);

    // 2. Repository Contract Implementation
    authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      localDataSource: authLocalDataSource,
      apiClient: apiClient,
    );

    // 3. Domain UseCases
    loginUseCase = LoginUseCase(authRepository);
    registerUseCase = RegisterUseCase(authRepository);
    forgotPasswordUseCase = ForgotPasswordUseCase(authRepository);
    resetPasswordUseCase = ResetPasswordUseCase(authRepository);
    getMeUseCase = GetMeUseCase(authRepository);
    logoutUseCase = LogoutUseCase(authRepository);

    // 4. BLoC State Management Instance
    authBloc = AuthBloc(
      loginUseCase: loginUseCase,
      registerUseCase: registerUseCase,
      forgotPasswordUseCase: forgotPasswordUseCase,
      resetPasswordUseCase: resetPasswordUseCase,
      getMeUseCase: getMeUseCase,
      logoutUseCase: logoutUseCase,
      apiClient: apiClient,
    );
  }
}
