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
    final response = await apiClient.get(
      '${EnvConfig.apiBaseUrl}/api/items',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null && category != 'All') 'category': category,
      },
    );

    final List list = response is List ? response : (response['items'] ?? response['data'] ?? []);
    return list.map((json) => InventoryItemModel.fromJson(json)).toList();
  }

  @override
  Future<InventoryItemModel> addItem(InventoryItemModel item) async {
    final response = await apiClient.post(
      '${EnvConfig.apiBaseUrl}/api/items',
      body: item.toJson(),
    );

    return InventoryItemModel.fromJson(response is Map<String, dynamic> ? response : item.toJson());
  }

  @override
  Future<InventoryItemModel> updateItem(InventoryItemModel item) async {
    final response = await apiClient.post(
      '${EnvConfig.apiBaseUrl}/api/items/${item.id}',
      body: item.toJson(),
    );

    return InventoryItemModel.fromJson(response is Map<String, dynamic> ? response : item.toJson());
  }

  @override
  Future<void> deleteItem(String itemId) async {
    await apiClient.post(
      '${EnvConfig.apiBaseUrl}/api/items/$itemId/delete',
    );
  }
}
