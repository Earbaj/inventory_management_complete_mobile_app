import '../../../posbilling/domain/entities/sale_entity.dart';
import '../../domain/entities/report_summary_entity.dart';
import '../../reports_models.dart';

abstract class ReportsState {
  const ReportsState();
}

class ReportsInitialState extends ReportsState {
  const ReportsInitialState();
}

class ReportsLoadingState extends ReportsState {
  const ReportsLoadingState();
}

class ReportsLoadedState extends ReportsState {
  final ReportSummaryEntity summary;
  final List<SaleEntity> invoiceLogs;
  final List<SaleEntity> filteredLogs;
  final String searchQuery;
  final bool isListLoading;
  final DateFilterType selectedDateFilter;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? branchId;

  const ReportsLoadedState({
    required this.summary,
    required this.invoiceLogs,
    required this.filteredLogs,
    required this.searchQuery,
    this.isListLoading = false,
    this.selectedDateFilter = DateFilterType.allTime,
    this.startDate,
    this.endDate,
    this.branchId,
  });
}

class ReportsErrorState extends ReportsState {
  final String message;

  const ReportsErrorState(this.message);
}
