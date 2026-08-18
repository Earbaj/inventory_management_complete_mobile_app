import 'dart:async';

import '../../domain/entities/trash_item_entity.dart';
import '../../domain/usecases/get_trash_items_usecase.dart';
import '../../domain/usecases/permanent_delete_trash_item_usecase.dart';
import '../../domain/usecases/restore_trash_item_usecase.dart';
import 'recycle_bin_event.dart';
import 'recycle_bin_state.dart';

class RecycleBinBloc {
  final GetTrashItemsUseCase getTrashItemsUseCase;
  final RestoreTrashItemUseCase restoreTrashItemUseCase;
  final PermanentDeleteTrashItemUseCase permanentDeleteTrashItemUseCase;

  RecycleBinState _state = const RecycleBinInitialState();
  final _stateController = StreamController<RecycleBinState>.broadcast();

  RecycleBinState get state => _state;
  Stream<RecycleBinState> get stream => _stateController.stream;

  List<TrashItemEntity> _allItems = [];
  String _activeFilter = 'all';
  String _searchQuery = '';

  RecycleBinBloc({
    required this.getTrashItemsUseCase,
    required this.restoreTrashItemUseCase,
    required this.permanentDeleteTrashItemUseCase,
  });

  void add(RecycleBinEvent event) {
    _handleEvent(event);
  }

  Future<void> _handleEvent(RecycleBinEvent event) async {
    if (event is FetchTrashItemsEvent) {
      await _onFetchItems(event);
    } else if (event is RestoreTrashItemEvent) {
      await _onRestoreItem(event);
    } else if (event is PermanentDeleteTrashItemEvent) {
      await _onPermanentDeleteItem(event);
    }
  }

  Future<void> _onFetchItems(FetchTrashItemsEvent event) async {
    if (event.entityType != null) {
      _activeFilter = event.entityType!;
    }
    if (event.search != null) {
      _searchQuery = event.search!;
    }

    _emit(const RecycleBinLoadingState());
    try {
      _allItems = await getTrashItemsUseCase(
        entityType: _activeFilter,
        search: _searchQuery,
      );
      _emitLoadedState();
    } catch (e) {
      _emit(RecycleBinErrorState(e.toString().replaceAll('Exception: ', '').replaceAll('ServerFailure: ', '')));
    }
  }

  Future<void> _onRestoreItem(RestoreTrashItemEvent event) async {
    try {
      await restoreTrashItemUseCase(
        entityType: event.entityType,
        id: event.id,
      );
      _allItems.removeWhere((item) => item.id == event.id);
      _emit(RecycleBinOperationSuccessState('"${event.title}" restored successfully!'));
      _emitLoadedState();
    } catch (e) {
      _emit(RecycleBinErrorState(e.toString().replaceAll('Exception: ', '').replaceAll('ServerFailure: ', '')));
    }
  }

  Future<void> _onPermanentDeleteItem(PermanentDeleteTrashItemEvent event) async {
    try {
      await permanentDeleteTrashItemUseCase(
        entityType: event.entityType,
        id: event.id,
      );
      _allItems.removeWhere((item) => item.id == event.id);
      _emit(RecycleBinOperationSuccessState('"${event.title}" permanently deleted from database.'));
      _emitLoadedState();
    } catch (e) {
      _emit(RecycleBinErrorState(e.toString().replaceAll('Exception: ', '').replaceAll('ServerFailure: ', '')));
    }
  }

  void _emitLoadedState() {
    _emit(RecycleBinLoadedState(
      items: List.from(_allItems),
      activeFilter: _activeFilter,
      searchQuery: _searchQuery,
    ));
  }

  void _emit(RecycleBinState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  void dispose() {
    _stateController.close();
  }
}
