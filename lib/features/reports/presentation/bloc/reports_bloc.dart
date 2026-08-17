import 'dart:async';
import '../../../posbilling/domain/entities/sale_entity.dart';
import '../../domain/entities/report_summary_entity.dart';
import '../../domain/usecases/get_invoice_logs_usecase.dart';
import '../../domain/usecases/get_reports_summary_usecase.dart';
import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc {
  final GetReportsSummaryUseCase getReportsSummaryUseCase;
  final GetInvoiceLogsUseCase getInvoiceLogsUseCase;

  ReportsState _state = const ReportsInitialState();
  final _stateController = StreamController<ReportsState>.broadcast();

  ReportSummaryEntity? _cachedSummary;
  List<SaleEntity> _allLogs = [];
  String _currentSearchQuery = '';

  ReportsState get state => _state;
  Stream<ReportsState> get stream => _stateController.stream;

  ReportsBloc({
    required this.getReportsSummaryUseCase,
    required this.getInvoiceLogsUseCase,
  });

  void add(ReportsEvent event) {
    _handleEvent(event);
  }

  void _emit(ReportsState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }

  Future<void> _handleEvent(ReportsEvent event) async {
    if (event is FetchReportsEvent) {
      await _onFetchReports(event);
    } else if (event is FilterReportsByDateRangeEvent) {
      await _onFilterByDateRange(event);
    }
  }

  Future<void> _onFetchReports(FetchReportsEvent event) async {
    _currentSearchQuery = event.searchQuery ?? _currentSearchQuery;

    if (_cachedSummary == null) {
      _emit(const ReportsLoadingState());
    }

    try {
      final summary = await getReportsSummaryUseCase(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      final logs = await getInvoiceLogsUseCase(
        invoiceNoQuery: null,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      _cachedSummary = summary;
      _allLogs = logs;

      _emitLoadedState();
    } catch (e) {
      _emit(ReportsErrorState(e.toString()));
    }
  }

  Future<void> _onFilterByDateRange(FilterReportsByDateRangeEvent event) async {
    await _onFetchReports(FetchReportsEvent(
      searchQuery: _currentSearchQuery,
      startDate: event.startDate,
      endDate: event.endDate,
    ));
  }

  void _emitLoadedState() {
    final query = _currentSearchQuery.trim().toLowerCase();
    final filtered = _allLogs.where((sale) {
      final matchesSearch = query.isEmpty ||
          sale.invoiceNo.toLowerCase().contains(query) ||
          (sale.customer?.name.toLowerCase().contains(query) ?? false);

      return matchesSearch;
    }).toList();

    _emit(ReportsLoadedState(
      summary: _cachedSummary ?? const ReportSummaryEntity(
        totalRevenue: 0.0,
        totalSalesCount: 0,
        totalDiscount: 0.0,
        totalDue: 0.0,
        cashRevenue: 0.0,
        digitalRevenue: 0.0,
        dueRevenue: 0.0,
      ),
      invoiceLogs: _allLogs,
      filteredLogs: filtered,
      searchQuery: _currentSearchQuery,
    ));
  }

  void dispose() {
    _stateController.close();
  }
}
