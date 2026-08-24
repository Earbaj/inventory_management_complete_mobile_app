import '../entities/report_summary_entity.dart';
import '../repositories/reports_repository.dart';

/// UseCase: Fetches sales summary analytics.
class GetReportsSummaryUseCase {
  final ReportsRepository repository;

  const GetReportsSummaryUseCase(this.repository);

  Future<ReportSummaryEntity> call({DateTime? startDate, DateTime? endDate, String? branchId}) {
    return repository.getReportsSummary(startDate: startDate, endDate: endDate, branchId: branchId);
  }
}
