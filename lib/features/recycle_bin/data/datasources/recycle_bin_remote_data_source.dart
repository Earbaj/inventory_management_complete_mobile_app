import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/pagination_meta_model.dart';
import '../models/trash_item_model.dart';

abstract class RecycleBinRemoteDataSource {
  Future<PaginatedTrashModel> getTrashItems({
    String? entityType,
    String? search,
    int page = 1,
    int limit = 10,
  });

  Future<void> restoreItem(String entityType, String id);

  Future<void> permanentDeleteItem(String entityType, String id);
}

class RecycleBinRemoteDataSourceImpl implements RecycleBinRemoteDataSource {
  final ApiClient apiClient;

  RecycleBinRemoteDataSourceImpl(this.apiClient);

  @override
  Future<PaginatedTrashModel> getTrashItems({
    String? entityType,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    developer.log(
      '♻️ [RecycleBinRemoteDataSource] getTrashItems() calling GET ${ApiEndpoints.trash} (type: $entityType, search: "$search", page: $page, limit: $limit)...',
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

      final paginatedResult = PaginatedTrashModel.fromJson(response);

      developer.log(
        '✅ [RecycleBinRemoteDataSource] getTrashItems() success. Parsed ${paginatedResult.items.length} trash items (page ${paginatedResult.meta.page}/${paginatedResult.meta.totalPages}, total: ${paginatedResult.meta.total}).',
        name: 'RecycleBinRemoteDataSource',
      );
      return paginatedResult;
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
