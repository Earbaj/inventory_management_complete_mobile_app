import '../entities/inventory_item_entity.dart';

/// Abstract Inventory Repository Contract
///
/// Defines business operations for fetching, adding, updating, and soft-deleting inventory items.
abstract class InventoryRepository {
  /// Fetches list of inventory items with optional search query and category filter.
  Future<List<InventoryItemEntity>> getInventoryItems({
    String? searchQuery,
    String? category,
  });

  /// Adds a new inventory item.
  Future<InventoryItemEntity> addInventoryItem(InventoryItemEntity item);

  /// Updates an existing inventory item.
  Future<InventoryItemEntity> updateInventoryItem(InventoryItemEntity item);

  /// Soft-deletes an inventory item.
  Future<void> deleteInventoryItem(String itemId);
}
