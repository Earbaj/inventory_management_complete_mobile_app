import '../../domain/entities/user_entity.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitialState extends AuthState {
  const AuthInitialState();
}

class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

class AuthenticatedState extends AuthState {
  final UserEntity? user;
  final String? token;

  const AuthenticatedState({
    this.user,
    this.token,
  });
}

class UnauthenticatedState extends AuthState {
  final String? reason;
  const UnauthenticatedState([this.reason]);
}

class OtpSentSuccessState extends AuthState {
  final String email;
  final String message;

  const OtpSentSuccessState({
    required this.email,
    required this.message,
  });
}

class PasswordResetSuccessState extends AuthState {
  final String message;
  const PasswordResetSuccessState([this.message = 'Password reset successfully!']);
}

class AuthFailureState extends AuthState {
  final String message;
  const AuthFailureState(this.message);
}
