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
    final response = await apiClient.post(
      '${EnvConfig.apiBaseUrl}/api/sales',
      body: sale.toJson(),
    );

    return SaleModel.fromJson(response is Map<String, dynamic> ? response : sale.toJson());
  }

  @override
  Future<List<SaleModel>> getSalesLogs() async {
    final response = await apiClient.get(
      '${EnvConfig.apiBaseUrl}/api/sales',
    );

    final List list = response is List ? response : (response['sales'] ?? response['data'] ?? []);
    return list.map((json) => SaleModel.fromJson(json)).toList();
  }
}
