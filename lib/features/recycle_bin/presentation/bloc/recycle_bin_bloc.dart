import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/recycle_bin_remote_data_source.dart';
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
  final RecycleBinRemoteDataSource remoteDataSource;

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
    required this.remoteDataSource,
  }) : super(const RecycleBinInitialState()) {
    on<FetchTrashItemsEvent>(_onFetchItems);
    on<LoadMoreTrashItemsEvent>(_onLoadMoreItems);
    on<RestoreTrashItemEvent>(_onRestoreItem);
    on<PermanentDeleteTrashItemEvent>(_onPermanentDeleteItem);
    on<EmptyTrashEvent>(_onEmptyTrash);
    on<CleanupAuditLogsEvent>(_onCleanupAuditLogs);
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

    final currentState = state;
    if (_currentPage == 1 && (event.isRefresh || event.forceRefresh)) {
      if (currentState is RecycleBinLoadedState) {
        emit(currentState.copyWith(isListLoading: true));
      } else {
        emit(const RecycleBinLoadingState());
      }
    } else if (_currentPage == 1 && state is! RecycleBinLoadedState) {
      emit(const RecycleBinLoadingState());
    }

    try {
      final paginatedResult = await getTrashItemsUseCase(
        entityType: _activeFilter,
        search: _searchQuery,
        page: _currentPage,
        limit: 10,
        forceRefresh: event.forceRefresh || event.isRefresh,
      );

      _allItems = List.from(paginatedResult.items);
      _meta = paginatedResult.meta;
      _hasReachedMax = !paginatedResult.meta.hasNextPage;

      _emitLoadedState(emit);
    } catch (e) {
      final prev = currentState is RecycleBinLoadedState ? currentState.items : <TrashItemEntity>[];
      emit(RecycleBinErrorState(
        e.toString().replaceAll('Exception: ', '').replaceAll('ServerFailure: ', ''),
        previousItems: prev,
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
    final currentState = state;
    if (currentState is RecycleBinLoadedState) {
      emit(currentState.copyWith(isListLoading: true));
    }
    try {
      await restoreTrashItemUseCase(
        entityType: event.entityType,
        id: event.id,
      );
      _allItems.removeWhere((item) => item.id == event.id);
      _decrementMetaTotal();
      emit(RecycleBinOperationSuccessState('"${event.title}" restored successfully!'));

      final paginatedResult = await getTrashItemsUseCase(
        entityType: _activeFilter,
        search: _searchQuery,
        page: 1,
        limit: 10,
        forceRefresh: true,
      );
      _allItems = List.from(paginatedResult.items);
      _meta = paginatedResult.meta;
      _hasReachedMax = !paginatedResult.meta.hasNextPage;
      _emitLoadedState(emit);
    } catch (e) {
      if (currentState is RecycleBinLoadedState) {
        emit(currentState.copyWith(isListLoading: false));
      }
      emit(RecycleBinErrorState(
        e.toString().replaceAll('Exception: ', '').replaceAll('ServerFailure: ', ''),
      ));
    }
  }

  Future<void> _onPermanentDeleteItem(
    PermanentDeleteTrashItemEvent event,
    Emitter<RecycleBinState> emit,
  ) async {
    final currentState = state;
    if (currentState is RecycleBinLoadedState) {
      emit(currentState.copyWith(isListLoading: true));
    }
    try {
      await permanentDeleteTrashItemUseCase(
        entityType: event.entityType,
        id: event.id,
      );
      _allItems.removeWhere((item) => item.id == event.id);
      _decrementMetaTotal();
      emit(RecycleBinOperationSuccessState('"${event.title}" permanently deleted.'));

      final paginatedResult = await getTrashItemsUseCase(
        entityType: _activeFilter,
        search: _searchQuery,
        page: 1,
        limit: 10,
        forceRefresh: true,
      );
      _allItems = List.from(paginatedResult.items);
      _meta = paginatedResult.meta;
      _hasReachedMax = !paginatedResult.meta.hasNextPage;
      _emitLoadedState(emit);
    } catch (e) {
      if (currentState is RecycleBinLoadedState) {
        emit(currentState.copyWith(isListLoading: false));
      }
      emit(RecycleBinErrorState(
        e.toString().replaceAll('Exception: ', '').replaceAll('ServerFailure: ', ''),
      ));
    }
  }

  Future<void> _onEmptyTrash(
    EmptyTrashEvent event,
    Emitter<RecycleBinState> emit,
  ) async {
    final currentState = state;
    if (currentState is RecycleBinLoadedState) {
      emit(currentState.copyWith(isListLoading: true));
    }
    try {
      await remoteDataSource.emptyTrash();
      _allItems.clear();
      _meta = const PaginationMetaEntity(
        total: 0,
        page: 1,
        limit: 10,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: false,
      );
      emit(const RecycleBinOperationSuccessState('Recycle Bin emptied successfully! 🧹'));
      _emitLoadedState(emit);
    } catch (e) {
      if (currentState is RecycleBinLoadedState) {
        emit(currentState.copyWith(isListLoading: false));
      }
      emit(RecycleBinErrorState('Failed to empty Recycle Bin: ${e.toString()}'));
    }
  }

  Future<void> _onCleanupAuditLogs(
    CleanupAuditLogsEvent event,
    Emitter<RecycleBinState> emit,
  ) async {
    final currentState = state;
    if (currentState is RecycleBinLoadedState) {
      emit(currentState.copyWith(isListLoading: true));
    }
    try {
      await remoteDataSource.cleanupAuditLogs(days: event.days);
      emit(RecycleBinOperationSuccessState('Audit logs older than ${event.days} days cleared. 🧹'));
      _emitLoadedState(emit);
    } catch (e) {
      if (currentState is RecycleBinLoadedState) {
        emit(currentState.copyWith(isListLoading: false));
      }
      emit(RecycleBinErrorState('Failed to clean audit logs: ${e.toString()}'));
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
      isListLoading: false,
    ));
  }
}
