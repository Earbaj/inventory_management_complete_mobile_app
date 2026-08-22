import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../posbilling/domain/entities/sale_entity.dart';
import '../../domain/entities/report_summary_entity.dart';
import '../../domain/usecases/get_invoice_logs_usecase.dart';
import '../../domain/usecases/get_reports_summary_usecase.dart';
import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final GetReportsSummaryUseCase getReportsSummaryUseCase;
  final GetInvoiceLogsUseCase getInvoiceLogsUseCase;

  ReportSummaryEntity? _cachedSummary;
  List<SaleEntity> _allLogs = [];
  String _currentSearchQuery = '';

  ReportsBloc({
    required this.getReportsSummaryUseCase,
    required this.getInvoiceLogsUseCase,
  }) : super(const ReportsInitialState()) {
    // Registering Event Handlers
    on<FetchReportsEvent>(_onFetchReports);
    on<FilterReportsByDateRangeEvent>(_onFilterByDateRange);
  }

  Future<void> _onFetchReports(
      FetchReportsEvent event,
      Emitter<ReportsState> emit,
      ) async {
    _currentSearchQuery = event.searchQuery ?? _currentSearchQuery;

    if (_cachedSummary == null) {
      emit(const ReportsLoadingState());
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

      _emitLoadedState(emit);
    } catch (e) {
      emit(ReportsErrorState(e.toString()));
    }
  }

  Future<void> _onFilterByDateRange(
      FilterReportsByDateRangeEvent event,
      Emitter<ReportsState> emit,
      ) async {
    await _onFetchReports(
      FetchReportsEvent(
        searchQuery: _currentSearchQuery,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
      emit,
    );
  }

  void _emitLoadedState(Emitter<ReportsState> emit) {
    final query = _currentSearchQuery.trim().toLowerCase();
    final filtered = _allLogs.where((sale) {
      final matchesSearch = query.isEmpty ||
          sale.invoiceNo.toLowerCase().contains(query) ||
          (sale.customer?.name.toLowerCase().contains(query) ?? false);

      return matchesSearch;
    }).toList();

    emit(ReportsLoadedState(
      summary: _cachedSummary ??
          const ReportSummaryEntity(
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
}