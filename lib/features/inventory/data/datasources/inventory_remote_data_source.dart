import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/config/env_config.dart';
import '../models/inventory_item_model.dart';

abstract class InventoryRemoteDataSource {
  Future<List<InventoryItemModel>> getItems({
    String? search,
    String? category,
  });
  Future<InventoryItemModel> addItem(InventoryItemModel item);
  Future<InventoryItemModel> updateItem(InventoryItemModel item);
  Future<void> deleteItem(String itemId);
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final ApiClient apiClient;

  InventoryRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<InventoryItemModel>> getItems({
    String? search,
    String? category,
  }) async {
    developer.log('📦 [InventoryRemoteDataSource] getItems() called with search: "$search", category: "$category"', name: 'InventoryRemoteDataSource');
    try {
      final response = await apiClient.get(
        '${EnvConfig.apiBaseUrl}/api/items',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (category != null && category != 'All') 'category': category,
        },
      );

      final List list = response is List ? response : (response['items'] ?? response['data'] ?? []);
      developer.log('✅ [InventoryRemoteDataSource] getItems() success. Parsed ${list.length} inventory items.', name: 'InventoryRemoteDataSource');
      return list.map((json) => InventoryItemModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      developer.log('❌ [InventoryRemoteDataSource] getItems() API Error: $e', name: 'InventoryRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<InventoryItemModel> addItem(InventoryItemModel item) async {
    developer.log('📦 [InventoryRemoteDataSource] addItem() called for item: "${item.name}" (SKU: ${item.sku})', name: 'InventoryRemoteDataSource');
    try {
      final response = await apiClient.post(
        '${EnvConfig.apiBaseUrl}/api/items',
        body: item.toJson(),
      );

      developer.log('✅ [InventoryRemoteDataSource] addItem() success.', name: 'InventoryRemoteDataSource');
      return InventoryItemModel.fromJson(response is Map<String, dynamic> ? response : item.toJson());
    } catch (e, stackTrace) {
      developer.log('❌ [InventoryRemoteDataSource] addItem() API Error: $e', name: 'InventoryRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<InventoryItemModel> updateItem(InventoryItemModel item) async {
    developer.log('📦 [InventoryRemoteDataSource] updateItem() called for itemId: "${item.id}" (name: ${item.name})', name: 'InventoryRemoteDataSource');
    try {
      final response = await apiClient.put(
        '${EnvConfig.apiBaseUrl}/api/items/${item.id}',
        body: item.toJson(),
      );

      developer.log('✅ [InventoryRemoteDataSource] updateItem() success.', name: 'InventoryRemoteDataSource');
      return InventoryItemModel.fromJson(response is Map<String, dynamic> ? response : item.toJson());
    } catch (e, stackTrace) {
      developer.log('❌ [InventoryRemoteDataSource] updateItem() API Error: $e', name: 'InventoryRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> deleteItem(String itemId) async {
    developer.log('📦 [InventoryRemoteDataSource] deleteItem() called for itemId: "$itemId"', name: 'InventoryRemoteDataSource');
    try {
      await apiClient.delete(
        '${EnvConfig.apiBaseUrl}/api/items/$itemId',
      );
      developer.log('✅ [InventoryRemoteDataSource] deleteItem() success.', name: 'InventoryRemoteDataSource');
    } catch (e, stackTrace) {
      developer.log('❌ [InventoryRemoteDataSource] deleteItem() API Error: $e', name: 'InventoryRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
