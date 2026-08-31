import '../../../posbilling/domain/entities/sale_entity.dart';
import '../entities/report_summary_entity.dart';

/// Abstract Reports Repository Contract
abstract class ReportsRepository {
  /// Fetches overall reports summary metrics (GET /api/reports/summary).
  Future<ReportSummaryEntity> getReportsSummary({DateTime? startDate, DateTime? endDate, String? branchId});

  /// Fetches sales invoice transaction logs (GET /api/sales).
  Future<List<SaleEntity>> getInvoiceLogs({String? invoiceNoQuery, DateTime? startDate, DateTime? endDate, String? branchId});

  /// Deletes a sales invoice record from backend (DELETE /api/sales/:id).
  Future<void> deleteInvoice(String invoiceId);
}
