import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/inventory_remote_data_source.dart';
import '../../domain/entities/inventory_item_entity.dart';
import '../../domain/usecases/add_inventory_item_usecase.dart';
import '../../domain/usecases/delete_inventory_item_usecase.dart';
import '../../domain/usecases/get_inventory_items_usecase.dart';
import '../../domain/usecases/update_inventory_item_usecase.dart';
import '../view/inventory_screen.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final GetInventoryItemsUseCase getItemsUseCase;
  final AddInventoryItemUseCase addItemUseCase;
  final UpdateInventoryItemUseCase updateItemUseCase;
  final DeleteInventoryItemUseCase deleteItemUseCase;
  final InventoryRemoteDataSource remoteDataSource;

  List<InventoryItemEntity> _allItems = [];
  List<String> _fetchedCategories = [];
  String _currentSearchQuery = '';
  String _currentCategory = 'All';
  InventoryFilter _currentFilter = InventoryFilter.all;

  InventoryBloc({
    required this.getItemsUseCase,
    required this.addItemUseCase,
    required this.updateItemUseCase,
    required this.deleteItemUseCase,
    required this.remoteDataSource,
  }) : super(const InventoryInitialState()) {
    // Event Handler Registrations
    on<FetchInventoryItemsEvent>(_onFetchItems);
    on<AddInventoryItemEvent>(_onAddItem);
    on<UpdateInventoryItemEvent>(_onUpdateItem);
    on<DeleteInventoryItemEvent>(_onDeleteItem);
    on<CreateCategoryEvent>(_onCreateCategory);
  }

  Future<void> _onFetchItems(
      FetchInventoryItemsEvent event,
      Emitter<InventoryState> emit,
      ) async {
    _currentSearchQuery = event.searchQuery ?? _currentSearchQuery;
    _currentCategory = event.category ?? _currentCategory;
    _currentFilter = event.filter;

    if (_allItems.isEmpty) {
      emit(const InventoryLoadingState());
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

      _emitLoadedState(emit);
    } catch (e, stackTrace) {
      developer.log('❌ [InventoryBloc] _onFetchItems error: $e', name: 'InventoryBloc', error: e, stackTrace: stackTrace);
      emit(InventoryErrorState(e.toString()));
    }
  }

  Future<void> _onAddItem(
      AddInventoryItemEvent event,
      Emitter<InventoryState> emit,
      ) async {
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
      emit(const InventoryOperationSuccessState('Item added successfully!'));
      _emitLoadedState(emit);
    } catch (e) {
      emit(InventoryErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateItem(
      UpdateInventoryItemEvent event,
      Emitter<InventoryState> emit,
      ) async {
    try {
      final updatedItem = event.item;
      final index = _allItems.indexWhere((item) => item.id == updatedItem.id);
      if (index != -1) {
        _allItems[index] = updatedItem;
      } else {
        _allItems.insert(0, updatedItem);
      }
      emit(const InventoryOperationSuccessState('Item updated successfully!'));
      _emitLoadedState(emit);
    } catch (e) {
      emit(InventoryErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteItem(
      DeleteInventoryItemEvent event,
      Emitter<InventoryState> emit,
      ) async {
    try {
      await deleteItemUseCase(event.itemId);
      _allItems.removeWhere((item) => item.id == event.itemId);
      emit(const InventoryOperationSuccessState('Item deleted successfully!'));
      _emitLoadedState(emit);
    } catch (e) {
      emit(InventoryErrorState(e.toString()));
    }
  }

  Future<void> _onCreateCategory(
      CreateCategoryEvent event,
      Emitter<InventoryState> emit,
      ) async {
    developer.log('🏷️ [InventoryBloc] Creating category "${event.name}" via POST /api/categories...', name: 'InventoryBloc');
    try {
      await remoteDataSource.createCategory(event.name, description: event.description);
      developer.log('✅ [InventoryBloc] Category "${event.name}" created successfully on backend!', name: 'InventoryBloc');

      if (!_fetchedCategories.contains(event.name)) {
        _fetchedCategories.add(event.name);
      }
      emit(InventoryOperationSuccessState('Category "${event.name}" created successfully!'));
      _emitLoadedState(emit);
    } catch (e, stackTrace) {
      developer.log('❌ [InventoryBloc] _onCreateCategory Error: $e', name: 'InventoryBloc', error: e, stackTrace: stackTrace);
      emit(InventoryErrorState('Failed to create category: $e'));
    }
  }

  void _emitLoadedState(Emitter<InventoryState> emit) {
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

    emit(InventoryLoadedState(
      items: _allItems,
      filteredItems: filtered,
      categories: categories,
      selectedCategory: _currentCategory,
      selectedFilter: _currentFilter,
      searchQuery: _currentSearchQuery,
    ));
  }
}