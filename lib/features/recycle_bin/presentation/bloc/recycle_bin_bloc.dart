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

  /**
   * ============================================================================
   * Permanent Delete Trash Item Handler
   * ============================================================================
   *
   * [কী করা হয়েছে]:
   * ১. ইউজকেসের মাধ্যমে ডেটাবেজ/সার্ভার থেকে আইটেমটি স্থায়ীভাবে ডিলিট করা হয়েছে।
   * ২. অপারেশন সফল হলে লোকাল মেমরি (_allItems) থেকে আইটেমটি রিমুভ করে
   *    UI-তে সাকসেস মেসেজ ও আপডেটেড লোডেড স্টেট এমিট করা হয়েছে।
   *
   * [শুধু 'id' না নিয়ে 'entityType' কেন নেওয়া হয়েছে?]:
   * ১. পলিমরফিক রিসাইকেল বিন (Multi-table Database):
   *    অ্যাপে বিভিন্ন ধরনের ডেটা (Note, Folder, Task ইত্যাদি) ভিন্ন ভিন্ন টেবিলে
   *    সংরক্ষিত থাকে। ব্যাকএন্ডকে নির্দিষ্ট টেবিল চেনানোর জন্য এটি প্রয়োজন:
   *    - entityType: "note", id: "123" -> notes টেবিল থেকে ডিলিট
   *    - entityType: "task", id: "123" -> tasks টেবিল থেকে ডিলিট
   *
   * ২. এপিআই রাউটিং (Dynamic Endpoint):
   *    ব্যাকএন্ড যদি ডাইনামিক পাথ ব্যবহার করে, যেমন:
   *    /api/trash/{entityType}/{id}/permanent-delete
   *
   * ৩. আইডি কনফ্লিক্ট প্রতিরোধ (ID Collision):
   *    আলাদা আলাদা টেবিলে একই অটো-ইনক্রিমেন্ট আইডি (যেমন: ID = 5) থাকতে পারে।
   *    'entityType' ছাড়া সঠিক টেবিলের ৫ নম্বর রেকর্ড শনাক্ত করা সম্ভব নয়।
   * ============================================================================
   */
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
