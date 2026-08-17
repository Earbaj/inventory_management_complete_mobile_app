import 'dart:developer' as developer;
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
    developer.log('🔄 [ReturnsRemoteDataSource] processReturn() called for invoice: "${returnModel.invoiceNo}", item: "${returnModel.itemName}"', name: 'ReturnsRemoteDataSource');
    try {
      final response = await apiClient.post(
        '${EnvConfig.apiBaseUrl}/api/returns',
        body: returnModel.toJson(),
      );

      developer.log('✅ [ReturnsRemoteDataSource] processReturn() success.', name: 'ReturnsRemoteDataSource');
      return ReturnItemModel.fromJson(response is Map<String, dynamic> ? response : returnModel.toJson());
    } catch (e, stackTrace) {
      developer.log('❌ [ReturnsRemoteDataSource] processReturn() API Error: $e', name: 'ReturnsRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<ReturnItemModel>> getReturnLogs() async {
    developer.log('🔄 [ReturnsRemoteDataSource] getReturnLogs() called...', name: 'ReturnsRemoteDataSource');
    try {
      final response = await apiClient.get(
        '${EnvConfig.apiBaseUrl}/api/returns',
      );

      final List list = response is List ? response : (response['returns'] ?? response['data'] ?? []);
      developer.log('✅ [ReturnsRemoteDataSource] getReturnLogs() success. Parsed ${list.length} return logs.', name: 'ReturnsRemoteDataSource');
      return list.map((json) => ReturnItemModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      developer.log('❌ [ReturnsRemoteDataSource] getReturnLogs() API Error: $e', name: 'ReturnsRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
