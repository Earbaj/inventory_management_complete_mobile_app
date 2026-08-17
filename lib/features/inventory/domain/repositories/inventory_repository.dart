import '../entities/inventory_item_entity.dart';

abstract class InventoryRepository {
  Future<List<InventoryItemEntity>> getInventoryItems({
    String? searchQuery,
    String? category,
  });

  Future<InventoryItemEntity> addInventoryItem(InventoryItemEntity item);

  Future<InventoryItemEntity> updateInventoryItem(InventoryItemEntity item);

  Future<void> deleteInventoryItem(String itemId);
}
