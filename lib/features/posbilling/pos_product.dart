import '../inventory/domain/entities/inventory_item_entity.dart';

/// Legacy alias connecting to Clean Architecture [InventoryItemEntity]
typedef PosProduct = InventoryItemEntity;

extension PosProductExt on InventoryItemEntity {
  double get price => retailSellPrice;
  int get stock => stockQuantity;
}