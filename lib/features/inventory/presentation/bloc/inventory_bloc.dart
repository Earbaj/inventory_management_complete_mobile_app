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
    on<ImportCsvEvent>(_onImportCsv);
    on<AddCategoryLocalEvent>(_onAddCategoryLocal);
  }

  Future<void> _onFetchItems(
      FetchInventoryItemsEvent event,
      Emitter<InventoryState> emit,
      ) async {
    _currentSearchQuery = event.searchQuery ?? _currentSearchQuery;
    _currentCategory = event.category ?? _currentCategory;
    _currentFilter = event.filter;

    if (_allItems.isEmpty && _fetchedCategories.isEmpty) {
      emit(const InventoryLoadingState());
    } else {
      _emitLoadedState(emit, isListLoading: true);
    }

    try {
      final apiSearch = _currentSearchQuery.trim().isEmpty ? null : _currentSearchQuery.trim();
      final apiCategory = _currentCategory == 'All' ? null : _currentCategory;

      developer.log('📦 [InventoryBloc] Fetching inventory items from API (search: "$apiSearch", category: "$apiCategory")...', name: 'InventoryBloc');
      _allItems = await getItemsUseCase(GetInventoryItemsParams(
        page: event.page,
        limit: event.limit,
        searchQuery: apiSearch,
        category: apiCategory,
      ));

      _fetchedCategories = await remoteDataSource.getCategories(forceRefresh: true);
      developer.log('✅ [InventoryBloc] Fetched ${_allItems.length} items & ${_fetchedCategories.length} categories from API', name: 'InventoryBloc');

      _emitLoadedState(emit, isListLoading: false);
    } catch (e, stackTrace) {
      developer.log('❌ [InventoryBloc] _onFetchItems error: $e', name: 'InventoryBloc', error: e, stackTrace: stackTrace);
      if (_allItems.isEmpty) {
        emit(InventoryErrorState(e.toString()));
      } else {
        _emitLoadedState(emit, isListLoading: false);
      }
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

      final freshCategories = await remoteDataSource.getCategories(forceRefresh: true);
      if (freshCategories.isNotEmpty) {
        _fetchedCategories = freshCategories;
      }
      if (!_fetchedCategories.contains(event.name)) {
        _fetchedCategories.add(event.name);
      }
      emit(InventoryOperationSuccessState('Category "${event.name}" created successfully!'));
      _emitLoadedState(emit);
    } catch (e, stackTrace) {
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('already exists') || errorMsg.contains('409') || errorMsg.contains('conflict')) {
        developer.log('ℹ️ [InventoryBloc] Category "${event.name}" already exists on server. Refreshing...', name: 'InventoryBloc');
        final freshCategories = await remoteDataSource.getCategories(forceRefresh: true);
        if (freshCategories.isNotEmpty) {
          _fetchedCategories = freshCategories;
        }
        if (!_fetchedCategories.contains(event.name)) {
          _fetchedCategories.add(event.name);
        }
        emit(InventoryOperationSuccessState('Category "${event.name}" is ready!'));
        _emitLoadedState(emit);
      } else {
        developer.log('❌ [InventoryBloc] _onCreateCategory Error: $e', name: 'InventoryBloc', error: e, stackTrace: stackTrace);
        emit(InventoryErrorState('Failed to create category: $e'));
      }
    }
  }

  Future<void> _onImportCsv(
    ImportCsvEvent event,
    Emitter<InventoryState> emit,
  ) async {
    developer.log('📦 [InventoryBloc] Importing ${event.items.length} CSV product items...', name: 'InventoryBloc');
    try {
      await remoteDataSource.importCsv(event.items);
      for (final json in event.items) {
        final entity = InventoryItemEntity(
          id: json['id']?.toString() ?? 'csv_${DateTime.now().millisecondsSinceEpoch}_${json['name']}',
          name: json['name']?.toString() ?? 'Imported Product',
          sku: json['sku']?.toString() ?? json['barcode']?.toString() ?? 'SKU-${DateTime.now().millisecondsSinceEpoch}',
          category: json['category']?.toString() ?? 'General',
          retailSellPrice: (json['price'] ?? json['sellingPrice'] ?? 0.0).toDouble(),
          purchasePrice: (json['costPrice'] ?? 0.0).toDouble(),
          stockQuantity: (json['quantity'] ?? json['stock'] ?? 10) as int,
          lowStockQuantity: (json['minStockThreshold'] ?? 5) as int,
          unit: json['unit']?.toString() ?? 'pcs',
        );
        _allItems.insert(0, entity);
      }
      emit(InventoryOperationSuccessState('${event.items.length} টি প্রোডাক্ট সফলভাবে ইম্পোর্ট করা হয়েছে! 📦'));
      _emitLoadedState(emit);
    } catch (e) {
      emit(InventoryErrorState('CSV ইম্পোর্ট করতে ব্যর্থ: $e'));
    }
  }

  void _onAddCategoryLocal(
    AddCategoryLocalEvent event,
    Emitter<InventoryState> emit,
  ) {
    final name = event.categoryName.trim();
    if (name.isNotEmpty && !_fetchedCategories.contains(name)) {
      _fetchedCategories.add(name);
      developer.log('🏷️ [InventoryBloc] Locally added category "$name" to category list without refetching all items', name: 'InventoryBloc');
    }
    _emitLoadedState(emit, isListLoading: false);
  }

  void _emitLoadedState(Emitter<InventoryState> emit, {bool isListLoading = false}) {
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
      isListLoading: isListLoading,
    ));
  }
}