import '../entities/return_item_entity.dart';
import '../repositories/returns_repository.dart';

/// UseCase: Processes item return transaction and restocks inventory.
class ProcessReturnUseCase {
  final ReturnsRepository repository;

  const ProcessReturnUseCase(this.repository);

  Future<ReturnItemEntity> call(ReturnItemEntity returnEntity) {
    return repository.processReturn(returnEntity);
  }
}
