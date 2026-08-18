import '../repositories/recycle_bin_repository.dart';

/// UseCase: Restores a soft-deleted record back to active database list.
class RestoreTrashItemUseCase {
  final RecycleBinRepository repository;

  const RestoreTrashItemUseCase(this.repository);

  Future<void> call({
    required String entityType,
    required String id,
  }) {
    return repository.restoreItem(
      entityType: entityType,
      id: id,
    );
  }
}
