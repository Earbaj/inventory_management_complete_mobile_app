import '../../../../core/network/api_client.dart';
import '../../../../core/config/env_config.dart';
import '../models/return_item_model.dart';

abstract class ReturnsRemoteDataSource {
  Future<ReturnItemModel> processReturn(ReturnItemModel returnModel);
  Future<List<ReturnItemModel>> getReturnLogs();
}

class ReturnsRemoteDataSourceImpl implements ReturnsRemoteDataSource {
  final ApiClient apiClient;

  ReturnsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ReturnItemModel> processReturn(ReturnItemModel returnModel) async {
    final response = await apiClient.post(
      '${EnvConfig.apiBaseUrl}/api/returns',
      body: returnModel.toJson(),
    );

    return ReturnItemModel.fromJson(response is Map<String, dynamic> ? response : returnModel.toJson());
  }

  @override
  Future<List<ReturnItemModel>> getReturnLogs() async {
    final response = await apiClient.get(
      '${EnvConfig.apiBaseUrl}/api/returns',
    );

    final List list = response is List ? response : (response['returns'] ?? response['data'] ?? []);
    return list.map((json) => ReturnItemModel.fromJson(json)).toList();
  }
}
