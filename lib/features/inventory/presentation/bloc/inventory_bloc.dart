import 'dart:async';
import '../../domain/entities/inventory_item_entity.dart';
import '../../domain/usecases/add_inventory_item_usecase.dart';
import '../../domain/usecases/delete_inventory_item_usecase.dart';
import '../../domain/usecases/get_inventory_items_usecase.dart';
import '../../domain/usecases/update_inventory_item_usecase.dart';
import '../view/inventory_screen.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryBloc {
  final GetInventoryItemsUseCase getItemsUseCase;
  final AddInventoryItemUseCase addItemUseCase;
  final UpdateInventoryItemUseCase updateItemUseCase;
  final DeleteInventoryItemUseCase deleteItemUseCase;

  InventoryState _state = const InventoryInitialState();
  final _stateController = StreamController<InventoryState>.broadcast();

  List<InventoryItemEntity> _allItems = [];
  String _currentSearchQuery = '';
  String _currentCategory = 'All';
  InventoryFilter _currentFilter = InventoryFilter.all;

  InventoryState get state => _state;
  Stream<InventoryState> get stream => _stateController.stream;

  InventoryBloc({
    required this.getItemsUseCase,
    required this.addItemUseCase,
    required this.updateItemUseCase,
    required this.deleteItemUseCase,
  });

  void add(InventoryEvent event) {
    _handleEvent(event);
  }

  void _emit(InventoryState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }

  Future<void> _handleEvent(InventoryEvent event) async {
    if (event is FetchInventoryItemsEvent) {
      await _onFetchItems(event);
    } else if (event is AddInventoryItemEvent) {
      await _onAddItem(event);
    } else if (event is UpdateInventoryItemEvent) {
      await _onUpdateItem(event);
    } else if (event is DeleteInventoryItemEvent) {
      await _onDeleteItem(event);
    }
  }

  Future<void> _onFetchItems(FetchInventoryItemsEvent event) async {
    _currentSearchQuery = event.searchQuery ?? _currentSearchQuery;
    _currentCategory = event.category ?? _currentCategory;
    _currentFilter = event.filter;

    if (_allItems.isEmpty) {
      _emit(const InventoryLoadingState());
    }

    try {
      _allItems = await getItemsUseCase(GetInventoryItemsParams(
        searchQuery: null,
        category: null,
      ));

      _emitLoadedState();
    } catch (e) {
      _emit(InventoryErrorState(e.toString()));
    }
  }

  Future<void> _onAddItem(AddInventoryItemEvent event) async {
    try {
      final savedItem = await addItemUseCase(event.item);
      _allItems.insert(0, savedItem);
      _emit(const InventoryOperationSuccessState('Item added successfully!'));
      _emitLoadedState();
    } catch (e) {
      _emit(InventoryErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateItem(UpdateInventoryItemEvent event) async {
    try {
      final updatedItem = await updateItemUseCase(event.item);
      final index = _allItems.indexWhere((item) => item.id == updatedItem.id);
      if (index != -1) {
        _allItems[index] = updatedItem;
      }
      _emit(const InventoryOperationSuccessState('Item updated successfully!'));
      _emitLoadedState();
    } catch (e) {
      _emit(InventoryErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteItem(DeleteInventoryItemEvent event) async {
    try {
      await deleteItemUseCase(event.itemId);
      _allItems.removeWhere((item) => item.id == event.itemId);
      _emit(const InventoryOperationSuccessState('Item deleted successfully!'));
      _emitLoadedState();
    } catch (e) {
      _emit(InventoryErrorState(e.toString()));
    }
  }

  void _emitLoadedState() {
    final categories = ['All', ..._allItems.map((item) => item.category).toSet()];

    final query = _currentSearchQuery.trim().toLowerCase();
    final filtered = _allItems.where((item) {
      final matchesSearch = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.sku.toLowerCase().contains(query);

      final matchesCategory = _currentCategory == 'All' || item.category == _currentCategory;

      final matchesFilter = switch (_currentFilter) {
        InventoryFilter.all => true,
        InventoryFilter.lowStock => item.isLowStock,
        InventoryFilter.outOfStock => item.isOutOfStock,
      };

      return matchesSearch && matchesCategory && matchesFilter;
    }).toList();

    _emit(InventoryLoadedState(
      items: _allItems,
      filteredItems: filtered,
      categories: categories,
      selectedCategory: _currentCategory,
      selectedFilter: _currentFilter,
      searchQuery: _currentSearchQuery,
    ));
  }

  void dispose() {
    _stateController.close();
  }
}
