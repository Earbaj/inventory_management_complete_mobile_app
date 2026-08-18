import '../entities/inventory_item_entity.dart';

abstract class InventoryRepository {
  Future<List<InventoryItemEntity>> getInventoryItems({
    int page = 1,
    int limit = 20,
    String? searchQuery,
    String? category,
  });

  Future<InventoryItemEntity> addInventoryItem(InventoryItemEntity item);

  Future<InventoryItemEntity> updateInventoryItem(InventoryItemEntity item);

  Future<void> deleteInventoryItem(String itemId);
}
