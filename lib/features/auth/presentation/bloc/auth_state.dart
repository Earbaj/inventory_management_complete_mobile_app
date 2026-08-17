import '../../domain/entities/user_entity.dart';

/// Base class for all Authentication BLoC States.
abstract class AuthState {
  const AuthState();
}

/// Initial uninitialized state.
class AuthInitialState extends AuthState {
  const AuthInitialState();
}

/// State emitted while an asynchronous authentication API call is in progress.
class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

/// State emitted when the user is successfully authenticated.
/// Holds the active [user] domain entity profile and Bearer [token].
class AuthenticatedState extends AuthState {
  final UserEntity? user;
  final String? token;

  const AuthenticatedState({
    this.user,
    this.token,
  });
}

/// State emitted when the user is unauthenticated or logged out.
class UnauthenticatedState extends AuthState {
  final String? reason;
  const UnauthenticatedState([this.reason]);
}

/// State emitted when 6-digit OTP code has been successfully requested.
class OtpSentSuccessState extends AuthState {
  final String email;
  final String message;

  const OtpSentSuccessState({
    required this.email,
    required this.message,
  });
}

/// State emitted when password has been successfully reset using OTP code.
class PasswordResetSuccessState extends AuthState {
  final String message;
  const PasswordResetSuccessState([this.message = 'Password reset successfully!']);
}

/// State emitted when an authentication API call fails.
class AuthFailureState extends AuthState {
  final String message;
  const AuthFailureState(this.message);
}
