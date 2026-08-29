import 'dart:developer' as developer;
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/config/env_config.dart';
import '../models/inventory_item_model.dart';

abstract class InventoryRemoteDataSource {
  Future<List<InventoryItemModel>> getItems({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
  });
  Future<InventoryItemModel> addItem(InventoryItemModel item);
  Future<InventoryItemModel> updateItem(InventoryItemModel item);
  Future<void> deleteItem(String itemId);
  Future<List<String>> getCategories({bool forceRefresh = false});
  Future<void> createCategory(String name, {String? description});
  Future<void> importCsv(List<Map<String, dynamic>> items);
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final ApiClient apiClient;

  InventoryRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<InventoryItemModel>> getItems({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
  }) async {
    final safeLimit = limit.clamp(1, 100);
    developer.log('📦 [InventoryRemoteDataSource] getItems() page: $page, limit: $safeLimit (requested: $limit), search: "$search", category: "$category"', name: 'InventoryRemoteDataSource');
    try {
      final response = await apiClient.get(
        '${EnvConfig.apiBaseUrl}/api/items',
        queryParameters: {
          'page': page,
          'limit': safeLimit,
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
    } catch (e) {
      developer.log('⚠️ [InventoryRemoteDataSource] addItem() API Error: $e', name: 'InventoryRemoteDataSource');
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

  @override
  Future<List<String>> getCategories({bool forceRefresh = false}) async {
    developer.log('📦 [InventoryRemoteDataSource] getCategories() calling GET ${ApiEndpoints.categories} (forceRefresh: $forceRefresh)', name: 'InventoryRemoteDataSource');
    try {
      final response = await apiClient.get(
        ApiEndpoints.categories,
        cache: !forceRefresh,
        cachePolicy: forceRefresh ? CachePolicy.refresh : null,
        maxStale: const Duration(minutes: 30),
      );

      final List list = response is List
          ? response
          : (response is Map
              ? (response['categories'] is List
                  ? response['categories']
                  : (response['data'] is List
                      ? response['data']
                      : (response['data'] is Map && response['data']['categories'] is List
                          ? response['data']['categories']
                          : [])))
              : []);

      final categories = <String>[];
      for (final c in list) {
        if (c is Map) {
          final name = c['name'] ?? c['category'] ?? c['title'] ?? c['label'];
          if (name != null && name.toString().trim().isNotEmpty) {
            categories.add(name.toString().trim());
          }
        } else if (c != null && c.toString().trim().isNotEmpty) {
          categories.add(c.toString().trim());
        }
      }

      developer.log('✅ [InventoryRemoteDataSource] getCategories() parsed ${categories.length} categories: $categories', name: 'InventoryRemoteDataSource');
      return categories;
    } catch (e, stackTrace) {
      developer.log('⚠️ [InventoryRemoteDataSource] getCategories() error: $e', name: 'InventoryRemoteDataSource', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<void> createCategory(String name, {String? description}) async {
    developer.log('📦 [InventoryRemoteDataSource] createCategory() calling POST ${ApiEndpoints.categories} with name: "$name"', name: 'InventoryRemoteDataSource');
    try {
      final response = await apiClient.post(
        ApiEndpoints.categories,
        body: {
          'name': name,
          if (description != null && description.isNotEmpty) 'description': description,
        },
      );
      await apiClient.clearCache();
      developer.log('✅ [InventoryRemoteDataSource] createCategory() success: $response', name: 'InventoryRemoteDataSource');
    } catch (e, stackTrace) {
      developer.log('❌ [InventoryRemoteDataSource] createCategory() API Error: $e', name: 'InventoryRemoteDataSource', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> importCsv(List<Map<String, dynamic>> items) async {
    developer.log('📦 [InventoryRemoteDataSource] Calling POST ${ApiEndpoints.importCsv} with ${items.length} items...', name: 'InventoryRemoteDataSource');
    try {
      await apiClient.post(
        ApiEndpoints.importCsv,
        body: {'items': items},
      );
      developer.log('✅ [InventoryRemoteDataSource] importCsv success.', name: 'InventoryRemoteDataSource');
    } catch (e, stackTrace) {
      developer.log('⚠️ [InventoryRemoteDataSource] importCsv API call error: $e', name: 'InventoryRemoteDataSource', error: e, stackTrace: stackTrace);
    }
  }
}
