import '../entities/inventory_item_entity.dart';
import '../repositories/inventory_repository.dart';

class GetInventoryItemsParams {
  final String? searchQuery;
  final String? category;

  const GetInventoryItemsParams({
    this.searchQuery,
    this.category,
  });
}

/// UseCase: Fetches inventory items list from repository.
class GetInventoryItemsUseCase {
  final InventoryRepository repository;

  const GetInventoryItemsUseCase(this.repository);

  Future<List<InventoryItemEntity>> call([GetInventoryItemsParams? params]) {
    return repository.getInventoryItems(
      searchQuery: params?.searchQuery,
      category: params?.category,
    );
  }
}
