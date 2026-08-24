import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/pagination_meta_entity.dart';
import '../../domain/entities/trash_item_entity.dart';
import '../../domain/usecases/get_trash_items_usecase.dart';
import '../../domain/usecases/permanent_delete_trash_item_usecase.dart';
import '../../domain/usecases/restore_trash_item_usecase.dart';
import 'recycle_bin_event.dart';
import 'recycle_bin_state.dart';

class RecycleBinBloc extends Bloc<RecycleBinEvent, RecycleBinState> {
  final GetTrashItemsUseCase getTrashItemsUseCase;
  final RestoreTrashItemUseCase restoreTrashItemUseCase;
  final PermanentDeleteTrashItemUseCase permanentDeleteTrashItemUseCase;

  List<TrashItemEntity> _allItems = [];
  PaginationMetaEntity _meta = PaginationMetaEntity.empty();
  String _activeFilter = 'all';
  String _searchQuery = '';
  int _currentPage = 1;
  bool _isFetchingMore = false;
  bool _hasReachedMax = false;

  RecycleBinBloc({
    required this.getTrashItemsUseCase,
    required this.restoreTrashItemUseCase,
    required this.permanentDeleteTrashItemUseCase,
  }) : super(const RecycleBinInitialState()) {
    on<FetchTrashItemsEvent>(_onFetchItems);
    on<LoadMoreTrashItemsEvent>(_onLoadMoreItems);
    on<RestoreTrashItemEvent>(_onRestoreItem);
    on<PermanentDeleteTrashItemEvent>(_onPermanentDeleteItem);
  }

  Future<void> _onFetchItems(
    FetchTrashItemsEvent event,
    Emitter<RecycleBinState> emit,
  ) async {
    if (event.entityType != null) {
      _activeFilter = event.entityType!;
    }
    if (event.search != null) {
      _searchQuery = event.search!;
    }

    _currentPage = event.page;
    _hasReachedMax = false;

    if (_currentPage == 1 && !event.isRefresh) {
      emit(const RecycleBinLoadingState());
    }

    try {
      final paginatedResult = await getTrashItemsUseCase(
        entityType: _activeFilter,
        search: _searchQuery,
        page: _currentPage,
        limit: 10,
      );

      _allItems = List.from(paginatedResult.items);
      _meta = paginatedResult.meta;
      _hasReachedMax = !paginatedResult.meta.hasNextPage;

      _emitLoadedState(emit);
    } catch (e) {
      emit(RecycleBinErrorState(
        e.toString().replaceAll('Exception: ', '').replaceAll('ServerFailure: ', ''),
      ));
    }
  }

  Future<void> _onLoadMoreItems(
    LoadMoreTrashItemsEvent event,
    Emitter<RecycleBinState> emit,
  ) async {
    if (_isFetchingMore || _hasReachedMax) return;
    if (state is! RecycleBinLoadedState) return;

    _isFetchingMore = true;
    final currentState = state as RecycleBinLoadedState;
    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = _currentPage + 1;

    try {
      final paginatedResult = await getTrashItemsUseCase(
        entityType: _activeFilter,
        search: _searchQuery,
        page: nextPage,
        limit: 10,
      );

      _currentPage = nextPage;
      _allItems.addAll(paginatedResult.items);
      _meta = paginatedResult.meta;
      _hasReachedMax = !paginatedResult.meta.hasNextPage;
      _isFetchingMore = false;

      _emitLoadedState(emit);
    } catch (e) {
      _isFetchingMore = false;
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onRestoreItem(
    RestoreTrashItemEvent event,
    Emitter<RecycleBinState> emit,
  ) async {
    try {
      await restoreTrashItemUseCase(
        entityType: event.entityType,
        id: event.id,
      );
      _allItems.removeWhere((item) => item.id == event.id);
      _decrementMetaTotal();
      emit(RecycleBinOperationSuccessState('"${event.title}" restored successfully!'));
      _emitLoadedState(emit);
    } catch (e) {
      emit(RecycleBinErrorState(
        e.toString().replaceAll('Exception: ', '').replaceAll('ServerFailure: ', ''),
      ));
    }
  }

  Future<void> _onPermanentDeleteItem(
    PermanentDeleteTrashItemEvent event,
    Emitter<RecycleBinState> emit,
  ) async {
    try {
      await permanentDeleteTrashItemUseCase(
        entityType: event.entityType,
        id: event.id,
      );
      _allItems.removeWhere((item) => item.id == event.id);
      _decrementMetaTotal();
      emit(RecycleBinOperationSuccessState('"${event.title}" permanently deleted from database.'));
      _emitLoadedState(emit);
    } catch (e) {
      emit(RecycleBinErrorState(
        e.toString().replaceAll('Exception: ', '').replaceAll('ServerFailure: ', ''),
      ));
    }
  }

  void _decrementMetaTotal() {
    final newTotal = (_meta.total - 1) < 0 ? 0 : _meta.total - 1;
    _meta = PaginationMetaEntity(
      total: newTotal,
      page: _meta.page,
      limit: _meta.limit,
      totalPages: _meta.totalPages,
      hasNextPage: _meta.hasNextPage,
      hasPrevPage: _meta.hasPrevPage,
    );
  }

  void _emitLoadedState(Emitter<RecycleBinState> emit) {
    emit(RecycleBinLoadedState(
      items: List.from(_allItems),
      meta: _meta,
      activeFilter: _activeFilter,
      searchQuery: _searchQuery,
      isLoadingMore: false,
      hasReachedMax: _hasReachedMax,
    ));
  }
}
