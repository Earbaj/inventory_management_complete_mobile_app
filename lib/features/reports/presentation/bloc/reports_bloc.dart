import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../posbilling/domain/entities/sale_entity.dart';
import '../../../../core/di/injection_container.dart';
import '../../../recycle_bin/presentation/bloc/recycle_bin_event.dart';
import '../../domain/entities/report_summary_entity.dart';
import '../../domain/usecases/delete_invoice_usecase.dart';
import '../../domain/usecases/get_invoice_logs_usecase.dart';
import '../../domain/usecases/get_reports_summary_usecase.dart';
import '../../reports_models.dart';
import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final GetReportsSummaryUseCase getReportsSummaryUseCase;
  final GetInvoiceLogsUseCase getInvoiceLogsUseCase;
  final DeleteInvoiceUseCase deleteInvoiceUseCase;

  ReportSummaryEntity? _cachedSummary;
  List<SaleEntity> _allLogs = [];
  String _currentSearchQuery = '';
  DateTime? _currentStartDate;
  DateTime? _currentEndDate;
  String? _currentBranchId;
  DateFilterType _currentDateFilter = DateFilterType.allTime;

  ReportsBloc({
    required this.getReportsSummaryUseCase,
    required this.getInvoiceLogsUseCase,
    required this.deleteInvoiceUseCase,
  }) : super(const ReportsInitialState()) {
    on<FetchReportsEvent>(_onFetchReports);
    on<FilterReportsByDateRangeEvent>(_onFilterByDateRange);
    on<SearchReportsEvent>(_onSearchReports);
    on<DeleteInvoiceEvent>(_onDeleteInvoice);
  }

  Future<void> _onFetchReports(
      FetchReportsEvent event,
      Emitter<ReportsState> emit,
      ) async {
    _currentSearchQuery = event.searchQuery ?? _currentSearchQuery;
    if (event.startDate != null || event.dateFilterType != null) {
      _currentStartDate = event.startDate;
      _currentEndDate = event.endDate;
    }
    if (event.branchId != null) {
      _currentBranchId = event.branchId;
    }
    if (event.dateFilterType != null) {
      _currentDateFilter = event.dateFilterType!;
    }

    if (_cachedSummary == null || event.forceRefresh) {
      if (state is ReportsLoadedState) {
        _emitLoadedState(emit, isListLoading: true);
      } else {
        emit(const ReportsLoadingState());
      }
    }

    try {
      final summary = await getReportsSummaryUseCase(
        startDate: _currentStartDate,
        endDate: _currentEndDate,
        branchId: _currentBranchId,
      );
      final logs = await getInvoiceLogsUseCase(
        invoiceNoQuery: null,
        startDate: _currentStartDate,
        endDate: _currentEndDate,
        branchId: _currentBranchId,
      );

      _cachedSummary = summary;
      _allLogs = logs;

      _emitLoadedState(emit, isListLoading: false);
    } catch (e) {
      emit(ReportsErrorState(e.toString()));
    }
  }

  Future<void> _onFilterByDateRange(
      FilterReportsByDateRangeEvent event,
      Emitter<ReportsState> emit,
      ) async {
    _currentStartDate = event.startDate;
    _currentEndDate = event.endDate;
    _currentDateFilter = event.dateFilterType;
    if (event.branchId != null) {
      _currentBranchId = event.branchId;
    }

    if (state is ReportsLoadedState) {
      _emitLoadedState(emit, isListLoading: true);
    } else {
      emit(const ReportsLoadingState());
    }

    try {
      final summary = await getReportsSummaryUseCase(
        startDate: _currentStartDate,
        endDate: _currentEndDate,
        branchId: _currentBranchId,
      );
      final logs = await getInvoiceLogsUseCase(
        invoiceNoQuery: null,
        startDate: _currentStartDate,
        endDate: _currentEndDate,
        branchId: _currentBranchId,
      );

      _cachedSummary = summary;
      _allLogs = logs;

      _emitLoadedState(emit, isListLoading: false);
    } catch (e) {
      emit(ReportsErrorState(e.toString()));
    }
  }

  Future<void> _onSearchReports(
      SearchReportsEvent event,
      Emitter<ReportsState> emit,
      ) async {
    _currentSearchQuery = event.query;
    final query = event.query.trim().toLowerCase();

    // 1. Instant local search on existing 100 items
    final localMatches = _allLogs.where((sale) {
      final matchesInvoice = sale.invoiceNo.toLowerCase().contains(query);
      final matchesCustomer = sale.customer?.name.toLowerCase().contains(query) ?? false;
      final matchesPhone = sale.customer?.phone.toLowerCase().contains(query) ?? false;
      return matchesInvoice || matchesCustomer || matchesPhone;
    }).toList();

    // If query is empty or local matches found, emit instantly (0ms delay, no API call)
    if (query.isEmpty || localMatches.isNotEmpty) {
      _emitLoadedState(emit, overrideFilteredLogs: localMatches);
      return;
    }

    // 2. If 0 local matches and query is at least 2 chars, fetch from backend API
    if (query.length >= 2) {
      _emitLoadedState(emit, isListLoading: true, overrideFilteredLogs: []);
      try {
        final serverLogs = await getInvoiceLogsUseCase(
          invoiceNoQuery: query,
          startDate: _currentStartDate,
          endDate: _currentEndDate,
          branchId: _currentBranchId,
        );
        _emitLoadedState(emit, isListLoading: false, overrideFilteredLogs: serverLogs);
      } catch (e) {
        _emitLoadedState(emit, isListLoading: false, overrideFilteredLogs: []);
      }
    } else {
      _emitLoadedState(emit, overrideFilteredLogs: []);
    }
  }

  Future<void> _onDeleteInvoice(
      DeleteInvoiceEvent event,
      Emitter<ReportsState> emit,
      ) async {
    final targetIndex = _allLogs.indexWhere((s) => s.id == event.invoiceId);
    SaleEntity? removedSale;
    if (targetIndex != -1) {
      removedSale = _allLogs[targetIndex];
      _allLogs.removeAt(targetIndex);
    }

    _emitLoadedState(emit, isListLoading: true);

    try {
      await deleteInvoiceUseCase(event.invoiceId);

      // Re-fetch reports summary & logs to guarantee 100% accuracy with backend
      final summary = await getReportsSummaryUseCase(
        startDate: _currentStartDate,
        endDate: _currentEndDate,
        branchId: _currentBranchId,
      );
      final logs = await getInvoiceLogsUseCase(
        invoiceNoQuery: null,
        startDate: _currentStartDate,
        endDate: _currentEndDate,
        branchId: _currentBranchId,
      );

      _cachedSummary = summary;
      _allLogs = logs;
      _emitLoadedState(emit, isListLoading: false);

      // Sync recycle bin bloc so deleted sale appears in trash
      try {
        InjectionContainer.recycleBinBloc.add(const FetchTrashItemsEvent());
      } catch (_) {}
    } catch (e) {
      if (removedSale != null && targetIndex != -1) {
        _allLogs.insert(targetIndex, removedSale);
      }
      _emitLoadedState(emit, isListLoading: false);
      emit(ReportsErrorState('Failed to delete invoice: ${e.toString()}'));
    }
  }

  void _emitLoadedState(
      Emitter<ReportsState> emit, {
        bool isListLoading = false,
        List<SaleEntity>? overrideFilteredLogs,
      }) {
    final query = _currentSearchQuery.trim().toLowerCase();
    List<SaleEntity> filtered;

    if (overrideFilteredLogs != null) {
      filtered = overrideFilteredLogs;
    } else if (query.isEmpty) {
      filtered = List.from(_allLogs);
    } else {
      filtered = _allLogs.where((sale) {
        final matchesInvoice = sale.invoiceNo.toLowerCase().contains(query);
        final matchesCustomer = sale.customer?.name.toLowerCase().contains(query) ?? false;
        final matchesPhone = sale.customer?.phone.toLowerCase().contains(query) ?? false;
        return matchesInvoice || matchesCustomer || matchesPhone;
      }).toList();
    }

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
      isListLoading: isListLoading,
      selectedDateFilter: _currentDateFilter,
      startDate: _currentStartDate,
      endDate: _currentEndDate,
      branchId: _currentBranchId,
    ));
  }
}