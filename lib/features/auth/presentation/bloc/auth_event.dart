/// Base class for all Authentication BLoC events.
abstract class AuthEvent {
  const AuthEvent();
}

/// Event triggered when user submits Login form.
class LoginRequestedEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginRequestedEvent({
    required this.email,
    required this.password,
  });
}

/// Event triggered when a new Shop Owner submits Registration form.
class RegisterRequestedEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String? shopName;
  final String? phone;

  const RegisterRequestedEvent({
    required this.name,
    required this.email,
    required this.password,
    this.shopName,
    this.phone,
  });
}

/// Event triggered to request a 6-digit OTP code for password recovery.
class ForgotPasswordRequestedEvent extends AuthEvent {
  final String email;

  const ForgotPasswordRequestedEvent({
    required this.email,
  });
}

/// Event triggered to reset password using the 6-digit OTP code.
class ResetPasswordRequestedEvent extends AuthEvent {
  final String email;
  final String otpCode;
  final String newPassword;

  const ResetPasswordRequestedEvent({
    required this.email,
    required this.otpCode,
    required this.newPassword,
  });
}

/// Event triggered on app launch to check if user has a valid saved token.
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

/// Event triggered to fetch current user profile from GET /api/auth/me.
class GetMeRequestedEvent extends AuthEvent {
  const GetMeRequestedEvent();
}

/// Event triggered when user clicks Sign Out.
class LogoutRequestedEvent extends AuthEvent {
  const LogoutRequestedEvent();
}

/// Event triggered automatically by ApiClient 401 Interceptor when session expires.
class SessionExpiredEvent extends AuthEvent {
  const SessionExpiredEvent();
}
