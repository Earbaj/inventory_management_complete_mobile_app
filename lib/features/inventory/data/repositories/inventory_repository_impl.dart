import '../../../../core/error/failures.dart';
import '../../domain/entities/inventory_item_entity.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_local_data_source.dart';
import '../datasources/inventory_remote_data_source.dart';
import '../mappers/inventory_mapper.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;
  final InventoryLocalDataSource localDataSource;

  InventoryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<InventoryItemEntity>> getInventoryItems({
    String? searchQuery,
    String? category,
  }) async {
    try {
      final remoteModels = await remoteDataSource.getItems(
        search: searchQuery,
        category: category,
      );
      await localDataSource.cacheItems(remoteModels);
      return remoteModels.map(InventoryMapper.modelToEntity).toList();
    } catch (_) {
      // API hit failed -> Try fallback to local cache
      final cachedModels = await localDataSource.getCachedItems();

      // If cache expired (> 5 mins) or empty -> Throw Failure to show UI Error Widget
      if (cachedModels.isEmpty) {
        throw const ServerFailure('Something went wrong. Could not load data.');
      }

      var filtered = cachedModels;

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        filtered = filtered.where((item) =>
            item.name.toLowerCase().contains(q) ||
            item.sku.toLowerCase().contains(q)).toList();
      }

      if (category != null && category != 'All') {
        filtered = filtered.where((item) => item.category == category).toList();
      }

      return filtered.map(InventoryMapper.modelToEntity).toList();
    }
  }

  @override
  Future<InventoryItemEntity> addInventoryItem(InventoryItemEntity item) async {
    final modelToSave = InventoryMapper.entityToModel(item);
    try {
      final savedModel = await remoteDataSource.addItem(modelToSave);
      final currentCache = await localDataSource.getCachedItems();
      await localDataSource.cacheItems([savedModel, ...currentCache]);
      return InventoryMapper.modelToEntity(savedModel);
    } catch (_) {
      final currentCache = await localDataSource.getCachedItems();
      final updatedList = [modelToSave, ...currentCache];
      await localDataSource.cacheItems(updatedList);
      return item;
    }
  }

  @override
  Future<InventoryItemEntity> updateInventoryItem(InventoryItemEntity item) async {
    final modelToUpdate = InventoryMapper.entityToModel(item);
    try {
      final updatedModel = await remoteDataSource.updateItem(modelToUpdate);
      final currentCache = await localDataSource.getCachedItems();
      final index = currentCache.indexWhere((el) => el.id == item.id);
      if (index != -1) {
        currentCache[index] = updatedModel;
        await localDataSource.cacheItems(currentCache);
      }
      return InventoryMapper.modelToEntity(updatedModel);
    } catch (_) {
      final currentCache = await localDataSource.getCachedItems();
      final index = currentCache.indexWhere((el) => el.id == item.id);
      if (index != -1) {
        currentCache[index] = modelToUpdate;
        await localDataSource.cacheItems(currentCache);
      }
      return item;
    }
  }

  @override
  Future<void> deleteInventoryItem(String itemId) async {
    try {
      await remoteDataSource.deleteItem(itemId);
    } catch (_) {}
    final currentCache = await localDataSource.getCachedItems();
    currentCache.removeWhere((el) => el.id == itemId);
    await localDataSource.cacheItems(currentCache);
  }
}
