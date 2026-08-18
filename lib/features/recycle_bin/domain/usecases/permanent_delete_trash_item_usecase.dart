import '../repositories/recycle_bin_repository.dart';

/// UseCase: Permanently hard-deletes a soft-deleted record from MongoDB storage.
class PermanentDeleteTrashItemUseCase {
  final RecycleBinRepository repository;

  const PermanentDeleteTrashItemUseCase(this.repository);

  Future<void> call({
    required String entityType,
    required String id,
  }) {
    return repository.permanentDeleteItem(
      entityType: entityType,
      id: id,
    );
  }
}
