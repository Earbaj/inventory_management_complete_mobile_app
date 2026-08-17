import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository repository;

  const ForgotPasswordUseCase(this.repository);

  Future<void> call(String email) {
    return repository.requestForgotPasswordOtp(email: email);
  }
}
