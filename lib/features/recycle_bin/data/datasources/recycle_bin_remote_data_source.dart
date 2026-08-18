import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/trash_item_model.dart';

abstract class RecycleBinRemoteDataSource {
  Future<List<TrashItemModel>> getTrashItems({
    String? entityType,
    String? search,
    int page = 1,
    int limit = 20,
  });

  Future<void> restoreItem(String entityType, String id);

  Future<void> permanentDeleteItem(String entityType, String id);
}

class RecycleBinRemoteDataSourceImpl implements RecycleBinRemoteDataSource {
  final ApiClient apiClient;

  RecycleBinRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<TrashItemModel>> getTrashItems({
    String? entityType,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    developer.log(
      '♻️ [RecycleBinRemoteDataSource] getTrashItems() calling GET ${ApiEndpoints.trash} (type: $entityType, search: "$search")...',
      name: 'RecycleBinRemoteDataSource',
    );
    try {
      final response = await apiClient.get(
        ApiEndpoints.trash,
        queryParameters: {
          if (entityType != null && entityType.isNotEmpty && entityType != 'all') 'entityType': entityType,
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
          'page': page,
          'limit': limit,
        },
      );

      final List list = response is List
          ? response
          : (response['data'] ?? response['items'] ?? []);

      developer.log(
        '✅ [RecycleBinRemoteDataSource] getTrashItems() success. Parsed ${list.length} trash items.',
        name: 'RecycleBinRemoteDataSource',
      );
      return list.map((json) => TrashItemModel.fromJson(json)).toList();
    } catch (e) {
      developer.log('⚠️ [RecycleBinRemoteDataSource] getTrashItems() API Error: $e', name: 'RecycleBinRemoteDataSource');
      rethrow;
    }
  }

  @override
  Future<void> restoreItem(String entityType, String id) async {
    developer.log(
      '♻️ [RecycleBinRemoteDataSource] restoreItem() calling POST ${ApiEndpoints.trashRestore(entityType, id)}',
      name: 'RecycleBinRemoteDataSource',
    );
    try {
      await apiClient.post(
        ApiEndpoints.trashRestore(entityType, id),
      );
      developer.log('✅ [RecycleBinRemoteDataSource] restoreItem() success.', name: 'RecycleBinRemoteDataSource');
    } catch (e) {
      developer.log('⚠️ [RecycleBinRemoteDataSource] restoreItem() API Error: $e', name: 'RecycleBinRemoteDataSource');
      rethrow;
    }
  }

  @override
  Future<void> permanentDeleteItem(String entityType, String id) async {
    developer.log(
      '♻️ [RecycleBinRemoteDataSource] permanentDeleteItem() calling DELETE ${ApiEndpoints.trashPermanent(entityType, id)}',
      name: 'RecycleBinRemoteDataSource',
    );
    try {
      await apiClient.delete(
        ApiEndpoints.trashPermanent(entityType, id),
      );
      developer.log('✅ [RecycleBinRemoteDataSource] permanentDeleteItem() success.', name: 'RecycleBinRemoteDataSource');
    } catch (e) {
      developer.log('⚠️ [RecycleBinRemoteDataSource] permanentDeleteItem() API Error: $e', name: 'RecycleBinRemoteDataSource');
      rethrow;
    }
  }
}
