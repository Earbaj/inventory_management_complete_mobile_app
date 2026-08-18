import '../entities/trash_item_entity.dart';
import '../repositories/recycle_bin_repository.dart';

/// UseCase: Fetches soft-deleted records from Recycle Bin.
class GetTrashItemsUseCase {
  final RecycleBinRepository repository;

  const GetTrashItemsUseCase(this.repository);

  Future<List<TrashItemEntity>> call({
    String? entityType,
    String? search,
    int page = 1,
    int limit = 20,
  }) {
    return repository.getTrashItems(
      entityType: entityType,
      search: search,
      page: page,
      limit: limit,
    );
  }
}
