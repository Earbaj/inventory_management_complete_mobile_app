import 'dart:async';
import '../../domain/entities/return_item_entity.dart';
import '../../domain/usecases/get_return_logs_usecase.dart';
import '../../domain/usecases/process_return_usecase.dart';
import 'returns_event.dart';
import 'returns_state.dart';

class ReturnsBloc {
  final ProcessReturnUseCase processReturnUseCase;
  final GetReturnLogsUseCase getReturnLogsUseCase;

  ReturnsState _state = const ReturnsInitialState();
  final _stateController = StreamController<ReturnsState>.broadcast();

  List<ReturnItemEntity> _allReturnLogs = [];
  String _currentSearchQuery = '';

  ReturnsState get state => _state;
  Stream<ReturnsState> get stream => _stateController.stream;

  ReturnsBloc({
    required this.processReturnUseCase,
    required this.getReturnLogsUseCase,
  });

  void add(ReturnsEvent event) {
    _handleEvent(event);
  }

  void _emit(ReturnsState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }

  Future<void> _handleEvent(ReturnsEvent event) async {
    if (event is FetchReturnLogsEvent) {
      await _onFetchReturnLogs(event);
    } else if (event is ProcessReturnItemEvent) {
      await _onProcessReturn(event);
    }
  }

  Future<void> _onFetchReturnLogs(FetchReturnLogsEvent event) async {
    _currentSearchQuery = event.searchQuery ?? _currentSearchQuery;

    if (_allReturnLogs.isEmpty) {
      _emit(const ReturnsLoadingState());
    }

    try {
      _allReturnLogs = await getReturnLogsUseCase();
      _emitLoadedState();
    } catch (e) {
      _emit(ReturnsErrorState(e.toString()));
    }
  }

  Future<void> _onProcessReturn(ProcessReturnItemEvent event) async {
    try {
      final processedItem = await processReturnUseCase(event.returnItem);
      _allReturnLogs.insert(0, processedItem);
      _emit(const ReturnsOperationSuccessState('Item return processed & inventory restocked successfully!'));
      _emitLoadedState();
    } catch (e) {
      _emit(ReturnsErrorState(e.toString()));
    }
  }

  void _emitLoadedState() {
    final query = _currentSearchQuery.trim().toLowerCase();
    final filtered = _allReturnLogs.where((item) {
      final matchesSearch = query.isEmpty ||
          item.invoiceNo.toLowerCase().contains(query) ||
          item.itemName.toLowerCase().contains(query) ||
          (item.customerName?.toLowerCase().contains(query) ?? false);

      return matchesSearch;
    }).toList();

    _emit(ReturnsLoadedState(
      returnLogs: _allReturnLogs,
      filteredLogs: filtered,
      searchQuery: _currentSearchQuery,
    ));
  }

  void dispose() {
    _stateController.close();
  }
}
