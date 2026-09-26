import 'package:inventory_management_complete/core/error/exceptions.dart';

import '../entities/inventory_item_entity.dart';
import '../repositories/inventory_repository.dart';

/// UseCase: Adds a new inventory item.
class AddInventoryItemUseCase {
  final InventoryRepository repository;

  const AddInventoryItemUseCase(this.repository);

  Future<InventoryItemEntity> call(InventoryItemEntity item) {
    // if(item.purchasePrice < 0 || item.retailSellPrice < 0){
    //   throw ValidationException('Price cannot be negative');
    // }
    return repository.addInventoryItem(item);
  }
}
