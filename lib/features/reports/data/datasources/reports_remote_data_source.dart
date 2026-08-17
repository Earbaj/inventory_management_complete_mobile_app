import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/config/env_config.dart';
import '../../../posbilling/data/models/sale_model.dart';
import '../models/report_summary_model.dart';

abstract class ReportsRemoteDataSource {
  Future<ReportSummaryModel> getReportsSummary({DateTime? startDate, DateTime? endDate});
  Future<List<SaleModel>> getInvoiceLogs({String? query, DateTime? startDate, DateTime? endDate});
}

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  final ApiClient apiClient;

  ReportsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ReportSummaryModel> getReportsSummary({DateTime? startDate, DateTime? endDate}) async {
    developer.log('📊 [ReportsRemoteDataSource] getReportsSummary() called (startDate: $startDate, endDate: $endDate)', name: 'ReportsRemoteDataSource');
    try {
      final response = await apiClient.get(
        '${EnvConfig.apiBaseUrl}/api/reports/summary',
        queryParameters: {
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
        },
      );

      developer.log('✅ [ReportsRemoteDataSource] getReportsSummary() success.', name: 'ReportsRemoteDataSource');
      return ReportSummaryModel.fromJson(response is Map<String, dynamic> ? response : {});
    } catch (e, stackTrace) {
      developer.log('⚠️ [ReportsRemoteDataSource] /api/reports/summary failed ($e). Calculating summary metrics locally from sales logs...', name: 'ReportsRemoteDataSource', error: e, stackTrace: stackTrace);

      // Fallback calculation from sales logs if summary endpoint is not present
      final salesLogs = await getInvoiceLogs(startDate: startDate, endDate: endDate);
      final double totalRev = salesLogs.fold(0.0, (sum, s) => sum + s.netTotal);
      final double totalDisc = salesLogs.fold(0.0, (sum, s) => sum + s.discountAmount);
      final double totalD = salesLogs.fold(0.0, (sum, s) => sum + s.dueAmount);
      final double cashRev = salesLogs.where((s) => s.paymentMethod.toLowerCase() == 'cash').fold(0.0, (sum, s) => sum + s.netTotal);
      final double digitalRev = salesLogs.where((s) => s.paymentMethod.toLowerCase() == 'bkash' || s.paymentMethod.toLowerCase() == 'card').fold(0.0, (sum, s) => sum + s.netTotal);
      final double dueRev = salesLogs.where((s) => s.paymentMethod.toLowerCase() == 'due').fold(0.0, (sum, s) => sum + s.netTotal);

      return ReportSummaryModel(
        totalRevenue: totalRev,
        totalSalesCount: salesLogs.length,
        totalDiscount: totalDisc,
        totalDue: totalD,
        cashRevenue: cashRev,
        digitalRevenue: digitalRev,
        dueRevenue: dueRev,
      );
    }
  }

  @override
  Future<List<SaleModel>> getInvoiceLogs({String? query, DateTime? startDate, DateTime? endDate}) async {
    developer.log('📊 [ReportsRemoteDataSource] getInvoiceLogs() called with query: "$query"', name: 'ReportsRemoteDataSource');
    try {
      final response = await apiClient.get(
        '${EnvConfig.apiBaseUrl}/api/sales',
        queryParameters: {
          if (query != null && query.isNotEmpty) 'search': query,
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
        },
      );

      final List list = response is List ? response : (response['sales'] ?? response['data'] ?? []);
      developer.log('✅ [ReportsRemoteDataSource] getInvoiceLogs() success. Parsed ${list.length} invoice logs.', name: 'ReportsRemoteDataSource');
      return list.map((json) => SaleModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      developer.log('❌ [ReportsRemoteDataSource] getInvoiceLogs() API Error: $e', name: 'ReportsRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
