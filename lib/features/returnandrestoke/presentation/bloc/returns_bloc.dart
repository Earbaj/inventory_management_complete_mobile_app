import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../customers/presentation/bloc/customer_event.dart';
import '../../../inventory/presentation/bloc/inventory_event.dart';
import '../../../reports/presentation/bloc/reports_event.dart';
import '../../domain/entities/return_item_entity.dart';
import '../../domain/usecases/get_return_logs_usecase.dart';
import '../../domain/usecases/process_return_usecase.dart';
import 'returns_event.dart';
import 'returns_state.dart';

class ReturnsBloc extends Bloc<ReturnsEvent, ReturnsState> {
  final ProcessReturnUseCase processReturnUseCase;
  final GetReturnLogsUseCase getReturnLogsUseCase;

  List<ReturnItemEntity> _allReturnLogs = [];
  String _currentSearchQuery = '';

  ReturnsBloc({
    required this.processReturnUseCase,
    required this.getReturnLogsUseCase,
  }) : super(const ReturnsInitialState()) {
    on<FetchReturnLogsEvent>(_onFetchReturnLogs);
    on<ProcessReturnItemEvent>(_onProcessReturn);
  }

  Future<void> _onFetchReturnLogs(
    FetchReturnLogsEvent event,
    Emitter<ReturnsState> emit,
  ) async {
    _currentSearchQuery = event.searchQuery ?? _currentSearchQuery;
    emit(const ReturnsLoadingState());

    try {
      _allReturnLogs = await getReturnLogsUseCase();
    } catch (e) {
      _allReturnLogs = [];
    }
    _emitLoadedState(emit);
  }

  Future<void> _onProcessReturn(
    ProcessReturnItemEvent event,
    Emitter<ReturnsState> emit,
  ) async {
    try {
      final processedItem = await processReturnUseCase(event.returnItem);
      _allReturnLogs.insert(0, processedItem);
      emit(const ReturnsOperationSuccessState('Item return processed & inventory restocked successfully!'));

      try {
        InjectionContainer.inventoryBloc.add(const FetchInventoryItemsEvent());
        InjectionContainer.reportsBloc.add(const FetchReportsEvent());
        InjectionContainer.customerBloc.add(const FetchCustomersEvent());
      } catch (_) {}

      _emitLoadedState(emit);
    } catch (e) {
      emit(ReturnsErrorState(e.toString()));
    }
  }

  void _emitLoadedState(Emitter<ReturnsState> emit) {
    final query = _currentSearchQuery.trim().toLowerCase();
    final filtered = _allReturnLogs.where((item) {
      final matchesSearch = query.isEmpty ||
          item.invoiceNo.toLowerCase().contains(query) ||
          item.itemName.toLowerCase().contains(query) ||
          (item.customerName?.toLowerCase().contains(query) ?? false);

      return matchesSearch;
    }).toList();

    emit(ReturnsLoadedState(
      returnLogs: _allReturnLogs,
      filteredLogs: filtered,
      searchQuery: _currentSearchQuery,
    ));
  }
}
