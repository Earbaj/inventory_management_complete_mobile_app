import '../../../../core/error/failures.dart';
import '../../posbilling/data/datasources/pos_local_data_source.dart';
import '../../posbilling/data/mappers/pos_mapper.dart';
import '../../posbilling/domain/entities/sale_entity.dart';
import '../../domain/entities/report_summary_entity.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_local_data_source.dart';
import '../datasources/reports_remote_data_source.dart';
import '../mappers/reports_mapper.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remoteDataSource;
  final ReportsLocalDataSource localDataSource;
  final PosLocalDataSource posLocalDataSource;

  ReportsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.posLocalDataSource,
  });

  @override
  Future<ReportSummaryEntity> getReportsSummary({DateTime? startDate, DateTime? endDate}) async {
    try {
      final remoteModel = await remoteDataSource.getReportsSummary(startDate: startDate, endDate: endDate);
      await localDataSource.cacheSummary(remoteModel);
      return ReportsMapper.modelToEntity(remoteModel);
    } catch (_) {
      final cachedSummary = await localDataSource.getCachedSummary();
      if (cachedSummary == null) {
        throw const ServerFailure('Something went wrong. Could not load reports summary.');
      }
      return ReportsMapper.modelToEntity(cachedSummary);
    }
  }

  @override
  Future<List<SaleEntity>> getInvoiceLogs({String? invoiceNoQuery, DateTime? startDate, DateTime? endDate}) async {
    try {
      final remoteModels = await remoteDataSource.getInvoiceLogs(query: invoiceNoQuery, startDate: startDate, endDate: endDate);
      await posLocalDataSource.cacheSales(remoteModels);
      return remoteModels.map(PosMapper.saleModelToEntity).toList();
    } catch (_) {
      final cachedModels = await posLocalDataSource.getCachedSales();
      if (cachedModels.isEmpty) {
        throw const ServerFailure('Something went wrong. Could not load invoice logs.');
      }

      var filtered = cachedModels;
      if (invoiceNoQuery != null && invoiceNoQuery.trim().isNotEmpty) {
        final q = invoiceNoQuery.trim().toLowerCase();
        filtered = filtered.where((s) => s.invoiceNo.toLowerCase().contains(q) || (s.customer?.name.toLowerCase().contains(q) ?? false)).toList();
      }

      return filtered.map(PosMapper.saleModelToEntity).toList();
    }
  }
}
