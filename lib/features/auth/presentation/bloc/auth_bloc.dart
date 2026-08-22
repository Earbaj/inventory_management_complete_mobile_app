import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/get_me_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication Business Logic Component (BLoC)
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final GetMeUseCase getMeUseCase;
  final LogoutUseCase logoutUseCase;
  final ApiClient apiClient;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.forgotPasswordUseCase,
    required this.resetPasswordUseCase,
    required this.getMeUseCase,
    required this.logoutUseCase,
    required this.apiClient,
  }) : super(const AuthInitialState()) {
    // Event Handler Registration (Bloc v8.0+)
    on<LoginRequestedEvent>(_onLoginRequested);
    on<RegisterRequestedEvent>(_onRegisterRequested);
    on<ForgotPasswordRequestedEvent>(_onForgotPasswordRequested);
    on<ResetPasswordRequestedEvent>(_onResetPasswordRequested);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<GetMeRequestedEvent>(_onGetMeRequested);
    on<LogoutRequestedEvent>(_onLogoutRequested);
    on<SessionExpiredEvent>(_onSessionExpired);

    // Setup Global 401 Unauthorized Interceptor Callback
    apiClient.onUnauthorized = () {
      add(const SessionExpiredEvent());
    };
  }

  /// Handles Login process.
  Future<void> _onLoginRequested(
      LoginRequestedEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoadingState());
    try {
      final tokens = await loginUseCase(LoginParams(
        email: event.email,
        password: event.password,
      ));
      final user = await getMeUseCase();
      emit(AuthenticatedState(user: user, token: tokens.accessToken));
    } catch (e) {
      emit(AuthFailureState(e.toString()));
    }
  }

  /// Handles Shop Owner Registration process.
  Future<void> _onRegisterRequested(
      RegisterRequestedEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoadingState());
    try {
      final tokens = await registerUseCase(RegisterParams(
        name: event.name,
        email: event.email,
        password: event.password,
        shopName: event.shopName,
        phone: event.phone,
      ));
      final user = await getMeUseCase();
      emit(AuthenticatedState(user: user, token: tokens.accessToken));
    } catch (e) {
      emit(AuthFailureState(e.toString()));
    }
  }

  /// Handles 6-digit OTP request for forgot password.
  Future<void> _onForgotPasswordRequested(
      ForgotPasswordRequestedEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoadingState());
    try {
      await forgotPasswordUseCase(event.email);
      emit(OtpSentSuccessState(
        email: event.email,
        message: '6-digit OTP code sent to ${event.email}',
      ));
    } catch (e) {
      emit(AuthFailureState(e.toString()));
    }
  }

  /// Handles resetting password using OTP code.
  Future<void> _onResetPasswordRequested(
      ResetPasswordRequestedEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoadingState());
    try {
      await resetPasswordUseCase(ResetPasswordParams(
        email: event.email,
        otpCode: event.otpCode,
        newPassword: event.newPassword,
      ));
      emit(const PasswordResetSuccessState('Password reset successfully! Please log in with your new password.'));
    } catch (e) {
      emit(AuthFailureState(e.toString()));
    }
  }

  /// Verifies active token and fetches user profile.
  Future<void> _onCheckAuthStatus(
      CheckAuthStatusEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoadingState());
    try {
      final user = await getMeUseCase();
      emit(AuthenticatedState(user: user));
    } catch (_) {
      emit(const UnauthenticatedState());
    }
  }

  /// Handles GetMe event (reuses same logic as check status).
  Future<void> _onGetMeRequested(
      GetMeRequestedEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoadingState());
    try {
      final user = await getMeUseCase();
      emit(AuthenticatedState(user: user));
    } catch (_) {
      emit(const UnauthenticatedState());
    }
  }

  /// User initiated Sign Out.
  Future<void> _onLogoutRequested(
      LogoutRequestedEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoadingState());
    await logoutUseCase();
    emit(const UnauthenticatedState('Logged out successfully'));
  }

  /// Triggered automatically by ApiClient 401 Interceptor.
  Future<void> _onSessionExpired(
      SessionExpiredEvent event,
      Emitter<AuthState> emit,
      ) async {
    await logoutUseCase();
    emit(const UnauthenticatedState('Session expired. Please log in again.'));
  }
}