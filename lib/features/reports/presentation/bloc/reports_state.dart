import '../../../posbilling/domain/entities/sale_entity.dart';
import '../../domain/entities/report_summary_entity.dart';

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

  const ReportsLoadedState({
    required this.summary,
    required this.invoiceLogs,
    required this.filteredLogs,
    required this.searchQuery,
  });
}

class ReportsErrorState extends ReportsState {
  final String message;

  const ReportsErrorState(this.message);
}
