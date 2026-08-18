import '../entities/inventory_item_entity.dart';
import '../repositories/inventory_repository.dart';

class GetInventoryItemsParams {
  final int page;
  final int limit;
  final String? searchQuery;
  final String? category;

  const GetInventoryItemsParams({
    this.page = 1,
    this.limit = 20,
    this.searchQuery,
    this.category,
  });
}

class GetInventoryItemsUseCase {
  final InventoryRepository repository;

  const GetInventoryItemsUseCase(this.repository);

  Future<List<InventoryItemEntity>> call([GetInventoryItemsParams? params]) {
    return repository.getInventoryItems(
      page: params?.page ?? 1,
      limit: params?.limit ?? 20,
      searchQuery: params?.searchQuery,
      category: params?.category,
    );
  }
}
