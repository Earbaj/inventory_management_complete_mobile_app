import '../entities/branch_entity.dart';
import '../repositories/branch_repository.dart';

/// UseCase: Fetches all registered branches for current shop.
class GetBranchesUseCase {
  final BranchRepository repository;

  const GetBranchesUseCase(this.repository);

  Future<List<BranchEntity>> call() {
    return repository.getBranches();
  }
}
