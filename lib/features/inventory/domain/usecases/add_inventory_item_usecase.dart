import '../entities/inventory_item_entity.dart';
import '../repositories/inventory_repository.dart';

/// UseCase: Adds a new inventory item.
class AddInventoryItemUseCase {
  final InventoryRepository repository;

  const AddInventoryItemUseCase(this.repository);

  Future<InventoryItemEntity> call(InventoryItemEntity item) {
    return repository.addInventoryItem(item);
  }
}
