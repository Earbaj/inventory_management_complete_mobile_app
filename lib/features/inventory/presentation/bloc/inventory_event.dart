import '../../domain/entities/inventory_item_entity.dart';
import '../view/inventory_screen.dart';

abstract class InventoryEvent {
  const InventoryEvent();
}

/// Event: Fetches inventory items with optional search and category filters.
class FetchInventoryItemsEvent extends InventoryEvent {
  final int page;
  final int limit;
  final String? searchQuery;
  final String? category;
  final InventoryFilter filter;

  const FetchInventoryItemsEvent({
    this.page = 1,
    this.limit = 20,
    this.searchQuery,
    this.category,
    this.filter = InventoryFilter.all,
  });
}

/// Event: Adds a new inventory item.
class AddInventoryItemEvent extends InventoryEvent {
  final InventoryItemEntity item;

  const AddInventoryItemEvent(this.item);
}

/// Event: Updates an existing inventory item.
class UpdateInventoryItemEvent extends InventoryEvent {
  final InventoryItemEntity item;

  const UpdateInventoryItemEvent(this.item);
}

/// Event: Deletes an inventory item.
class DeleteInventoryItemEvent extends InventoryEvent {
  final String itemId;

  const DeleteInventoryItemEvent(this.itemId);
}

/// Event: Creates a new product category.
class CreateCategoryEvent extends InventoryEvent {
  final String name;
  final String? description;

  const CreateCategoryEvent({required this.name, this.description});
}

/// Event: Bulk imports products via CSV items list.
class ImportCsvEvent extends InventoryEvent {
  final List<Map<String, dynamic>> items;

  const ImportCsvEvent(this.items);
}

/// Event: Locally adds a newly created category name to the category list without reloading items.
class AddCategoryLocalEvent extends InventoryEvent {
  final String categoryName;

  const AddCategoryLocalEvent(this.categoryName);
}
