import '../../domain/entities/inventory_item_entity.dart';
import '../view/inventory_screen.dart';

abstract class InventoryState {
  const InventoryState();
}

class InventoryInitialState extends InventoryState {
  const InventoryInitialState();
}

class InventoryLoadingState extends InventoryState {
  const InventoryLoadingState();
}

class InventoryLoadedState extends InventoryState {
  final List<InventoryItemEntity> items;
  final List<InventoryItemEntity> filteredItems;
  final List<String> categories;
  final String selectedCategory;
  final InventoryFilter selectedFilter;
  final String searchQuery;

  const InventoryLoadedState({
    required this.items,
    required this.filteredItems,
    required this.categories,
    required this.selectedCategory,
    required this.selectedFilter,
    required this.searchQuery,
  });

  int get lowStockCount => items.where((item) => item.isLowStock).length;
  int get outOfStockCount => items.where((item) => item.isOutOfStock).length;
}

class InventoryOperationSuccessState extends InventoryState {
  final String message;
  const InventoryOperationSuccessState(this.message);
}

class InventoryErrorState extends InventoryState {
  final String message;
  const InventoryErrorState(this.message);
}
