import 'dart:async';
import '../../../../core/network/api_client.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/get_me_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final GetMeUseCase getMeUseCase;
  final LogoutUseCase logoutUseCase;
  final ApiClient apiClient;

  AuthState _state = const AuthInitialState();
  final _stateController = StreamController<AuthState>.broadcast();

  AuthState get state => _state;
  Stream<AuthState> get stream => _stateController.stream;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.forgotPasswordUseCase,
    required this.resetPasswordUseCase,
    required this.getMeUseCase,
    required this.logoutUseCase,
    required this.apiClient,
  }) {
    // Setup Global 401 Unauthorized Interceptor Callback (Loop-safe)
    apiClient.onUnauthorized = () {
      add(const SessionExpiredEvent());
    };
  }

  void add(AuthEvent event) {
    _handleEvent(event);
  }

  void _emit(AuthState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }

  Future<void> _handleEvent(AuthEvent event) async {
    if (event is LoginRequestedEvent) {
      await _onLoginRequested(event);
    } else if (event is RegisterRequestedEvent) {
      await _onRegisterRequested(event);
    } else if (event is ForgotPasswordRequestedEvent) {
      await _onForgotPasswordRequested(event);
    } else if (event is ResetPasswordRequestedEvent) {
      await _onResetPasswordRequested(event);
    } else if (event is CheckAuthStatusEvent || event is GetMeRequestedEvent) {
      await _onCheckAuthStatus();
    } else if (event is LogoutRequestedEvent) {
      await _onLogoutRequested();
    } else if (event is SessionExpiredEvent) {
      await _onSessionExpired();
    }
  }

  Future<void> _onLoginRequested(LoginRequestedEvent event) async {
    _emit(const AuthLoadingState());
    try {
      final tokens = await loginUseCase(LoginParams(
        email: event.email,
        password: event.password,
      ));
      final user = await getMeUseCase();
      _emit(AuthenticatedState(user: user, token: tokens.accessToken));
    } catch (e) {
      _emit(AuthFailureState(e.toString()));
    }
  }

  Future<void> _onRegisterRequested(RegisterRequestedEvent event) async {
    _emit(const AuthLoadingState());
    try {
      final tokens = await registerUseCase(RegisterParams(
        name: event.name,
        email: event.email,
        password: event.password,
        shopName: event.shopName,
        phone: event.phone,
      ));
      final user = await getMeUseCase();
      _emit(AuthenticatedState(user: user, token: tokens.accessToken));
    } catch (e) {
      _emit(AuthFailureState(e.toString()));
    }
  }

  Future<void> _onForgotPasswordRequested(ForgotPasswordRequestedEvent event) async {
    _emit(const AuthLoadingState());
    try {
      await forgotPasswordUseCase(event.email);
      _emit(OtpSentSuccessState(
        email: event.email,
        message: '6-digit OTP sent to ${event.email}',
      ));
    } catch (e) {
      _emit(AuthFailureState(e.toString()));
    }
  }

  Future<void> _onResetPasswordRequested(ResetPasswordRequestedEvent event) async {
    _emit(const AuthLoadingState());
    try {
      await resetPasswordUseCase(ResetPasswordParams(
        email: event.email,
        otpCode: event.otpCode,
        newPassword: event.newPassword,
      ));
      _emit(const PasswordResetSuccessState('Password reset successfully! Please log in with your new password.'));
    } catch (e) {
      _emit(AuthFailureState(e.toString()));
    }
  }

  Future<void> _onCheckAuthStatus() async {
    _emit(const AuthLoadingState());
    try {
      final user = await getMeUseCase();
      _emit(AuthenticatedState(user: user));
    } catch (_) {
      _emit(const UnauthenticatedState());
    }
  }

  Future<void> _onLogoutRequested() async {
    _emit(const AuthLoadingState());
    await logoutUseCase();
    _emit(const UnauthenticatedState('Logged out successfully'));
  }

  Future<void> _onSessionExpired() async {
    await logoutUseCase();
    _emit(const UnauthenticatedState('Session expired. Please log in again.'));
  }

  void dispose() {
    _stateController.close();
  }
}
