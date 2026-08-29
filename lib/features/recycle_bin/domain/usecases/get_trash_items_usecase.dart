import '../entities/pagination_meta_entity.dart';
import '../repositories/recycle_bin_repository.dart';

/// UseCase: Fetches soft-deleted records from Recycle Bin with pagination.
class GetTrashItemsUseCase {
  final RecycleBinRepository repository;

  const GetTrashItemsUseCase(this.repository);

  Future<PaginatedTrashEntity> call({
    String? entityType,
    String? search,
    int page = 1,
    int limit = 10,
    bool forceRefresh = false,
  }) {
    return repository.getTrashItems(
      entityType: entityType,
      search: search,
      page: page,
      limit: limit,
      forceRefresh: forceRefresh,
    );
  }
}
