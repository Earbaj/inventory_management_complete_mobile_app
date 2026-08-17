import '../../domain/entities/inventory_item_entity.dart';
import '../models/inventory_item_model.dart';

/// Translator mapping between [InventoryItemModel] DTO and [InventoryItemEntity].
class InventoryMapper {
  static InventoryItemEntity modelToEntity(InventoryItemModel model) {
    return InventoryItemEntity(
      id: model.id,
      name: model.name,
      sku: model.sku,
      category: model.category,
      unit: model.unit,
      stockQuantity: model.stockQuantity,
      lowStockQuantity: model.lowStockQuantity,
      retailSellPrice: model.retailSellPrice,
      purchasePrice: model.purchasePrice,
      createdAt: model.createdAt != null ? DateTime.tryParse(model.createdAt!) : null,
      updatedAt: model.updatedAt != null ? DateTime.tryParse(model.updatedAt!) : null,
    );
  }

  static InventoryItemModel entityToModel(InventoryItemEntity entity) {
    return InventoryItemModel(
      id: entity.id,
      name: entity.name,
      sku: entity.sku,
      category: entity.category,
      unit: entity.unit,
      stockQuantity: entity.stockQuantity,
      lowStockQuantity: entity.lowStockQuantity,
      retailSellPrice: entity.retailSellPrice,
      purchasePrice: entity.purchasePrice,
      createdAt: entity.createdAt?.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
    );
  }
}
