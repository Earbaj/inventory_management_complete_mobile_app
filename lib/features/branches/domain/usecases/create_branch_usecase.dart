import '../entities/branch_entity.dart';
import '../repositories/branch_repository.dart';

/// UseCase: Creates a new shop branch.
class CreateBranchUseCase {
  final BranchRepository repository;

  const CreateBranchUseCase(this.repository);

  Future<BranchEntity> call({
    required String name,
    required String address,
    required String phone,
  }) {
    return repository.createBranch(
      name: name,
      address: address,
      phone: phone,
    );
  }
}
