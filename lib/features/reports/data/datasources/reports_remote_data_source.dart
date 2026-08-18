import 'dart:developer' as developer;
import '../../../../core/config/env_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../posbilling/data/models/sale_model.dart';
import '../models/report_summary_model.dart';

abstract class ReportsRemoteDataSource {
  Future<ReportSummaryModel> getReportsSummary({DateTime? startDate, DateTime? endDate});
  Future<List<SaleModel>> getInvoiceLogs({int page = 1, int limit = 20, String? query, DateTime? startDate, DateTime? endDate});
}

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  final ApiClient apiClient;

  ReportsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ReportSummaryModel> getReportsSummary({DateTime? startDate, DateTime? endDate}) async {
    developer.log('📊 [ReportsRemoteDataSource] getReportsSummary() called (startDate: $startDate, endDate: $endDate)', name: 'ReportsRemoteDataSource');
    try {
      final response = await apiClient.get(
        ApiEndpoints.reportsSales,
        queryParameters: {
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
        },
      );

      developer.log('✅ [ReportsRemoteDataSource] getReportsSummary() success from ${ApiEndpoints.reportsSales}.', name: 'ReportsRemoteDataSource');
      return ReportSummaryModel.fromJson(response is Map<String, dynamic> ? response : {});
    } catch (e) {
      developer.log('⚠️ [ReportsRemoteDataSource] /api/reports/sales failed ($e). Attempting /api/dashboard/stats...', name: 'ReportsRemoteDataSource');
      try {
        final response = await apiClient.get(ApiEndpoints.dashboardStats);
        developer.log('✅ [ReportsRemoteDataSource] getReportsSummary() success from ${ApiEndpoints.dashboardStats}.', name: 'ReportsRemoteDataSource');
        return ReportSummaryModel.fromJson(response is Map<String, dynamic> ? response : {});
      } catch (e2, stackTrace) {
        developer.log('⚠️ [ReportsRemoteDataSource] Backend summary endpoints failed. Calculating summary metrics locally from sales logs...', name: 'ReportsRemoteDataSource', error: e2, stackTrace: stackTrace);

        // Fallback calculation from sales logs if endpoints fail
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
  }

  @override
  Future<List<SaleModel>> getInvoiceLogs({
    int page = 1,
    int limit = 20,
    String? query,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    developer.log('📊 [ReportsRemoteDataSource] getInvoiceLogs() page: $page, limit: $limit, query: "$query"', name: 'ReportsRemoteDataSource');
    try {
      final response = await apiClient.get(
        '${EnvConfig.apiBaseUrl}/api/sales',
        queryParameters: {
          'page': page,
          'limit': limit,
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
