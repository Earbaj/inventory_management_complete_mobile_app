import '../repositories/auth_repository.dart';

class DeleteAccountUseCase {
  final AuthRepository repository;

  const DeleteAccountUseCase(this.repository);

  Future<void> call() {
    return repository.deleteAccount();
  }
}
