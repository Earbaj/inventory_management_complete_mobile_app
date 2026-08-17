import '../repositories/inventory_repository.dart';

/// UseCase: Soft-deletes an inventory item.
class DeleteInventoryItemUseCase {
  final InventoryRepository repository;

  const DeleteInventoryItemUseCase(this.repository);

  Future<void> call(String itemId) {
    return repository.deleteInventoryItem(itemId);
  }
}
