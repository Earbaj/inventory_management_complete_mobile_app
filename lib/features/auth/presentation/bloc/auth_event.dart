abstract class AuthEvent {
  const AuthEvent();
}

class LoginRequestedEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginRequestedEvent({
    required this.email,
    required this.password,
  });
}

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

class ForgotPasswordRequestedEvent extends AuthEvent {
  final String email;

  const ForgotPasswordRequestedEvent({
    required this.email,
  });
}

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

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class GetMeRequestedEvent extends AuthEvent {
  const GetMeRequestedEvent();
}

class LogoutRequestedEvent extends AuthEvent {
  const LogoutRequestedEvent();
}

class SessionExpiredEvent extends AuthEvent {
  const SessionExpiredEvent();
}
