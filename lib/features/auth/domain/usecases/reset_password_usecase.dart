import '../repositories/auth_repository.dart';

class ResetPasswordParams {
  final String email;
  final String otpCode;
  final String newPassword;

  const ResetPasswordParams({
    required this.email,
    required this.otpCode,
    required this.newPassword,
  });
}

class ResetPasswordUseCase {
  final AuthRepository repository;

  const ResetPasswordUseCase(this.repository);

  Future<void> call(ResetPasswordParams params) {
    return repository.resetPassword(
      email: params.email,
      otpCode: params.otpCode,
      newPassword: params.newPassword,
    );
  }
}
