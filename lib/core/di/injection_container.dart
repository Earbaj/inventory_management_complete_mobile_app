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

class InjectionContainer {
  static late final ApiClient apiClient;
  static late final AuthLocalDataSource authLocalDataSource;
  static late final AuthRemoteDataSource authRemoteDataSource;
  static late final AuthRepository authRepository;

  static late final LoginUseCase loginUseCase;
  static late final RegisterUseCase registerUseCase;
  static late final ForgotPasswordUseCase forgotPasswordUseCase;
  static late final ResetPasswordUseCase resetPasswordUseCase;
  static late final GetMeUseCase getMeUseCase;
  static late final LogoutUseCase logoutUseCase;

  static late final AuthBloc authBloc;

  static void init() {
    apiClient = ApiClient();
    authLocalDataSource = AuthLocalDataSourceImpl();
    authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient);

    authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      localDataSource: authLocalDataSource,
      apiClient: apiClient,
    );

    loginUseCase = LoginUseCase(authRepository);
    registerUseCase = RegisterUseCase(authRepository);
    forgotPasswordUseCase = ForgotPasswordUseCase(authRepository);
    resetPasswordUseCase = ResetPasswordUseCase(authRepository);
    getMeUseCase = GetMeUseCase(authRepository);
    logoutUseCase = LogoutUseCase(authRepository);

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
