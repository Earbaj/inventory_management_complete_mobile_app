import '../entities/inventory_item_entity.dart';
import '../repositories/inventory_repository.dart';

/// UseCase: Updates an existing inventory item.
class UpdateInventoryItemUseCase {
  final InventoryRepository repository;

  const UpdateInventoryItemUseCase(this.repository);

  Future<InventoryItemEntity> call(InventoryItemEntity item) {
    return repository.updateInventoryItem(item);
  }
}
