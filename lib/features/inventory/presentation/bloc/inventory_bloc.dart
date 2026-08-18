import 'dart:async';
import 'dart:developer' as developer;
import '../../data/datasources/inventory_remote_data_source.dart';
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
  final InventoryRemoteDataSource remoteDataSource;

  InventoryState _state = const InventoryInitialState();
  final _stateController = StreamController<InventoryState>.broadcast();

  List<InventoryItemEntity> _allItems = [];
  List<String> _fetchedCategories = [];
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
    required this.remoteDataSource,
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
    } else if (event is CreateCategoryEvent) {
      await _onCreateCategory(event);
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
      developer.log('📦 [InventoryBloc] Fetching inventory items & categories...', name: 'InventoryBloc');
      _allItems = await getItemsUseCase(GetInventoryItemsParams(
        page: event.page,
        limit: event.limit,
        searchQuery: null,
        category: null,
      ));

      _fetchedCategories = await remoteDataSource.getCategories();
      developer.log('✅ [InventoryBloc] Fetched ${_allItems.length} items & ${_fetchedCategories.length} categories from API', name: 'InventoryBloc');

      _emitLoadedState();
    } catch (e, stackTrace) {
      developer.log('❌ [InventoryBloc] _onFetchItems error: $e', name: 'InventoryBloc', error: e, stackTrace: stackTrace);
      _emit(InventoryErrorState(e.toString()));
    }
  }

  Future<void> _onAddItem(AddInventoryItemEvent event) async {
    try {
      final item = event.item;
      final savedItem = item.id.isNotEmpty ? item : await addItemUseCase(item);
      final exists = _allItems.any((element) =>
          (element.id.isNotEmpty && element.id == savedItem.id) ||
          (element.sku.isNotEmpty && element.sku == savedItem.sku));
      if (!exists) {
        _allItems.insert(0, savedItem);
      } else {
        final index = _allItems.indexWhere((element) => element.id == savedItem.id);
        if (index != -1) _allItems[index] = savedItem;
      }
      _emit(const InventoryOperationSuccessState('Item added successfully!'));
      _emitLoadedState();
    } catch (e) {
      _emit(InventoryErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateItem(UpdateInventoryItemEvent event) async {
    try {
      final updatedItem = event.item;
      final index = _allItems.indexWhere((item) => item.id == updatedItem.id);
      if (index != -1) {
        _allItems[index] = updatedItem;
      } else {
        _allItems.insert(0, updatedItem);
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

  Future<void> _onCreateCategory(CreateCategoryEvent event) async {
    developer.log('🏷️ [InventoryBloc] Creating category "${event.name}" via POST /api/categories...', name: 'InventoryBloc');
    try {
      await remoteDataSource.createCategory(event.name, description: event.description);
      developer.log('✅ [InventoryBloc] Category "${event.name}" created successfully on backend!', name: 'InventoryBloc');
      
      if (!_fetchedCategories.contains(event.name)) {
        _fetchedCategories.add(event.name);
      }
      _emit(InventoryOperationSuccessState('Category "${event.name}" created successfully!'));
      _emitLoadedState();
    } catch (e, stackTrace) {
      developer.log('❌ [InventoryBloc] _onCreateCategory Error: $e', name: 'InventoryBloc', error: e, stackTrace: stackTrace);
      _emit(InventoryErrorState('Failed to create category: $e'));
    }
  }

  void _emitLoadedState() {
    final categoriesSet = <String>{
      'All',
      ..._fetchedCategories,
      ..._allItems.map((item) => item.category),
    };
    final categories = categoriesSet.toList();

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
