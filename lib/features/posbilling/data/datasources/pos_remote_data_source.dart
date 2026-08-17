import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/config/env_config.dart';
import '../models/sale_model.dart';

abstract class PosRemoteDataSource {
  Future<SaleModel> createSale(SaleModel sale);
  Future<List<SaleModel>> getSalesLogs();
}

class PosRemoteDataSourceImpl implements PosRemoteDataSource {
  final ApiClient apiClient;

  PosRemoteDataSourceImpl(this.apiClient);

  @override
  Future<SaleModel> createSale(SaleModel sale) async {
    developer.log('🛒 [PosRemoteDataSource] createSale() called for invoice: "${sale.invoiceNo}" (Total: ৳${sale.netTotal})', name: 'PosRemoteDataSource');
    try {
      final response = await apiClient.post(
        '${EnvConfig.apiBaseUrl}/api/sales',
        body: sale.toJson(),
      );

      developer.log('✅ [PosRemoteDataSource] createSale() success.', name: 'PosRemoteDataSource');
      return SaleModel.fromJson(response is Map<String, dynamic> ? response : sale.toJson());
    } catch (e, stackTrace) {
      developer.log('❌ [PosRemoteDataSource] createSale() API Error: $e', name: 'PosRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<SaleModel>> getSalesLogs() async {
    developer.log('🛒 [PosRemoteDataSource] getSalesLogs() called...', name: 'PosRemoteDataSource');
    try {
      final response = await apiClient.get(
        '${EnvConfig.apiBaseUrl}/api/sales',
      );

      final List list = response is List ? response : (response['sales'] ?? response['data'] ?? []);
      developer.log('✅ [PosRemoteDataSource] getSalesLogs() success. Parsed ${list.length} sales logs.', name: 'PosRemoteDataSource');
      return list.map((json) => SaleModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      developer.log('❌ [PosRemoteDataSource] getSalesLogs() API Error: $e', name: 'PosRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
