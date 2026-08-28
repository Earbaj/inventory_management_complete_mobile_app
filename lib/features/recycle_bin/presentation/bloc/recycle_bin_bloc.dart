import 'package:flutter_bloc/flutter_bloc.dart';

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
  String _activeFilter = 'all';
  String _searchQuery = '';

  RecycleBinBloc({
    required this.getTrashItemsUseCase,
    required this.restoreTrashItemUseCase,
    required this.permanentDeleteTrashItemUseCase,
  }) : super(const RecycleBinInitialState()) {
    on<FetchTrashItemsEvent>(_onFetchItems);
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

    emit(const RecycleBinLoadingState());
    try {
      _allItems = await getTrashItemsUseCase(
        entityType: _activeFilter,
        search: _searchQuery,
      );
      _emitLoadedState(emit);
    } catch (e) {
      emit(RecycleBinErrorState(
        e.toString().replaceAll('Exception: ', '').replaceAll('ServerFailure: ', ''),
      ));
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
      emit(RecycleBinOperationSuccessState('"${event.title}" permanently deleted from database.'));
      _emitLoadedState(emit);
    } catch (e) {
      emit(RecycleBinErrorState(
        e.toString().replaceAll('Exception: ', '').replaceAll('ServerFailure: ', ''),
      ));
    }
  }

  void _emitLoadedState(Emitter<RecycleBinState> emit) {
    emit(RecycleBinLoadedState(
      items: List.from(_allItems),
      activeFilter: _activeFilter,
      searchQuery: _searchQuery,
    ));
  }
}
