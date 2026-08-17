import '../entities/auth_tokens_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  final String name;
  final String email;
  final String password;
  final String? shopName;
  final String? phone;

  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    this.shopName,
    this.phone,
  });
}

class RegisterUseCase {
  final AuthRepository repository;

  const RegisterUseCase(this.repository);

  Future<AuthTokensEntity> call(RegisterParams params) {
    return repository.register(
      name: params.name,
      email: params.email,
      password: params.password,
      shopName: params.shopName,
      phone: params.phone,
    );
  }
}
