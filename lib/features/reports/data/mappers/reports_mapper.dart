import '../../domain/entities/report_summary_entity.dart';
import '../models/report_summary_model.dart';

/// Translator mapping between Reports DTO Model and Domain Entity.
class ReportsMapper {
  static ReportSummaryEntity modelToEntity(ReportSummaryModel model) {
    return ReportSummaryEntity(
      totalRevenue: model.totalRevenue,
      totalSalesCount: model.totalSalesCount,
      totalDiscount: model.totalDiscount,
      totalDue: model.totalDue,
      cashRevenue: model.cashRevenue,
      digitalRevenue: model.digitalRevenue,
      dueRevenue: model.dueRevenue,
    );
  }

  static ReportSummaryModel entityToModel(ReportSummaryEntity entity) {
    return ReportSummaryModel(
      totalRevenue: entity.totalRevenue,
      totalSalesCount: entity.totalSalesCount,
      totalDiscount: entity.totalDiscount,
      totalDue: entity.totalDue,
      cashRevenue: entity.cashRevenue,
      digitalRevenue: entity.digitalRevenue,
      dueRevenue: entity.dueRevenue,
    );
  }
}
